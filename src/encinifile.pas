unit encinifile;

interface

uses IniFiles, Classes, md5, SyncObjs;

type
  { THashedStringList - A TStringList that uses TStringHash to improve the
    speed of Find }
  THashedStringList = class(TStringList)
  private
    FValueHash: TStringHash;
    FNameHash: TStringHash;
    FValueHashValid: Boolean;
    FNameHashValid: Boolean;
    procedure UpdateValueHash;
    procedure UpdateNameHash;
  protected
    procedure Changed; override;
  public
    destructor Destroy; override;
    function IndexOf(const S: string): Integer; override;
    function IndexOfName(const Name: string): Integer; override;
  end;
  TEncStringlist = class(TStringList)
  private
    fPassHash: TMD5Digest;
  public
    constructor Create(pass: string); overload;
    constructor Create(pass: TMD5Digest); overload;
    procedure LoadFromFile(const FileName: string); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override; 
  end;

  // threadsafe TIniFile with encryption support
  TEncIniFile = class(TCustomIniFile)
  private
    il: TCriticalSection;
    FFilename: string;
    FPassHash: TMD5Digest;
    FSections: TStringList;
    fCompression: Boolean;
    function AddSection(const Section: string): TStrings;
    function GetCaseSensitive: Boolean;
    procedure LoadValues;
    procedure SetCaseSensitive(Value: Boolean);
  public
    AutoUpdate: Boolean;
    constructor Create(const FileName, Passphrase: string; autoupdate: Boolean = False; compression: Boolean = True); overload;
    constructor Create(const FileName: string; Passphrase: TMD5Digest; autoupdate: Boolean = False; compression: Boolean = True); overload;
    destructor Destroy; override;
    procedure LoadUnencrypted(filename: string);
    procedure SaveUnencrypted(filename: string);
    procedure Clear;
    procedure DeleteKey(const Section, Ident: String); override;
    procedure EraseSection(const Section: string); override;
    procedure GetStrings(List: TStrings);
    procedure ReadSection(const Section: string; Strings: TStrings); override;
    procedure ReadSections(Strings: TStrings); override;
    procedure ReadSectionValues(const Section: string; Strings: TStrings); override;
    function ReadString(const Section, Ident, Default: string): string; override;
    procedure SetStrings(List: TStrings);
    procedure UpdateFile; override;
    procedure Rename(const FileName: string; Reload: Boolean);
    procedure WriteString(const Section, Ident, Value: String); override;
    property CaseSensitive: Boolean read GetCaseSensitive write SetCaseSensitive;
  end;

implementation

uses SysUtils, myblowfish;

{ THashedStringList }

procedure THashedStringList.Changed;
begin
  inherited Changed;
  FValueHashValid := False;
  FNameHashValid := False;
end;

destructor THashedStringList.Destroy;
begin
  FValueHash.Free;
  FNameHash.Free;
  inherited Destroy;
end;

function THashedStringList.IndexOf(const S: string): Integer;
begin
  UpdateValueHash;
  if not CaseSensitive then
    Result :=  FValueHash.ValueOf(AnsiUpperCase(S))
  else
    Result :=  FValueHash.ValueOf(S);
end;

function THashedStringList.IndexOfName(const Name: string): Integer;
begin
  UpdateNameHash;
  if not CaseSensitive then
    Result := FNameHash.ValueOf(AnsiUpperCase(Name))
  else
    Result := FNameHash.ValueOf(Name);
end;

procedure THashedStringList.UpdateNameHash;
var
  I: Integer;
  P: Integer;
  Key: string;
begin
  if FNameHashValid then Exit;
  
  if FNameHash = nil then
    FNameHash := TStringHash.Create
  else
    FNameHash.Clear;
  for I := 0 to Count - 1 do
  begin
    Key := Get(I);
    P := AnsiPos('=', Key);
    if P <> 0 then
    begin
      if not CaseSensitive then
        Key := AnsiUpperCase(Copy(Key, 1, P - 1))
      else
        Key := Copy(Key, 1, P - 1);
      FNameHash.Add(Key, I);
    end;
  end;
  FNameHashValid := True;
end;

procedure THashedStringList.UpdateValueHash;
var
  I: Integer;
begin
  if FValueHashValid then Exit;
  
  if FValueHash = nil then
    FValueHash := TStringHash.Create
  else
    FValueHash.Clear;
  for I := 0 to Count - 1 do
    if not CaseSensitive then
      FValueHash.Add(AnsiUpperCase(Self[I]), I)
    else
      FValueHash.Add(Self[I], I);
  FValueHashValid := True;
end;


constructor TEncIniFile.Create(const FileName: string; Passphrase: TMD5Digest; autoupdate: Boolean = False; compression: Boolean = True); 
begin
  inherited Create(FileName);
  il:= TCriticalSection.Create;
  fPassHash:= Passphrase;
  self.AutoUpdate:= autoupdate;
  FFilename:= FileName;
  fCompression:= compression;
  FSections := THashedStringList.Create;
{$IFDEF LINUX}
  FSections.CaseSensitive := True;
{$ENDIF}
  LoadValues;
end;

constructor TEncIniFile.Create(const FileName, Passphrase: string; autoupdate: Boolean = False; compression: Boolean = True);
begin
  inherited Create(FileName);
  il:= TCriticalSection.Create;
  fPassHash:= MD5String(Passphrase);
  self.AutoUpdate:= autoupdate;
  FFilename:= FileName;
  fCompression:= compression;
  FSections := THashedStringList.Create;
{$IFDEF LINUX}
  FSections.CaseSensitive := True;
{$ENDIF}
  LoadValues;
end;

destructor TEncIniFile.Destroy;
begin
  if AutoUpdate then
    UpdateFile;
    
  if FSections <> nil then
    Clear;
  FSections.Free;
  il.Free;
  inherited Destroy;
end;

function TEncIniFile.AddSection(const Section: string): TStrings;
begin
  Result := THashedStringList.Create;
  try
    THashedStringList(Result).CaseSensitive := CaseSensitive;
    FSections.AddObject(Section, Result);
  except
    Result.Free;
    raise;
  end;
end;

procedure TEncIniFile.Clear;
var
  I: Integer;
begin
  il.Enter;
  for I := 0 to FSections.Count - 1 do
    TObject(FSections.Objects[I]).Free;
  FSections.Clear;
  il.Leave;
end;

procedure TEncIniFile.DeleteKey(const Section, Ident: String);
var
  I, J: Integer;
  Strings: TStrings;
begin
  il.Enter;
  I := FSections.IndexOf(Section);
  if I >= 0 then
  begin
    Strings := TStrings(FSections.Objects[I]);
    J := Strings.IndexOfName(Ident);
    if J >= 0 then
      Strings.Delete(J);
  end;
  il.Leave;  
end;

procedure TEncIniFile.EraseSection(const Section: string);
var
  I: Integer;
begin
  il.Enter;
  I := FSections.IndexOf(Section);
  if I >= 0 then
  begin
    TStrings(FSections.Objects[I]).Free;
    FSections.Delete(I);
  end;
  il.Leave;
end;

function TEncIniFile.GetCaseSensitive: Boolean;
begin
  il.Enter;
  Result := FSections.CaseSensitive;
  il.Leave;  
end;

procedure TEncIniFile.GetStrings(List: TStrings);
var
  I, J: Integer;
  Strings: TStrings;
begin
  List.BeginUpdate;
  try
    for I := 0 to FSections.Count - 1 do
    begin
      List.Add('[' + FSections[I] + ']');
      Strings := TStrings(FSections.Objects[I]);
      for J := 0 to Strings.Count - 1 do List.Add(Strings[J]);
      List.Add('');
    end;
  finally
    List.EndUpdate;
  end;
end;

procedure TEncIniFile.LoadValues;
var
  List: TStringList;
  myS: TMemoryStream;
begin
  if (FileName <> '') and FileExists(FileName) then
  begin
    myS:= TMemoryStream.Create;
    List := TStringList.Create;
    DecryptFileToStream(fFilename, myS, FPassHash.v, fCompression);
    try
      List.LoadFromStream(myS);
      SetStrings(List);
    finally
      List.Free;
      myS.Free;
    end;
  end
  else
    Clear;
end;

procedure TEncIniFile.ReadSection(const Section: string;
  Strings: TStrings);
var
  I, J: Integer;
  SectionStrings: TStrings;
begin
  il.Enter;
  Strings.BeginUpdate;
  try
    Strings.Clear;
    I := FSections.IndexOf(Section);
    if I >= 0 then
    begin
      SectionStrings := TStrings(FSections.Objects[I]);
      for J := 0 to SectionStrings.Count - 1 do
        Strings.Add(SectionStrings.Names[J]);
    end;
  finally
    Strings.EndUpdate;
    il.Leave;
  end;
end;

procedure TEncIniFile.ReadSections(Strings: TStrings);
begin
  il.Enter;
  Strings.Assign(FSections);
  il.Leave;
end;

procedure TEncIniFile.ReadSectionValues(const Section: string;
  Strings: TStrings);
var
  I: Integer;
begin
  il.Enter;
  Strings.BeginUpdate;
  try
    Strings.Clear;
    I := FSections.IndexOf(Section);
    if I >= 0 then
      Strings.Assign(TStrings(FSections.Objects[I]));
  finally
    Strings.EndUpdate;
    il.Leave;
  end;
end;

function TEncIniFile.ReadString(const Section, Ident,
  Default: string): string;
var
  I: Integer;
  Strings: TStrings;
begin
  Result := Default;
  il.Enter;
  I := FSections.IndexOf(Section);
  if I >= 0 then
  begin
    Strings := TStrings(FSections.Objects[I]);
    I := Strings.IndexOfName(Ident);
    if I >= 0 then
      Result := Copy(Strings[I], Length(Ident) + 2, Maxint);
  end;
  il.Leave;
end;


procedure TEncIniFile.SetCaseSensitive(Value: Boolean);
var
  I: Integer;
begin
  il.Enter;
  if Value <> FSections.CaseSensitive then
  begin
    FSections.CaseSensitive := Value;
    for I := 0 to FSections.Count - 1 do
      with THashedStringList(FSections.Objects[I]) do
      begin
        CaseSensitive := Value;
        Changed;
      end;
    THashedStringList(FSections).Changed;
  end;
  il.Leave;
end;

procedure TEncIniFile.SetStrings(List: TStrings);
var
  I, J: Integer;
  S: string;
  Strings: TStrings;
begin
  Clear;
  il.Enter;
  Strings := nil;
  for I := 0 to List.Count - 1 do
  begin
    S := Trim(List[I]);
    if (S <> '') and (S[1] <> ';') then
      if (S[1] = '[') and (S[Length(S)] = ']') then
      begin
        Delete(S, 1, 1);
        SetLength(S, Length(S)-1);
        Strings := AddSection(Trim(S));
      end
      else
        if Strings <> nil then
        begin
          J := Pos('=', S);
          if J > 0 then // remove spaces before and after '='
            Strings.Add(Trim(Copy(S, 1, J-1)) + '=' + Trim(Copy(S, J+1, MaxInt)) )
          else
            Strings.Add(S);
        end;
  end;
  il.Leave;
end;

procedure TEncIniFile.UpdateFile;
var
  List: TStringList;
  myS: TMemoryStream;
begin
  myS:= TMemoryStream.Create;
  List := TStringList.Create;
  try
    GetStrings(List);

    List.SaveToStream(myS);
    EncryptStreamToFile(myS, fFilename, FPassHash.v, fCompression);
  finally
    List.Free;
    myS.Free;
  end;
end;


procedure TEncIniFile.Rename(const FileName: string; Reload: Boolean);
begin
  FFileName := FileName;
  if Reload then
    LoadValues;
end;

procedure TEncIniFile.WriteString(const Section, Ident, Value: String);
var
  I: Integer;
  S: string;
  Strings: TStrings;
begin
  il.Enter;
  I := FSections.IndexOf(Section);
  if I >= 0 then
    Strings := TStrings(FSections.Objects[I])
  else
    Strings := AddSection(Section);
  S := Ident + '=' + Value;
  I := Strings.IndexOfName(Ident);
  if I >= 0 then
    Strings[I] := S
  else
    Strings.Add(S);

  if self.AutoUpdate then
    UpdateFile;

  il.Leave;
end;

procedure TEncIniFile.SaveUnencrypted(filename: string);
var
  List: TStringList;
begin
  List := TStringList.Create;
  try
    GetStrings(List);

    List.SaveToFile(filename);
  finally
    List.Free;
  end;
end;


procedure TEncIniFile.LoadUnencrypted(filename: string);
var
  List: TStringList;
begin
  if (FileName <> '') and FileExists(FileName) then
  begin
    List := TStringList.Create;
    try
      List.LoadFromFile(filename);
      SetStrings(List);
    finally
      List.Free;
    end;
  end
  else
    Clear;
end;

{ TEncStringlist }

constructor TEncStringlist.Create(pass: string);
begin
  fPassHash:= MD5String(pass);
  inherited Create;
end;

constructor TEncStringlist.Create(pass: TMD5Digest);
begin
  fPassHash:= pass;
  inherited Create;
end;

procedure TEncStringlist.LoadFromFile(const FileName: string);
var
  Stream: TStream;
begin
  if FileExists(FileName) then
  begin
    Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    try
      LoadFromStream(Stream);
    finally
      Stream.Free;
    end;
  end;
end;

procedure TEncStringlist.LoadFromStream(Stream: TStream);
var s: TStringStream;
begin
  s:= TStringStream.Create( '' );
  BeginUpdate;
  try
    DecryptStreamToStream(Stream, s, fPassHash.v, True);
    SetTextStr(s.DataString);
  finally
    s.Free;
    EndUpdate;
  end;
end;

procedure TEncStringlist.SaveToStream(Stream: TStream);
var s: TStringStream;
begin
  s:= TStringStream.Create( GetTextStr );
  s.Position:= 0;
  try
    EncryptStreamToStream(s, Stream, FPassHash.v, True);
  finally
    s.Free;
  end;
end;

end.

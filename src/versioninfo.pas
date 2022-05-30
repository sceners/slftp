unit versioninfo;

interface
{$IFDEF MSWINDOWS}
uses SysUtils, Windows, Classes;


type
  TEPInfoExe = class
  private
    { Déclarations privées }
    FLangId           : string;
    FExeName          : string;
    FCompanyName      : string;
    FFileDescription  : string;
    FFileVersion      : string;
    FInternalName     : string;
    FLegalCopyright   : string;
    FLegalTradeMarks  : string;
    FOriginalFilename : string;
    FProductName      : string;
    FProductVersion   : string;
    FComments         : string;
  protected
    { Déclarations protégées }

  public
    { Déclarations publiques }
    constructor Create(exename: string); overload; 

  published
    { Déclarations publiées }
    property LangId : string read FLangId write FLangId;
    property ExeName : string read FExeName write FExeName;
    property CompanyName : string read FCompanyName;
    property FileDescription : string read FFileDescription;
    property FileVersion : string read FFileVersion;
    property InternalName : string read FInternalName;
    property LegalCopyright : string read FLegalCopyright;
    property LegalTradeMarks : string read FLegalTradeMarks;
    property OriginalFilename : string read FOriginalFilename;
    property ProductName : string read FProductName;
    property ProductVersion : string read FProductVersion;
    property Comments : string read FComments;
  end;
{$ENDIF}

function Get_VersionString(exename: string): string;

implementation

{$IFDEF MSWINDOWS}
constructor TEPInfoExe.Create(exename: string);
var
  loc_InfoBufSize : integer;
  loc_InfoBuf     : PChar;
  loc_VerBufSize  : integer;
  loc_VerBuf      : PChar;
begin
  inherited Create();

  FLangId           := '040A';
  FExeName          := exename;
  FCompanyName      := '';
  FFileDescription  := '';
  FFileVersion      := '';
  FInternalName     := '';
  FLegalCopyright   := '';
  FLegalTradeMarks  := '';
  FOriginalFilename := '';
  FProductName      := '';
  FProductVersion   := '';
  FComments         := '';

  loc_InfoBufSize := GetFileVersionInfoSize(PChar(FExename),DWORD(loc_InfoBufSize));
  if loc_InfoBufSize > 0 then
  begin
    loc_InfoBuf := AllocMem(loc_InfoBufSize);
    GetFileVersionInfo(PChar(FExeName),0,loc_InfoBufSize,loc_InfoBuf);

    VerQueryValue(loc_InfoBuf,PChar('StringFileInfo\'+FLangId+'04E4\CompanyName'),Pointer(loc_VerBuf),DWORD(loc_VerBufSize));
    FCompanyName := loc_VerBuf;

    VerQueryValue(loc_InfoBuf,PChar('StringFileInfo\'+FLangId+'04E4\FileDescription'),Pointer(loc_VerBuf),DWORD(loc_VerBufSize));
    FFileDescription := loc_VerBuf;

    VerQueryValue(loc_InfoBuf,PChar('StringFileInfo\'+FLangId+'04E4\FileVersion'),Pointer(loc_VerBuf),DWORD(loc_VerBufSize));
    FFileVersion := loc_VerBuf;

    VerQueryValue(loc_InfoBuf,PChar('StringFileInfo\'+FLangId+'04E4\InternalName'),Pointer(loc_VerBuf),DWORD(loc_VerBufSize));
    FInternalName := loc_VerBuf;

    VerQueryValue(loc_InfoBuf,PChar('StringFileInfo\'+FLangId+'04E4\LegalCopyright'),Pointer(loc_VerBuf),DWORD(loc_VerBufSize));
    FLegalCopyright := loc_VerBuf;

    VerQueryValue(loc_InfoBuf,PChar('StringFileInfo\'+FLangId+'04E4\LegalTradeMarks'),Pointer(loc_VerBuf),DWORD(loc_VerBufSize));
    FLegalTradeMarks := loc_VerBuf;

    VerQueryValue(loc_InfoBuf,PChar('StringFileInfo\'+FLangId+'04E4\OriginalFilename'),Pointer(loc_VerBuf),DWORD(loc_VerBufSize));
    FOriginalFilename := loc_VerBuf;

    VerQueryValue(loc_InfoBuf,PChar('StringFileInfo\'+FLangId+'04E4\ProductName'),Pointer(loc_VerBuf),DWORD(loc_VerBufSize));
    FProductName := loc_VerBuf;

    VerQueryValue(loc_InfoBuf,PChar('StringFileInfo\'+FLangId+'04E4\ProductVersion'),Pointer(loc_VerBuf),DWORD(loc_VerBufSize));
    FProductVersion := loc_VerBuf;

    VerQueryValue(loc_InfoBuf,PChar('StringFileInfo\'+FLangId+'04E4\Comments'),Pointer(loc_VerBuf),DWORD(loc_VerBufSize));
    FComments := loc_VerBuf;

    FreeMem(loc_InfoBuf, loc_InfoBufSize);
  end;
end;
function Get_VersionString(exename: string): string;
var x: TEPInfoExe;
begin
  x:= TEPInfoExe.Create(exename);
  Result:= x.ProductName+' v'+x.FileVersion;
  x.Free;
end;
{$ELSE}
function Get_VersionString(exename: string): string;
begin
  Result:= 'slftp-1.1.0.0';
end;
{$ENDIF}

end.

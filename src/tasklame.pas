unit tasklame;
interface

uses tasksunit, idTCPClient;

type TLameTask = class(TTask)
       idTCP: TIdTCPClient;
       filename: string;
       dir: string;
       genremode: Boolean;
       filesize: Integer;
       constructor Create(site: string; dir: string; filename: string; filesize: Integer; genremode: Boolean);
       function Execute(slot: Pointer): Boolean; override;
       function Name: string; override;
  private
    function Olvass(var buffer: array of byte; mennyit: Integer): string;
    function Konnekt(ct: Integer): string;
     end;

implementation

uses IdSSLOpenSSL, sitesunit, mystrings, SysUtils, DebugUnit, irc, lame;

const section = 'lame';

{ TLoginTask }

function TLameTask.Olvass(var buffer: array of byte; mennyit: Integer): string;
begin
  Result:= '';
  try
    idTCP.ReadBuffer(buffer, mennyit);
  except on e: Exception do
    Result:= e.Message;
  end;
end;

function TLameTask.Konnekt(ct: Integer): string;
begin
  Result:= '';
  try
    idTCP.Connect(ct*1000);
    with idTCP.IOHandler as TIdSSLIOHandlerSocket do
      PassThrough:= False;
  except on e: Exception do
    Result:= e.Message;
  end;
end;

constructor TLameTask.Create(site: string; dir: string; filename: string; filesize: Integer; genremode: Boolean);
begin
  self.filename:= filename;
  self.filesize:= filesize;
  self.dir:= dir;
  self.genremode:= genremode;
  idTCP:= nil;
  inherited Create(site, tLame);
end;

function TLameTask.Execute(slot: Pointer): Boolean;
label ujra;
var s: TSiteSlot;
    probak: Integer;
    host: string;
    port: Integer;
    tartas: Integer;
    re1, re2: string;
    ss: string;
    mennyitolvass: Integer;
    buffer: array[0..8191] of Byte;
begin
  Result:= False;
  probak:= 0;
  s:= slot;
  re1:= '';
  re2:= '';
  Debug(dpMessage, section, Name);

ujra:
  if s.status <> ssOnline then
    if not s.ReLogin then
    begin
      readyerror:= True;
      exit;
    end;

  if (not s.Cwd(dir, true)) then goto ujra;

  if not s.SendProtP then goto ujra;

  tartas:= 0;
  if genremode then tartas:= 1;

  while(true) do
  begin
    if not s.Send('PASV') then goto ujra;
    if not s.Read() then goto ujra;

    if (s.lastResponseCode <> 227) then
    begin
      irc.Announce(section, True, Trim(s.lastResponse));
      if probak = 0 then
      begin
        inc(probak);
        goto ujra;
      end else
      begin
        response:= 'Couldnt use passive mode / '+filename;
        readyerror:= True;
        exit;
      end;
    end;

    ParsePasvString(s.lastResponse, host, port);
    if port = 0 then
    begin
        response:= 'Couldnt parse passive string / '+filename;
        readyerror:= True;
        exit;
    end;

      idTCP:= TIdTCPClient.Create(nil);
      idTCP.Host:= host;
      idTCP.Port:= port;
      SetupSocket(idTCP, True);

      if tartas = 0 then
      begin
        // itt lameszarokat kell olvasni az elejerol
        if not s.Send('REST 0') then goto ujra;

        mennyitolvass:= 8192;
      end
      else
      if tartas = 1 then
      begin
        // itt id3v1-t kell olvasni
        if not s.Send('REST %d',[filesize-128]) then goto ujra;

        mennyitolvass:= 128;
      end
      else
      begin
        // itt seekelni kell x-hez
        if not s.Send('REST %d',[tartas]) then goto ujra;

        mennyitolvass:= 8192;
      end;

      if not s.Read() then goto ujra;

      if not s.Send('RETR %s', [filename]) then
      begin
        idTCP.Free;
        idTCP:= nil;
        goto ujra;
      end;



      ss:= Konnekt(s.site.connect_timeout);
      if ss <> '' then
      begin
        if probak = 0 then
        begin
          irc.Announce(section, True, ss);
          idTCP.Free;
          idTCP:= nil;
          goto ujra;
        end else
        begin
          response:= 'Couldnt connect to site ('+ss+') / '+filename;
          readyerror:= True;
          exit;
        end;
      end;

      if not s.Read() then
      begin
        if probak = 0 then
        begin
          irc.Announce(section, True, ss);
          idTCP.Free;
          idTCP:= nil;
          goto ujra;
        end else
        begin
          response:= 'Couldnt read response of site / '+filename;
          readyerror:= True;
          exit;
        end;
      end;

      ss:= Olvass(buffer, mennyitolvass);
      if ss <> '' then
      begin
        if probak = 0 then
        begin
          irc.Announce(section, True, ss);
          idTCP.Free;
          idTCP:= nil;
          goto ujra;
        end else
        begin
          response:= 'Couldnt connect to site ('+ss+') / '+filename;
          readyerror:= True;
          exit;
        end;
      end;

      if idTCP.Connected then
        idTCP.Disconnect;

      if not s.Read() then goto ujra;

      if tartas = 1 then
        ID3_Check(buffer, re2)
      else
      begin
        tartas:= Lame_Check(buffer, 0, re1);
        if tartas <= 0 then tartas:= 1;
      end;

      if idTCP <> nil then
      begin
        idTCP.Free;
        idTCP:= nil;
      end;

      if re2 <> '' then break;
  end;

  response:= re1 + ' / '+ re2 + ' / '+ filename;

  Result:= True;
  ready:= True;
end;

function TLameTask.Name: string;
begin
  Result:= 'LAME '+site1+' '+filename;
end;

end.


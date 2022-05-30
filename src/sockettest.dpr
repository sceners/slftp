program sockettest;

{$APPTYPE CONSOLE}

uses
  SysUtils, IdTCPClient, IdSSLOpenSSL;

type TDebugPriority = (dpSpam,dpError,dpMessage);
     TReadStatus = (rsException, rsTimeout, rsRead);

resourcestring section = 'sockettest';

var myTCPClient: TIdTCPClient;
    lastresponsecode: Integer;
    lastresponse: string;


procedure Debug(priority: TDebugPriority; section, msg: string); overload;
var nowstr: string;
begin
  DateTimeToString(nowstr, 'mm-dd hh:nn:ss.zzz', Now());
  WriteLn(Format('%s [%-12s] %s', [nowstr, section, msg]));
end;

procedure Debug(priority: TDebugPriority; const section, FormatStr: string; const Args: array of const); overload;
begin
  Debug(priority, section, Format(FormatStr, Args));
end;


procedure SetupSocket(tcpClient: TIdTCPClient; atereszt: Boolean = True);
begin
  tcpClient.IOHandler:= TIdSSLIOHandlerSocket.Create(tcpClient);
  with tcpClient.IOHandler as TIdSSLIOHandlerSocket do
  begin
    SSLOptions.Method:= sslvSSLv23;
    PassThrough:= atereszt;
  end;

end;

procedure DestroySocket(down: Boolean);
begin
  try
    if myTcpClient.Connected then
      myTcpClient.Disconnect;

    if myTcpClient.IOHandler <> nil then
    begin
      myTcpClient.IOHandler.Free;
      myTcpClient.IOHandler:= nil;
    end;

  except on e: Exception do
    debug(dpError, section, 'ERROR in destroysocket: %s', [e.Message]);
  end;
end;

function RPos(SubStr: Char; Str: String): Integer;
var m, i: Integer;
begin
  Result:= 0;
  m:= length(Str);
  for i:= 1 to m do
    if Str[i] = SubStr Then Result:= i;
end;
function ParseResponseCode(s: string): Integer;
var p: Integer;
begin
  Result:= 0;
  s:= Trim(s);
  p:= RPos(#13, s);
  if (p <= length(s)-5) then
  begin
    inc(p);
    if (s[p] in [#13, #10]) then inc(p);

    Result:= StrToIntDef(Copy(s, p, 3), 0);
    if s[p+3] <> ' ' then inc(Result, 1000);
  end;
end;


function ReadB(raiseontimeout: Boolean = True; raiseonclose: Boolean = True; timeout: Integer = 0): TReadStatus;
label ujra;
var o: Integer;
    aktread: string;
begin
  lastResponse:= '';
  lastResponseCode:= 0;
  Result:= rsException;
  if timeout = 0 then timeout:= 20 * 1000;
  try
ujra:
    o:= myTCPClient.ReadFromStack(True, timeout, raiseontimeout);
    if ((o <> myTCPClient.InputBuffer.Size) and (0 < myTCPClient.InputBuffer.Size)) then
      o:= myTCPClient.InputBuffer.Size;

    if o > 0 then
    begin
      aktread:= myTCPClient.ReadString(o);
      lastResponse:= lastResponse + aktread;
      Debug(dpSpam, 'protocol', ' <<'+#13#10+aktread);
      lastResponseCode:= ParseResponseCode(lastResponse);

      if ((lastResponseCode >= 1000) or (lastResponseCode < 100)) then
        // auto read more
        goto ujra;


      Result:= rsRead;
    end else
      Result:= rsTimeout;
  except on E: Exception do
    begin
      DestroySocket(True);
      if raiseOnClose then
        Debug(dpSpam, section, '%s', [e.Message]);
    end;
  end;
end;
function Read(raiseontimeout: Boolean = True; raiseonclose: Boolean = True; timeout: Integer = 0): Boolean;
begin
  Result:= ReadB(raiseontimeout, raiseonclose, timeout) = rsRead;
end;

function Send(s: string): Boolean;overload;
begin
  Result:= False;
  try
    myTCPClient.WriteLn(s);
    Debug(dpSpam, 'protocol', ' >>'+#13#10+s);
    Result:= True;
  except on E: Exception do
    begin
      Debug(dpSpam, section, '%s', [e.Message]);
      DestroySocket(True);
    end;
  end;
end;

function Send(s: string; const Args: array of const): Boolean; overload;
begin
  Result:= Send(Format(s, Args));
end;

function LoginBnc(): Boolean;
begin
  Result:= False;
  SetupSocket(myTCPClient);



  // elso lepes a connect
  try
    myTCPClient.Host:= 'cc.cirmoscica.hu';
    myTCPClient.Port:= 51001;
    myTCPClient.Connect(20*1000);

  // banner
  if not Read() then exit;
  if(lastResponseCode <> 220) then
    raise Exception.Create(Trim(lastResponse));

      // AUTH TLS-t probalunk
      if not Send('AUTH TLS') then exit;
      if not Read() then exit;

      if lastResponseCode = 234 then
      begin
        (myTCPClient.IOHandler as TIdSSLIOHandlerSocket).PassThrough:= False;
      end;

  if not Send('USER %s', ['BDSM']) then exit;
  if not Read then exit;

  if lastResponseCode <> 331 then
    raise Exception.Create(Trim(lastResponse));

  if not Send('PASS %s', ['t3stp4ss']) then exit;
  if not Read then exit;

  if lastResponseCode <> 230 then
    raise Exception.Create(Trim(lastResponse));


  if not Send('TYPE I') then exit;
  if not Read then exit;


    // siker
    Result:= True;

  except
    on e: Exception do
    begin
      Debug(dpSpam, section, '%s', [e.Message]);
      DestroySocket(True);
    end;
  end;
end;

procedure TestBegin;
begin
  myTCPClient:= TIdTCPClient.Create(nil);
end;

procedure TestEnd;
begin
  DebuG(dpSpam, section, 'kilepes');
  myTCPClient.Free;
end;

procedure TestCsinald;
begin
  if not LoginBnc then exit;

  while(true) do
  begin
    if not Send('STAT -l') then exit;
    if not Read() then exit;

    sleep(5000);
  end;
end;

begin
  TestBegin;
  TestCsinald;
  TestEnd;
end.

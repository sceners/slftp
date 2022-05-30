unit irc;

interface

uses Classes, SyncObjs, Contnrs, SysUtils, IdTCPClient;

type
  TMyIrcThread = class(TThread)
  private
    flood: Integer;
    irc_last_read: TDateTime;
    myIrcClient: TIdTCPClient;
    registered: Boolean;
    channels: TStringList;
    ssl: Boolean;
    ircpassword: string;
    procedure IrcSetupSocket;
    procedure IrcConnect;
    procedure IrcQuit;
    procedure IrcRegister;
    procedure IrcProcessLine(s: string);
    procedure IrcProcess;
    procedure IrcPing(cumo: string);
    procedure IrcPrivMsg(s: string);
    procedure IrcWrite(s: string);
    procedure IrcSendPrivMessage(channel, plainmsgformat: string; const args: array of const); overload;
    procedure IrcSendPrivMessage(channel, plainmsg: string); overload;
    function IrcSendPrivMessage(oneliner: string): Boolean; overload;
    procedure IrcProcessCommand(channel, msg: string);
    procedure ShouldJoinGame;
    function getHost: string;
    function getPort: Integer;
    procedure ClearSiteInvited;
  public
    shouldquit: Boolean;
    shouldrestart: Boolean;
    shouldjoin: Boolean;
    netname: string;
    status: string;
    cmdprefix: string;
    constructor Create(netname: string);
    procedure Execute; override;
    destructor Destroy; override;
    property Host: string read getHost;
    property Port: Integer read getPort;    
  end;


function Bold(s: string): string; overload;
function Bold(s: Integer): string; overload;
function Red(s: string): string;

procedure IrcStart;
procedure irc_Addtext(msg: string); overload;
procedure irc_Addtext(channel: string; msg: string); overload;
procedure irc_Addtext(channel: string; msgFormat: string; Args: array of const); overload;

procedure Announce(section: string; error: Boolean; s: string); overload;
procedure Announce(section: string; error: Boolean; formatStr: string; const args: array of const); overload;

function FindIrcnetwork(netname: string): TMyIrcThread;

var
  myIrcThreads: TObjectList = nil;
  irc_lock: TCriticalSection;
  irc_queue: TStringList;
  irc_queue_nets: TStringList;
  nickname, adminchan: string;

implementation

uses debugunit, configunit, ircblowfish, IdStack,
     IdSSLOpenSSL, socks5, IdIOHandlerSocket, versioninfo,
     helper, mystrings, DateUtils, idGlobal,
     irccommandsunit, sitesunit, taskraw, queueunit,
     precatcher, 
     mainthread;




const section = 'irc';

function FindIrcnetwork(netname: string): TMyIrcThread;
var i: Integer;
begin
  Result:= nil;
  for i:= 0 to myIrcThreads.Count-1 do
    if (myIrcThreads[i] as TMyIrcThread).netname = netname then
      Result:= myIrcThreads[i] as TMyIrcThread;
end;

function Bold(s: string): string;
begin
 Result:= #2+ s + #2;
end;
function Bold(s: Integer): string;
begin
 Result:= #2+ IntToStr(s) + #2;
end;
function Red(s: string): string;
begin
 if ((length(s) > 0) and ('0' <= s[1]) and (s[1] <= '9')) then
    s:= ' ' + s;
 Result:= #3+'4'+ s + #3;
end;

procedure irc_Addtext(msg: string); overload;
begin
  irc_Addtext(config.ReadString(section, 'chan_name', ''), msg);
end;


procedure irc_Addtext(channel: string; msg: string); overload;
begin
  if kilepes then exit;
  irc_lock.Enter;
  irc_queue.Add(channel+' '+msg);
  irc_queue_nets.Add('MAIN');
  irc_lock.Leave;
end;
procedure irc_Addtext(channel: string; msgFormat: string; Args: array of const); overload;
begin
  irc_Addtext(channel, Format(msgFormat, Args));
end;


procedure IrcStart;
var x: TStringList;
    i: Integer;
    channel, netname: string;
begin
  nickname:= config.ReadString(section, 'nickname', 'sl');
  adminchan:= config.ReadString(section, 'chan_name', '');

  irc_lock.Enter;

  // ez az elso lesz a default mindenhez
  irc_RegisterChannel('MAIN', config.ReadString(section, 'chan_name', ''), config.ReadString(section, 'chan_blow', ''), config.ReadString(section, 'chan_key', ''));
  irc_RegisterChannel('MAIN', config.ReadString('regpredb', 'nick', 'xxx'), config.ReadString('regpredb', 'blow', ''));

  // register other sitechan keys
  x:= TStringList.Create;
  sitesdat.ReadSections(x);
  for i:= 0 to x.Count -1 do
  begin
    if (1 = Pos('channel-', x[i])) then
    begin
      netname:= SubString(x[i], '-', 2);
      channel:= Copy(x[i], Length('channel-')+Length(netname)+2, 1000);
      irc_RegisterChannel(netname, channel, sitesdat.ReadString(x[i], 'blowkey', ''), sitesdat.ReadString(x[i], 'chankey', ''), sitesdat.ReadBool(x[i], 'inviteonly', False));
    end;
  end;


  if config.ReadBool(section, 'enabled', False) then
    myIrcThreads.Add(TMyIrcThread.Create('MAIN'));

  // create other network threads
  sitesdat.ReadSections(x);
  for i:= 0 to x.Count -1 do
    if (1 = Pos('ircnet-', x[i])) then
      myIrcThreads.Add(TMyIrcThread.Create(Copy(x[i], 8, 1000)));
  x.Free;

  irc_lock.Leave;
end;

{ TMyIrcThread }

constructor TMyIrcThread.Create(netname: string);
begin
  channels:= TStringList.Create;
  self.netname:= netname;
  status:= 'creating...';
  shouldquit:= False;
  shouldrestart:= False;

  myIrcClient:= TIdTCPClient.Create(nil);

  flood:= config.ReadInteger(section, 'flood', 333);
  cmdprefix:= config.ReadString(section, 'cmdprefix', '!');

  Debug(dpMessage, section, 'Irc thread for %s has started', [netname]);

  FreeOnTerminate:= True;

  inherited Create(False);
end;

destructor TMyIrcThread.Destroy;
begin
  status:= 'destroying...';

  irc_lock.Enter;
  myIrcThreads.Remove(self);
  irc_lock.Leave;

  channels.Free;
  myIrcClient.Free;

  inherited;
end;

procedure TMyIrcThread.IrcSetupSocket;
begin
  irc_last_read:= Now();
  registered:= False;
  if myIrcClient.Connected then
    myIrcClient.Disconnect;
    
  if myIrcClient.IOHandler <> nil then
  begin
    myIrcClient.IOHandler.Free;
    myIrcClient.IOHandler:= nil;
  end;


  if netname = 'MAIN' then
  begin
    myIrcClient.Host:= config.ReadString(section, 'host', '');
    myIrcClient.Port:= config.ReadInteger(section, 'port', 0);
    ssl:= config.ReadBool(section, 'ssl', False);
    ircpassword:= config.ReadString(section, 'password', '');
  end else
  begin
    myIrcClient.Host:= sitesdat.ReadString('ircnet-'+netname, 'host', '');
    myIrcClient.Port:= sitesdat.ReadInteger('ircnet-'+netname, 'port', 0);
    ssl:= sitesdat.ReadBool('ircnet-'+netname, 'ssl', False);
    ircpassword:= sitesdat.ReadString('ircnet-'+netname, 'password', '');
  end;
  

  if ssl then
  begin
    myIrcClient.IOHandler:= TIdSSLIOHandlerSocket.Create(myIrcClient);
    with myIrcClient.IOHandler as TIdSSLIOHandlerSocket do
    begin
      SSLOptions.Method:= sslvSSLv23;
      PassThrough:= True;
    end;
  end;

  if config.ReadBool(section, 'socks5', False) then
  begin
    if not ssl then
      myIrcClient.IOHandler:= TIdIOHandlerSocket.Create(myIrcClient);
    SetupSocks5(myIrcClient);
  end;
end;

procedure TMyIrcThread.IrcWrite(s: string);
begin
  irc_last_read:= Now();
  myIrcClient.WriteLn(s);
  Debug(dpSpam, section, '>> '+s);
end;
procedure TMyIrcThread.IrcConnect;
var LOurAddr: string;
begin
  status:= 'connecting...';

  myIrcClient.Connect(config_connect_timeout * 1000);

  if ssl then
  begin
    status:= 'ssl handshake...';
    with myIrcClient.IOHandler as TIdSSLIOHandlerSocket do
      PassThrough:= False;
  end;

  status:= 'connected...';

  if (Length(myIrcClient.BoundIP)>0) then
    LOurAddr := myIrcClient.BoundIP
  else
    LOurAddr := GStack.LocalAddress;

(*
NICK rsc
USER rsc 127.0.0.1 irc.link-net.hu :Realname
*)

  if ircpassword <> '' then
    IrcWrite('PASS '+ircpassword);

  IrcWrite('NICK '+nickname);
  IrcWrite(
    Format('USER %s %s %s :%s',
      [
        config.ReadString(section, 'username', 'sl'),
        LOurAddr,
        config.ReadString(section, 'host', ''),
        config.ReadString(section, 'realname', 'soulless')
      ]
    )
  );


end;


procedure TMyIrcThread.IrcQuit;
begin
	IrcWrite('QUIT :I live in a dark world, where no light shines through');
  Sleep(100);
//  myIrcClient.Disconnect; // majd a free ugyis rendbetesz
end;

procedure TMyIrcThread.IrcPing(cumo: string);
begin
  IrcWrite('PONG '+cumo);
end;
procedure TMyIrcThread.IrcProcessCommand(channel, msg: string);
var cmd: string;
    i, c: integer;
    params: string;
begin
  cmd:= SubString(msg, ' ', 1);
  i:= FindIrcCommand(cmd);
  if i <> 0 then
  begin
    params:= Trim(RightStrv2(msg, length(cmd)+1));
    c:= Count(' ', params);
    if params <> '' then inc(c);

    if ((irccommands[i].minparams <> -1) and (irccommands[i].minparams > c)) then
    begin
      IrcSendPrivMessage(channel, 'Too few parameters.');
      exit;
    end;
    if ((irccommands[i].maxparams <> -1) and (irccommands[i].maxparams < c)) then
    begin
      IrcSendPrivMessage(channel, 'Too many parameters.');
      exit;
    end;

    TIRCCommandThread.Create(self, irccommands[i].hnd, channel, params);
  end;
end;
procedure TMyIrcThread.IrcPrivMsg(s: string);
var channel, msg, nick: string;
begin
  channel:= SubString(s, ' ', 3);
  nick:= Copy(s, 2, Pos('!', s)-2);
  if channel = nickname then // nickname az a sajat nickem amivel ircen vagyok
  begin
    //privat uzenet, ki kell hamozni a nikket
    channel:= nick;
  end;
  msg:= RightStrv2(s, Pos(' ', s));
  msg:= RightStrv2(msg, Pos(':', msg));

  if (1 = Pos('+OK ', msg)) then
  begin
    msg:= Trim(irc_decrypt(netname, channel, Copy(msg, 5, 1000)));
    Debug(dpSpam, section, 'PLAIN: '+msg);
  end;

  if ((netname = 'MAIN') and (channel = adminchan)) then
  begin
    if (1 = Pos(cmdprefix, msg)) then
    begin
      // commandhandlerrel kezdodik
      msg:= Copy(msg, length(cmdprefix)+1, 1000);
      IrcProcessCommand(channel, msg);
    end;
  end else
  begin
    PrecatcherProcess(netname, channel, nick, msg);
  end;
end;
procedure TMyIrcThread.IrcProcessLine(s: string);
var s1, s2, chan: string;
    b: TIrcBlowkey;
begin
  if s = '' then exit;

  irc_last_read:= Now();
  Debug(dpSpam, section, '<< '+s);
  if 1 = Pos('PING :', s) then
    IrcPing(Copy(s, 6, 1000))
  else                                   // MODES=
                                         //:End of /MOTD
  if ((registered = False) and (0 <> Pos(' 266 ', s))) then
    registered:= True
  else
  begin
    s1:= SubString(s, ' ', 1);

    if ((s1 = 'ERROR') and (netname <> 'MAIN')) then
    begin
  //  02-20 20:28:16.887 (12C8) [irc         ] << ERROR :Closing Link: 213.186.38.105 (*** Banned )
      irc_addtext(Format('<%s> %s', [netname, RightStrV2(s, 7)]));
    end;

    s2:= SubString(s, ' ', 2);

    if (0 = Pos(':'+nickname+'!', s)) then
    begin
      if (s2 = 'PRIVMSG') then
        IrcPrivMsg(s)
      else
      //:rsc!rsctm@coctail.sda.bme.hu INVITE rsctm :#femforgacs
      if (s2 = 'INVITE') then
      begin
        chan:= Copy(SubString(s, ' ', 4), 2, 1000);
        irc_lock.Enter;
        b:= FindIrcBlowfish(netname, chan, False) ;
        if nil <> b then
        begin
          // oke, ha hivtak hat belepunk
          myIrcClient.WriteLn(Trim('JOIN '+b.channel+' '+b.chankey));
        end;
        irc_lock.Leave;
      end
      //:rsc!rsctm@coctail.sda.bme.hu KICK #femforgacs rsctm :no reason
      else
      if (s2 = 'KICK') then
      begin
        if (SubString(s, ' ', 4) = nickname) then
        begin
          irc_lock.Enter;
          chan:= SubString(s, ' ', 3);
          if channels.IndexOf(chan) <> -1 then
            channels.Delete (channels.IndexOf(chan));
          status:= 'online ('+channels.DelimitedText+')';
          irc_lock.Leave;
        end;
      end;
    end
    else
    if (1 = Pos(':'+nickname+'!', s)) then
    begin
      //:rsctm!rsctm@catv-80-98-130-97.catv.broadband.hu JOIN :#akela
      if (s2 = 'JOIN') then
      begin
        irc_lock.Enter;
        channels.Add(Copy(SubString(s, ' ', 3), 2, 1000));
        status:= 'online ('+channels.DelimitedText+')';
        irc_lock.Leave;
      end else
      //:rsctm!rsctm@catv-80-98-130-97.catv.broadband.hu PART #akela :
      if (s2 = 'PART') then
      begin
        irc_lock.Enter;
        chan:= SubString(s, ' ', 3);
        if channels.IndexOf(chan) <> -1 then
          channels.Delete (channels.IndexOf(chan));
        status:= 'online ('+channels.DelimitedText+')';
        irc_lock.Leave;
      end;
    end;
  end;
end;
procedure TMyIrcThread.IrcSendPrivMessage(channel, plainmsgformat: string; const args: array of const);
begin
  IrcSendPrivMessage(channel, FormaT(plainmsgformat, args));
end;
procedure TMyIrcThread.IrcSendPrivMessage(channel, plainmsg: string);
begin
  irc_last_read:= Now();
  Debug(dpSpam, section, 'PLAIN: '+plainmsg);
  IrcWrite('PRIVMSG '+channel+' :'+ irc_encrypt(netname, channel, plainmsg, True) );
end;
function TMyIrcThread.IrcSendPrivMessage(oneliner: string): Boolean;
var channel, msg: string;
begin
  Result:= False;
  channel:= SubString(oneliner, ' ', 1);
  if channel = '' then exit;
  if ((channel[1] = '#') and (channels.IndexOf(channel) = -1)) then exit;
  msg:= Copy(oneliner, length(channel)+2, 1000);
  IrcSendPrivMessage(channel, msg);
  Result:= True;
end;

procedure TMyIrcThread.ShouldJoinGame;
var
    i: Integer;
    b: TIrcBlowkey;
    s: TSite;
    r: TRawTask;
    added: Boolean;
begin
      irc_lock.Enter;
      shouldjoin:= False;

      debug(dpSpam, section, 'ShouldJoinGame');

      // most akkor belepunk mindenhova illetve addoljuk az invite taskokat
      for i:= 0 to chankeys.Count-1 do
      begin
        b:= chankeys[i] as TIrcBlowkey;
        if ((b.netname = netname) and (-1 = channels.IndexOf(b.channel)) and (b.channel[1] = '#')) then
        begin
          // be kell lepni erre a csatornara
          if (not b.inviteonly) then // meghivot kene kuldeni
            myIrcClient.WriteLn(Trim('JOIN '+b.channel+' '+b.chankey));
        end;
      end;

      // itt pedig azt nezzuk kell e valahonnan partolni
      for i:= 0 to channels.Count -1 do
        if nil = FindIrcBlowfish(netname, channels[i], False) then
          myIrcClient.WriteLn('PART '+channels[i]);

      irc_lock.Leave;

      added:= False;
      queue_lock.Enter;
      for i:= 0 to sites.Count -1 do
      begin
        s:= sites[i] as TSite;
          if ((s.RCString('ircnet', '') = netname) and (not s.siteinvited)) then
          begin
            s.siteinvited:= True;
            r:= TRawTask.Create(s.name, '', 'SITE INVITE '+nickname);
            AddTask(r);
            added:= True;
          end;
      end;
      if added then
        QueueFire;
      queue_lock.Leave;
end;
procedure TMyIrcThread.IrcProcess;
var s: string;
//    s2: string;
    o: Integer;
    i: Integer;
begin
  while ((not kilepes) and (not Terminated) and (not shouldrestart) and (not shouldquit)) do
  begin



(*
    if o > 0 then
    begin
      s:= myIrcClient.ReadString(o);
      o:= 1;
      while true do
      begin
        s2:= SubString(s, EOL, o);
        if s2= '' then Break;

        IrcProcessLine(s2);
        inc(o);
      end;
    end;
*)

    if shouldjoin then
      ShouldJoinGame();

    o:= myIrcClient.ReadFromStack(True, flood, False);
    while ((o > 0) or ((o <> myIrcClient.InputBuffer.Size) and (0 < myIrcClient.InputBuffer.Size))) do
    begin
      s:= myIrcClient.ReadLn();
      dec(o, length(s)+2);
      IrcProcessLine(s);
    end;

    irc_lock.Enter;
    i:= 0;
    while(i < irc_queue.Count) do
    begin
      if (irc_queue_nets[i] = netname) then
      begin
        if IrcSendPrivMessage(irc_queue[i]) then
        begin
          irc_queue.Delete(i);
          irc_queue_nets.Delete(i);
          Break;
        end;
      end;
      inc(i);
    end;
    irc_lock.Leave;

    if SecondsBetween(Now, irc_last_read) > config.ReadInteger(section, 'timeout', 120) then
      raise Exception.Create('IRC Server didnt PING, it might be down');    
  end;
end;

procedure TMyIrcThread.IrcRegister;
var i, o: Integer;
    s, key: string;
begin
  registered:= False;
  status:= 'registering...';

  for i:= 1 to (config.ReadInteger(section, 'register_timeout', 10) * 2) do
  begin

    o:= myIrcClient.ReadFromStack(True, 500, False);
    while ((o > 0) or ((o <> myIrcClient.InputBuffer.Size) and (0 < myIrcClient.InputBuffer.Size))) do
    begin
      s:= myIrcClient.ReadLn();
      dec(o, length(s)+2);
      IrcProcessLine(s);
    end;

    if registered then Break;
  end;

  if not registered then
    raise Exception.Create('IRC Not registered within io timeout');

  status:= 'online...';

	if (config.ReadBool(section, 'manglehost', False) ) then
    IrcWrite('MODE '+nickname+' +h');

  //joinolni is kell meg
  if netname = 'MAIN' then
  begin
    key:= config.ReadString(section, 'chan_key', '');
    if key <> '' then
      IrcWrite('JOIN '+adminchan+' '+key)
    else
      IrcWrite('JOIN '+adminchan);
  end;
end;

procedure TMyIrcThread.ClearSiteInvited;
var s: TSite;
    i: Integer;
begin
  queue_lock.Enter;
  for i:= 0 to sites.Count -1 do
  begin
    s:= TSite(sites[i]);
    if s.RCString('ircnet', '') = netname then
      s.siteinvited:= False;
  end;
  queue_lock.Leave;  
end;

procedure TMyIrcThread.Execute;
var i, m: Integer;
begin
  if (netname = 'MAIN') then
    irc_Addtext(config.ReadString(section, 'chan_name', ''), '%s started', [Red(Get_VersionString(ParamStr(0)))]);
  while ((not kilepes) and (not Terminated) and (not shouldquit)) do
  begin
    try
      shouldrestart:= False;
      shouldjoin:= True;
      channels.Clear;

      ClearSiteInvited;

      IrcSetupSocket;
      IrcConnect;

      IrcRegister;
      IrcProcess;

      IrcQuit;
    except on E: Exception do
      begin
        Debug(dpError, section, e.Message);
        m:= config.ReadInteger(section, 'sleep_on_error', 60);
        for i:= 1 to m do
          if ((not kilepes) and (not Terminated) and (not shouldquit)) then
            Sleep(1000);
      end;
    end;
  end;
end;

procedure IrcInit;
begin
  myIrcThreads:= TObjectList.Create(False);
  irc_queue:= TStringList.Create;
  irc_queue_nets:= TStringList.Create;
  irc_lock:= TCriticalSection.Create;
end;

procedure IrcUnInit;
begin
  irc_lock.Free;
  irc_queue.Free;
  irc_queue_nets.Free;
  myIrcThreads.Free;
end;


procedure Announce(section: string; error: Boolean; s: string);
begin
  s:= Trim(s);
  if s <> '' then
  begin
    Debug(dpMessage, section, s);
    if s <> '' then
    begin
      if error then
        s:= Red(s);
        
      irc_Addtext(s);
    end;
  end;
end;

procedure Announce(section: string; error: Boolean; formatStr: string; const args: array of const);
begin
  Announce(section, error, Format(formatStr, args));
end;


function TMyIrcThread.getHost: string;
begin
  Result:= myIrcClient.Host;
end;

function TMyIrcThread.getPort: Integer;
begin
  Result:= myIrcClient.Port;
end;

initialization
  IrcInit;
finalization
  IrcUninit;
end.

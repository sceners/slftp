unit sitesunit;

interface

uses Classes, encinifile, md5, Contnrs, IdTCPClient, SyncObjs, tasksunit;

type
  TSlotStatus = (ssNone, ssDown, ssOffline, ssOnline);
  TSSLMethods = (sslNone, sslImplicit, sslSSLv23, sslTLSv1);
  TSiteSw = (sswUnknown, sswGlftpd, sswDrftpd, sswIoftpd);
  TProtection = (prNone, prProtP, prProtC);
  TSiteStatus = (sstUnknown, sstUp, sstDown);
  TSSLReq = (srNone, srNeeded, srUnsupported);
  TReadStatus = (rsException, rsTimeout, rsRead);

  TSite = class; // forward
  TSiteSlot = class(TThread)
  private
    myTCPClient: TIdTCPClient;
    lastdir2: string;
    aktdir: string;
    prot: TProtection;
    kilepve: Boolean;
    no: Integer;
    fstatus: TSlotStatus;
    event: TEvent;
    function LoginBnc(i: Integer; kill: Boolean = False): Boolean;
    procedure AddLoginTask;
    procedure SetOnline(value: TSlotStatus);
    procedure ProcessFeat;
  public
    localport: Integer;
    peerport: Integer;
    peerip: string;
    uploadingto: Boolean;
    downloadingfrom: Boolean;
    lastio: TDateTime;
    lastactivity: TDateTime;
    lastResponse: string;
    lastResponseCode: Integer;

    todotask: TTask;
    lepjki: Boolean;
    site: TSite;
    procedure DestroySocket(down: Boolean);
    procedure Quit;
    function Name: string;
    procedure Fire;
    function Login(kill: Boolean = False): boolean;
    procedure Execute; override;
    constructor Create(site: TSite; no: Integer);
    destructor Destroy; override;
    function RCBool(name: string; def: Boolean): Boolean;
    function RCInteger(name: string; def: Integer): Integer;
    function RCString(name, def: string): string;

    function ReadB(raiseontimeout: Boolean = True; raiseonclose: Boolean = True; timeout: Integer = 0): TReadStatus; overload;
    function Read(raiseontimeout: Boolean = True; raiseonclose: Boolean = True; timeout: Integer = 0): Boolean; overload;
    function Send(s: string): Boolean; overload;
    function Send(s: string; const Args: array of const): Boolean; overload;
    function ReLogin(hanyszor: Integer = 0; kill: Boolean = False): boolean;
    function bnc: string;
    function Cwd(dir: string; force: Boolean = False): Boolean;
    function Dirlist(dir1, dir2: string): Boolean; overload;
    function Dirlist(dir: string; forcecwd: Boolean=False): Boolean; overload;
    function RemoveFile(dir, filename: string): Boolean;
    function RemoveDir(dir: string): Boolean;
    function SendProtP: Boolean;
    function SendProtC: Boolean;
    function Mkdir(maindir, aktdir: string): Boolean;
  published
    property Status: TSlotStatus read fstatus write SetOnline;
  end;
  TSite = class
  private
    fworking: TSiteStatus;
    foutofannounce: TDateTime;
    fkreditz: TDateTime;


    procedure WaitForSlot(slot: TSiteSlot);
    procedure SetWorking(value: TSiteStatus);

    function GetMaxDn: Integer;
    procedure SetMaxDn(value: Integer);
    function GetMaxUp: Integer;
    procedure SetMaxUp(value: Integer);
    function GetMaxIdle: Integer;
    procedure SetMaxIdle(value: Integer);
    function GetIdleInterval: Integer;
    procedure SetIdleInterval(value: Integer);
    function GetIo_timeout: Integer;
    procedure SetIo_timeout(const value: Integer);
    function GetConnect_timeout: Integer;
    procedure SetConnect_timeout(const value: Integer);
    function Getsslmethod: TSSLMethods;
    procedure Setsslmethod(const Value: TSSLMethods);
    function Getsslfxp: TSSLReq;
    procedure Setsslfxp(const Value: TSSLReq);
    procedure WCBool(name: string; val: Boolean);
    function GetPrecmd: string;
    function GetPredir: string;
    procedure SetPrecmd(const Value: string);
    procedure SetPredir(const Value: string);
    function Getlegacydirlist: Boolean;
    procedure Setlegacydirlist(const Value: Boolean);
    function GetSectionDir(name: string): string;
    procedure SetSectionDir(name: string; const Value: string);
    function GetSectionAffil(name: string): string;
    procedure SetSectionAffil(name: string; const Value: string);
    function GetSections: string;
    procedure SettSections(value: string);
    function GetLeechers: string;
    procedure SettLeechers(value: string);
    function GetTraders: string;
    procedure SettTraders(value: string);
    function GetUsers: string;
  public
    emptyQueue: Boolean;
    markeddown: Boolean;
    siteinvited: Boolean;

    name: string;
    slots: TObjectList;

//    siteinvited: Boolean;

    constructor Create(name: string);
    destructor Destroy; override;
    procedure DeleteKey(name: string);
    function RCBool(name: string; def: Boolean): Boolean;
    function RCInteger(name: string; def: Integer): Integer;
    function RCString(name, def: string): string;
    procedure WCInteger(name: string; val: Integer);
    procedure WCString(name: string; val: string);
    procedure SetOutofSpace;
    procedure SetKredits;

    procedure AutoBnctest;
    procedure AutoDirlist;
    procedure Auto;

    function FreeLeechSlots: Integer;    
    function FreeTraderSlots: Integer;
    function SetSections(sections: string; remove: Boolean = False): string;
    function SetLeechers(users: string; remove: Boolean): string;
    function SetTraders(users: string; remove: Boolean): string;
    function IsSection(section: string): Boolean;
    function IsAffil(section, affil: string): Boolean;
    function SetAffils(section, affils: string; remove: Boolean = False): string;
    function IsUser(user: string): Boolean;
    property sections: string read GetSections write SettSections;
    property leechers: string read GetLeechers write SettLeechers;
    property traders: string read GetTraders write SettTraders;
    property users: string read GetUsers;
    property sectiondir[name: string]: string read GetSectionDir write SetSectionDir;
    property sectionaffil[name: string]: string read GetSectionAffil write SetSectionAffil;
  published
    property working: TSiteStatus read fWorking write SetWorking;
    property max_dn: Integer read GetMaxDn write SetMaxDn;
    property max_up: Integer read GetMaxUp write SetMaxUp;
    property maxidle: Integer read Getmaxidle write Setmaxidle;
    property idleinterval: Integer read Getidleinterval write Setidleinterval;

    property io_timeout: Integer read Getio_timeout write Setio_timeout;
    property connect_timeout: Integer read Getconnect_timeout write Setconnect_timeout;
    property sslmethod: TSSLMethods read Getsslmethod write Setsslmethod;
    property sslfxp: TSSLReq read Getsslfxp write Setsslfxp;
    property legacydirlist: Boolean read Getlegacydirlist write Setlegacydirlist;
    property predir: string read GetPredir write SetPredir;
    property precmd: string read GetPrecmd write SetPrecmd;
  end;

function ReadSites(pw: TMD5Digest): Boolean;
procedure SitesStart;
procedure SlotsFire;
procedure SiteAutoStart;

function FindSiteByName(sitename: string): TSite;
function FindSlotByName(slotname: string): TSiteSlot;
procedure SetupSocket(tcpClient: TIdTCPClient; atereszt: Boolean = True);

var sitesdat: TEncIniFile = nil;
    sites: TObjectList;

implementation

uses SysUtils, irc, tasklogin, DateUtils, configunit, queueunit, debugunit,
  IdSSLOpenSSL, socks5, console, taskautodirlist,
  IdTCPConnection, mystrings, versioninfo, mainthread, IniFiles,
  IdSocketHandle;
const section='sites';

var sitelaststart: TDateTime;
    bnccsere: TCriticalSection;

procedure SetupSocket(tcpClient: TIdTCPClient; atereszt: Boolean = True);
begin
  if tcpClient.IOHandler = nil then
  begin
    tcpClient.IOHandler:= TIdSSLIOHandlerSocket.Create(tcpClient);
    with tcpClient.IOHandler as TIdSSLIOHandlerSocket do
    begin
      SSLOptions.Method:= sslvSSLv23;
      PassThrough:= atereszt;
    end;
  end;

  SetupSocks5(tcpClient);
end;

// NOTE: ez a fuggveny hivasahoz lokkolni KELL eloszor a mindensegit
function FindSiteByName(sitename: string): TSite;
var i: Integer;
begin
  Result:= nil;
  for i:= 0 to sites.Count-1 do
    if TSite(sites[i]).name = sitename then
    begin
      Result:= TSite(sites[i]);
      exit;
    end;
end;

function FindSlotByName(slotname: string): TSiteSlot;
var i, j: Integer;
begin
  Result:= nil;
  for i:= 0 to sites.Count-1 do
    for j:= 0 to TSite(sites[i]).slots.Count-1 do
      if TSiteSlot(TSite(sites[i]).slots[j]).name = slotname then
      begin
        Result:= TSiteSlot(TSite(sites[i]).slots[j]);
        exit;
      end;
end;


function ReadSites(pw: TMD5Digest): Boolean;
var sitesdatfile: string;
begin
  Result:= False;
  sitesdatfile:= config.ReadString(section, 'sites_dat', 'sites.dat');
  if not FileExists(sitesdatfile) then
  begin
    Debug(dpError, section, 'sites.dat not exists, creating it');
    sitesdat:= TEncIniFile.Create(sitesdatfile, pw, True);
    sitesdat.WriteString(section, 'default', 'exists');
    sitesdat.UpdateFile;
    Result:= True;
  end else
  begin
    try
      sitesdat:= TEncIniFile.Create(sitesdatfile, pw);
      if sitesdat.ReadString(section, 'default', '') = 'exists' then
      begin
        sitesdat.autoupdate:= True;
        Result:= True;        
      end;
    except
    end;
  end;
end;



procedure SitesInit;
begin
  sitelaststart:= Now();
  bnccsere:= TCriticalSection.Create;
  sites:= TObjectList.Create;
end;
procedure SitesUninit;
begin
  if sitesdat <> nil then
  begin
    sitesdat.Free;
    sitesdat:= nil;
  end;

  if sites <> nil then
  begin
    sites.Free;
    sites:= nil;
  end;

  bnccsere.Free;
end;

{ TSiteSlot }

procedure TSiteSlot.AddLoginTask;
var t: TLoginTask;
begin
  if(sitelaststart <> 0) then
  begin
    bnccsere.Enter;
    sitelaststart:= IncMilliSecond(sitelaststart, 333);
    bnccsere.Leave;
  end;
  t:= TLoginTask.Create(site.name, False, False);
  t.wantedslot:= name;
  t.startat:= sitelaststart;
  AddTask(t);
end;

constructor TSiteSlot.Create(site: TSite; no: Integer);
begin
  self.site:= site;
  self.no:= no;
  debug(dpSpam, section, 'Slot %s is creating', [name]);

  todotask:= nil;
  event:= TEvent.Create(nil, False, False, Name);
  myTCPClient:= TIdTCPClient.Create(nil);
  kilepve:= False;

  uploadingto:= False;
  downloadingfrom:= False;
  aktdir:= '';
  prot:= prNone;
  status:= ssNone;
  lastResponse:= '';
  lastResponseCode:= 0;
  lastio:= Now();
  lastactivity:= Now();
  lepjki:= False;

  // ha autologin be van kapcsolva akkor
  if ((config.ReadBool(section, 'autologin', False)) or (RCBool('autologin', False))) then
    AddLoginTask;

  debug(dpSpam, section, 'Slot %s has created', [name]);
  inherited Create(False);
end;

function TSiteSlot.Name: string;
begin
  Result:= site.name+'/'+IntToStr(no);
end;
procedure TSiteSlot.DestroySocket(down: Boolean);
begin
  try
    if myTcpClient.Connected then
      myTcpClient.Disconnect;

    if myTcpClient.IOHandler <> nil then
    begin
      myTcpClient.IOHandler.Free;
      myTcpClient.IOHandler:= nil;
    end;

   finally
      Console_Slot_Close(self);

      prot:= prNone;
      aktdir:= '';

      if down then
        status:= ssDown
      else
        status:= ssOffline;
    end;
end;
procedure TSiteSlot.Execute;
begin
  Debug(dpSpam, section, 'Slot %s has started', [name]);
  while ((not kilepes) and  (not lepjki)) do// and (not False)
  begin
    try
      if status = ssOnline then
        Console_Slot_Add(self, True, name, 'Idle...', []);

      if todotask <> nil then
      begin
        if todotask.Execute(self) then
          lastactivity:= Now();

        uploadingto:= False;
        downloadingfrom:= False;
        if todotask.slot2 = self then // vagyis vegzett a slot2 is
          todotask.slot2:= nil;
        todotask:= nil;
        queue_lock.Enter;
        QueueFire;
        queue_lock.Leave;        
      end
      else
        event.WaitFor($FFFFFFFF);

    except
      on E: Exception do
      begin
        Debug(dpError, section, 'Slot %s exception %s', [Name, e.Message]);
      end;
    end;
  end;
  kilepve:= True;
end;

destructor TSiteSlot.Destroy;
begin
  DestroySocket(True);
  myTCPClient.Free;
  event.Free;
  inherited;
end;


function TSiteSlot.SendProtC: Boolean;
begin
  Result:= False;
  if prot <> prProtC then
  begin
    if not Send('PROT C') then exit;
    if not Read() then exit;

    prot:= prProtC;
  end;
  Result:= True;
end;

function TSiteSlot.SendProtP: Boolean;
begin
  Result:= False;
  if prot <> prProtP then
  begin
    if not Send('PROT P') then exit;
    if not Read() then exit;

    prot:= prProtP;
  end;
  Result:= True;
end;

procedure TSiteSlot.ProcessFeat;
begin
  if (0 < Pos('PRET', lastResponse)) then
    sitesdat.WriteInteger('site-'+site.name, 'sw', Integer(sswDrftpd))
  else
  if (0 < Pos('CPSV', lastResponse)) then
    sitesdat.WriteInteger('site-'+site.name, 'sw', Integer(sswGlftpd));
end;

function TSiteSlot.Cwd(dir: string; force: Boolean = False): Boolean;
begin
  Result:= False;
  if dir <> aktdir then
  begin
    if ((site.legacydirlist) or (force)) then
    begin
      if not Send('CWD %s', [dir]) then exit;
      if not Read() then exit;
      if (lastResponseCode = 250) then
      begin
        if dir[1] <> '/' then
          aktdir:= MyIncludeTrailingSlash(aktdir) + dir
        else
          aktdir:= dir;
      end
      else
      begin
        Announce(section, True, '%s: %s', [name, trim(lastResponse)]);
        exit;
      end;
    end else
      aktdir:= dir;
  end;
  Result:= True;
end;

function TSiteSlot.LoginBnc(i: Integer; kill: Boolean = False): Boolean;
var sslm: TSSLMethods;
    b: Boolean;
    un: string;
begin
  Result:= False;
  SetupSocket(myTCPClient);



  // elso lepes a connect
  try
    myTCPClient.Host:= RCString('bnc_host-'+IntToStr(i), '');
    myTCPClient.Port:= RCInteger('bnc_port-'+IntToStr(i), 0);
    myTCPClient.Connect(site.connect_timeout*1000);

    peerport:= myTCPClient.Socket.Binding.PeerPort;
    peerip:= myTCPClient.Socket.Binding.PeerIP;
    localport:= myTCPClient.Socket.Binding.Port;

    sslm:= TSSLMethods(site.sslmethod);

    if sslm = sslImplicit then
      (myTCPClient.IOHandler as TIdSSLIOHandlerSocket).PassThrough:= False;


  // banner
  if not Read() then exit;
  if(lastResponseCode <> 220) then
    raise Exception.Create(Trim(lastResponse));

  if (sslm in [sslSSLv23, sslTLSv1]) then
  begin
    b:= False;
    if sslm = sslTLSv1 then
    begin
      // AUTH TLS-t probalunk
      if not Send('AUTH TLS') then exit;
      if not Read() then exit;

      if lastResponseCode = 234 then
      begin
        (myTCPClient.IOHandler as TIdSSLIOHandlerSocket).PassThrough:= False;
        b:= True; // siker
      end;
    end;

    if not b then
    begin
      // AUTH SSL-t probalunk
      if not Send('AUTH SSL') then exit;
      if not Read() then exit;

      if lastResponseCode = 234 then
        (myTCPClient.IOHandler as TIdSSLIOHandlerSocket).PassThrough:= False
      else
        Debug(dpMessage, section, '%s: PLAINTEXT CONNECTION', [name]);
    end;
  end;

  un:= RCString('username', 'anonymous');
  if(kill) then un:= '!'+un;

  if not Send('USER %s', [un]) then exit;
  if not Read then exit;

  if lastResponseCode <> 331 then
    raise Exception.Create(Trim(lastResponse));

  if not Send('PASS %s', [RCString('password', 'foo@foobar.hu')]) then exit;
  if not Read then exit;

  if lastResponseCode <> 230 then
    raise Exception.Create(Trim(lastResponse));


  if not Send('TYPE I') then exit;
  if not Read then exit;


  if(TSiteSw(RCInteger('sw', 0)) = sswUnknown) then
  begin
    if not Send('FEAT') then exit;
    if not Read() then exit;

	  ProcessFeat();
  end;

  if not Send('SITE XDUPE 3') then exit;
  if not Read then exit;

  if (site.sslfxp = srNeeded) then
  begin
    if (not SendProtP()) then exit;
  end;



   if (TSiteSw(RCInteger('sw', 0)) = sswDrftpd) then
   begin
      if ( not Send('CLNT %s', [Get_VersionString(ParamStr(0))])) then exit;
      if (not Read()) then exit;
   end;

   if(site.predir <> '') then
   begin
     if not Cwd(site.predir) then
       if status = ssDown then exit;
   end;

    // siker
    Result:= True;
    // Announce(section, False, 'SLOT %s IS UP: %s', [name, bnc]);
    status:= ssOnline;

    // modositjuk is a top1 bnc-t erre:
    if i <> 0 then
    begin
      bnccsere.Enter;
      sitesdat.WriteString('site-'+site.name, 'bnc_host-'+IntToStr(i), RCString('bnc_host-0', ''));
      sitesdat.WriteInteger('site-'+site.name, 'bnc_port-'+IntToStr(i), RCInteger('bnc_port-0', 0));

      sitesdat.WriteString('site-'+site.name, 'bnc_host-0', myTCPClient.Host);
      sitesdat.WriteInteger('site-'+site.name, 'bnc_port-0', myTCPClient.Port);
      bnccsere.Leave;      
    end;
  except
    on e: Exception do
    begin
      Announce(section, True, '%s@%s:: %s', [name, bnc, e.Message]);
      DestroySocket(False);
    end;
  end;
end;


function TSiteSlot.Login(kill: Boolean = False): boolean;
var host: string;
    i: Integer;
begin
  Result:= False;

    i:= 0;
    while (not kilepes) do
    begin
      host:= RCString('bnc_host-'+IntToStr(i), '');
      if host = '' then break;

      Result:= LoginBnc(i, kill);
      if Result then Break;
      inc(i);
    end;

  if not kilepes then
    if not Result then
    begin
      DestroySocket(False);
      Announce(section, True, 'SLOT %s IS DOWN', [Name]);
    end;
end;

function TSiteSlot.ReLogin(hanyszor: Integer = 0; kill: Boolean = False): boolean;
var maxrelogins: Integer;
    relogins: Integer;
begin
  Result:= False;
  Debug(dpSpam, section, 'Relogin '+name+' '+IntToStr(hanyszor));
  if hanyszor = 0 then
    maxrelogins:= config.ReadInteger(section, 'maxrelogins', 3)
  else
    maxrelogins:= hanyszor;

  relogins:= 0;
  while ((relogins < maxrelogins) and (not kilepes)) do
  begin
    Result:= Login(kill);
    if Result then
      Break;

    inc(relogins);
  end;

  if not kilepes then
    if not Result then
      site.working:= sstDown;
end;

procedure TSiteSlot.Fire;
begin
  event.SetEvent;
end;

function TSiteSlot.Read(raiseontimeout: Boolean = True; raiseonclose: Boolean = True; timeout: Integer = 0): Boolean;
begin
  Result:= ReadB(raiseontimeout, raiseonclose, timeout) = rsRead;
end;
function TSiteSlot.ReadB(raiseontimeout: Boolean = True; raiseonclose: Boolean = True; timeout: Integer = 0): TReadStatus;
label ujra;
var o: Integer;
    aktread: string;
begin
  lastResponse:= '';
  lastResponseCode:= 0;
  Result:= rsException;
  if timeout = 0 then timeout:= site.io_timeout * 1000;
  try
ujra:
    o:= myTCPClient.ReadFromStack(True, timeout, raiseontimeout);
    if ((o <> myTCPClient.InputBuffer.Size) and (0 < myTCPClient.InputBuffer.Size)) then
      o:= myTCPClient.InputBuffer.Size;

    if o > 0 then
    begin
      aktread:= myTCPClient.ReadString(o);
      lastResponse:= lastResponse + aktread;
      Debug(dpSpam, 'protocol', name+' <<'+#13#10+aktread);
      lastResponseCode:= ParseResponseCode(lastResponse);

      if ((lastResponseCode >= 1000) or (lastResponseCode < 100)) then
        // auto read more
        goto ujra;

      lastio:= Now();

      Result:= rsRead;
    end else
      Result:= rsTimeout;
  except on E: Exception do
    begin
      DestroySocket(False);
      if raiseOnClose then
        Announce(section, True, '%s: %s (%s)', [name, e.Message, bnc]);
    end;
  end;
end;

function TSiteSlot.Send(s: string): Boolean;
begin
  Result:= False;
  Console_Slot_Add(self, True, name, '%s', [s]);
  try
    myTCPClient.WriteLn(s);
    Debug(dpSpam, 'protocol', name+' >>'+#13#10+s);
    lastio:= Now();
    Result:= True;
  except on E: Exception do
    begin
      Announce(section, True, '%s: %s', [name, e.Message]);
      DestroySocket(False);
    end;
  end;
end;

function TSiteSlot.Send(s: string; const Args: array of const): Boolean;
begin
  Result:= Send(Format(s, Args));
end;

function TSiteSlot.RCInteger(name: string; def: Integer): Integer;
begin
  Result:= site.RCInteger(name, def);
end;

function TSiteSlot.RCString(name, def: string): string;
begin
  Result:= site.RCString(name, def);
end;

procedure TSiteSlot.SetOnline(value: TSlotStatus);
begin
  fStatus:= value;

  if (fStatus = ssOnline) then
    site.working:= sstUp;
end;

function TSiteSlot.bnc: string;
begin
  Result:= myTCPClient.Host+':'+IntToStr( myTCPClient.Port);
end;

procedure TSiteSlot.Quit;
begin
  if status <> ssOnline then exit;

  if (not Send('QUIT')) then exit;
  Read(False, False);
  DestroySocket(False);
end;

function TSiteSlot.RCBool(name: string; def: Boolean): Boolean;
begin
  Result:= site.RCBool(name, def);
end;

function TSiteSlot.RemoveFile(dir, filename: string): Boolean;
var cmd: string;
begin
  Result:= False;
  if site.legacydirlist then
  begin
    if not Cwd(dir) then exit;
    cmd:= 'DELE '+filename;
  end else
    cmd:= 'DELE '+MyIncludeTrailingSlash(dir)+filename;

  if not Send(cmd) then exit;
  if not Read() then exit;

  Result:= True;
end;
function TSiteSlot.RemoveDir(dir: string): Boolean;
var cmd: string;
    feljebb: string;
begin
  Result:= False;
  if dir[Length(dir)] = '/' then dir:= Copy(dir, 1, Length(dir)-1);
  if site.legacydirlist then
  begin
    feljebb:= Copy(dir, 1, Rpos('/', dir));
    if not Cwd(feljebb) then exit;
    cmd:= 'RMD '+Copy(dir, Rpos('/', dir)+1,1000)
  end else
    cmd:= 'RMD '+dir;

  if not Send(cmd) then exit;
  if not Read() then exit;

  Result:= True;
end;


function TSiteSlot.Mkdir(maindir, aktdir: string): Boolean;
var dir: string;
begin
  Result:= False;
  if (site.legacydirlist)  then
  begin
    if not Cwd(maindir) then exit;
    dir:= aktdir;
  end else
    dir:= MyIncludeTrailingSlash(maindir)+aktdir;
  if not Send('MKD %s', [dir]) then exit;
  if not Read() then exit;
  Result:= True;
end;
function TSiteSlot.Dirlist(dir1, dir2: string): Boolean;
var fulldir: string;
begin
  Result:= False;
  fulldir:= MyIncludeTrailingSlash(dir1)+dir2;
  if ((fulldir <> aktdir) and (site.legacydirlist)) then
  begin
    if not Cwd(dir1, dir2 <> lastdir2) then exit;
    lastdir2:= dir2;
    Result:= Dirlist(dir2, False);
  end else
    Result:= Dirlist(fulldir, False);
end;

function TSiteSlot.Dirlist(dir: string; forcecwd: Boolean=False): Boolean;
var cmd: string;
begin
  Result:= False;
  if ((site.legacydirlist) or (forcecwd)) then
  begin
    if not Cwd(dir, forcecwd) then exit;
    cmd:= 'STAT -l';
  end else
    cmd:= 'STAT -l '+MyIncludeTrailingSlash(dir);

  if not Send(cmd) then exit;
  if not Read() then exit;

  Result:= True;
end;

{ TSite }

constructor TSite.Create(name: string);
var i: Integer;
begin
//  siteinvited:= False;
  
  debug(dpSpam, section, 'Site %s is creating', [name]);
  foutofannounce:= 0;
// nullazni a felfedezendo beallitasokat
  sitesdat.WriteInteger('site-'+name, 'sw', Integer(sswUnknown));
  working:= sstUnknown;

  self.name:= name;


  slots:= TObjectList.Create(False);
  for i:= 1 to RCInteger('slots', 2) do
    slots.Add(TSiteSlot.Create(self, i-1));

  // rakjuk rendbe a direket
  if ((RCString('predir', '') <> '') and (sectiondir['PRE'] = '')) then
  begin
    sectiondir['PRE']:= RCString('predir', '');
    sitesdat.DeleteKey('site-'+self.name, 'predir');
  end;


  debug(dpSpam, section, 'Site %s has created', [name]);
end;

procedure TSite.WaitForSlot(slot: TSiteSlot);
begin
  slot.lepjki:= True;
  slot.event.SetEvent;
  while not slot.kilepve do sleep(100);
end;

destructor TSite.Destroy;
var i: Integer;
begin
  for i:= 0 to slots.Count -1 do
  begin
    WaitForSlot(slots[i] as TSiteSlot);
    slots[i].Free;
    slots[i]:= nil;
  end;
  slots.Free;
  inherited;
end;

procedure SitesStart;
var x: TStringList;
    i: Integer;
begin
  queue_lock.Enter;
  x:= TStringList.Create;
  sitesdat.ReadSections(x);
  for i:= 0 to x.Count -1 do
    if 1 = Pos('site-', x[i]) then
      sites.Add(TSite.Create(Copy(x[i], 6, 1000)));
  x.Free;
  queue_lock.Leave;
  sitelaststart:= 0;  
end;


procedure SlotsFire;
var i, j: Integer;
begin
  queue_lock.Enter;
  for i:= 0 to sites.Count-1 do
    for j:= 0 to TSite(sites[i]).slots.Count-1 do
      TSiteSlot(TSite(sites[i]).slots[j]).Fire;
      
  queue_lock.Leave;
end;

function TSite.RCString(name: string; def: string): string;
begin
  Result:=  sitesdat.ReadString('site-'+self.name, name, def);
end;

function TSite.RCInteger(name: string; def: Integer): Integer;
begin
  Result:=  sitesdat.ReadInteger('site-'+self.name, name, def);
end;


function TSite.RCBool(name: string; def: Boolean): Boolean;
begin
  Result:=  sitesdat.ReadBool('site-'+self.name, name, def);
end;

procedure SiteStat;
var i: Integer;
    allsites, upsites, downsites, unknown: Integer;
begin
  allsites:= 0;
  upsites:= 0;
  downsites:= 0;
  unknown:= 0;
  queue_lock.Enter;
  for i:= 0 to sites.Count -1 do
  begin
    case TSite(sites[i]).working of
      sstUnknown: inc(unknown);
      sstUp: inc(upsites);
      sstDown: inc(downsites);
    end;
    inc(allsites);
  end;
  queue_lock.Leave;

  Console_SiteStat(allsites, upsites, downsites, unknown);
end;

procedure TSite.SetWorking(value: TSiteStatus);
begin
  if value <> fWorking then
  begin
    fWorking:= value;

    if value = sstUp then
    begin
      Announce(section, False, 'SITE %s IS UP', [name]);
      markeddown:= False;
    end
    else
    if value = sstDown then
    begin
      Announce(section, True, 'SITE %s IS DOWN', [name]);
    end;

    SiteStat;
  end;

  if value = sstDown then
  begin
    queue_lock.Enter;
    QueueEmpty(name);
    queue_lock.Leave;
  end;
end;


function TSite.Getconnect_timeout: Integer;
begin
  Result:= RCInteger('connect_timeout', 15);
end;


function TSite.GetIdleInterval: Integer;
begin
  Result:= RCInteger('idleinterval', 20);
end;

function TSite.Getio_timeout: Integer;
begin
  Result:= RCInteger('io_timeout', 10);
end;

function TSite.GetMaxDn: Integer;
begin
  Result:= RCInteger('max_dn', 2);
end;

function TSite.GetMaxIdle: Integer;
begin
  Result:= RCInteger('max_idle', 120);
end;

function TSite.GetMaxUp: Integer;
begin
  Result:= RCInteger('max_up', 2);
end;

procedure TSite.Setconnect_timeout(const Value: Integer);
begin
  WCInteger('connect_timeout', Value);
end;

procedure TSite.SetIdleInterval(value: Integer);
begin
  WCInteger('idleinterval', Value);
end;

procedure TSite.Setio_timeout(const Value: Integer);
begin
  WCInteger('io_timeout', Value);
end;

procedure TSite.SetMaxDn(value: Integer);
begin
  WCInteger('max_dn', Value);
end;

procedure TSite.SetMaxIdle(value: Integer);
begin
  WCInteger('max_idle', Value);
end;

procedure TSite.SetMaxUp(value: Integer);
begin
  WCInteger('max_up', Value);
end;

function TSite.Getsslmethod: TSSLMethods;
begin
  Result:= TSSLMethods(RCInteger('sslmethod', Integer(sslTLSv1)));
end;

procedure TSite.Setsslmethod(const Value: TSSLMethods);
begin
  WCInteger('sslmethod', Integer(Value));
end;

procedure TSite.WCBool(name: string; val: Boolean);
begin
  sitesdat.WriteBool('site-'+self.name, name, val);
end;
procedure TSite.WCInteger(name: string; val: Integer);
begin
  sitesdat.WriteInteger('site-'+self.name, name, val);
end;
procedure TSite.WCString(name: string; val: string);
begin
  sitesdat.WriteString('site-'+self.name, name, val);
end;

function TSite.Getsslfxp: TSSLReq;
begin
  Result:= TSSLReq(RCInteger('sslfxp', 0));
end;

procedure TSite.Setsslfxp(const Value: TSSLReq);
begin
  WCInteger('sslfxp', Integer(Value));
end;

function TSite.GetPrecmd: string;
begin
  Result:= RCString('precmd', '');
end;

function TSite.GetPredir: string;
begin
  Result:= sectiondir['PRE'];
end;

procedure TSite.SetPrecmd(const Value: string);
begin
  WCString('precmd', Value);
end;

procedure TSite.SetPredir(const Value: string);
begin
  sectiondir['PRE']:= Value;
end;

function TSite.Getlegacydirlist: Boolean;
begin
  Result:= RCBool('legacycwd', True);

end;

procedure TSite.Setlegacydirlist(const Value: Boolean);
begin
  WCBool('legacycwd', Value);

end;

procedure TSite.SetOutofSpace;
begin
  if ((foutofannounce = 0) or (HoursBetween(Now, foutofannounce) >= 1)) then
  begin
    foutofannounce:= Now();
    Announce(section, True, 'Site %s is out of disk space.', [name]);
  end;
end;

procedure TSite.SetKredits;
begin
  if ((fkreditz = 0) or (HoursBetween(Now, fkreditz) >= 1)) then
  begin
    fkreditz:= Now();
    Announce(section, True, 'Site %s is out of credits.', [name]);
  end;

end;

function TSite.GetSectionDir(name: string): string;
begin
  Result:= RCString('dir-'+name, '')
end;

procedure TSite.SetSectionDir(name: string; const Value: string);
begin
  if Value <> '' then
    WCString('dir-'+name, Value)
  else
  begin
    DeleteKey('dir-'+name);
  end;
end;

function TSite.GetSections: string;
begin
  Result:= RCString('sections', '');
end;
procedure TSite.SettSections(value: string);
begin
  WCString('sections', value);
end;

procedure TSite.DeleteKey(name: string);
begin
  sitesdat.DeleteKey('site-'+self.name, name);
end;

function TSite.GetSectionAffil(name: string): string;
begin
  Result:= RCString('affils-'+name, '')
end;

procedure TSite.SetSectionAffil(name: string; const Value: string);
begin
  if Value <> '' then
    WCString('affils-'+name, Value)
  else
  begin
    DeleteKey('affils-'+name);
  end;
end;

function TSite.IsAffil(section, affil: string): Boolean;
var x: TStringList;
begin
  x:= TStringList.Create;
  x.Delimiter:= ' ';
  x.CaseSensitive:= False;
  x.DelimitedText:= sectionaffil[section];
  Result:= x.IndexOf(affil) <> -1;
  x.Free;
end;
function TSite.IsSection(section: string): Boolean;
var x: TStringList;
begin
  x:= TStringList.Create;
  x.Delimiter:= ' ';
  x.CaseSensitive:= False;
  x.DelimitedText:= sections;
  Result:= x.IndexOf(section) <> -1;
  x.Free;
end;
function TSite.IsUser(user: string): Boolean;
var x: TStringList;
begin
  x:= TStringList.Create;
  x.Delimiter:= ' ';
  x.CaseSensitive:= False;
  x.DelimitedText:= leechers;
  Result:= x.IndexOf(user) <> -1;
  if not Result then
  begin
    x.DelimitedText:= traders;
    Result:= x.IndexOf(user) <> -1;
  end;
  x.Free;
end;


function TSite.SetSections(sections: string; remove: Boolean): string;
var x: TStringList;
    ss: string;
    i: Integer;
begin
  x:= TStringList.Create;
  x.Delimiter:= ' ';
  x.CaseSensitive:= False;
  x.DelimitedText:= self.sections;
  for i:= 1 to 1000 do
  begin
    ss:= SubString(sections, ' ', i);
    if ss = '' then Break;

    if x.IndexOf(ss) <> -1 then
    begin
      if remove then
        x.Delete(x.IndexOf(ss))
    end
    else
      x.Add(ss);
  end;
  x.Sort;
  self.sections:= x.DelimitedText;
  Result:= x.DelimitedText;
  x.Free;
end;

function TSite.SetLeechers(users: string; remove: Boolean): string;
var x: TStringList;
    ss: string;
    i, maxleechers: Integer;
begin
  maxleechers:= RCInteger('maxleechers', -1);
  x:= TStringList.Create;
  x.Delimiter:= ' ';
  x.CaseSensitive:= False;
  x.DelimitedText:= self.leechers;
  for i:= 1 to 1000 do
  begin
    ss:= SubString(sections, ' ', i);
    if ss = '' then Break;

    if x.IndexOf(ss) <> -1 then
    begin
      if remove then
        x.Delete(x.IndexOf(ss))
    end
    else
    begin
      if ((maxleechers = -1) or (x.Count+1 <= maxleechers)) then
        x.Add(ss)
      else
        irc_Addtext('Limit reached');
    end;
  end;
  x.Sort;
  self.leechers:= x.DelimitedText;
  Result:= x.DelimitedText;
  x.Free;
end;

function TSite.SetTraders(users: string; remove: Boolean): string;
var x: TStringList;
    ss: string;
    i, maxtraders: Integer;
begin
  maxtraders:= RCInteger('maxtraders', -1);
  x:= TStringList.Create;
  x.Delimiter:= ' ';
  x.CaseSensitive:= False;
  x.DelimitedText:= self.traders;
  for i:= 1 to 1000 do
  begin
    ss:= SubString(sections, ' ', i);
    if ss = '' then Break;

    if x.IndexOf(ss) <> -1 then
    begin
      if remove then
        x.Delete(x.IndexOf(ss))
    end
    else
    begin
      if ((maxtraders = -1) or (x.Count+1 <= maxtraders)) then
        x.Add(ss)
      else
        irc_Addtext('Limit reached');
    end;
  end;
  x.Sort;
  self.traders:= x.DelimitedText;
  Result:= x.DelimitedText;
  x.Free;
end;

function TSite.SetAffils(section, affils: string; remove: Boolean): string;
var x: TStringList;
    ss: string;
    i: Integer;
begin
  x:= TStringList.Create;
  x.Delimiter:= ' ';
  x.CaseSensitive:= False;
  x.DelimitedText:= sectionaffil[section];
  for i:= 1 to 1000 do
  begin
    ss:= SubString(affils, ' ', i);
    if ss = '' then Break;

    if x.IndexOf(ss) <> -1 then
    begin
      if remove then
        x.Delete(x.IndexOf(ss))
    end
    else
      x.Add(ss);
  end;
  x.Sort;
  sectionaffil[section]:= x.DelimitedText;
  Result:= x.DelimitedText;
  x.Free;
end;

function TSite.GetLeechers: string;
begin
  Result:= RCString('leechers', '');
end;

function TSite.GetTraders: string;
begin
  Result:= RCString('traders', '');
end;

procedure TSite.SettLeechers(value: string);
begin
  WCString('leechers', value);
end;

procedure TSite.SettTraders(value: string);
begin
  WCString('leechers', value);
end;

function TSite.GetUsers: string;
begin
  Result:= Bold(leechers)+' '+traders;
end;

function TSite.FreeLeechSlots: Integer;
var
    x: TStringList;
begin
  Result:= RCInteger('maxleechers', -1);
  if Result = -1 then exit;

  x:= TStringList.Create;
  x.Delimiter:= ' ';
  x.DelimitedText:= leechers;
  if x.Count <= Result then dec(Result, x.Count) else  Result:= 0;
  x.Free;
end;
function TSite.FreeTraderSlots: Integer;
var
    x: TStringList;
begin
  Result:= RCInteger('maxtraders', -1);
  if Result = -1 then exit;

  x:= TStringList.Create;
  x.Delimiter:= ' ';
  x.DelimitedText:= traders;
  if x.Count <= Result then dec(Result, x.Count) else  Result:= 0;
  x.Free;
end;

procedure TSite.AutoBnctest;
var i: Integer;
    t: TLoginTask;
begin
  for i:= 0 to tasks.Count -1 do
    if (tasks[i] is TLoginTask) then
    begin
      t:= TLoginTask(tasks[i]);
      if ((t.site1 = name) and (t.readd)) then exit;
    end;

  // nincs, addolni kell.
  t:= TLoginTask.Create(name, False, True);
  t.dontremove:= True;  
  AddTask(t);
end;

procedure TSite.AutoDirlist;
var i: Integer;
    t: TAutoDirlistTask;
begin
  for i:= 0 to tasks.Count -1 do
    if (tasks[i] is TAutoDirlistTask) then
    begin
      t:= TAutoDirlistTask(tasks[i]);
      if (t.site1 = name)  then exit;
    end;

  // nincs, addolni kell.
  t:= TAutoDirlistTask.Create(name);
  t.dontremove:= True;
  AddTask(t);
end;


procedure TSite.Auto;
begin
  if RCInteger('autobnctest', 0) > 0 then
    AutoBnctest;

  if RCInteger('autodirlist', 0) > 0 then
    AutoDirlist;
end;

procedure SiteAutoStart;
var i: Integer;
begin
  queue_lock.Enter;
  for i:= 0 to sites.Count -1 do
    TSite(sites[i]).Auto;
  queue_lock.Leave;
end;

initialization
  SitesInit;
finalization
  SitesUninit;
end.

unit mainthread;

interface

uses SysUtils, md5;

procedure Run;
procedure Stop;

var kilepes: Boolean;
    running: Boolean = False;
    started: TDateTime;

implementation

uses ident, kb, fake, helper, console, mycrypto, queueunit, irc, sitesunit, versioninfo, pazo, debugunit, configunit, precatcher, rulesunit, DateUtils;
const section = 'mainthread';



procedure Run;
var s: string;
begin
  Debug(dpError, section, '%s started', [Get_VersionString(ParamStr(0))]);
  s:= OpenSSLShortVersion();
  if (s < '0.9.8') then
  begin
    WriteLn('OpenSSL version is unsupported! 0.9.8+ needed.');
    halt;
    exit;
  end;
  Debug(dpMessage, section, OpenSSLVersion());
  started:= Now();
  ConsoleStart();
  MycryptoStart(passphrase);
  IdentStart();
  RulesStart();
  FakeStart();
  kb_Start();
  SitesStart;
  IrcStart();
  PrecatcherStart();
  SiteAutoStart;
  kilepes:= False;
  running:= True;

  QueueStart();

  try
    try
      while not kilepes do
      begin
        if MilliSecondsBetween(Now, queue_last_run) >= config.readInteger(section, 'queue_fire', 900) then
        begin
          queue_lock.Enter;
          QueueFire;
          queue_lock.Leave;

          if MilliSecondsBetween(Now, pazo_last_garbage) >= 9990 then
            PazoGarbage;
        end;
        Sleep(100);
      end;
    finally
      kilepes:= True;
      Debug(dpError, section, 'slFtp exiting');
      QueueFire;
      SlotsFire;
    end;
  except on e: Exception do
    begin
      Debug(dpError, section, 'slFtp exiting because of %s', [e.Message]);
    end;

  end;
end;

procedure Stop;
begin
  ConsoleStop();
  IdentStop();
  queue_lock.Enter;
  kb_Save();
  QueueFire();
  queue_lock.Leave;
end;

procedure MainThreadUninit;
begin
  // ez a legutolsonak betoltott unit, kilepesnel varni fog a tobbi cucc befejezodesere
  while
    (myIdentserver <> nil)
    or
    (kb_thread <> nil)
    or
    (myIrcThreads.Count <> 0)
    do Sleep(500);

  Debug(dpError, section, 'Clean exit');
end;
initialization
finalization
  MainThreadUninit;
end.

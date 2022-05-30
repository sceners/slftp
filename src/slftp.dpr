program slftp;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  configunit,
  debugunit,
  helper,
  mycrypto,
  sitesunit,
  ident,
  socks5,
  versioninfo,
  console,
  dirlist,
  irc,
  lame,
  tags,
  queueunit,
  precatcher,
  kb,
  mainthread;

{$R *.res}


begin
  if ReadSites(passphrase) then //
  begin
    Run;
    Stop;
  end
  else
    Writeln('Negative on that, Houston');
end.

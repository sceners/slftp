unit socks5;

interface

uses IdTCPClient;

procedure SetupSocks5(c: TIdTCPClient);

implementation

uses configunit, IdSocks;
const section='socks5';

var socks5enabled: Boolean;

procedure SetupSocks5(c: TIdTCPClient);
begin
  if ((socks5enabled) and (c.Socket <> nil)) then
  begin
    c.Socket.SocksInfo:= TIdSocksInfo.Create(c.Socket);
    with c.Socket.SocksInfo do
    begin
     Host := config.ReadString(section, 'host', '');
     Port := config.ReadInteger(section, 'port', 0);
     if config.ReadBool(section, 'anonymous', False) then
       Authentication := saNoAuthentication
     else
       Authentication := saUsernamePassword;
     Username := config.ReadString(section, 'username', '');
     Password := config.ReadString(section, 'password', '');
     Version := svSocks5;
    end;
  end;
end;

procedure Socks5Init;
begin
  socks5enabled:= config.ReadBool(section, 'enabled', False);
end;

initialization
  Socks5Init;
finalization
end.

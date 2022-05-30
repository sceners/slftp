unit ident;

interface

uses SysUtils, IdIdentServer, IdTCPServer;

type
  TMyIdentServer = class(TIdIdentServer)
  private
    identresponse: string;
    procedure myIdentQuery(AThread: TIdPeerThread; AServerPort, AClientPort : Integer);
    function FindIdent(PeerIP: string; PeerPort: Integer): string;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

procedure IdentStart;
procedure IdentStop;

var myIdentserver: TMyIdentServer = nil;

implementation

uses configunit, sitesunit, queueunit, debugunit, IniFiles, IdGlobal, mainthread;
const section='ident';

procedure IdentStart;
begin
{$IFDEF MSWINDOWS}
  try
    if config.ReadBool(section, 'enabled', True) then
      myIdentserver:= TMyIdentServer.Create;
  except
    myIdentserver:= nil;
  end;
{$ENDIF}
end;
procedure IdentStop;
begin
  if myIdentserver <> nil then
  begin
    myIdentserver.Free;
    myIdentserver:= nil;
  end;
end;

{ TMyIdentServer }

constructor TMyIdentServer.Create;
begin
  inherited Create(nil);

  identresponse:= config.ReadString(section, 'response', 'rsctm');
  ListenQueue:= config.ReadInteger(section, 'listenqueue', 30);
  ReuseSocket:= rsTrue;
  OnIdentQuery:= myIdentQuery;
  Active:= True;
end;

destructor TMyIdentServer.Destroy;
begin
  Active:= False;
  inherited;
end;

function TMyIdentServer.FindIdent(PeerIP: string; PeerPort: Integer): string;
var i, j: Integer;
    s: TSite;
    ss: TSiteSlot;
begin
  Result:= identresponse;
  queue_lock.Enter;
  for i:= 0 to sites.Count -1 do
  begin
    s:= TSite(sites[i]);
    for j:= 0 to s.slots.Count-1 do
    begin
      ss:= TSiteSlot(s.slots[j]);
      if ((ss.peerport = peerport) and (ss.peerip = peerip)) then
      begin
        Result:= ss.RCString('ident', identresponse);
        queue_lock.Leave;
        exit;
      end;
    end;
  end;
  queue_lock.Leave;
end;

procedure TMyIdentServer.myIdentQuery(AThread: TIdPeerThread; AServerPort,
  AClientPort: Integer);
var i: string;
    peerip: string;
begin
  try
    peerip:= AThread.Connection.Socket.Binding.PeerIP;
    i:= FindIdent(peerip, AClientPort);
    AThread.Connection.WriteLn(Format('%d, %d : USERID : UNIX : %s', [AServerPort, AClientPort, i]));
    Debug(dpMessage, section, 'Request from: %s %d %d', [peerip, AServerPort, AClientPort]);
  except
  end;
end;

end.


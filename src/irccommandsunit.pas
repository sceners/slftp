unit irccommandsunit;

interface

uses Classes, irc;

type
  TIrcCommandHandler = function (th: TMyIrcThread; channel, params: string): Boolean;
  TIrcCommand = record
    cmd: string;
    hnd: TIrcCommandHandler;
    minparams: Integer;
    maxparams: Integer;
  end;

  TIRCCommandThread = class(TThread)
    c: TIRCCommandHandler;
    th: TMyIrcThread;
    channel, params: string;
    constructor Create(th: TMyIrcThread; c: TIRCCommandHandler; channel, params: string);
    procedure Execute; override;
  end;

function FindIrcCommand(cmd: string): Integer;
function IrcDie(th: TMyIrcThread; channel, params: string): Boolean;
function IrcHelp(th: TMyIrcThread; channel, params: string): Boolean;
function IrcUptime(th: TMyIrcThread; channel, params: string): Boolean;
function IrcRaw(th: TMyIrcThread; channel, params: string): Boolean;
function IrcInvite(th: TMyIrcThread; channel, params: string): Boolean;
function IrcPretest(th: TMyIrcThread; channel, params: string): Boolean;
function IrcBnctest(th: TMyIrcThread; channel, params: string): Boolean;
function IrcKill(th: TMyIrcThread; channel, params: string): Boolean;
function IrcSites(th: TMyIrcThread; channel, params: string): Boolean;
function IrcSite(th: TMyIrcThread; channel, params: string): Boolean;
function IrcSetdown(th: TMyIrcThread; channel, params: string): Boolean;
function IrcNope(th: TMyIrcThread; channel, params: string): Boolean;
function IrcQueue(th: TMyIrcThread; channel, params: string): Boolean;

function IrcMaxUpDn(th: TMyIrcThread; channel, params: string): Boolean;
function IrcMaxIdle(th: TMyIrcThread; channel, params: string): Boolean;
function IrcTimeout(th: TMyIrcThread; channel, params: string): Boolean;
function IrcDelsite(th: TMyIrcThread; channel, params: string): Boolean;
function IrcSlots(th: TMyIrcThread; channel, params: string): Boolean;

function IrcAddSite(th: TMyIrcThread; channel, params: string): Boolean;

function IrcAddBnc(th: TMyIrcThread; channel, params: string): Boolean;
function IrcDelBnc(th: TMyIrcThread; channel, params: string): Boolean;


function IrcSetdir(th: TMyIrcThread; channel, params: string): Boolean;
function IrcPredir(th: TMyIrcThread; channel, params: string): Boolean;
function IrcPrecmd(th: TMyIrcThread; channel, params: string): Boolean;
function IrcSslmethod(th: TMyIrcThread; channel, params: string): Boolean;
function IrcSslfxp(th: TMyIrcThread; channel, params: string): Boolean;
function IrcLegacyCwd(th: TMyIrcThread; channel, params: string): Boolean;

function IrcSpeeds(th: TMyIrcThread; channel, params: string): Boolean;
function IrcSetSpeed(th: TMyIrcThread; channel, params: string): Boolean;
function IrcInroutes(th: TMyIrcThread; channel, params: string): Boolean;
function IrcOutroutes(th: TMyIrcThread; channel, params: string): Boolean;

function IrcDirlist(th: TMyIrcThread; channel, params: string): Boolean;
function IrcLame(th: TMyIrcThread; channel, params: string): Boolean;

function IrcDelrelease(th: TMyIrcThread; channel, params: string): Boolean;
function IrcDelAllrelease(th: TMyIrcThread; channel, params: string): Boolean;

function IrcCheck(th: TMyIrcThread; channel, params: string): Boolean;
function IrcSpread(th: TMyIrcThread; channel, params: string): Boolean;
function IrcPre(th: TMyIrcThread; channel, params: string): Boolean;
function IrcStop(th: TMyIrcThread; channel, params: string): Boolean;

function IrcBatchAdd(th: TMyIrcThread; channel, params: string): Boolean;
function IrcBatchDel(th: TMyIrcThread; channel, params: string): Boolean;

function IrcTransfer(th: TMyIrcThread; channel, params: string): Boolean;

function IrcStatus(th: TMyIrcThread; channel, params: string): Boolean;
function IrcChannels(th: TMyIrcThread; channel, params: string): Boolean;
function IrcSetBlowkey(th: TMyIrcThread; channel, params: string): Boolean;
function IrcSetChankey(th: TMyIrcThread; channel, params: string): Boolean;
//function IrcSetChanInvite(th: TMyIrcThread; channel, params: string): Boolean;
function IrcAddnet(th: TMyIrcThread; channel, params: string): Boolean;
function IrcModnet(th: TMyIrcThread; channel, params: string): Boolean;
function IrcDelnet(th: TMyIrcThread; channel, params: string): Boolean;
function IrcDelchan(th: TMyIrcThread; channel, params: string): Boolean;
function IrcJump(th: TMyIrcThread; channel, params: string): Boolean;
function IrcSay(th: TMyIrcThread; channel, params: string): Boolean;

function IrcSitechan(th: TMyIrcThread; channel, params: string): Boolean;
function IrcPrereload(th: TMyIrcThread; channel, params: string): Boolean;
function IrcPredebug(th: TMyIrcThread; channel, params: string): Boolean;
function IrcPrelist(th: TMyIrcThread; channel, params: string): Boolean;
function IrcPreadd(th: TMyIrcThread; channel, params: string): Boolean;
function IrcPredel(th: TMyIrcThread; channel, params: string): Boolean;

function IrcRuleAdd(th: TMyIrcThread; channel, params: string): Boolean;
function IrcRuleIns(th: TMyIrcThread; channel, params: string): Boolean;
function IrcRuleMod(th: TMyIrcThread; channel, params: string): Boolean;
function IrcRuleDel(th: TMyIrcThread; channel, params: string): Boolean;
function IrcRuleHelp(th: TMyIrcThread; channel, params: string): Boolean;
function IrcRuleList(th: TMyIrcThread; channel, params: string): Boolean;
function IrcRules(th: TMyIrcThread; channel, params: string): Boolean;

function IrcAffils(th: TMyIrcThread; channel, params: string): Boolean;
function IrcSections(th: TMyIrcThread; channel, params: string): Boolean;
function IrcUsers(th: TMyIrcThread; channel, params: string): Boolean;
function IrcLeechers(th: TMyIrcThread; channel, params: string): Boolean;
function IrcTraders(th: TMyIrcThread; channel, params: string): Boolean;
function IrcUserslots(th: TMyIrcThread; channel, params: string): Boolean;
function IrcFreeslots(th: TMyIrcThread; channel, params: string): Boolean;
function IrcFindAffil(th: TMyIrcThread; channel, params: string): Boolean;
function IrcFindSection(th: TMyIrcThread; channel, params: string): Boolean;
function IrcFindUser(th: TMyIrcThread; channel, params: string): Boolean;
function IrcAuto(th: TMyIrcThread; channel, params: string): Boolean;
function IrcAutoLogin(th: TMyIrcThread; channel, params: string): Boolean;
function IrcAutoBncTest(th: TMyIrcThread; channel, params: string): Boolean;
function IrcAutoDirlist(th: TMyIrcThread; channel, params: string): Boolean;
function IrcKbShow(th: TMyIrcThread; channel, params: string): Boolean;
function IrcKbList(th: TMyIrcThread; channel, params: string): Boolean;
function IrcKbExtra(th: TMyIrcThread; channel, params: string): Boolean;

function IrcNoHelp(th: TMyIrcThread; channel, params: string): Boolean;
function IrcIdent(th: TMyIrcThread; channel, params: string): Boolean;

const
      irccommands : array[1..95] of TIrcCommand = (
        (cmd: '- General:'; hnd: IrcNope; minparams: 0; maxparams: 0),
        (cmd: 'uptime'; hnd: IrcUptime; minparams: 0; maxparams: 0),
        (cmd: 'help'; hnd: IrcHelp; minparams: 0; maxparams: 1),
        (cmd: 'bnctest'; hnd: IrcBnctest; minparams: 0; maxparams: -1),
        (cmd: 'kill'; hnd: IrcKill; minparams: 1; maxparams: 1),
        (cmd: 'setdown'; hnd: IrcSetdown; minparams: 1; maxparams: 1),
        (cmd: 'queue'; hnd: IrcQueue; minparams: 0; maxparams: 0),
        (cmd: 'die'; hnd: IrcDie; minparams: 0; maxparams: 0),
        (cmd: '- Site management:'; hnd: IrcNope; minparams: 0; maxparams: 0),
        (cmd: 'sites'; hnd: IrcSites; minparams: 0; maxparams: 0),
        (cmd: 'site'; hnd: IrcSite; minparams: 1; maxparams: 1),
        (cmd: 'addsite'; hnd: IrcAddsite; minparams: 4; maxparams: -1),
        (cmd: 'delsite'; hnd: IrcDelsite; minparams: 1; maxparams: 1),
        (cmd: 'addbnc'; hnd: IrcAddBnc; minparams: 2; maxparams: 2),
        (cmd: 'delbnc'; hnd: IrcDelBnc; minparams: 2; maxparams: 2),
        (cmd: 'slots'; hnd: IrcSlots; minparams: 2; maxparams: 2),
        (cmd: 'maxupdn'; hnd: IrcMaxUpDn; minparams: 3; maxparams: 3),
        (cmd: 'maxidle'; hnd: IrcMaxIdle; minparams: 2; maxparams: 3),
        (cmd: 'timeout'; hnd: IrcTimeout; minparams: 3; maxparams: 3),
        (cmd: 'sslfxp'; hnd: IrcSslfxp; minparams: 2; maxparams: 2),
        (cmd: 'sslmethod'; hnd: IrcSslmethod; minparams: 2; maxparams: 2),
        (cmd: 'legacycwd'; hnd: IrcLegacycwd; minparams: 2; maxparams: 2),
        (cmd: 'setpredir'; hnd: IrcPredir; minparams: 2; maxparams: 2),
        (cmd: 'setdir'; hnd: IrcSetDir; minparams: 2; maxparams: 3),
        (cmd: 'setprecmd'; hnd: IrcPrecmd; minparams: 2; maxparams: -1),
        (cmd: '- Auto:'; hnd: IrcNope; minparams: 0; maxparams: 0),
        (cmd: 'autologin'; hnd: IrcAutoLogin; minparams: 1; maxparams: 2),
        (cmd: 'autobnctest'; hnd: IrcAutoBnctest; minparams: 1; maxparams: 2),
        (cmd: 'autodirlist'; hnd: IrcAutoDirlist; minparams: 1; maxparams: -1),
        (cmd: 'auto'; hnd: IrcAuto; minparams: 0; maxparams: 1),
        (cmd: '- Speed management:'; hnd: IrcNope; minparams: 0; maxparams: 0),
        (cmd: 'speeds'; hnd: IrcSpeeds; minparams: 1; maxparams: 1),
        (cmd: 'setspeed'; hnd: IrcSetspeed; minparams: 3; maxparams: 3),
        (cmd: 'inroutes'; hnd: IrcInroutes; minparams: 0; maxparams: 0),
        (cmd: 'outroutes'; hnd: IrcOutroutes; minparams: 0; maxparams: 0),
        (cmd: '- Work:'; hnd: IrcNope; minparams: 0; maxparams: 0),
        (cmd: 'dirlist'; hnd: IrcDirlist; minparams: 1; maxparams: 3),
        (cmd: 'lame'; hnd: IrcLame; minparams: 2; maxparams: 3),
        (cmd: 'spread'; hnd: IrcSpread; minparams: 2; maxparams: 3),
        (cmd: 'transfer'; hnd: IrcTransfer; minparams: 3; maxparams: 4),
        (cmd: 'stop'; hnd: IrcStop; minparams: 1; maxparams: 1),
        (cmd: '- Other rip stuffs:'; hnd: IrcNope; minparams: 0; maxparams: 0),
        (cmd: 'check'; hnd: IrcCheck; minparams: 2; maxparams: 3),
        (cmd: 'pre'; hnd: IrcPre; minparams: 1; maxparams: 3),
        (cmd: 'pretest'; hnd: IrcPretest; minparams: 2; maxparams: 3),
        (cmd: 'batch'; hnd: IrcBatchAdd; minparams: 2; maxparams: 4),
        (cmd: 'batchdel'; hnd: IrcBatchDel; minparams: 2; maxparams: 3),
        (cmd: 'delrelease'; hnd: IrcDelrelease; minparams: 2; maxparams: 3),
        (cmd: 'delallrelease'; hnd: IrcDelallrelease; minparams: 2; maxparams: 3),
        (cmd: '- Misc:'; hnd: IrcNope; minparams: 0; maxparams: 0),
        (cmd: 'raw'; hnd: IrcRaw; minparams: 1; maxparams: -1),
        (cmd: 'invite'; hnd: IrcInvite; minparams: 1; maxparams: 1),
        (cmd: 'sitechan'; hnd: IrcSiteChan; minparams: 1; maxparams: 2),
        (cmd: 'nohelp'; hnd: IrcNohelp; minparams: 0; maxparams: 0),
        (cmd: 'ident'; hnd: IrcIdent; minparams: 1; maxparams: 2),
        (cmd: '- IRC management'; hnd: IrcNope; minparams: 0; maxparams: 0),
        (cmd: 'ircstatus'; hnd: IrcStatus; minparams: 0; maxparams: 0),
        (cmd: 'ircsay'; hnd: IrcSay; minparams: 3; maxparams: -1),
        (cmd: 'ircjump'; hnd: IrcJump; minparams: 1; maxparams: 1),
        (cmd: 'ircnetadd'; hnd: IrcAddnet; minparams: 3; maxparams: 4),
        (cmd: 'ircnetmod'; hnd: IrcModnet; minparams: 3; maxparams: 4),
        (cmd: 'ircnetdel'; hnd: IrcDelnet; minparams: 1; maxparams: 1),
        (cmd: 'ircchannels'; hnd: IrcChannels; minparams: 0; maxparams: 1),
        (cmd: 'ircchandel'; hnd: IrcDelchan; minparams: 2; maxparams: 2),
        (cmd: 'ircchanblow'; hnd: IrcSetBlowkey; minparams: 2; maxparams: 3),
        (cmd: 'ircchankey'; hnd: IrcSetChankey; minparams: 2; maxparams: 3),
//        (cmd: 'ircsetinviteonly'; hnd: IrcSetChanInvite; minparams: 3; maxparams: 3)
        (cmd: '- Pre catcher'; hnd: IrcNope; minparams: 0; maxparams: 0),
        (cmd: 'catchreload'; hnd: IrcPrereload; minparams: 0; maxparams: 0),
        (cmd: 'catchdebug'; hnd: IrcPredebug; minparams: 1; maxparams: 1),
        (cmd: 'catchlist'; hnd: IrcPrelist; minparams: 0; maxparams: 2),
        (cmd: 'catchadd'; hnd: IrcPreadd; minparams: 4; maxparams: 7),
        (cmd: 'catchdel'; hnd: IrcPredel; minparams: 1; maxparams: 1),
        (cmd: '- Rules management'; hnd: IrcNope; minparams: 0; maxparams: 0),
        (cmd: 'ruleadd'; hnd: IrcRuleAdd; minparams: 6; maxparams: -1),
        (cmd: 'ruleins'; hnd: IrcRuleIns; minparams: 7; maxparams: -1),
        (cmd: 'rulemod'; hnd: IrcRuleMod; minparams: 7; maxparams: -1),
        (cmd: 'ruledel'; hnd: IrcRuleDel; minparams: 1; maxparams: 1),
        (cmd: 'rulehelp'; hnd: IrcRuleHelp; minparams: 1; maxparams: 1),
        (cmd: 'rulelist'; hnd: IrcRuleList; minparams: 0; maxparams: 0),
        (cmd: 'rules'; hnd: IrcRules; minparams: 2; maxparams: 2),
        (cmd: '- Affils/users/shit'; hnd: IrcNope; minparams: 0; maxparams: 0),
        (cmd: 'affils'; hnd: IrcAffils; minparams: 2; maxparams: -1),
        (cmd: 'sections'; hnd: IrcSections; minparams: 1; maxparams: -1),
        (cmd: 'users'; hnd: IrcUsers; minparams: 1; maxparams: 1),
        (cmd: 'leechers'; hnd: IrcLeechers; minparams: 1; maxparams: -1),
        (cmd: 'traders'; hnd: IrcTraders; minparams: 1; maxparams: -1),
        (cmd: 'userslots'; hnd: IrcUserslots; minparams: 3; maxparams: 3),
        (cmd: 'freeslots'; hnd: IrcFreeslots; minparams: 0; maxparams: 0),
        (cmd: 'findaffil'; hnd: IrcFindAffil; minparams: 2; maxparams: 2),
        (cmd: 'findsection'; hnd: IrcFindSection; minparams: 1; maxparams: 1),
        (cmd: 'finduser'; hnd: IrcFindUser; minparams: 1; maxparams: 1),
        (cmd: '- KB'; hnd: IrcNope; minparams: 0; maxparams: 0),
        (cmd: 'kbshow'; hnd: IrcKbShow; minparams: 2; maxparams: 2),
        (cmd: 'kblist'; hnd: IrcKbList; minparams: 0; maxparams: 0),        
        (cmd: 'kbextra'; hnd: IrcKbExtra; minparams: 3; maxparams: -1)
      );


implementation

uses SysUtils, DateUtils, Math, idGlobal, dirlist,versioninfo,
   queueunit, tasksunit, mystrings, sitesunit, notify,taskraw, tasklogin,
   taskdirlist, taskdel, tasklame, taskcwd, taskrace, pazo, configunit,
   kb, ircblowfish, precatcher, rulesunit, mainthread;


const
  section = 'irccommands';

var batchqueue, webtags: TStringList;




function FindIrcCommand(cmd: string): Integer;
var i: Integer;
begin
  Result:= 0;
  if ((cmd <> '') and (cmd[1] =  '-')) then exit;

  for i:= Low(irccommands) to High(irccommands) do
    if irccommands[i].cmd = cmd then
    begin
      Result:= i;
      exit;
    end;
end;

function IrcNope(th: TMyIrcThread; channel, params: string): Boolean;
begin
  Result:= False;
end;

function IrcSetdir(th: TMyIrcThread; channel, params: string): Boolean;
var sitename, section: string;
    s: TSite;
    dir: string;
begin
  Result:= False;
  sitename:=  UpperCase(SubString(params, ' ', 1));
  section:=  UpperCase(SubString(params, ' ', 2));
  dir:= SubString(params, ' ', 3);

  if ((dir <> '') and (dir[1] <> '/')) then
  begin
    irc_addtext(channel, 'Syntax error.');
    exit;
  end;

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    irc_addtext(channel, 'Site %s not found.', [Bold(sitename)]);
    queue_lock.Leave;
    exit;
  end;

  s.sectiondir[section]:= dir;
  queue_lock.Leave;

  if dir = '' then // el kell tavolitani a rulejait is
  begin
    queue_lock.Enter;
    RulesRemove(sitename, section);
    queue_lock.Leave;
  end;

  Result:= True;
end;
function IrcPredir(th: TMyIrcThread; channel, params: string): Boolean;
begin
  Result:= False;
  irc_addtext('not available in this version');
end;
function IrcPrecmd(th: TMyIrcThread; channel, params: string): Boolean;
begin
  Result:= False;
  irc_addtext('not available in this version');
end;

procedure Outroutes(sitename, channel: string);
var x: TStringList;
    i: integer;
    ss: string;
begin
  x:= TStringList.Create;
  sitesdat.ReadSection('speed-from-'+sitename, x);
  ss:= '';
  for i:= 0 to x.Count -1 do
  begin
    if ss <> '' then ss := ss + ', ';
    ss:= ss + x[i] + ' '+ sitesdat.ReadString('speed-from-'+sitename, x[i], '');
  end;
  if ss <> '' then
    irc_addText(channel, '%s -> %s', [Bold(sitename),  Bold(ss)]);
  x.Free;

end;
procedure Inroutes(sitename, channel: string);
var x: TStringList;
    i: integer;
    ss: string;
begin
  x:= TStringList.Create;
  sitesdat.ReadSection('speed-to-'+sitename, x);
  ss:= '';
  for i:= 0 to x.Count -1 do
  begin
    if ss <> '' then ss := ss + ', ';
    ss:= ss + x[i] + ' '+ sitesdat.ReadString('speed-to-'+sitename, x[i], '');
  end;
  if ss <> '' then
    irc_addText(channel, '%s <- %s', [Bold(sitename),  Bold(ss)]);

  x.Free;

end;

function IrcSpeeds(th: TMyIrcThread; channel, params: string): Boolean;
var sitename: string;
    s: TSite;
begin
  Result:= False;
  sitename:=  UpperCase(SubString(params, ' ', 1));

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    queue_lock.Leave;
    irc_addtext(channel, 'Site %s not found.', [Bold(sitename)]);
    exit;
  end;

  Outroutes(sitename, channel);
  Inroutes(sitename, channel);


  queue_lock.Leave;

  Result:= True;
end;
function IrcSetSpeed(th: TMyIrcThread; channel, params: string): Boolean;
var sitename1, sitename2: string;
    speed: Integer;
    s1, s2: TSite;
begin
  Result:= False;
  sitename1:=  UpperCase(SubString(params, ' ', 1));
  sitename2:=  UpperCase(SubString(params, ' ', 2));
  speed:=  StrToIntDef(SubString(params, ' ', 3), -1);

  if ((speed >= 10) or (speed < 0)) then
  begin
    irc_addtext(channel, 'Syntax error.');
    exit;
  end;

  queue_lock.Enter;
  s1:= FindSiteByName(sitename1);
  if s1 = nil then
  begin
    irc_addtext(channel, 'Site %s not found.', [Bold(sitename1)]);
    queue_lock.Leave;
    exit;
  end;
  s2:= FindSiteByName(sitename2);
  if s2 = nil then
  begin
    irc_addtext(channel, 'Site %s not found.', [Bold(sitename2)]);
    queue_lock.Leave;
    exit;
  end;

  if speed > 0 then
  begin
    sitesdat.WriteInteger('speed-from-'+sitename1, sitename2, speed);
    sitesdat.WriteInteger('speed-to-'+sitename2, sitename1, speed);
  end else
  begin
    sitesdat.DeleteKey('speed-from-'+sitename1, sitename2);
    sitesdat.DeleteKey('speed-to-'+sitename2, sitename1);
  end;

  queue_lock.Leave;

  Result:= True;
end;
function IrcInroutes(th: TMyIrcThread; channel, params: string): Boolean;
var s: TSite;
    i: Integer;
begin

  queue_lock.Enter;
  for i:= 0 to sites.Count -1 do
  begin
    s:= TSite(sites[i]);
    Inroutes(s.name, channel);
  end;

  queue_lock.Leave;

  Result:= True;
end;
function IrcOutroutes(th: TMyIrcThread; channel, params: string): Boolean;
var s: TSite;
    i: Integer;
begin

  queue_lock.Enter;
  for i:= 0 to sites.Count -1 do
  begin
    s:= TSite(sites[i]);
    Outroutes(s.name, channel);
  end;

  queue_lock.Leave;

  Result:= True;
end;

function DirlistB(sitename, dir: string): TDirList;
var
    r: TDirlistTask;
    tn: TTaskNotify;
begin
  Result:= nil;

  queue_lock.Enter;
  r:= TDirlistTask.Create(sitename, dir);
  tn:= AddNotify;
  tn.tasks.Add(r);
  AddTask(r);
  QueueFire;
  queue_lock.Leave;

  tn.event.WaitFor($FFFFFFFF);


  queue_lock.Enter;
  if tn.responses.Count = 1 then
    Result:= TDirList.Create(nil, nil, TSiteResponse(tn.responses[0]).response);

  RemoveTN(tn);
  queue_lock.Leave;

end;

function IrcDirlist(th: TMyIrcThread; channel, params: string): Boolean;
var s: TSite;
    i: Integer;
    sitename, section, predir, dir: string;
    d: TDirlist;
    de: TDirListEntry;
begin
  Result:= False;

  sitename:= UpperCase(SubString(params, ' ', 1));
  section:= UpperCase(SubString(params, ' ', 2));

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    irc_addtext(channel, 'Site %s not found.', [Bold(sitename)]);
    queue_lock.Leave;
    exit;
  end;
  predir:= s.sectiondir[section];

  dir:= RightStrv2(params, length(sitename)+length(section)+2);
  if ((dir = '') and (predir = '')) then
  begin
    section:= 'PRE';
    predir:= s.sectiondir[section];
    dir:= RightStrv2(params, length(sitename)+1);
  end;

  if ((0 < Pos('../', dir)) or (0 < Pos('/..', dir))) then
  begin
    irc_addText(channel, 'Syntax error.');
    queue_lock.Leave;
    exit;
  end;

  if (predir = '') then
  begin
    irc_addtext(channel, 'Site %s has no dir set for section %s.', [Bold(sitename), section]);
    queue_lock.Leave;
    exit;
  end;
  queue_lock.Leave;

  d:= DirlistB(sitename, MyIncludeTrailingSlash(predir)+dir);
  if d <> nil then
  begin
    for i:= 0 to d.entries.Count-1 do
    begin
      de:= TDirListEntry(d.entries[i]);

      if de.directory then
        irc_addtext(channel, '%s', [Bold(de.filename)])
      else
        irc_addtext(channel, '%s (%d)', [de.filename, de.filesize]);
    end;
    d.Free;
  end;

  Result:= True;
end;

function IrcLame(th: TMyIrcThread; channel, params: string): Boolean;
begin
  Result:= False;
  irc_addtext('not available in this version');
end;


function IrcDelrelease(th: TMyIrcThread; channel, params: string): Boolean;
var s: TSite;
    sitename, section, predir, dir: string;
    r: TDelreleaseTask;
    tn: TTaskNotify;
    p: TPazo;
    ps: TPazoSite;
begin
  Result:= False;

  sitename:= UpperCase(SubString(params, ' ', 1));
  section:= UpperCase(SubString(params, ' ', 2));


  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    irc_addtext(channel, 'Site %s not found.', [Bold(sitename)]);
    queue_lock.Leave;
    exit;
  end;
  predir:= s.sectiondir[section];

  dir:= RightStrv2(params, length(sitename)+length(section)+2);
  if ((dir = '') and (predir = '')) then
  begin
    section:= 'PRE';
    predir:= s.sectiondir[section];
    dir:= RightStrv2(params, length(sitename)+1);
  end;

  if ((0 < Pos('../', dir)) or (0 < Pos('/..', dir))) then
  begin
    irc_addText(channel, 'Syntax error.');
    queue_lock.Leave;
    exit;
  end;

  if (predir = '') then
  begin
    irc_addtext(channel, 'Site %s has no predir set.', [Bold(sitename)]);
    queue_lock.Leave;
    exit;
  end;

  if (s.working = sstUnknown) then
  begin
    irc_addtext(channel, 'Status of site %s is unknown.', [Bold(sitename)]);
    queue_lock.Leave;
    exit;
  end;


  p:= FindPazoByName(section, dir);
  if p <> nil then
  begin
    ps:= p.FindSite(sitename);
    if (ps <> nil)  then
      ps.Clear;
  end;

  r:= TDelreleaseTask.Create(sitename, MyIncludeTrailingSlash(predir)+dir);
  tn:= AddNotify;
  tn.tasks.Add(r);
  AddTask(r);
  QueueFire;
  queue_lock.Leave;

  tn.event.WaitFor($FFFFFFFF);


  queue_lock.Enter;
  RemoveTN(tn);
  queue_lock.Leave;



  Result:= True;
end;

function IrcDelallrelease(th: TMyIrcThread; channel, params: string): Boolean;
var s: TSite;
    predir, section, sitename, dir: string;
    r: TDelreleaseTask;
    tn: TTaskNotify;
    added: Boolean;
    i: Integer;
    pazo_id: Integer;
    p: TPazo;
    ps: TPazoSite;
begin
  Result:= False;
  sitename:= UpperCase(SubString(params, ' ', 1));
  section:= UpperCase(SubString(params, ' ', 2));


  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    irc_addtext(channel, 'Site %s not found.', [Bold(sitename)]);
    queue_lock.Leave;
    exit;
  end;


  predir:= s.sectiondir[section];

  dir:= RightStrv2(params, length(sitename)+length(section)+2);
  if ((dir = '') and (predir = '')) then
  begin
    section:= 'PRE';
    predir:= s.sectiondir[section];
    dir:= RightStrv2(params, length(sitename)+1);
  end;

  if ((0 < Pos('../', dir)) or (0 < Pos('/..', dir))) then
  begin
    irc_addText(channel, 'Syntax error.');
    queue_lock.Leave;
    exit;
  end;

  if (predir = '') then
  begin
    irc_addtext(channel, 'Site %s has no dir set for section %s.', [Bold(sitename), section]);
    queue_lock.Leave;
    exit;
  end;

  pazo_id:= kb_Add(sitename, section, '', 'NEWDIR', dir, '', True);
  if pazo_id = -1 then
  begin
    queue_lock.Leave;
    exit;
  end;
  p:= TPazo(kb_list.Objects[pazo_id]);


  for i:= 0 to p.sites.Count -1 do
  begin
    ps:= TPazoSite(p.sites[i]);

    if (ps.name <> sitename) then
    begin
      s:= FindSiteByName(ps.name);
      if s <> nil then
      begin
        if (s.sectiondir[section] <> '') and (s.working = sstUnknown)  then
        begin
          irc_addtext(channel, 'Status of site %s is unknown.', [Bold(s.name)]);
          queue_lock.Leave;
          exit;
        end;
      end;
    end;
  end;

  added:= False;
  tn:= AddNotify;
  for i:= 0 to p.sites.Count -1 do
  begin
    ps:= TPazoSite(p.sites[i]);

    if (ps.name <> sitename) then
    begin
      if (ps.Source) then
      begin
        ps.Clear;

        r:= TDelreleaseTask.Create(ps.name, MyIncludeTrailingSlash(ps.maindir)+dir);
        tn.tasks.Add(r);
        AddTask(r);
        added:= True;
      end;
    end;
  end;


  QueueFire;
  queue_lock.Leave;

  if added then
    tn.event.WaitFor($FFFFFFFF)
  else
    irc_addtext(channel, 'No sites found...');


  queue_lock.Enter;
  RemoveTN(tn);
  queue_lock.Leave;

  Result:= True;
end;




function IrcCheck(th: TMyIrcThread; channel, params: string): Boolean;
var s: TSite;
    predir, section, sitename, dir: string;
    tn: TTaskNotify;
    added: Boolean;
    i: Integer;
    sr: TSiteResponse;
    d: TDirList;
    files, size: Integer;
    addednumber: Integer;
    aktfiles, aktsize: Integer;
    nfofound: Boolean;
    p: TPazo;
    ps: TPazoSite;
    r: TDirListTask;
    failed, perfect: Integer;
begin
  Result:= False;

  sitename:= UpperCase(SubString(params, ' ', 1));
  section:= UpperCase(SubString(params, ' ', 2));

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    irc_addtext(channel, 'Site %s not found.', [Bold(sitename)]);
    queue_lock.Leave;
    exit;
  end;

  predir:= s.sectiondir[section];

  dir:= RightStrv2(params, length(sitename)+length(section)+2);
  if ((dir = '') and (predir = '')) then
  begin
    section:= 'PRE';
    predir:= s.sectiondir[section];
    dir:= RightStrv2(params, length(sitename)+1);
  end;
  if (predir = '') then
  begin
    irc_addtext(channel, 'Site %s has no dir set for section %s.', [Bold(sitename), section]);
    queue_lock.Leave;
    exit;
  end;



  kb_Add(sitename, section, '', 'COMPLETE', dir, '', True);
  i:= kb_list.IndexOf(section+'-'+dir);
  if i = -1 then exit; // this is not possible

  p:= TPazo(kb_list.Objects[i]);


  addednumber:= 0;
  tn:= AddNotify;
  for i:= 0 to p.sites.Count -1 do
  begin
    ps:= TPazoSite(p.sites[i]);
    s:= FindSiteByName(ps.name);
    if ((s <> nil) and (not s.markeddown) and (ps.status <> rssNotAllowed)) then
    begin
      r:= TDirlistTask.Create(ps.name, MyIncludeTrailingSlash(ps.maindir)+dir);
      // r.announce:= ps.name+' dirlist ready...'; // we dont want this anymore because of the lag
      tn.tasks.Add(r);
      AddTask(r);
      inc(addednumber);
    end;
  end;

  QueueFire;
  queue_lock.Leave;

  if addednumber = 0 then
  begin
    queue_lock.Enter;
    RemoveTN(tn);
    queue_lock.Leave;
    exit;
  end;

  tn.event.WaitFor($FFFFFFFF);

  added:= True;
  queue_lock.Enter;
  if tn.responses.Count <> addednumber then
  begin
    irc_addtext(channel, 'ERROR: %s', [Red('We got different number of dirlist responses...')]);
    added:= False;
  end;
  
  if(added) then
  begin
    added:= False;
    nfofound:= False;
    for i:= 0 to tn.responses.Count -1 do
    begin
      sr:= TSiteResponse(tn.responses[i]);
      if sr.sitename = sitename then
      begin
        added:= True;
        d:= TDirList.Create(nil, nil, sr.response);
        nfofound:= d.hasnfo;
        d.UsefulFiles(files, size);
        d.Free;
        Break;
      end;
    end;

    if ((files = 0) or (size = 0))then
    begin
      irc_addtext(channel, 'ERROR: %s', [Red('Something is wrong: i think there are no files on src '+Bold(sitename)+'...')]);
      added:= False;
    end;

    if (not nfofound)then
    begin
      irc_addtext(channel, 'ERROR: %s', [Red('Durex check failed on src '+Bold(sitename)+'...')]);
      added:= False;
    end;

    if added then
    begin
      irc_addtext(channel, '%s @ %s is %d bytes in %d files.', [Bold(dir), Bold(sitename), size, files]);

      perfect:= 0;
      failed:= 0;
//      addednumber:= 0;
      for i:= 0 to tn.responses.Count -1 do
      begin
        sr:= TSiteResponse(tn.responses[i]);
        if sr.sitename <> sitename then
        begin
//          inc(addednumber);

          d:= TDirList.Create(nil, nil, sr.response);
          d.UsefulFiles(aktfiles, aktsize);
          nfofound:= d.hasnfo;
          d.Free;

          if ((aktfiles <> files) or (aktsize <> size)) then
          begin
            irc_addtext(channel, 'ERROR: %s @ %s is %d bytes in %d files.', [Red(dir), Red(Bold(sr.sitename)), aktsize, aktfiles]);
            added:= False;
            inc(failed);
          end else
            inc(perfect);

          if (not nfofound) then
          begin
            irc_addtext(channel, 'ERROR: %s @ %s has no condom.', [Red(dir), Red(Bold(sr.sitename))]);
            added:= False;
          end;
        end;
      end;

      if ((perfect > 0) and (failed > 0)) then
        irc_addtext(channel, 'Perfect on %d sites and failed on %d sites compared to %s.', [perfect, failed, Bold(sitename)])
      else
      if (failed > 0) then
        irc_addtext(channel, 'Failed on %d sites compared to %s.', [failed, Bold(sitename)])
      else
      if (perfect > 0) then
        irc_addtext(channel, 'Perfect on %d sites compared to %s.', [perfect, Bold(sitename)]);

    end;
  end;
  RemoveTN(tn);
  queue_lock.Leave;

//  irc_addtext(channel, 'Kileptunk checkbol');

  if added then
    Result:= True;
end;

// y-ba belepakolja az osszes olyan siteot amibe el lehet jutni honnanbol...
procedure Routeable(honnan: string; y: TStringList);
var x: TStringList;
    i: Integer;
    s: TSite;
begin
  if -1 = y.IndexOf(honnan) then
  begin
    y.Add(honnan);
    x:= TStringList.Create;
    try
      sitesdat.ReadSection('speed-from-'+honnan, x);
      for i:= 0 to x.Count -1 do
      begin
        s:= FindSiteByName(x[i]);
        if ((s <> nil) and (s.working = sstUp)) then
          Routeable(x[i], y);
      end;
    finally
      x.Free;
    end;
  end;
end;

function mySpeedComparer(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result:=
    CompareValue(
      StrToIntDef(list.ValueFromIndex[index2],0),
      StrToIntDef(list.ValueFromIndex[index1],0)
    );
end;



function IrcSpread(th: TMyIrcThread; channel, params: string): Boolean;
var s: TSite;
    ps: TPazoSite;
    predir, sitename, section, dir: string;
    lastAnn: TDateTime;
    ann: Integer;
    pazo_id: Integer;
    p: TPazo;
    y: TStringList;
    stat, elozostat: string;
    added: Boolean;
    i, addednumber: Integer;
//    hanyszor: Integer;
begin
  Result:= False;

  sitename:= UpperCase(SubString(params, ' ', 1));
  section:= UpperCase(SubString(params, ' ', 2));

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    irc_addtext(channel, 'Site %s not found.', [Bold(sitename)]);
    queue_lock.Leave;
    exit;
  end;

  predir:= s.sectiondir[section];

  dir:= RightStrv2(params, length(sitename)+length(section)+2);
  if ((dir = '') and (predir = '')) then
  begin
    section:= 'PRE';
    predir:= s.sectiondir[section];
    dir:= RightStrv2(params, length(sitename)+1);
  end;

  if (predir = '') then
  begin
    irc_addtext(channel, 'Site %s has no dir set for section %s.', [Bold(sitename), section]);
    queue_lock.Leave;
    exit;
  end;


  if ((0 < Pos('../', dir)) or (0 < Pos('/..', dir))) then
  begin
    irc_addText(channel, 'Syntax error.');
    queue_lock.Leave;
    exit;
  end;

  (*most leellenorizzuk a routingot*)
  added:= True;
  addednumber:= 0;
  if 1 = Pos('PRE', section) then
    pazo_id:= kb_add(sitename, section, '', 'PRE', dir, '', True)
  else
    pazo_id:= kb_add(sitename, section, '', 'NEWDIR', dir, '', True);
  if pazo_id = -1 then
  begin
    queue_lock.Leave;
    exit;
  end;

  p:= TPazo(kb_list.Objects[pazo_id]);
  p.Clear;
  p.AddSites; // ha kozben valamelyik site up lett...

  y:= TStringList.Create;
  Routeable(sitename, y);

  for i:= 0 to p.sites.Count -1 do
  begin
    ps:= TPazoSite(p.sites[i]);
    s:= FindSiteByName(ps.name);

    if s.working = sstUnknown then
    begin
      irc_addtext(channel, 'Status of site %s is unknown.', [Bold(s.name)]);
      added:= False;
      Break;
    end;

    (* ez tobbe nem fordul elo:
    if s.predir = '' then
    begin
      irc_addtext(channel, 'Site %s has no predir set.', [Bold(s.name)]);
      added:= False;
      Break;
    end;
    *)

    if ((ps.name <> sitename) and (s.working = sstUp)) then
    begin
      inc(addednumber);
      if -1 = y.IndexOf(ps.name) then
      begin
        irc_addtext(channel, '%s -> %s is not routeable.', [Bold(sitename), Bold(ps.name)]);
        added:= False;
        Break;
      end;
    end;
  end;

  if (addednumber = 0) then
  begin
    irc_addtext(channel, 'There are no sites up to spread to...');
    added:= False;
  end;

  if not added then
  begin
    queue_lock.Leave;
    y.Free;
    exit;
  end;


  if 1 = Pos('PRE', section) then
    pazo_id:= kb_add(sitename, section, '', 'PRE', dir, '', False, True)
  else
    pazo_id:= kb_add(sitename, section, '', 'NEWDIR', dir, '', False, True);
  if pazo_id = -1 then
  begin
    irc_addtext(channel, 'Is it allowed anywhere at all?');
    exit;
  end;

  queue_lock.Leave;
  
  irc_addtext(channel, 'Spread has started. Type !stop %s if you want.', [Bold(pazo_id)]);

  // most pedig varunk x mp-et es announceoljuk az eredmenyt, illetve megszakitjuk
  // ha meg kell hogy szakadjon
  //  hanyszor:= 0;
  elozostat:= '';
  ann:= config.ReadInteger('spread', 'announcetime', 20);
  lastAnn:= Now();
  while(true)do
  begin
    if(kilepes) then exit;
    Sleep(500);

    queue_lock.Enter;
    p:= FindPazoById(pazo_id);
    if p = nil then
    begin
      queue_lock.Leave;
      exit; // ez a szituacio nem nagyon fordulhat elo
    end;
    if p.stopped then
    begin
      irc_addtext(channel, 'Spreading of %s has stopped.',[Bold(dir)]);
      queue_lock.Leave;
      exit;
    end;

    if ((p.ready) or (p.readyerror)) then
    begin
//      irc_addtext(channel, 'Spreading of %s has successfully finished.',[Bold(dir)]);
      if not p.readyerror then
        Result:= True;

      queue_lock.Leave;
      Break;
    end;


    if((ann <> 0) and (SecondsBetween(Now, lastAnn) > ann)) then
    begin
      stat:= p.FullStats;
      (* ezt a featuret nem hasznaljuk tobbe
      if stat = elozostat then
      begin
        inc(hanyszor);
        if hanyszor >= 3 then
        begin
          irc_addtext(channel, 'No change for %d seconds, exiting.',[hanyszor*ann]);
          p.stopped:= True;
          RemovePazo(p.pazo_id);
          queue_lock.Leave;
          exit;
        end;
      end else
        hanyszor:= 0;
      *)
      elozostat:= stat;
      irc_addtext(channel, stat);
      lastAnn:= Now();
    end;
    queue_lock.Leave;
  end;


end;


function IrcTransfer(th: TMyIrcThread; channel, params: string): Boolean;
var s1, s2: TSite;
    sitename1, sitename2, section, predir1, predir2, dir: string;
    lastAnn: TDateTime;
    ann: Integer;
    pazo_id: Integer;
    p: TPazo;
    ps: TPazoSite;
    pd: TPazoDirlistTask;
    rc: TCRelease;
    rls: TRelease;
    i,j: string;
begin
  Result:= False;

  sitename1:= UpperCase(SubString(params, ' ', 1));
  sitename2:= UpperCase(SubString(params, ' ', 2));
  section:= UpperCase(SubString(params, ' ', 3));

  queue_lock.Enter;
  s1:= FindSiteByName(sitename1);
  if s1 = nil then
  begin
    irc_addtext(channel, 'Site %s not found.', [Bold(sitename1)]);
    queue_lock.Leave;
    exit;
  end;
  if s1.working <> sstUp then
  begin
    irc_addtext(channel, 'Site %s is not up.', [Bold(sitename1)]);
    queue_lock.Leave;
    exit;
  end;
  s2:= FindSiteByName(sitename2);
  if s2 = nil then
  begin
    irc_addtext(channel, 'Site %s not found.', [Bold(sitename2)]);
    queue_lock.Leave;
    exit;
  end;
  if s2.working <> sstUp then
  begin
    irc_addtext(channel, 'Site %s is not up.', [Bold(sitename2)]);
    queue_lock.Leave;
    exit;
  end;

  predir1:= s1.sectiondir[section];
  predir2:= s2.sectiondir[section];

  dir:= RightStrv2(params, length(sitename1)+length(sitename2)+length(section)+3);
  if ((dir = '') and (predir1 = '')) then
  begin
    section:= 'PRE';
    predir1:= s1.sectiondir[section];
    predir2:= s2.sectiondir[section];
    dir:= RightStrv2(params, length(sitename1)+length(sitename2)+2);
  end;

  if ((0 < Pos('../', dir)) or (0 < Pos('/..', dir))) then
  begin
    irc_addText(channel, 'Syntax error.');
    queue_lock.Leave;
    exit;
  end;

  if (predir1 = '') then
  begin
    irc_addtext(channel, 'Site %s has no dir set for section %s.', [Bold(sitename1), section]);
    queue_lock.Leave;
    exit;
  end;
  if (predir2 = '') then
  begin
    irc_addtext(channel, 'Site %s has no dir set for section %s.', [Bold(sitename2), section]);
    queue_lock.Leave;
    exit;
  end;

  // most el kene keszitenunk a taskot es a pazot
  rc:= FindSectionHandler(section);
  rls:= rc.Create(dir, section);
  p:= PazoAdd(rls);
  pazo_id:= p.pazo_id;
  kb_list.AddObject('TRANSFER-'+IntToStr(RandomRange(10000000,99999999)), p);

  p.AddSite(sitename1, predir1);
  p.AddSite(sitename2, predir2);

  ps:= p.FindSite(sitename1);
  ps.AddDestination(sitename2);
  ps:= p.FindSite(sitename2);
  ps.AddSource(sitename1);

  ps:= TPazoSite(p.sources[0]);
  pd:= TPazoDirlistTask.Create(ps.name, p, '', True);
  AddTask(pd);
  QueueFire;
  queue_lock.Leave;

  irc_addtext(channel, 'Spread has started. Type !stop %s if you want.', [Bold(pazo_id)]);

  // most pedig varunk x mp-et es announceoljuk az eredmenyt, illetve megszakitjuk
  // ha meg kell hogy szakadjon
  ann:= config.ReadInteger('spread', 'announcetime', 20);
  lastAnn:= Now();
  while(true)do
  begin
    if(kilepes) then exit;
    Sleep(500);

    queue_lock.Enter;
    p:= FindPazoById(pazo_id);
    if p = nil then
    begin
      queue_lock.Leave;
      exit; // ez a szituacio nem nagyon fordulhat elo
    end;
    if p.stopped then
    begin
      irc_addtext(channel, 'Spreading of %s has stopped.',[Bold(dir)]);
      queue_lock.Leave;
      exit;
    end;

    if ((p.ready) or (p.readyerror)) then
    begin
      if not p.readyerror then
      begin
//        irc_addtext(channel, '%s DONE: %s',[Bold(dir), p.Stats]);
        Result:= True;
      end
      else
        irc_addtext(channel, '%s ERROR',[Bold(dir)]);
      queue_lock.Leave;
      Break;
    end;


    if((ann <> 0) and (SecondsBetween(Now, lastAnn) > ann)) then
    begin
      i:= '?';
      ps:= p.FindSite(sitename1);
      if ((ps <> nil) and (ps.dirlist <> nil)) then
        i:= IntToStr(ps.dirlist.Done);

      j:= '?';
      ps:= p.FindSite(sitename2);
      if ((ps <> nil) and (ps.dirlist <> nil)) then
        j:= IntToStr(ps.dirlist.RacedByMe);

      irc_addtext(channel, '%s: %s-%s %s-%s', [dir, sitename1, i, sitename2, j]);
      lastann:= Now();
    end;
    queue_lock.Leave;
  end;


end;


function IrcStop(th: TMyIrcThread; channel, params: string): Boolean;
var p: TPazo;
    pazo_id: Integer;
begin
  Result:= False; // ezutan nem akarunk ok-et
  pazo_id:= StrToIntDef(params, -1);
  if pazo_id = -1 then
  begin
    irc_addtext(channel, 'Syntax error.');
    exit;
  end;

  queue_lock.Enter;
  p:= FindPazoById(pazo_id);
  if p <> nil then
  begin
    p.stopped:= True;
    RemovePazo(p.pazo_id);
  end;
  queue_lock.Leave;
end;

function webstuff(dir: string): Boolean;
var i: Integer;
begin
  Result:= False;
  for i:= 0 to webtags.Count-1 do
    if 0 < Pos(webtags[i], dir) then
    begin
      Result:= True;
      exit;
    end;
end;

function IrcBatch(th: TMyIrcThread; channel, params: string): Boolean;
begin
  Result:= False;
  irc_addtext('not available in this version');
end;

function IrcBatchAdd(th: TMyIrcThread; channel, params: string): Boolean;
begin
  Result:= False;
  irc_addtext('not available in this version');
end;

function IrcBatchDel(th: TMyIrcThread; channel, params: string): Boolean;
var sitename, dir, ripper: string;
    i: integer;
begin
  Result:= False;

  sitename:= SubString(params, ' ', 1);
  dir:= SubString(params, ' ', 2);
  ripper:= SubString(params, ' ', 3);

  queue_lock.Enter;
  i:= batchqueue.IndexOf(sitename+#9+dir+#9+ripper);
  if i <> -1 then
  begin
    batchqueue.Delete(i);
    Result:= True;
  end;
  queue_lock.Leave;

  if not Result then
    irc_Addtext(channel, 'Cant find this one in the queue.');
end;



function IrcPre(th: TMyIrcThread; channel, params: string): Boolean;
begin
  Result:= False;
  irc_addtext('not available in this version');
end;


function IrcSslmethod(th: TMyIrcThread; channel, params: string): Boolean;
var sitename: string;
    s: TSite;
begin
  Result:= False;
  sitename:=  UpperCase(SubString(params, ' ', 1));

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    irc_addtext(channel, 'Site %s not found.', [Bold(sitename)]);
    queue_lock.Leave;
    exit;
  end;
  s.sslmethod:= TSSLMethods(StrToIntDef(SubString(params, ' ', 2), Integer(s.sslmethod)));

  queue_lock.Leave;

  Result:= True;
end;

function IrcSslfxp(th: TMyIrcThread; channel, params: string): Boolean;
var sitename: string;
    s: TSite;
    sslfxp: TSSLReq;
begin
  Result:= False;
  sitename:=  UpperCase(SubString(params, ' ', 1));
  sslfxp:= TSSLReq(StrToIntDef(SubString(params, ' ', 2), 0));

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    irc_addtext(channel, 'Site %s not found.', [Bold(sitename)]);
    queue_lock.Leave;
    exit;
  end;

  s.sslfxp:= sslfxp;

  queue_lock.Leave;

  Result:= True;
end;

function IrcLegacycwd(th: TMyIrcThread; channel, params: string): Boolean;
var sitename: string;
    s: TSite;
    cwd: Boolean;
begin
  Result:= False;
  sitename:=  UpperCase(SubString(params, ' ', 1));
  cwd:= StrToBoolDef(SubString(params, ' ', 2), False);

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    irc_addtext(channel, 'Site %s not found.', [Bold(sitename)]);
    queue_lock.Leave;
    exit;
  end;

  s.legacydirlist:= cwd;

  queue_lock.Leave;

  Result:= True;
end;

function IrcAddSite(th: TMyIrcThread; channel, params: string): Boolean;
var sitename, username, password: string;
    s: TSite;
    bnc: string;
    bnchost: string;
    bncport: Integer;
    i: Integer;
begin
  Result:= False;
  sitename:=  UpperCase(SubString(params, ' ', 1));
  username:= SubString(params, ' ', 2);
  password:= SubString(params, ' ', 3);
  bnc:= SubString(params, ' ', 4);
  bnchost:= SubString(bnc, ':', 1);
  bncport:= StrToIntDef(SubString(bnc, ':', 2),0);

  if(username = '') or (password = '') then
  begin
    irc_addtext(channel, 'Syntax error.');
    exit;
  end;

  if (bnchost = '') or (bncport = 0) then
  begin
    irc_addtext(channel, 'Syntax error.');
    exit;
  end;

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s <> nil then
  begin
    irc_addtext(channel, 'Site %s already added.', [Bold(sitename)]);
    queue_lock.Leave;
    exit;
  end;

  sitesdat.WriteString('site-'+sitename, 'username', username);
  sitesdat.WriteString('site-'+sitename, 'password', password);

  i:= 4;
  while(true) do
  begin
    bnc:= SubString(params, ' ', i);
    bnchost:= SubString(bnc, ':', 1);
    bncport:= StrToIntDef(SubString(bnc, ':', 2),0);
    if ((bnchost = '') or (bncport = 0)) then break;

    sitesdat.WriteString('site-'+sitename, 'bnc_host-'+IntToStr(i-4), bnchost);
    sitesdat.WriteInteger('site-'+sitename, 'bnc_port-'+IntToStr(i-4), bncport);

    inc(i);
  end;

  sites.Add(TSite.Create(sitename));

  queue_lock.Leave;
  Result:= True;
end;

function IrcAddBnc(th: TMyIrcThread; channel, params: string): Boolean;
var sitename: string;
    s: TSite;
    aktbnc, bnc: string;
    bnchost: string;
    bncport: Integer;
    i: Integer;
begin
  Result:= False;
  sitename:=  UpperCase(SubString(params, ' ', 1));
  bnc:= SubString(params, ' ', 2);
  bnchost:= SubString(bnc, ':', 1);
  bncport:= StrToIntDef(SubString(bnc, ':', 2),0);

  if (bnchost = '') or (bncport = 0) then
  begin
    irc_addtext(channel, 'Syntax error.');
    exit;
  end;

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    irc_addtext(channel, 'Site %s not found.', [Bold(sitename)]);
    queue_lock.Leave;
    exit;
  end;

  i:= 0;
  while(true) do
  begin
    aktbnc:= s.RCString('bnc_host-'+IntToStr(i), '');
    if(aktbnc = '') then break;
    inc(i);
  end;
  s.WCString('bnc_host-'+IntToStr(i), bnchost);
  s.WCInteger('bnc_port-'+IntToStr(i), bncport);

  queue_lock.Leave;
  Result:= True;
end;

(*
procedure ListChain(channel, chain: string);
var x: TStringList;
    i: Integer;
    s: string;
begin
  x:= TStringList.Create;
  sitesdat.ReadSection('chain-'+chain, x);
  s:= chain+': ';
  for i:= 0 to x.Count -1 do
  begin
    if i <> 0 then s:= s +', ';
    s:= s + x[i];
  end;
  x.Free;
  irc_addtext(channel, s);
end;

function IrcChains(th: TMyIrcThread; channel, params: string): Boolean;
var x: TStringList;
    i: Integer;
begin

  queue_lock.Enter;
  x:= TStringList.Create;
  sitesdat.ReadSections(x);
  for i:= 0 to x.Count -1 do
    if 1 = Pos('chain-', x[i]) then
      ListChain(channel, Copy(x[i], 7, 1000));
  x.Free;
  queue_lock.Leave;

  Result:= True;
end;

function IrcChain(th: TMyIrcThread; channel, params: string): Boolean;
var i: Integer;
    chain: string;
    sitename: string;
    s: TSite;
    x: TStringList;
begin
  Result:= False;
  chain:= UpperCase(SubString(params, ' ', 1));

  queue_lock.Enter;
  i:= 2;
  while(true)do
  begin
    sitename:= UpperCase(SubString(params, ' ', i));
    if(sitename = '') then break;

    s:= FindSiteByName(sitename);
    if s = nil then
    begin
      irc_addtext(channel, 'Site %s is not found.', [Bold(sitename)]);
      queue_lock.Leave;
      exit;
    end;

    if ('' <> sitesdat.ReadString('chain-'+chain, sitename, '')) then
      sitesdat.DeleteKey('chain-'+chain, sitename)
    else
      sitesdat.WriteString('chain-'+chain, sitename, '1');

    inc(i);
  end;
  x:= TStringList.Create;
  sitesdat.ReadSection('chain-'+chain,x);
  if x.Count = 0 then
    sitesdat.EraseSection('chain-'+chain);
  x.Free;
  queue_lock.Leave;

  Result:= True;
end;
*)

function IrcDelBnc(th: TMyIrcThread; channel, params: string): Boolean;
var sitename: string;
    s: TSite;
    bnc: string;
    aktbnchost, bnchost: string;
    aktbncport, bncport: Integer;
    i: Integer;
    megvan: Boolean;
begin
  Result:= False;
  sitename:=  UpperCase(SubString(params, ' ', 1));
  bnc:= SubString(params, ' ', 2);
  bnchost:= SubString(bnc, ':', 1);
  bncport:= StrToIntDef(SubString(bnc, ':', 2),0);

  if (bnchost = '') or (bncport = 0) then
  begin
    irc_addtext(channel, 'Syntax error.');
    exit;
  end;

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    irc_addtext(channel, 'Site %s not found.', [Bold(sitename)]);
    queue_lock.Leave;
    exit;
  end;

  i:= 0;
  megvan:= False;
  while(true) do
  begin
    aktbnchost:= s.RCString('bnc_host-'+IntToStr(i), '');
    aktbncport:= s.RCInteger('bnc_port-'+IntToStr(i), 0);
    if(aktbnchost = '') then break;

    if(not megvan) then
    begin
      if(aktbnchost = bnchost) and (aktbncport = bncport) then
      begin
        megvan:= true;
        sitesdat.DeleteKey('site-'+sitename, 'bnc_host-'+IntToStr(i));
        sitesdat.DeleteKey('site-'+sitename, 'bnc_port-'+IntToStr(i));
      end;
    end else
    begin
      sitesdat.DeleteKey('site-'+sitename, 'bnc_host-'+IntToStr(i));
      sitesdat.DeleteKey('site-'+sitename, 'bnc_port-'+IntToStr(i));
      s.WCString('bnc_host-'+IntToStr(i-1), aktbnchost);
      s.WCInteger('bnc_port-'+IntToStr(i-1), aktbncport);      
    end;

    inc(i);
  end;
  if(not megvan) then
  begin
    queue_lock.Leave;
    irc_Addtext(channel, 'Bnc not found.');
    exit;
  end;

  queue_lock.Leave;
  Result:= True;
end;

function IrcMaxUpDn(th: TMyIrcThread; channel, params: string): Boolean;
var sitename: string;
    s: TSite;
    up, dn: Integer;
begin
  Result:= False;
  sitename:=  UpperCase(SubString(params, ' ', 1));
  up:= StrToIntDef(SubString(params, ' ', 2),0);
  dn:= StrToIntDef(SubString(params, ' ', 3),0);

  if (up = 0) or (dn = 0) then
  begin
    irc_addtext(channel, 'Syntax error.');
    exit;
  end;

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    irc_addtext(channel, 'Site %s not found.', [Bold(sitename)]);
    queue_lock.Leave;
    exit;
  end;

  s.max_dn:= dn;
  s.max_up:= up;

  queue_lock.Leave;

  Result:= True;
end;

function IrcMaxIdle(th: TMyIrcThread; channel, params: string): Boolean;
var sitename: string;
    s: TSite;
    maxidle, idleinterval: Integer;
begin
  Result:= False;
  sitename:=  UpperCase(SubString(params, ' ', 1));
  maxidle:= StrToIntDef(SubString(params, ' ', 2), -1);
  idleinterval:= StrToIntDef(SubString(params, ' ', 3),0);

  if (maxidle = -1)  then
  begin
    irc_addtext(channel, 'Syntax error.');
    exit;
  end;

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    irc_addtext(channel, 'Site %s not found.', [Bold(sitename)]);
    queue_lock.Leave;
    exit;
  end;

  s.maxidle:= maxidle;
  if idleinterval <> 0 then
    s.idleinterval:= idleinterval;

  queue_lock.Leave;
  Result:= True;
end;

function IrcTimeout(th: TMyIrcThread; channel, params: string): Boolean;
var sitename: string;
    s: TSite;
    iotimeout, connnecttimeout: Integer;
begin
  Result:= False;
  sitename:=  UpperCase(SubString(params, ' ', 1));
  connnecttimeout:= StrToIntDef(SubString(params, ' ', 2), 0);
  iotimeout:= StrToIntDef(SubString(params, ' ', 3),0);

  if (connnecttimeout = 0) or (iotimeout = 0) then
  begin
    irc_addtext(channel, 'Syntax error.');
    exit;
  end;

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    irc_addtext(channel, 'Site %s not found.', [Bold(sitename)]);
    queue_lock.Leave;
    exit;
  end;

  s.io_timeout:= iotimeout;
  s.connect_timeout:= connnecttimeout;

  queue_lock.Leave;
  Result:= True;
end;

function IrcDelsite(th: TMyIrcThread; channel, params: string): Boolean;
var sitename: string;
    s: TSite;
(*
    x: TStringList;
    i: Integer;
*)
begin
  Result:= False;
  sitename:=  UpperCase(params);

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    irc_addtext(channel, 'Site %s not found.', [Bold(sitename)]);
    queue_lock.Leave;
    exit;
  end;

  sites.Remove(s);
  sitesdat.EraseSection('site-'+sitename);

  (* we are not using chains anymore
  x:= TStringList.Create;
  sitesdat.ReadSections(x);
  for i:= 0 to x.Count -1 do
    if 1 = Pos('chain-', x[i]) then
      sitesdat.DeleteKey('chain-'+Copy(x[i], 7, 1000), sitename);
  x.Free;
  *)

  // eltavolitjuk a rulejait is
  RulesRemove(sitename, '');
  queue_lock.Leave;

  Result:= True;
end;

function IrcSlots(th: TMyIrcThread; channel, params: string): Boolean;
var sitename: string;
    s: TSite;
    slots: Integer;
begin
  Result:= False;
  sitename:=  UpperCase(SubString(params, ' ', 1));
  slots:= StrToIntDef(SubString(params, ' ', 2), 0);

  if slots = 0 then
  begin
    irc_addtext(channel, 'Syntax error.');
    exit;
  end;

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    irc_addtext(channel, 'Site %s not found.', [Bold(sitename)]);
    queue_lock.Leave;
    exit;
  end;

  sites.Remove(s);
  sitesdat.WriteInteger('site-'+sitename, 'slots', slots );
  sites.Add(TSite.Create(sitename));

  queue_lock.Leave;
  Result:= True;
end;



function IrcQueue(th: TMyIrcThread; channel, params: string): Boolean;
var i: Integer;
begin

  queue_lock.Enter;
  irc_Addtext(channel, 'Tasks in queue: %d', [tasks.Count]);
  for i:= 0 to Min(tasks.Count -1, 9) do
    irc_Addtext(channel, TTask(tasks[i]).Fullname);

  queue_lock.Leave;
  Result:= True;
end;

procedure RawB(sitename, dir, command, channel: string);
var
    r: TRawTask;
    tn: TTaskNotify;
    i: Integer;
    ss: string;

begin
  queue_lock.Enter;
  r:= TRawTask.Create(sitename, dir, command);
  tn:= AddNotify;
  tn.tasks.Add(r);
  AddTask(r);
  QueueFire;
  queue_lock.Leave;

  tn.event.WaitFor($FFFFFFFF);


  queue_lock.Enter;
  if tn.responses.Count = 1 then
  begin
    i:= 1;
    while(true) do
    begin
      ss:= SubString(TSiteResponse(tn.responses[0]).response, EOL, i);
      if ss = '' then break;

      Announce(section, False, ss);
      inc(i);
    end;

  end;
  RemoveTN(tn);
  queue_lock.Leave;

end;

function IrcInvite(th: TMyIrcThread; channel, params: string): Boolean;
var sitename: string;
    s: TSite;
begin
  Result:= False;
  sitename:= UpperCase(SubString(params, ' ', 1));

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    irc_addtext(channel, 'Site %s not found.', [Bold(sitename)]);
    queue_lock.Leave;
    exit;
  end;
  queue_lock.Leave;

  RawB(sitename, '', 'SITE INVITE '+nickname, channel);

  Result:= True;
end;
function IrcRaw(th: TMyIrcThread; channel, params: string): Boolean;
var command, sitename: string;
    s: TSite;
begin
  Result:= False;
  sitename:= UpperCase(SubString(params, ' ', 1));
  command:= RightStrv2(params, Length(sitename)+1);

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    irc_addtext(channel, 'Site %s not found.', [Bold(sitename)]);
    queue_lock.Leave;
    exit;
  end;
  queue_lock.Leave;

  RawB(sitename, '', command, channel);

  Result:= True;
end;
function IrcPretest(th: TMyIrcThread; channel, params: string): Boolean;
begin
  Result:= False;
  irc_addtext('not available in this version');
end;


function Bnctest(channel: string; s: TSite; tn: TTaskNotify; kill: Boolean = False): Boolean;
var
  l: TLoginTask;
begin
        l:= TLoginTask.Create(s.name, kill, False);
        if tn <> nil then
          tn.tasks.Add(l);
        AddTask(l);
        Result:= True;
end;

(* ez a regi verzio
function Bnctest(channel: string; s: TSite; tn: TTaskNotify; kill: Boolean = False): Boolean;
var
    l: TLoginTask;
    j: Integer;
    online: Boolean;
begin
  Result:= False;

  online:= False;
      for j:= 0 to s.slots.Count -1 do
        if ((TSiteSlot(s.slots[j]).Status = ssOnline) and (not kill)) then
        begin
          online:= True;
          irc_Addtext(channel, '%s IS ALREADY UP: %s', [Bold(s.name), TSiteSlot(s.slots[j]).bnc]);

          // nem szep de egyelore ez van
          TSiteSlot(s.slots[j]).site.working:= sstUp;

          Break;
        end;

      if not online then
      begin
        l:= TLoginTask.Create(s.name, kill, False);
        if tn <> nil then
          tn.tasks.Add(l);
        AddTask(l);
        Result:= True;
      end;

end;
*)

procedure SitesB(channel: string);
var up, down, unk: string;
    i: Integer;
    s: TSite;
begin
  up:= '';
  down:= '';
  unk:= '';
  queue_lock.Enter;
  for i:= 0 to sites.Count -1 do
  begin
    s:= TSite(sites[i]);
    case s.working of
      sstUp: begin if up <> '' then up:= up+', '; up:= up + Bold(s.name) end;
      sstDown: begin if down <> '' then down:= down+', '; down:= down + Bold(s.name) end;
      sstUnknown: begin if unk <> '' then unk:= unk+', '; unk:= unk + Bold(s.name) end;
    end;
  end;
  queue_lock.Leave;

  if up <> '' then
    irc_AddText(channel, 'UP: '+up);
  if down <> '' then
    irc_AddText(channel, 'DN: '+down);
  if unk <> '' then
    irc_AddText(channel, '??: '+unk);
end;

function IrcKill(th: TMyIrcThread; channel, params: string): Boolean;
var sitename: string;
    s: TSite;
begin
  Result:= False;

    sitename:= UpperCase(params);
    queue_lock.Enter;
    s:= FindSiteByName(sitename);
    if s = nil then
    begin
      irc_Addtext(channel, 'Site %s not found.', [Bold(sitename)]);
      queue_lock.Leave;
      exit;
    end;

    if BncTest(channel, s, nil, True) then
      QueueFire;

    queue_lock.Leave;


  Result:= True;
end;

function IrcBnctest(th: TMyIrcThread; channel, params: string): Boolean;
var s: TSite;
    x: TStringList;
    tn: TTaskNotify;
    added: Boolean;
    i: Integer;
    db: Integer;
begin
  Result:= False;
  added:= False;
  x:= TStringList.Create;
  x.Delimiter:= ' ';
  x.DelimitedText:= UpperCase(params);
  db:= 0;
  queue_lock.Enter;
  if x.Count > 0 then
  begin
    db:= x.Count;
    for i:= 0 to x.Count -1 do
    begin
      s:= FindSiteByName(x[i]);
      if s = nil then
      begin
        queue_lock.Leave;
        irc_addtext(channel, 'Site %s not found', [x[i]]);
        exit;
      end;
    end;
    tn:= AddNotify;    
    for i:= 0 to x.Count -1 do
    begin
      s:= FindSiteByName(x[i]);
      if BncTest(channel, s, tn) then
        added:= True;
    end;
  end else
  begin
    tn:= AddNotify;
    for i:= 0 to sites.Count -1 do
    begin
      inc(db);
      s:= TSite(sites[i]);
      if BncTest(channel, s, tn) then
        added:= True;
    end;
  end;
  if added then
    QueueFire;
  queue_lock.Leave;

  if added then
    tn.event.WaitFor($FFFFFFFF);

  if (db > 1) then
    Sitesb(channel);

  x.Free;

  queue_lock.Enter;
  RemoveTN(tn);
  queue_lock.Leave;


  Result:= True;
end;


function IrcSetdown(th: TMyIrcThread; channel, params: string): Boolean;
var sitename: string;
    s: TSite;
begin
  Result:= False;
  sitename:= UpperCase(params);

  queue_lock.Enter;
    s:= FindSiteByName(sitename);
    if s = nil then
    begin
      irc_Addtext(channel, 'Site %s not found.', [Bold(sitename)]);
      queue_lock.Leave;
      exit;
    end;

  s.markeddown:= True;
  s.working:= sstDown;
  QueueFire; // hogy eltavolitsuk a queue bejegyzeseket
  queue_lock.Leave;

  Result:= True;

end;

function IrcAddnet(th: TMyIrcThread; channel, params: string): Boolean;
var netname, host, password: string;
    port: Integer;
    ssl: Integer;
begin
  Result:= False;

  netname:= UpperCase(SubString(params, ' ', 1));
  if(0 < Pos('-', netname)) then
  begin
    irc_addText(channel, 'Syntax error');
    exit;
  end;
  host:= SubString(params, ' ', 2);
  port:= StrToIntDef(SubString(host, ':', 2), 0);
  if port <= 0 then
  begin
    irc_addText(channel, 'Syntax error');
    exit;
  end;
  host:= SubString(host, ':',1);
  ssl:= StrToIntDef(SubString(params, ' ', 3), -1);
  if ((ssl < 0) or (ssl > 1)) then
  begin
    irc_addText(channel, 'Syntax error');
    exit;
  end;
  password:= SubString(params, ' ', 4);

  irc_lock.Enter;
  if nil <> FindIrcnetwork(netname) then
  begin
    irc_addText(channel, 'Network with name %s already exists!', [netname]);
    irc_lock.Leave;
    exit;
  end;

  sitesdat.WriteString('ircnet-'+netname, 'host', host);
  sitesdat.WriteInteger('ircnet-'+netname, 'port', port);
  sitesdat.WriteBool('ircnet-'+netname, 'ssl', Boolean(ssl));

  myIrcThreads.Add(TMyIrcThread.Create(netname));

  irc_lock.Leave;


  Result:= True;

end;

function IrcModnet(th: TMyIrcThread; channel, params: string): Boolean;
var netname, host, password: string;
    port: Integer;
    ssl: Integer;
begin
  Result:= False;

  netname:= UpperCase(SubString(params, ' ', 1));
  if(0 < Pos('-', netname)) then
  begin
    irc_addText(channel, 'Syntax error');
    exit;
  end;
  host:= SubString(params, ' ', 2);
  port:= StrToIntDef(SubString(host, ':', 2), 0);
  if port <= 0 then
  begin
    irc_addText(channel, 'Syntax error');
    exit;
  end;
  host:= SubString(host, ':',1);
  ssl:= StrToIntDef(SubString(params, ' ', 3), -1);
  if ((ssl < 0) or (ssl > 1)) then
  begin
    irc_addText(channel, 'Syntax error');
    exit;
  end;
  password:= SubString(params, ' ', 4);

  irc_lock.Enter;
  if nil = FindIrcnetwork(netname) then
  begin
    irc_addText(channel, 'Network with name %s doesnt exists!', [netname]);
    irc_lock.Leave;
    exit;
  end;

  sitesdat.WriteString('ircnet-'+netname, 'host', host);
  sitesdat.WriteInteger('ircnet-'+netname, 'port', port);
  sitesdat.WriteBool('ircnet-'+netname, 'ssl', Boolean(ssl));
  irc_lock.Leave;

  IrcJump(th, channel, netname);

  Result:= True;

end;

function IrcDelnet(th: TMyIrcThread; channel, params: string): Boolean;
var i: Integer;
    s: TSite;
    ircth: TMyIrcThread;
    b: TIrcBlowkey;
begin
  Result:= False;

  params:= UpperCase(trim(params));
  if params = 'MAIN' then
  begin
    irc_Addtext(channel, 'You cant delete the main network.');
    exit;
  end;

  irc_lock.Enter;
  ircth:= FindIrcNetwork(params);
  if ircth <> nil then
  begin
    ircth.shouldquit:= True;
    sitesdat.EraseSection('ircnet-'+params);
  end;

  irc_lock.Leave;

  // most meg le kell wipeolnunk a siteokrol is ezt a networkot
  queue_lock.Enter;
  for i:= 0 to sites.Count -1 do
  begin
    s:= sites[i] as TSite;
    if s.RCString('ircnet', '') = params then
    begin
      s.DeleteKey('ircnet');
    end;
  end;

  queue_lock.Leave;

  // most meg le kell torolnunk a chanjait
  irc_lock.Enter;

  i:= 0;
  while (i < chankeys.Count) do
  begin
    b:= chankeys[i] as TIrcBlowkey;
    if b.netname = params then
    begin
      sitesdat.EraseSection('channel-'+b.netname+'-'+b.channel);
      chankeys.Remove(b);
      dec(i);
    end;
    inc(i);
  end;
  irc_lock.Leave;


  Result:= True;

end;

function IrcJump(th: TMyIrcThread; channel, params: string): Boolean;
var ircth: TMyIrcThread;
begin
  params:= UpperCase(trim(params));

  irc_lock.Enter;
  ircth:= FindIrcNetwork(params);
  if ircth <> nil then
    ircth.shouldrestart:= True;

  irc_lock.Leave;
  Result:= True;

end;

function IrcStatus(th: TMyIrcThread; channel, params: string): Boolean;
var i: Integer;
 (*
    r: TRelease;
    p: TPazo;
    ps: TPazoSite;
    pt: TPazoMkdirTask;
 *)
begin
 (*
// ez teszt miatt volt itt
  queue_lock.Enter;
  r:= TRelease.Create('Testing-Foobar-Foobar-2009-BERC', 'MP3');
  p:= PazoAdd(r);
  ps:= TPazoSite.Create(p, 'CC', '/MP3-TODAY', False);
  p.sites.Add(ps);
  pt:= TPazoMkdirTask.Create('CC', p, '');
  pt.dependencies.Add(pt);
  AddTask(pt);
  queue_lock.Leave;
  exit;
  *)
  irc_lock.Enter;
  for i:= 0 to myIrcThreads.Count-1 do
    with myIrcThreads[i] as TMyIrcThread do
    begin
      irc_queue.Add(channel+' '+Format('%s (%s:%d): %s',[netname, Host, Port, status]));
      irc_queue_nets.Add('MAIN');
    end;
  irc_lock.Leave;
  Result:= True;
end;

function IrcChannels(th: TMyIrcThread; channel, params: string): Boolean;
var i: Integer;
    b: TIrcBlowkey;
    netname: string;
begin
  netname:= Uppercase(Trim(params));
  irc_lock.Enter;
  for i:= 0 to chankeys.Count -1 do
  begin
    b:= chankeys[i] as TIrcBlowKey;
    if ((netname = '') or (netname = b.netname)) then
    begin
      irc_queue.Add(channel+' '+ Format('%s -> blowkey(%s) chankey(%s)',[ b.channel, b.blowkey, b.chankey])); //inviteonly(%s) BoolToStr(b.inviteonly, True)
      irc_queue_nets.Add('MAIN');
    end;
  end;
  irc_lock.Leave;
  Result:= True;
end;

function IrcSay(th: TMyIrcThread; channel, params: string): Boolean;
var netname, blowchannel, tosay: string;
begin
  Result:= False;
  netname:= Uppercase(SubString(params, ' ', 1));
  blowchannel:= SubString(params, ' ', 2);
  tosay:= RightStrv2(params, Length(netname)+Length(blowchannel)+2);
  irc_lock.Enter;
  if nil = FindIrcBlowfish(netname, blowchannel, False) then
  begin
    irc_lock.Leave;
    irc_addtext('Cant find channel.');
    exit;
  end;

  irc_queue.Add(blowchannel+' '+tosay);
  irc_queue_nets.Add(netname);
  irc_lock.Leave;
  Result:= True;
end;

function IrcSetChankey(th: TMyIrcThread; channel, params: string): Boolean;
var netname, blowchannel, key: string;
    b: TIrcBlowkey;
    ircth: TMyIrcThread;
begin
  Result:= False;
  netname:= Uppercase(SubString(params, ' ', 1));
  blowchannel:= SubString(params, ' ', 2);
  key:= RightStrv2(params, length(netname)+length(blowchannel)+2);

  irc_lock.Enter;
  ircth:= FindIrcnetwork(netname);
  irc_lock.Leave;

  if ircth = nil then
  begin
    irc_Addtext('Cant find network');
    exit;
  end;

  irc_lock.Enter;
  b:= FindIrcBlowfish(netname, blowchannel, False);
  if b <> nil then
  begin
    b.chankey:= key;
  end else
  begin
    if key <> '' then
      irc_RegisterChannel(netname, blowchannel, '', key);
  end;

  irc_lock.Leave;

  sitesdat.WriteString('channel-'+netname+'-'+blowchannel, 'chankey', key);

    irc_lock.Enter;
    ircth:= FindIrcnetwork(netname);
    if ircth <> nil then
      ircth.shouldjoin:= True;
    irc_lock.Leave;

  Result:= True;
end;

(*
function IrcSetChanInvite(th: TMyIrcThread; channel, params: string): Boolean;
var netname, blowchannel: string;
    b: TIrcBlowkey;
    ircth: TMyIrcThread;
    inviteonly: Boolean;
begin
  Result:= False;
  netname:= Uppercase(SubString(params, ' ', 1));
  blowchannel:= SubString(params, ' ', 2);
  inviteonly:= Boolean(StrToIntDef(SubString(params, ' ', 3), 0));

  irc_lock.Enter;
  ircth:= FindIrcnetwork(netname);
  irc_lock.Leave;

  if ircth = nil then
  begin
    irc_Addtext('Cant find network');
    exit;
  end;

  irc_lock.Enter;
  b:= FindIrcBlowfish(netname, blowchannel, False);
  if b <> nil then
  begin
    b.inviteonly:= inviteonly;
  end else
  begin
    irc_RegisterChannel(netname, blowchannel, '', '', inviteonly);
  end;

  irc_lock.Leave;

  sitesdat.WriteBool('channel-'+netname+'-'+blowchannel, 'inviteonly', inviteonly);

    irc_lock.Enter;
    ircth:= FindIrcnetwork(netname);
    if ircth <> nil then
      ircth.shouldjoin:= True;
    irc_lock.Leave;


  Result:= True;
end;
*)

function IrcDelchan(th: TMyIrcThread; channel, params: string): Boolean;
var netname, blowchannel: string;
    b: TIrcBlowkey;
    ircth: TMyIrcThread;
begin
  Result:= False;
  netname:= Uppercase(SubString(params, ' ', 1));
  blowchannel:= SubString(params, ' ', 2);

  irc_lock.Enter;
  ircth:= FindIrcnetwork(netname);
  irc_lock.Leave;

  if ircth = nil then
  begin
    irc_Addtext('Cant find network');
    exit;
  end;

  irc_lock.Enter;
  b:= FindIrcBlowfish(netname, blowchannel, False);
  if b <> nil then
    chankeys.Remove(b);

  irc_lock.Leave;

  sitesdat.EraseSection('channel-'+netname+'-'+blowchannel);

    irc_lock.Enter;
    ircth:= FindIrcnetwork(netname);
    if ircth <> nil then
      ircth.shouldjoin:= True;
    irc_lock.Leave;

  Result:= True;
end;


function IrcSetBlowkey(th: TMyIrcThread; channel, params: string): Boolean;
var netname, blowchannel, key: string;
    b: TIrcBlowkey;
    ircth: TMyIrcThread;
begin
  Result:= False;
  netname:= Uppercase(SubString(params, ' ', 1));
  blowchannel:= SubString(params, ' ', 2);
  key:= RightStrv2(params, length(netname)+length(blowchannel)+2);

  irc_lock.Enter;
  ircth:= FindIrcnetwork(netname);
  irc_lock.Leave;
  if ircth = nil then
  begin
    irc_Addtext('Cant find network');
    exit;
  end;

  irc_lock.Enter;
  b:= FindIrcBlowfish(netname, blowchannel, False);
  if b <> nil then
  begin
    if key <> '' then
    begin
      b.UpdateKey(key);
    end
    else
    begin
      chankeys.Remove(b);
    end;
  end else
  begin
    irc_RegisterChannel(netname, blowchannel, key);
  end;
  irc_lock.Leave;

  sitesdat.WriteString('channel-'+netname+'-'+blowchannel, 'blowkey', key);
  if ((key = '') and (sitesdat.ReadString('channel-'+netname+'-'+blowchannel, 'chankey', '') = '')) then
    sitesdat.EraseSection('channel-'+netname+'-'+blowchannel);

  Result:= True;
end;

function IrcSitechan(th: TMyIrcThread; channel, params: string): Boolean;
var sitename, netname: string;
    s: TSite;
begin
  Result:= False;
  sitename:= Uppercase(SubString(params, ' ', 1));
  netname:= Uppercase(SubString(params, ' ', 2));
  if netname <> '' then
  begin
    irc_lock.Enter;
    if nil = FindIrcnetwork(netname) then
    begin
      irc_lock.Leave;
      irc_addtext('Cant find network.');
      exit;
    end;
    irc_lock.Leave;
  end;

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if nil = s then
  begin
    irc_lock.Leave;
    irc_addtext('Cant find site.');
    exit;
  end;
  if netname <> '' then
    s.WCString('ircnet', netname)
  else
    s.DeleteKey('ircnet');
  queue_lock.Leave;

  Result:= True;
end;

function IrcRuleAdd(th: TMyIrcThread; channel, params: string): Boolean;
var r: TRule;
    sitename, rule, section, error: string;
    s: TSite;
begin
  Result:= False;
  sitename:= UpperCase(Substring(params, ' ', 1));
  section:= UpperCase(Substring(params, ' ', 2));
  rule:= params;

  if rule = '' then
  begin
    irc_Addtext('Syntax error');
    exit;
  end;

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if (nil = s) then
  begin
    irc_Addtext(channel, 'Site %s not found.', [sitename]);
    queue_lock.Leave;
    exit;
  end;
  if ((section <> 'GENERIC') and (s.sectiondir[section] = '')) then
  begin
    irc_Addtext(channel, 'Site %s has no section %s.', [sitename, section]);
    queue_lock.Leave;
    exit;
  end;

  r:= AddRule(rule, error);
  if ((r = nil) or (error <> '')) then
  begin
    irc_Addtext('Syntax error: '+error);
    queue_lock.Leave;
    exit;
  end;

  rules.Add(r);

  RulesSave;


  queue_lock.Leave;

  Result:= True;

end;
function IrcRuleIns(th: TMyIrcThread; channel, params: string): Boolean;
var id: Integer;
    r: TRule;
    sitename, rule, section, error: string;
    s: TSite;
begin
  Result:= False;
  id:= StrToIntDef(SubString(params, ' ', 1), -1);
  sitename:= UpperCase(Substring(params, ' ', 2));
  section:= UpperCase(Substring(params, ' ', 3));
  rule:= Copy(params, Length(IntToStr(id)) +2 , 1000);

  if rule = '' then
  begin
    irc_Addtext('Syntax error');
    exit;
  end;

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if (nil = s) then
  begin
    irc_Addtext(channel, 'Site %s not found.', [sitename]);
    queue_lock.Leave;
    exit;
  end;
  if ((section <> 'GENERIC') and (s.sectiondir[section] = '')) then
  begin
    irc_Addtext(channel, 'Site %s has no section %s.', [sitename, section]);
    queue_lock.Leave;
    exit;
  end;

  if ((id < 0) or (id >= rules.Count)) then
  begin
    irc_Addtext('Incorrect rule id');
    queue_lock.Leave;
    exit;
  end;

  r:= AddRule(rule, error);
  if ((r = nil) or (error <> '')) then
  begin
    irc_Addtext('Syntax error: '+error);
    queue_lock.Leave;
    exit;
  end;

  rules.Insert(id, r);

  RulesSave;


  queue_lock.Leave;

  Result:= True;
end;
function IrcRuleMod(th: TMyIrcThread; channel, params: string): Boolean;
var id: Integer;
    r: TRule;
    sitename, rule, section, error: string;
    s: TSite;
begin
  Result:= False;
  id:= StrToIntDef(SubString(params, ' ', 1), -1);
  sitename:= UpperCase(Substring(params, ' ', 2));
  section:= UpperCase(Substring(params, ' ', 3));
  rule:= Copy(params, Length(IntToStr(id)) +2 , 1000);

  if rule = '' then
  begin
    irc_Addtext('Syntax error');
    exit;
  end;

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if (nil = s) then
  begin
    irc_Addtext(channel, 'Site %s not found.', [sitename]);
    queue_lock.Leave;
    exit;
  end;
  if ((section <> 'GENERIC') and (s.sectiondir[section] = '')) then
  begin
    irc_Addtext(channel, 'Site %s has no section %s.', [sitename, section]);
    queue_lock.Leave;
    exit;
  end;

  if ((id < 0) or (id >= rules.Count)) then
  begin
    irc_Addtext('Incorrect rule id');
    queue_lock.Leave;
    exit;
  end;

  r:= AddRule(rule, error);
  if ((r = nil) or (error <> '')) then
  begin
    irc_Addtext('Syntax error: '+error);
    queue_lock.Leave;
    exit;
  end;

  rules.Delete(id);
  rules.Insert(id, r);

  RulesSave;


  queue_lock.Leave;

  Result:= True;
end;
function IrcRuleDel(th: TMyIrcThread; channel, params: string): Boolean;
var id: Integer;
begin
  Result:= False;
  id:= StrToIntDef(params, -1);

  queue_lock.Enter;
  if ((id < 0) or (id >= rules.Count)) then
  begin
    irc_Addtext('Incorrect rule id');
    queue_lock.Leave;
    exit;
  end;

  rules.Delete(id);
  RulesSave;
  queue_lock.Leave;

  Result:= True;
end;
function IrcRuleHelp(th: TMyIrcThread; channel, params: string): Boolean;
var i: Integer;
begin

  for i:= Low(conditions) to High(conditions) do
  begin
    if TCCondition(conditions[i]).name = params then
      irc_addtext(TCCondition(conditions[i]).Description);
  end;

  Result:= True;
end;

function IrcRules(th: TMyIrcThread; channel, params: string): Boolean;
var i: Integer;
    r: TRule;
    sitename, section: string;
begin
  sitename:= UpperCase(SubString(params, ' ', 1));
  section:= UpperCase(SubString(params, ' ', 2));
  queue_lock.Enter;
  for i:= 0 to rules.Count -1 do
  begin
    r:= TRule(rules[i]);
    if ((r.sitename = sitename) and (r.section = section)) then
    begin
      irc_Addtext(channel, '%d %s', [i, r.AsText(True)]);
    end;
  end;
  queue_lock.Leave;

  Result:= True;
end;

function IrcRuleList(th: TMyIrcThread; channel, params: string): Boolean;
var i: Integer;
    latest: string;
    latestline: string;
begin

  latestline:= '';
  latest:= '';
  for i:= Low(conditions) to High(conditions) do
  begin
    if TCCondition(conditions[i]).name <> latest then
    begin
      if latestline <> '' then
        irc_addtext(latestline);
      latest:= TCCondition(conditions[i]).name;
      latestline:= TCCondition(conditions[i]).name;
      if TCCondition(conditions[i]).operator <> '' then
        latestline:= latestline + ', ops: '
    end;
    latestline:= latestline+ TCCondition(conditions[i]).operator+' ';
  end;
  if latestline <> '' then
    irc_addtext(latestline);


  Result:= True;
end;

function IrcPrereload(th: TMyIrcThread; channel, params: string): Boolean;
begin
  queue_lock.Enter;
  PrecatcherReload;
  queue_lock.Leave;  
  Result:= True;
end;

function IrcPredebug(th: TMyIrcThread; channel, params: string): Boolean;
begin
  precatcher_debug:= Boolean(StrToIntDef(Params, 0));
  Result:= True;
end;

function IrcPreadd(th: TMyIrcThread; channel, params: string): Boolean;
var sitename, netname, channelname, botnicks, event, words, section: string;
begin
  Result:= False;
  sitename:= UpperCase(SubString(params, ' ', 1));
  netname:= UpperCase(SubString(params, ' ', 2));
  channelname:= SubString(params, ' ', 3);
  botnicks:= SubString(params, ' ', 4);
  event:= UpperCase(SubString(params, ' ', 5));
  words:= SubString(params, ' ', 6);
  section:= SubString(params, ' ', 7);
  if event = '-' then event:= '';
  if words = '-' then words:= '';
  if section = '-' then section:= '';

  queue_lock.Enter;
  if nil = FindSiteByName(sitename) then
  begin
    queue_lock.Leave;
    irc_Addtext('Site not found');
    exit;
  end;
  queue_lock.Leave;

  irc_lock.Enter;
  if nil = FindIrcBlowfish(netname, channelname, False) then
  begin
    irc_lock.Leave;
    irc_Addtext('Channel not found.');
    exit;
  end;
  irc_lock.Leave;

  queue_lock.Enter;
  catcherFile.Add(Format('%s;%s;%s;%s;%s;%s;%s',[netname, channelname, botnicks, sitename, event,words, section]));
  PrecatcherRebuild;
  queue_lock.Leave;

  Result:= True;
end;
function IrcPredel(th: TMyIrcThread; channel, params: string): Boolean;
var i: Integer;
begin
  Result:= False;
  i:= StrToIntDef(params, -1);
  if i < 0 then
  begin
    irc_addText('Syntax error.');
    exit;
  end;
  queue_lock.Enter;
  if catcherFile.Count > i then
    catcherFile.Delete(i);
  PrecatcherRebuild();
  queue_lock.Leave;
  Result:= True;
end;

function IrcPrelist(th: TMyIrcThread; channel, params: string): Boolean;
var i: Integer;
    s1, s2: string;
    mehetki: Boolean;
    netname, aktchannel, sitename, nick, event, words, section: string;
begin
  Result:= False;
  s1:= Uppercase(SubString(params, ' ', 1));
  s2:= SubString(params, ' ', 2);

  if ((s1 <> '') and (s2 <> '')) then
  begin
    irc_lock.Enter;
    if nil = FindIrcBlowfish(s1, s2, False) then
    begin
      irc_lock.Leave;
      irc_Addtext('Cant find channel.');
      exit;
    end;
    irc_lock.Leave;
  end
  else
  if (s1 <> '') then
  begin
    queue_lock.Enter;
    if nil = FindSiteByName(s1) then
    begin
      queue_lock.Leave;
      irc_Addtext('Cant find site.');
      exit;
    end;
    queue_lock.Leave;
  end;

  queue_lock.Enter;
  for i:= 0 to catcherFile.Count-1 do
  begin
    netname:= SubString(catcherFile[i],';', 1);
    aktchannel:= SubString(catcherFile[i],';', 2);
    nick:= SubString(catcherFile[i],';', 3);
    sitename:= SubString(catcherFile[i],';', 4);
    event:= SubString(catcherFile[i],';', 5);
    words:= SubString(catcherFile[i],';', 6);
    section:= SubString(catcherFile[i],';', 7);

    mehetki:= False;
    if ((s1 <> '') and (s2 <> '')) then
    begin
      if ((s1 = netname) and (s2 = aktchannel)) then mehetki:= True;
    end
    else
    if (s1 <> '' ) then
    begin
      if sitename = s1 then mehetki:= True;
    end
    else
      mehetki:= True;

    if mehetki then
      irc_addtext(channel, '#%d %s-%s-%s <%s> [%s] {%s} (%s)', [i, sitename, netname, aktchannel, nick, event, words, section]);
  end;
  queue_lock.Leave;
  Result:= True;
end;



function IrcUptime(th: TMyIrcThread; channel, params: string): Boolean;
var d: Int64; u: string;
begin

  d:= DateTimeToUnix(Now)-DateTimeToUnix(started);
  if d > 24*60*60 then begin d:= d div (24*60*60); u:= 'days' end
  else
  if d > 60*60 then begin d:= d div (60*60); u:= 'hours' end
  else
  if d > 60 then begin d:= d div 60; u:= 'minutes' end
  else
  begin u:= 'seconds' end;
  irc_AddText(channel, '%s is up for %d %s', [Red(Get_VersionString(ParamStr(0))), d, u]);
  Result:= True;
end;


function IrcHelp(th: TMyIrcThread; channel, params: string): Boolean;
var i: Integer;
    s: string;
    f: TextFile;
    fn: string;
begin

  if params <> '' then
  begin
    if (1 = Pos(th.cmdprefix, params)) then // commandhandlerrel kezdodik
      params:= Copy(params, length(th.cmdprefix)+1, 1000);

    i:= FindIrcCommand(params);
    if i <> 0 then
    begin
      fn:= 'help'+PathDelim+params+'.txt';
      if FileExists(fn) then
      begin
        AssignFile(f, fn);
        Reset(f);
        while not eof(f) do
        begin
          ReadLn(f,s);
          s:= Trim(s);
          if s <> '' then
          begin
            s:= Csere(s, '<prefix>', th.cmdprefix);
            s:= Csere(s, '<cmd>', th.cmdprefix+params);
            irc_AddText(channel, s);
          end;
        end;
        CloseFile(f);
      end else
        irc_AddText(channel, 'No help available on '+params)
    end
    else
      irc_AddText(channel, 'Command not found.');
  end else
  begin
    irc_AddText(channel, 'Available commands are:');
    s:= '';
    for i:= Low(irccommands) to High(irccommands) do
    begin
      if (irccommands[i].cmd[1] = '-')  then
      begin
        if s <> '' then
          irc_AddText(channel, s);
        if(irccommands[i].cmd <> '-') then
          irc_AddText(channel, irccommands[i].cmd);
        s:= '';
      end else
      begin
        if s <> '' then s:= s + ', ';
        s:= s + th.cmdprefix+ irccommands[i].cmd;
      end;
    end;
    if s <> '' then
       irc_AddText(channel, s);
    irc_AddText(channel, 'Type %shelp command to get detailed info.', [th.cmdprefix]);
  end;

  Result:= True;
end;

function IrcSites(th: TMyIrcThread; channel, params: string): Boolean;
begin

  Sitesb(channel);
  Result:= True;
end;


function IrcSite(th: TMyIrcThread; channel, params: string): Boolean;
var i: Integer;
    s: TSite;
    host, sitename: string;
    x: TStringList;
begin
  Result:= False;
  sitename:= UpperCase(params);
  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    irc_addtext(channel, 'Site %s not found.', [Bold(sitename)]);
    queue_lock.Leave;
    exit;
  end;

  x:= TStringList.Create;
  sitesdat.ReadSection('site-'+sitename, x);
  x.Sort;

  irc_addtext(channel, 'Site %s:', [Bold(sitename)]);
  for i:= 0 to x.Count -1 do
  begin
    if x[i] = 'password' then Continue;
    if (Copy(x[i], 1, 3) = 'bnc') then Continue;

    irc_addtext(channel, ' %s: %s', [x[i], s.RCString(x[i], '')]);
  end;
  x.Free;

   i:= 0;
    while (not kilepes) do
    begin
      host:= s.RCString('bnc_host-'+IntToStr(i), '');
      if host = '' then break;

      irc_addtext(channel, ' bnc: %s:%d', [host, s.RCInteger('bnc_port-'+IntToStr(i), 0)]);

      inc(i);
    end;

  queue_lock.Leave;

  Result:= True;
end;

function IrcDie(th: TMyIrcThread; channel, params: string): Boolean;
begin
  kilepes:= True;
  Result:= True;
end;

function IrcAffils(th: TMyIrcThread; channel, params: string): Boolean;
var ss, sitename, affils, section: string;
    s: TSite;
begin
  Result:= False;
  sitename:= UpperCase(SubString(params, ' ', 1));
  section:= UpperCase(SubString(params, ' ', 2));
  affils:= RightStrV2(params, Length(sitename)+Length(section)+2);

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    queue_lock.Leave;
    irc_addtext(channel, 'Site %s not found.', [sitename]);
    exit;
  end;
  ss:= s.SetAffils(section, affils, True);
  queue_lock.Leave;
  if ss <> '' then
    irc_addtext(ss);

  Result:= True;
end;

function IrcIdent(th: TMyIrcThread; channel, params: string): Boolean;
var ss, sitename: string;
    s: TSite;
    ident: string;
begin
  Result:= False;
  sitename:= UpperCase(SubString(params, ' ', 1));
  ident:= RightStrV2(params, Length(sitename)+1);

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    queue_lock.Leave;
    irc_addtext(channel, 'Site %s not found.', [sitename]);
    exit;
  end;
  if ident <> '' then
    s.WCString('ident', ident)
  else
    s.DeleteKey('ident');
  ss:= s.RCString('ident', config.ReadString(section, 'response', 'rsctm'));
  queue_lock.Leave;
  if ss <> '' then
    irc_addtext(channel, 'Ident reply for %s is %s', [sitename, ss]);

  Result:= True;
end;

function IrcSections(th: TMyIrcThread; channel, params: string): Boolean;
var ss, sitename, sections: string;
    s: TSite;
begin
  Result:= False;
  sitename:= UpperCase(SubString(params, ' ', 1));
  sections:= RightStrV2(params, Length(sitename)+1);

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    queue_lock.Leave;
    irc_addtext(channel, 'Site %s not found.', [sitename]);
    exit;
  end;
  ss:= s.SetSections(sections, True);
  queue_lock.Leave;
  if ss <> '' then
    irc_addtext(ss);

  Result:= True;
end;

function IrcLeechers(th: TMyIrcThread; channel, params: string): Boolean;
var ss, sitename, users: string;
    s: TSite;
begin
  Result:= False;
  sitename:= UpperCase(SubString(params, ' ', 1));
  users:= RightStrV2(params, Length(sitename)+1);

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    queue_lock.Leave;
    irc_addtext(channel, 'Site %s not found.', [sitename]);
    exit;
  end;
  ss:= s.SetLeechers(users, True);
  queue_lock.Leave;
  if ss <> '' then
    irc_addtext(ss);

  Result:= True;
end;

function IrcTraders(th: TMyIrcThread; channel, params: string): Boolean;
var ss, sitename, users: string;
    s: TSite;
begin
  Result:= False;
  sitename:= UpperCase(SubString(params, ' ', 1));
  users:= RightStrV2(params, Length(sitename)+1);

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    queue_lock.Leave;
    irc_addtext(channel, 'Site %s not found.', [sitename]);
    exit;
  end;
  ss:= s.SetTraders(users, True);
  queue_lock.Leave;
  if ss <> '' then
    irc_addtext(ss);

  Result:= True;
end;

function IrcUserslots(th: TMyIrcThread; channel, params: string): Boolean;
var sitename: string;
    s: TSite;
    leechslots, ratioslots: Integer;
begin
  Result:= False;
  sitename:= UpperCase(SubString(params, ' ', 1));
  leechslots:= StrToIntDef(SubString(params, ' ', 2), -1);
  ratioslots:= StrToIntDef(SubString(params, ' ', 3), -1);

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    queue_lock.Leave;
    irc_addtext(channel, 'Site %s not found.', [sitename]);
    exit;
  end;

  s.WCInteger('maxleechers', leechslots);
  s.WCInteger('maxtraders', ratioslots);
  queue_lock.Leave;

  Result:= True;
end;

function IrcFreeslots(th: TMyIrcThread; channel, params: string): Boolean;
var s: TSite;
    i: Integer;
begin

  irc_addtext(channel, 'SITE FR FL');
  queue_lock.Enter;
  for i:= 0 to sites.Count -1 do
  begin
    s:= TSite(sites[i]);

    irc_addtext(channel, '%s: %d %d', [Bold(s.name), s.FreeTraderSlots, s.FreeLeechSlots]);
  end;
  queue_lock.Leave;

  Result:= True;
end;

function IrcFindAffil(th: TMyIrcThread; channel, params: string): Boolean;
var s: TSite;
    i: Integer;
    section, affil: string;
begin
  section:= UpperCase(SubString(params, ' ', 1));
  affil:= SubString(params, ' ', 2);

  queue_lock.Enter;
  for i:= 0 to sites.Count -1 do
  begin
    s:= TSite(sites[i]);

    if s.IsAffil(section, affil) then
      irc_addtext(channel, '%s: %d %d', [Bold(s.name), s.FreeTraderSlots, s.FreeLeechSlots]);
  end;
  queue_lock.Leave;

  Result:= True;
end;

function IrcFindSection(th: TMyIrcThread; channel, params: string): Boolean;
var s: TSite;
    i: Integer;
    section: string;
begin
  section:= UpperCase(SubString(params, ' ', 1));

  queue_lock.Enter;
  for i:= 0 to sites.Count -1 do
  begin
    s:= TSite(sites[i]);

    if s.IsSection(section) then
      irc_addtext(channel, '%s: %d %d', [Bold(s.name), s.FreeTraderSlots, s.FreeLeechSlots]);
  end;
  queue_lock.Leave;

  Result:= True;
end;
function IrcAuto(th: TMyIrcThread; channel, params: string): Boolean;
begin
  if params <> '' then
  begin
    precatcher_auto:= Boolean(StrToIntDef(params, 0));
    sitesdat.WriteBool('precatcher', 'auto', precatcher_auto);
  end;
  irc_addtext(channel, 'Auto is: '+IntToStr(Integer(precatcher_auto)));

  Result:= True;
end;

function IrcAutoLogin(th: TMyIrcThread; channel, params: string): Boolean;
var sitename: string;
    status: Integer;
    s: TSite;
begin
  Result:= False;
  sitename:= UpperCase(SubString(params, ' ', 1));
  status:= StrToIntDef(SubString(params, ' ', 2), -1);

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    queue_lock.Leave;
    irc_addtext(channel, 'Site %s not found', [sitename]);
    exit;
  end;

  if status > -1 then
  begin
    s.WCInteger('autologin', status);
  end;
  irc_addtext(channel, 'Autologin of %s is: %d', [sitename, Integer(s.RCBool('autologin', False))]);

  queue_lock.Leave;

  Result:= True;
end;

function IrcAutoBnctest(th: TMyIrcThread; channel, params: string): Boolean;
var sitename: string;
    status: Integer;
    s: TSite;
    kell: Boolean;
begin
  Result:= False;
  sitename:= UpperCase(SubString(params, ' ', 1));
  status:= StrToIntDef(SubString(params, ' ', 2), -1);

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    queue_lock.Leave;
    irc_addtext(channel, 'Site %s not found', [sitename]);
    exit;
  end;

  kell:= False;
  if status > -1 then
  begin
    if status <> 0 then
    begin
      if s.RCInteger('autobnctest', 0) <= 0 then
        kell:= True;
      s.WCInteger('autobnctest', status);
    end else
      s.DeleteKey('autobnctest');
  end;
  irc_addtext(channel, 'Autobnctest of %s is: %d', [sitename, s.RCInteger('autobnctest', 0)]);

  if kell then
    s.AutoBnctest;
  queue_lock.Leave;

  Result:= True;
end;

function IrcAutoDirlist(th: TMyIrcThread; channel, params: string): Boolean;
var sitename: string;
    status: Integer;
    s: TSite;
    kell: Boolean;
    sections: string;
    ss: string;
    i: Integer;
begin
  Result:= False;
  sitename:= UpperCase(SubString(params, ' ', 1));
  status:= StrToIntDef(SubString(params, ' ', 2), -1);
  sections:= UpperCase(RightStrV2(params, length(sitename)+1+length(IntToStr(status))+1));

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    queue_lock.Leave;
    irc_addtext(channel, 'Site %s not found', [sitename]);
    exit;
  end;

  if ((status > -1) and (status <> 0)) then
  begin
    // hitelesitjuk a szekciokat
    for i:= 1 to 1000 do
    begin
      ss:= SubString(sections, ' ', i);
      if ss = '' then Break;

      if s.sectiondir[ss] = '' then
      begin
        queue_lock.Leave;
        irc_addtext(channel, 'Site %s has no %s section', [sitename, ss]);
        exit;
      end;
    end;
  end;

  kell:= False;
  if status > -1 then
  begin
    if status <> 0 then
    begin
      if s.RCInteger('autodirlist', 0) <= 0 then
        kell:= True;
      s.WCInteger('autodirlist', status);
      s.WCString('autodirlistsections', sections);
    end else
    begin
      s.DeleteKey('autodirlist');
      s.DeleteKey('autodirlistsections');
    end;
  end;
  irc_addtext(channel, 'Autodirlist of %s is: %d (%s)', [sitename, s.RCInteger('autodirlist', 0), s.RCString('autodirlistsections', '')]);

  if kell then
    s.AutoDirlist;
  queue_lock.Leave;

  Result:= True;
end;



function IrcKbShow(th: TMyIrcThread; channel, params: string): Boolean;
var section, rls: string;
    p: TPazo;
    i: Integer;
    s, ss: string;
begin
  section:= UpperCase(SubString(params, ' ', 1));
  rls:= SubString(params, ' ', 2);
  queue_lock.enter;
  i:= kb_list.IndexOf(section+'-'+rls);
  if i <> -1 then
  begin
    p:= TPazo(kb_list.Objects[i]);
    s:= p.AsText;
    for i:= 1 to 1000 do
    begin
      ss:= SubString(s, #13#10, i);
      if ss = '' then break;
      irc_addtext(channel, '%s', [ss]);
    end;
  end else
    irc_addtext('Cant found');
  queue_lock.leave;

  Result:= True;
end;

function IrcKbList(th: TMyIrcThread; channel, params: string): Boolean;
var p: TPazo;
    i, db: Integer;
begin
  queue_lock.enter;
  db:= 0;
  for i:= kb_list.Count -1 downto 0 do
  begin
    if(db > 10) then Break;
    p:= TPazo(kb_list.Objects[i]);
    irc_addtext(channel, '%s %s %s', [p.rls.section, p.rls.rlsname, p.rls.ExtraInfo]);
    inc(db);
  end;
  queue_lock.leave;

  Result:= True;
end;


function IrcKbExtra(th: TMyIrcThread; channel, params: string): Boolean;
var section, rls, extra: string;
begin
  section:= UpperCase(SubString(params, ' ', 1));
  rls:= SubString(params, ' ', 2);
  extra:= RightStrV2(params, Length(section)+Length(rls)+2);
  queue_lock.enter;
  kb_Add('', section, extra, 'NEWDIR', rls, '', True);
  queue_lock.leave;

  Result:= True;
end;

function IrcNoHelp(th: TMyIrcThread; channel, params: string): Boolean;
var i: Integer;
begin
  for i:= Low(irccommands) to High(irccommands) do
    if ((length(irccommands[i].cmd) > 0) and (irccommands[i].cmd[1] <> '-')) then
      if not FileExists(IncludeTrailingPathDelimiter('help')+irccommands[i].cmd+'.txt') then
      begin
        irc_Addtext(channel, 'Command %s has no help yet.', [irccommands[i].cmd]);
      end;

  Result:= True;
end;

function IrcFindUser(th: TMyIrcThread; channel, params: string): Boolean;
var s: TSite;
    i: Integer;
    user: string;
begin
  user:= SubString(params, ' ', 1);

  queue_lock.Enter;
  for i:= 0 to sites.Count -1 do
  begin
    s:= TSite(sites[i]);

    if s.IsUser(user) then
      irc_addtext(channel, '%s: %d %d', [Bold(s.name), s.FreeTraderSlots, s.FreeLeechSlots]);
  end;
  queue_lock.Leave;

  Result:= True;
end;

function IrcUsers(th: TMyIrcThread; channel, params: string): Boolean;
var ss, sitename: string;
    s: TSite;
begin
  Result:= False;
  sitename:= UpperCase(SubString(params, ' ', 1));

  queue_lock.Enter;
  s:= FindSiteByName(sitename);
  if s = nil then
  begin
    queue_lock.Leave;
    irc_addtext(channel, 'Site %s not found.', [sitename]);
    exit;
  end;
  ss:= s.users;
  queue_lock.Leave;
  if ss <> '' then
    irc_addtext(ss);

  Result:= True;
end;


{ TIRCCommandThread }

constructor TIRCCommandThread.Create(th: TMyIrcThread; c: TIRCCommandHandler; channel, params: string);
begin
  self.c:= c;
  self.th:= th;
  self.channel:= channel;
  self.params:= params;
  inherited Create(False);
  FreeOnTerminate:= True;
end;

procedure TIRCCommandThread.Execute;
begin
  if c(th, channel, params) then
    irc_AddText(channel, 'Ok.');
end;

procedure IrcCommandInit;
begin
//  genres:= TStringList.Create;
  batchqueue:= TStringList.Create;
  webtags:= TStringList.Create;
  webtags.Delimiter:= ',';
  webtags.DelimitedText:= config.ReadString(section, 'webtags', '-WEB-');
end;
procedure IrcCommandUnInit;
begin
//  genres.Free;
  batchqueue.Free;
  webtags.Free;
end;

initialization
  IrcCommandInit;
finalization
  IrcCommandUninit;
end.

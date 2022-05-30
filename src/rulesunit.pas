unit rulesunit;

interface

uses kb, masks, Classes, pazo, Contnrs;

type
  TCondition = class
    param: string;
    parami: Integer;
    constructor Create(param: string); virtual;
    function AsText: String; virtual; abstract;
    function Match(r: TPazo): Boolean; virtual; abstract;
    class function Name: string; virtual; abstract;
    class function Operator: string; virtual; abstract;
    class function Description: string; virtual; abstract;
  end;
  TConditionBoolean = class(TCondition)
    class function Operator: string; override;
    function AsText: String; override;
  end;
  TConditionArray = class(TCondition)
    lista: TStringList;
    class function Operator: string; override;
    constructor Create(param: string); override;
    destructor Destroy; override;
    function AsText: String; override;
  end;
  TConditionEqual = class(TCondition)
    class function Operator: string; override;
    function AsText: String; override;
  end;
  TConditionAt = class(TConditionEqual)
    class function Operator: string; override;
  end;
  TConditionMask = class(TConditionEqual)
    mask: TMask;
    constructor Create(param: string); override;
    class function Operator: string; override;
    destructor Destroy; override;
  end;

  //---------------------------------------------- tenyleges conditionok
  TConditionReleaseName = class(TConditionMask)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionInternal = class(TConditionBoolean)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionAgeGt = class(TConditionEqual)
    function Match(r: TPazo): Boolean; override;
    class function Operator: string; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionAgeLt = class(TConditionEqual)
    function Match(r: TPazo): Boolean; override;
    class function Operator: string; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionComplete = class(TConditionAt)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionNotComplete = class(TConditionAt)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionPre = class(TConditionAt)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionAllowed = class(TConditionAt)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionNotAllowed = class(TConditionAt)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionGroup = class(TConditionEqual)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionMGroup = class(TConditionMask)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionAGroup = class(TConditionArray)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionKnownGroup = class(TConditionBoolean)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionUnKnownGroup = class(TConditionBoolean)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionSource = class(TConditionEqual)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionASource = class(TConditionArray)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionNewdir = class(TConditionBoolean)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionMP3Genre = class(TConditionEqual)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionMP3MGenre = class(TConditionMask)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionMP3AGenre = class(TConditionArray)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionMP3EYear = class(TConditionEqual)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionMP3GtYear = class(TConditionEqual)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
    class function Operator: string; override;
  end;
  TConditionMP3GEtYear = class(TConditionEqual)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
    class function Operator: string; override;
  end;
  TConditionMP3LtYear = class(TConditionEqual)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
    class function Operator: string; override;
  end;
  TConditionMP3LEtYear = class(TConditionEqual)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
    class function Operator: string; override;
  end;
  TConditionMP3Language = class(TConditionEqual)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionMP3ALanguage = class(TConditionArray)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionMP3Foreign = class(TConditionBoolean)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionMP3Source = class(TConditionEqual)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionMP3ASource = class(TConditionArray)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionMP3Live = class(TConditionBoolean)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionMP3Type = class(TConditionEqual)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionMP3AType = class(TConditionArray)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionMP3Bootleg = class(TConditionBoolean)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionMP3LtNumDisks = class(TConditionEqual)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
    class function Operator: string; override;
  end;
  TConditionMP3LEtNumDisks = class(TConditionEqual)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
    class function Operator: string; override;
  end;
  TConditionMP3ENumDisks = class(TConditionEqual)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
    class function Operator: string; override;
  end;
  TConditionMP3GEtNumDisks = class(TConditionEqual)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
    class function Operator: string; override;
  end;
  TConditionMP3GtNumDisks = class(TConditionEqual)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
    class function Operator: string; override;
  end;
  TConditionMP3VA = class(TConditionBoolean)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionNfoMGenre = class(TConditionMask)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  TConditionDefault = class(TConditionBoolean)
    function Match(r: TPazo): Boolean; override;
    class function Name: string; override;
    class function Description: string; override;
  end;
  //----------------------------------------------- tenyleges conditionok vege


  TRuleAction = (raDrop, raAllow, raDontmatch);
  TRule = class
    sitename: string;
    section: string;
    isnot: Boolean;
    conditions: TObjectList;
    action: TRuleAction;
    error: string;

    function Execute(r: TPazo): TRuleAction;

    function AsText(includeSitesection: Boolean): string;
    procedure Reparse(rule: string);
    constructor Create(rule: string);
    destructor Destroy; override;
  end;

  TCCondition = class of TCondition;
  TACCondition = array[1..42] of TCCondition;

procedure RulesRemove(sitename, section: string);
procedure RulesSave;
procedure RulesStart;
function FindConditionByName(name, operator: string): TCCondition;
function AddRule(rule: string; var error: string): TRule;
procedure RulesOrder(p: TPazo);
procedure FireRules(p: TPazo; ps: TPazoSite; x: TStringList);

var rules: TObjectList;
  conditions : TACCondition =
  (
    TConditionReleaseName,
    TConditionInternal,
    TConditionAgeGt,
    TConditionAgeLt,    
    TConditionComplete,
    TConditionNotComplete,
    TConditionPre,
    TConditionAllowed,
    TConditionNotAllowed,
    TConditionGroup,
    TConditionMGroup,
    TConditionAGroup,
    TConditionKnownGroup,
    TConditionUnKnownGroup,
    TConditionSource,
    TConditionASource,
    TConditionNewdir,
    TConditionMP3Genre,
    TConditionMP3MGenre,
    TConditionMP3AGenre,
    TConditionMP3EYear,
    TConditionMP3GtYear,
    TConditionMP3GEtYear,
    TConditionMP3LtYear,
    TConditionMP3LEtYear,
    TConditionMP3Language,
    TConditionMP3ALanguage,
    TConditionMP3Foreign,
    TConditionMP3Source,
    TConditionMP3ASource,
    TConditionMP3Live,
    TConditionMP3Bootleg,
    TConditionMP3Type,
    TConditionMP3AType,
    TConditionMP3LtNumDisks,
    TConditionMP3LEtNumDisks,
    TConditionMP3ENumDisks,
    TConditionMP3GEtNumDisks,
    TConditionMP3GtNumDisks,
    TConditionMP3VA,
    TConditionNfoMGenre,
    TConditionDefault
  );


implementation

uses SysUtils, Math, sitesunit, queueunit, mystrings, encinifile, configunit;

function mySpeedComparer(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result:=
    CompareValue(
      StrToIntDef(list.ValueFromIndex[index2],0),
      StrToIntDef(list.ValueFromIndex[index1],0)
    );
end;

function FireRuleSet(p: TPazo; ps: TPazoSite): TRuleAction;
var i: Integer;
    r: TRule;
    ra: TRuleAction;
begin
  Result:= raDrop;
  for i:= 0 to rules.Count -1 do
  begin
    r:= TRule(rules[i]);
    if ((r.sitename = ps.name) and (r.section = 'GENERIC')) then
    begin
      ra:= r.Execute(p);
      if ra = raDrop then
      begin
        ps.reason:= r.AsText(True);
        exit;
      end;
      
      if ra = raAllow then
      begin
        ps.reason:= r.AsText(True);
        Result:= raAllow;
        exit;
      end;
    end;
  end;

  for i:= 0 to rules.Count -1 do
  begin
    r:= TRule(rules[i]);
    if ((r.sitename = ps.name) and (r.section = p.rls.section)) then
    begin
      ra:= r.Execute(p);
      if ra = raDrop then
      begin
        ps.reason:= r.AsText(True);
        exit;
      end;

      if ra = raAllow then
      begin
        ps.reason:= r.AsText(True);
        Result:= raAllow;
        exit;
      end;
    end;
  end;
  if ps.reason <> '' then
    ps.reason:= 'No matching rule';
end;

procedure FireRules(p: TPazo; ps: TPazoSite; x: TStringList);
var dstps: TPazoSite;
    y: TStringList;
    i: Integer;
    s: TSite;
    eljut: Boolean;

begin
  if not ps.Source then exit;
  s:= FindSiteByName(ps.name);
  if s = nil then exit;
  if s.working = sstDown then exit;

  p.srcsite:= ps.name;

  x.Add(ps.name);
  
  y:= TStringList.Create;
  sitesdat.ReadSectionValues('speed-from-'+ps.Name, y);
  y.CustomSort(myspeedcomparer);
  for i:= 0 to y.Count -1 do
  begin
    dstps:= p.FindSite(y.Names[i]);
    // onmagunkra es ha affil valahol, nem toltunk...
    if ((dstps <> nil) and (dstps <> ps)) then
    begin
      if (dstps.AllPre) then
      begin
        if (dstps.reason = '') then
          dstps.reason:= 'Affil';

        Continue;
      end;
      
      s:= FindSiteByName(dstps.name);
      // meg ha down a site akkor is
      if s = nil then Continue; // safety
      if s.working <> sstUp then
      begin
        if (dstps.reason = '') then
          dstps.reason:= 'Down';

        Continue;
      end;

      if (dstps.sources.IndexOf(ps) = -1) and (not dstps.Complete) then
      begin
        // aztan hogy allowed e...
        if FireRuleSet(p, dstps) = raAllow then
        begin
          eljut:= dstps.Eljut(ps);
          if (
              (not eljut)  // ha a cel nem forras egyuttal
               or
              (
                (dstps.status = rssAllowed) // a cel eredetileg forras volt, de belassult
                and
                (ps.Complete)
                and
                (0 <> sitesdat.ReadInteger('speed-from-'+ps.Name, dstps.name, 0)) // es van route!
              )
             )
          then
          begin
            if eljut then
            begin
              // a masodik eset all fenn, meg kell cserelni a cuccokat..
              ps.sources.Remove(dstps);
              dstps.destinations.Remove(ps);
            end;

            ps.AddDestination(dstps);
            if not dstps.Complete then
              dstps.status:= rssAllowed;
          end;
        end;
      end;
    end;
  end;
  y.Free;


  // es most rekurzio
  for i:= 0 to p.sites.Count -1 do
  begin
    dstps:= TPazoSite(p.sites[i]);
    if ((dstps <> ps) and (-1 = x.IndexOf(dstps.name))) then//and (dstps.Source) 
      FireRules(p, dstps, x);
  end;
end;

procedure RulesOrder(p: TPazo);
var x: TStringList;
    i, j, k: Integer;
    r: TRule;
    c: TConditionAt;
    fositeIndex, aktsiteIndex: Integer;
begin
  x:= TStringList.Create;
  for i:= 0 to p.sites.Count -1 do
    x.Add(TPazoSite(p.sites[i]).name);

  for i:= 0 to x.Count -1 do
  begin
    fositeIndex:= p.sites.IndexOf(p.FindSite(x[i]));
    for j:= 0 to rules.Count-1 do
    begin
      r:= TRule(rules[j]);
      if ((r.sitename = x[i]) and (r.section = p.rls.section)) then
      begin
        for k:= 0 to r.conditions.Count -1 do
        begin
          if r.conditions[k] is TConditionAt then
          begin
            c:= TConditionAt(r.conditions[k]);
            aktsiteIndex:= p.sites.IndexOf(p.FindSite(c.param));
            if (aktsiteIndex > fositeIndex) then
            begin
              p.sites.Move(aktsiteIndex, fositeIndex);
              fositeIndex:= fositeIndex + 1;
              // meg kell nezni egyezik e ezzel...
              // fositeIndex:= p.sites.IndexOf(p.FindSite(x[i]));
            end;
          end;
        end;
      end;
    end;
  end;

  x.Free;
end;

procedure RulesSave;
var i: Integer;
    f: TEncStringlist;
begin
  f:= TEncStringlist.Create(passphrase);
  try
    for i:= 0 to rules.Count -1 do
      f.Add(TRule(rules[i]).AsText(True));
    f.SaveToFile(ExtractFilePath(ParamStr(0))+'slftp.rules');
  finally
    f.Free;
  end;
end;

procedure RulesRemove(sitename, section: string);
var i: Integer;
    r: TRule;
begin
  i:= 0;
  while (i < rules.Count) do
  begin
    r:= TRule(rules[i]);
    if ((r.sitename = sitename) and ((section='')or(r.section= section)))then
    begin
      rules.Remove(r);
      dec(i);
    end;
    inc(i);
  end;
end;


function AddRule(rule: string; var error: string): TRule;
var r: TRule;
begin
  Result:= nil;

  r:= TRule.Create(rule);
  if r.error <> '' then
  begin
    error:= r.error;
    r.Free;
  end else
    Result:= r;
end;

procedure RulesStart;
var f: TEncStringlist;
    i: Integer;
    r: TRule;
    error: string;
begin
  //beparszoljuk a szabalyokat
  queue_lock.Enter;
  f:= TEncStringlist.Create(passphrase);
  try
    f.LoadFromFile(ExtractFilePath(ParamStr(0))+'slftp.rules');

    for i:= 0 to f.Count -1 do
    begin
      r:= AddRule(f[i], error);
      if r <> nil then
        rules.Add(r);
    end;

  finally
    f.Free;
    queue_lock.Leave;    
  end;
end;
procedure RulesInit;
begin
  rules:= TObjectList.Create;
end;
procedure RulesUninit;
begin
  rules.Free;
end;

function FindConditionByName(name, operator: string): TCCondition;
var i: Integer;
begin
  Result:= nil;
  for i:= Low(conditions) to High(conditions) do
    if ((conditions[i].Name = name) and (conditions[i].Operator = operator)) then
    begin
      Result:= conditions[i];
      exit;
    end;
end;

{ TRule }

function TRule.AsText(includeSitesection: Boolean): string;
var i: Integer;
begin
  Result:= '';
  if includeSitesection then
    Result:= sitename +' '+section+' ';
  if not isnot then
    Result:= Result+ 'if '
  else
    Result:= Result+'ifnot ';
  for i:= 0 to conditions.Count-1 do
  begin
    Result:= Result + TCondition(conditions[i]).AsText;
    if i <> conditions.Count -1 then
      Result:= Result + ' && ';
  end;
  Result:= Result + ' then ';
  if action = raDrop then
    Result:= Result + 'DROP'
  else
    Result:= Result + 'ALLOW';  
end;

constructor TRule.Create(rule: string);
begin
  conditions:= TObjectList.Create;
  error:= '';
  reparse(rule);
end;

destructor TRule.Destroy;
begin
  conditions.Free;
  inherited;
end;

function TRule.Execute(r: TPazo): TRuleAction;
var i: Integer;
begin
  Result:= raDontmatch;
  for i:= 0 to conditions.Count -1 do
    if not TCondition(conditions[i]).Match(r) then
    begin
      if not isnot then exit; // sima feltetelsor, dontmatch.
      Result:= action; // allow vagy drop
      exit;
    end;

  // minden feltetel teljesult.
  // ha tagado a feltetel akkor dontmatch
  if isnot then exit;

  // kulonben az alap akcio
  Result:= action;
end;

procedure TRule.Reparse(rule: string);
var i: Integer;
    ifstr, thenstr, actionstr, conditionstr, actcondition, conditionname, operator, params: string;
    c: TCCondition;
begin
  sitename:= UpperCase(SubString(rule, ' ', 1));
  section:= UpperCase(SubString(rule, ' ', 2));

  if sitename = '' then
  begin
    error:= 'Sitename is invalid';
    exit;
  end;

  if section = '' then
  begin
    error:= 'Section is invalid';
    exit;
  end;

  rule:= Copy(rule, Length(sitename)+Length(section)+3, 1000);
  ifstr:= LowerCase(SubString(rule, ' ', 1));
  if ifstr = 'if' then
    isnot:= False
  else
  if ifstr = 'ifnot' then
    isnot:= True
  else
  begin
    error:= 'Rule must start with if/ifnot';
    exit;
  end;

  i:= Count(' ', rule);
  if i < 3 then
  begin
    error:= 'Rule is too short?';
    exit;
  end;

  thenstr:= LowerCase(SubString(rule, ' ',i));
  actionstr:= UpperCase(SubString(rule, ' ',i+1));
  if thenstr <> 'then' then
  begin
    error:= 'then missing';
    exit;
  end;

  if actionstr = 'DROP' then
    action:= raDrop
  else
  if actionstr = 'ALLOW' then
    action:= raAllow
  else
  begin
    error:= 'Rule must end with ALLOW/DROP';
    exit;
  end;

  conditions.Clear;
  conditionstr:= Copy(rule, Length(ifstr)+2, 1000);
  conditionstr:= Trim(Copy(conditionstr, 1, Length(conditionstr)-Length(actionstr)-Length(thenstr)-1));

  if 0 <> Pos('||', conditionstr) then
  begin
    error:= 'Or connections are not supported. Use several statements.';
    exit;
  end;

  for i:= 1 to Count('&&', conditionstr)+1 do
  begin
    actcondition:= Trim(SubString(conditionstr, '&&', i));
    conditionname:= SubString(actcondition,' ', 1);
    operator:= SubString(actcondition,' ', 2);
    c:= FindConditionByName(conditionname, operator);
    if c = nil then
    begin
      error:= 'Cant find condition called '+conditionname+'/'+operator;
      exit;
    end;
    params:= Trim(Copy(actcondition, Length(conditionname)+Length(operator)+2, 1000));
    conditions.Add( c.Create(params) );
  end;
end;

{ TConditionReleaseName }

class function TConditionReleaseName.Description: string;
begin
  Result:=          'Returns true, if releasename matches the mask.'+#13#10;
  Result:= Result + 'Example: releasename =~ *-keygen*'+#13#10;
end;

function TConditionReleaseName.Match(r: TPazo): Boolean;
begin
  Result:= mask.Matches(r.rls.rlsname);
end;

class function TConditionReleaseName.Name: string;
begin
  Result:= 'releasename';
end;

{ TConditionBoolean }

function TConditionBoolean.AsText: String;
begin
  Result:= name;
end;

class function TConditionBoolean.Operator: string;
begin
  Result:= '';
end;

{ TConditionEqual }

function TConditionEqual.AsText: String;
begin
  Result:= name +' '+operator +' '+param;
end;


class function TConditionEqual.Operator: string;
begin
  Result:= '=';
end;

{ TConditionMask }

constructor TConditionMask.Create(param: string);
begin
  inherited Create(param);
  mask:= TMask.Create(param);
end;

destructor TConditionMask.Destroy;
begin
  mask.Free;
  inherited;
end;

class function TConditionMask.Operator: string;
begin
  Result:= '=~';
end;

{ TConditionComplete }

class function TConditionComplete.Description: string;
begin
  Result:=          'Returns true, if the release is complete on the specified site.'+#13#10;
  Result:= Result + 'Example: complete @ SITENAME'+#13#10;
end;

function TConditionComplete.Match(r: TPazo): Boolean;
var x: TPazoSite;
begin
  Result:= False;
  x:= r.FindSite(param);
  if ((x <> nil) and (x.Complete)) then
    Result:=  True;
end;

class function TConditionComplete.Name: string;
begin
  Result:= 'complete';
end;


{ TConditionPre }

class function TConditionPre.Description: string;
begin
  Result:=          'Returns true, if the release is pred on the specified site.'+#13#10;
  Result:= Result + 'Example: pre @ SITENAME'+#13#10;
end;

function TConditionPre.Match(r: TPazo): Boolean;
var x: TPazoSite;
begin
  Result:= False;
  x:= r.FindSite(param);
  if ((x <> nil) and (x.status = rssRealPre)) then
    Result:=  True;
end;

class function TConditionPre.Name: string;
begin
  Result:= 'pre';
end;

{ TConditionAt }

class function TConditionAt.Operator: string;
begin
  Result:= '@';
end;

{ TConditionArray }

function TConditionArray.AsText: String;
var i: Integer;
begin
  Result:= name +' '+ operator + ' ';
  for i:= 0 to lista.Count -1 do
  begin
    Result:= Result+ lista[i];
    if (i <> lista.Count -1) then
      Result:= Result +', ';
  end;
end;

constructor TConditionArray.Create(param: string);
var i: Integer;
    s: string;
begin
  inherited Create(param);
  lista:= TStringList.Create;
  lista.CaseSensitive:= False;
  for i:= 1 to 1000 do
  begin
    s:= Trim(SubString(param, ',',i));
    if s = '' then Break;
    lista.Add(s);
  end;
end;

destructor TConditionArray.Destroy;
begin
  lista.Free;
  inherited;
end;

class function TConditionArray.Operator: string;
begin
  Result:= 'in';
end;

{ TConditionNotAllowed }

class function TConditionNotAllowed.Description: string;
begin
  Result:=          'Returns true, if the release is not allowed on the specified site.'+#13#10;
  Result:= Result + 'Example: notallowed @ SITENAME'+#13#10;
end;

function TConditionNotAllowed.Match(r: TPazo): Boolean;
var x: TPazoSite;
begin
  Result:= False;
  x:= r.FindSite(param);
  if ((x <> nil) and (x.status = rssNotAllowed)) then
    Result:=  True;
end;

class function TConditionNotAllowed.Name: string;
begin
  Result:= 'notallowed';
end;

{ TConditionAllowed }

class function TConditionAllowed.Description: string;
begin
  Result:=          'Returns true, if the release is not notallowed on the specified site.'+#13#10;
  Result:= Result + 'Example: allowed @ SITENAME'+#13#10;
end;

function TConditionAllowed.Match(r: TPazo): Boolean;
var x: TPazoSite;
begin
  Result:= False;
  x:= r.FindSite(param);
  if ((x <> nil) and (x.status = rssAllowed)) then
    Result:=  True;
end;

class function TConditionAllowed.Name: string;
begin
  Result:= 'allowed';
end;

{ TConditionGroup }

class function TConditionGroup.Description: string;
begin
  Result:=          'Returns true, if the groupname equals with the specified one.'+#13#10;
  Result:= Result + 'Example: group = GRPNAME'+#13#10;
end;

function TConditionGroup.Match(r: TPazo): Boolean;
begin
  Result:= AnsiCompareText( r.rls.groupname, param) = 0;
end;

class function TConditionGroup.Name: string;
begin
  Result:= 'group';
end;

{ TConditionGroup }

class function TConditionMGroup.Description: string;
begin
  Result:=          'Returns true, if the groupname matches with the specified mask.'+#13#10;
  Result:= Result + 'Example: group =~ GRP*'+#13#10;
end;

function TConditionMGroup.Match(r: TPazo): Boolean;
begin
  Result:= mask.Matches( r.rls.groupname );
end;

class function TConditionMGroup.Name: string;
begin
  Result:= 'group';
end;

{ TConditionKnownGroup }

class function TConditionKnownGroup.Description: string;
begin
  Result:=          'Returns true, if the groupname is known (you can set the list in slftp.ini if i remember well).'+#13#10;
  Result:= Result + 'Example: knowngroup'+#13#10;
end;

function TConditionKnownGroup.Match(r: TPazo): Boolean;
begin
  Result:= r.rls.knowngroup = grp_known;
end;

class function TConditionKnownGroup.Name: string;
begin
  Result:= 'knowngroup';
end;

{ TConditionUnKnownGroup }

class function TConditionUnKnownGroup.Description: string;
begin
  Result:=          'Returns true, if the groupname is not known.'+#13#10;
  Result:= Result + 'Example: unknowngroup'+#13#10;
end;

function TConditionUnKnownGroup.Match(r: TPazo): Boolean;
begin
  Result:= r.rls.knowngroup = grp_unknown;
end;

class function TConditionUnKnownGroup.Name: string;
begin
  Result:= 'unknowngroup';
end;

{ TConditionSource }

class function TConditionSource.Description: string;
begin
  Result:=          'Returns true, if src site is the specified one.'+#13#10;
  Result:=          'You can use this function to setup static routing.'+#13#10;
  Result:= Result + 'Example: source = SITENAME'+#13#10;
end;

function TConditionSource.Match(r: TPazo): Boolean;
begin
  Result:= (r.srcsite = param);
end;

class function TConditionSource.Name: string;
begin
  Result:= 'source';
end;

{ TConditionASource }

class function TConditionASource.Description: string;
begin
  Result:=          'Returns true, if src site is one of the specified ones.'+#13#10;
  Result:=          'You can use this function to setup static routing.'+#13#10;
  Result:= Result + 'Example: source in SITE1, SITE2'+#13#10;
end;

function TConditionASource.Match(r: TPazo): Boolean;
begin
  Result:= lista.IndexOf(r.srcsite) <> -1;
end;

class function TConditionASource.Name: string;
begin
  Result:= 'source';
end;

{ TConditionNewdir }

class function TConditionNewdir.Description: string;
begin
  Result:=          'Returns true, if source is newdir (not pre or complete).'+#13#10;
  Result:= Result + 'Example: newdir'+#13#10;
end;

function TConditionNewdir.Match(r: TPazo): Boolean;
var x: TPazoSite;
begin
  Result:= False;
  x:= r.FindSite(r.srcsite);
  if ((x <> nil) and (x.status = rssAllowed))  then
    Result:= True;
end;

class function TConditionNewdir.Name: string;
begin
  Result:= 'newdir';
end;

{ TConditionMP3Genre }

class function TConditionMP3Genre.Description: string;
begin
  Result:=          'Returns true, if mp3 genre equals with the specified one.'+#13#10;
  Result:= Result + 'Example: mp3genre = Metal'+#13#10;
end;

function TConditionMP3Genre.Match(r: TPazo): Boolean;
begin
  Result:= False;
  if r.rls is TMP3Release then
    Result:= AnsiCompareText(TMP3Release(r.rls).mp3genre, param) = 0;
end;

class function TConditionMP3Genre.Name: string;
begin
  Result:= 'mp3genre';
end;

{ TConditionMP3MGenre }

class function TConditionMP3MGenre.Description: string;
begin
  Result:=          'Returns true, if mp3 genre matches with the specified mask.'+#13#10;
  Result:= Result + 'Example: mp3genre =~ *Metal*'+#13#10;
end;

function TConditionMP3MGenre.Match(r: TPazo): Boolean;
begin
  Result:= False;
  if r.rls is TMP3Release then
    Result:= mask.Matches(TMP3Release(r.rls).mp3genre);
end;

class function TConditionMP3MGenre.Name: string;
begin
  Result:= 'mp3genre';
end;

{ TConditionMP3AGenre }

class function TConditionMP3AGenre.Description: string;
begin
  Result:=          'Returns true, if mp3 genre is in the specified list.'+#13#10;
  Result:= Result + 'Example: mp3genre in Metal,Rock'+#13#10;
end;

function TConditionMP3AGenre.Match(r: TPazo): Boolean;
begin
  Result:= False;
  if (r.rls is TMP3Release) then
    Result:= lista.IndexOf(TMP3Release(r.rls).mp3genre) <> -1;
end;

class function TConditionMP3AGenre.Name: string;
begin
  Result:= 'mp3genre';
end;

{ TConditionMP3EYear }

class function TConditionMP3EYear.Description: string;
begin
  Result:=          'Returns true, if mp3 year equals the specified one.'+#13#10;
  Result:= Result + 'Example: mp3year = 2009'+#13#10;
end;

function TConditionMP3EYear.Match(r: TPazo): Boolean;
begin
  Result:= False;
  if (r.rls is TMP3Release) then
    Result:= TMP3Release(r.rls).mp3year = parami;
end;

class function TConditionMP3EYear.Name: string;
begin
  Result:= 'mp3year';
end;

{ TConditionInternal }

class function TConditionInternal.Description: string;
begin
  Result:=          'Returns true, if the release is tagged as internal.'+#13#10;
  Result:= Result + 'Example: internal'+#13#10;
end;

function TConditionInternal.Match(r: TPazo): Boolean;
begin
  Result:= r.rls.internal;
end;

class function TConditionInternal.Name: string;
begin
  Result:= 'internal';
end;

{ TConditionMP3GtYear }

class function TConditionMP3GtYear.Description: string;
begin
  Result:=          'Returns true, if the mp3 rip''s year is greater than the specified.'+#13#10;
  Result:= Result + 'Example: mp3year > 2008'+#13#10;
end;

function TConditionMP3GtYear.Match(r: TPazo): Boolean;
begin
  Result:= False;
  if (r.rls is TMP3Release) then
    Result:= TMP3Release(r.rls).mp3year > parami;
end;

class function TConditionMP3GtYear.Name: string;
begin
  Result:= 'mp3year';
end;

class function TConditionMP3GtYear.Operator: string;
begin
  Result:= '>';
end;

{ TConditionMP3GEtYear }

class function TConditionMP3GEtYear.Description: string;
begin
  Result:=          'Returns true, if the mp3 rip''s year is greater than or equals the specified.'+#13#10;
  Result:= Result + 'Example: mp3year >= 2008'+#13#10;
end;

function TConditionMP3GEtYear.Match(r: TPazo): Boolean;
begin
  Result:= False;
  if (r.rls is TMP3Release) then
    Result:= TMP3Release(r.rls).mp3year >= parami;
end;

class function TConditionMP3GEtYear.Name: string;
begin
  Result:= 'mp3year';
end;

class function TConditionMP3GEtYear.Operator: string;
begin
  Result:= '>=';
end;

{ TConditionMP3LtYear }

class function TConditionMP3LtYear.Description: string;
begin
  Result:=          'Returns true, if the mp3 rip''s year is lower than the specified.'+#13#10;
  Result:= Result + 'Example: mp3year < 2008'+#13#10;
end;

function TConditionMP3LtYear.Match(r: TPazo): Boolean;
begin
  Result:= False;
  if (r.rls is TMP3Release) then
    Result:= TMP3Release(r.rls).mp3year < parami;
end;

class function TConditionMP3LtYear.Name: string;
begin
  Result:= 'mp3year';
end;

class function TConditionMP3LtYear.Operator: string;
begin
  Result:= '<';
end;

{ TConditionMP3LEtYear }

class function TConditionMP3LEtYear.Description: string;
begin
  Result:=          'Returns true, if the mp3 rip''s year is lower than or equals the specified.'+#13#10;
  Result:= Result + 'Example: mp3year <= 2008'+#13#10;
end;

function TConditionMP3LEtYear.Match(r: TPazo): Boolean;
begin
  Result:= False;
  if (r.rls is TMP3Release) then
    Result:= TMP3Release(r.rls).mp3year < parami;
end;

class function TConditionMP3LEtYear.Name: string;
begin
  Result:= 'mp3year';
end;

class function TConditionMP3LEtYear.Operator: string;
begin
  Result:= '<=';
end;

{ TConditionMP3Language }

class function TConditionMP3Language.Description: string;
begin
  Result:=          'Returns true, if the mp3 rip''s language tag equals the specified. Language is EN by default'+#13#10;
  Result:= Result + 'Example: mp3language = HU'+#13#10;
end;

function TConditionMP3Language.Match(r: TPazo): Boolean;
begin
  Result:= False;
  if (r.rls is TMP3Release) then
    Result:= AnsiCompareText(TMP3Release(r.rls).mp3lng, param) = 0;

end;

class function TConditionMP3Language.Name: string;
begin
  Result:= 'mp3language';
end;

{ TConditionMP3ALanguage }

class function TConditionMP3ALanguage.Description: string;
begin
  Result:=          'Returns true, if the mp3 rip''s language tag is in the specified list. Language is EN by default'+#13#10;
  Result:= Result + 'Example: mp3language in EN, CZ, SK, HU'+#13#10;
end;

function TConditionMP3ALanguage.Match(r: TPazo): Boolean;
begin
  Result:= False;
  if (r.rls is TMP3Release) then
    Result:=  lista.IndexOf(TMP3Release(r.rls).mp3lng) <> -1;
end;

class function TConditionMP3ALanguage.Name: string;
begin
  Result:= 'mp3language';
end;

{ TConditionMP3Foreign }

class function TConditionMP3Foreign.Description: string;
begin
  Result:=          'Returns true, if the mp3 rip''s language is not english.'+#13#10;
  Result:= Result + 'Example: mp3foreign'+#13#10;
end;

function TConditionMP3Foreign.Match(r: TPazo): Boolean;
begin
  Result:= False;
  if (r.rls is TMP3Release) then
    Result:= TMP3Release(r.rls).mp3lng <> 'EN';
end;

class function TConditionMP3Foreign.Name: string;
begin
  Result:= 'mp3foreign';
end;

{ TConditionMP3Source }

class function TConditionMP3Source.Description: string;
begin
  Result:=          'Returns true, if the mp3 rip''s source equals the specified one.'+#13#10;
  Result:= Result + 'Example: mp3source = TAPE'+#13#10;
end;

function TConditionMP3Source.Match(r: TPazo): Boolean;
begin
  Result:= False;
  if (r.rls is TMP3Release) then
    Result:= AnsiCompareText(TMP3Release(r.rls).mp3source, param) = 0;
end;

class function TConditionMP3Source.Name: string;
begin
  Result:= 'mp3source';
end;

{ TConditionMP3ASource }

class function TConditionMP3ASource.Description: string;
begin
  Result:=          'Returns true, if the mp3 rip''s source tag is in the specified list.'+#13#10;
  Result:= Result + 'Example: mp3source in TAPE, VINYL, WEB'+#13#10;
end;

function TConditionMP3ASource.Match(r: TPazo): Boolean;
begin
  Result:= False;
  if (r.rls is TMP3Release) then
    Result:= lista.IndexOf(TMP3Release(r.rls).mp3source) <> -1;
end;

class function TConditionMP3ASource.Name: string;
begin
  Result:= 'mp3source';
end;

{ TConditionMP3Live }

class function TConditionMP3Live.Description: string;
begin
  Result:=          'Returns true, if the mp3 rip''s source is a live source. (You can define live source tags in slftp.ini i think)'+#13#10;
  Result:= Result + 'Example: mp3live'+#13#10;
end;

function TConditionMP3Live.Match(r: TPazo): Boolean;
begin
  Result:= False;
  if (r.rls is TMP3Release) then
    Result:= mp3livesources.IndexOf(TMP3Release(r.rls).mp3source) <> -1;
end;

class function TConditionMP3Live.Name: string;
begin
  Result:= 'mp3live';
end;

{ TCondition }

constructor TCondition.Create(param: string);
begin
  self.param:= param;
  self.parami:= StrToIntDef(param, -1);
end;


{ TConditionDefault }

class function TConditionDefault.Description: string;
begin
  Result:= 'This condition simple matches anything, you can use it for default policy.'+#13#10;
  Result:= Result + 'If there is no matching rule then no action is taken which is same as DROP by default.' +#13#10;
  Result:= Result + 'Example: if default then ALLOW'+#13#10;
end;

function TConditionDefault.Match(r: TPazo): Boolean;
begin
  Result:= True;
end;

class function TConditionDefault.Name: string;
begin
  Result:= 'default';
end;

{ TConditionAGroup }

class function TConditionAGroup.Description: string;
begin
  Result:=          'Returns true, if the groupname is in the the specified list.'+#13#10;
  Result:= Result + 'Example: group in GRPNAME1, GRPNAME2'+#13#10;
end;

function TConditionAGroup.Match(r: TPazo): Boolean;
begin
  Result:= lista.IndexOf(r.rls.groupname) <> -1;
end;

class function TConditionAGroup.Name: string;
begin
  Result:= 'group';
end;

{ TConditionMP3Type }

class function TConditionMP3Type.Description: string;
begin
  Result:= 'Returns true if the mp3 rip has the specified type.'+#13#10;
  Result:= Result + 'Example: mp3type = Advance';
end;

function TConditionMP3Type.Match(r: TPazo): Boolean;
var mp: TMP3Release;
begin
  Result:= False;
  if r.rls is TMP3Release then
  begin
    mp:= TMP3Release(r.rls);
    if 0 = AnsiCompareText(mp.mp3types1, param) then
      Result:= True
    else
    if 0 = AnsiCompareText(mp.mp3types2, param) then
      Result:= True
    else
    if 0 = AnsiCompareText(mp.mp3types3, param) then
      Result:= True
    ;
  end;
end;

class function TConditionMP3Type.Name: string;
begin
  Result:= 'mp3type';
end;

{ TConditionMP3Bootleg }

class function TConditionMP3Bootleg.Description: string;
begin
  Result:= 'Returns true if the mp3 rip is bootleg.';
end;

function TConditionMP3Bootleg.Match(r: TPazo): Boolean;
begin
  Result:= False;
  if (r.rls is TMP3Release) then
    Result:= TMP3Release(r.rls).bootleg;
end;

class function TConditionMP3Bootleg.Name: string;
begin
  Result:= 'mp3bootleg';
end;

{ TConditionMP3AType }

class function TConditionMP3AType.Description: string;
begin
  Result:= 'Returns true if the mp3 rip has any of the specified types.'+#13#10;
  Result:= Result + 'Example: mp3type in Promo, Advance';
end;

function TConditionMP3AType.Match(r: TPazo): Boolean;
var mp: TMP3Release;
begin
  Result:= False;
  if r.rls is TMP3Release then
  begin
    mp:= TMP3Release(r.rls);
    if -1 <> lista.IndexOf(mp.mp3types1) then
      Result:= True
    else
    if -1 <> lista.IndexOf(mp.mp3types2) then
      Result:= True
    else
    if -1 <> lista.IndexOf(mp.mp3types3) then
      Result:= True
    ;
  end;

end;

class function TConditionMP3AType.Name: string;
begin
  Result:= 'mp3type';
end;

{ TConditionMP3LtNumCDs }

class function TConditionMP3LtNumDisks.Description: string;
begin
  Result:= 'Returns true if number of CDs are less then the specified'+#13#10;
  Result:= REsult + 'Example: mp3numcds < 2';
end;

function TConditionMP3LtNumDisks.Match(r: TPazo): Boolean;
begin
  Result:= False;
  if r.rls is TMP3Release then
    if parami <> -1 then
      if TMP3Release(r.rls).Numdisks < parami then
        Result:= True;
end;

class function TConditionMP3LtNumDisks.Name: string;
begin
  Result:= 'mp3numdisks';
end;

class function TConditionMP3LtNumDisks.Operator: string;
begin
  Result:= '<';
end;

{ TConditionMP3LEtNumDisks }

class function TConditionMP3LEtNumDisks.Description: string;
begin
  Result:= 'Returns true if number of CDs are less then the specified'+#13#10;
  Result:= REsult + 'Example: mp3numcds <= 2';
end;

function TConditionMP3LEtNumDisks.Match(r: TPazo): Boolean;
begin
  Result:= False;
  if r.rls is TMP3Release then
    if parami <> -1 then
      if TMP3Release(r.rls).Numdisks <= parami then
        Result:= True;
end;

class function TConditionMP3LEtNumDisks.Name: string;
begin
  Result:= 'mp3numdisks';
end;

class function TConditionMP3LEtNumDisks.Operator: string;
begin
  Result:= '<=';
end;

{ TConditionMP3ENumDisks }

class function TConditionMP3ENumDisks.Description: string;
begin
  Result:= 'Returns true if number of CDs are less then the specified'+#13#10;
  Result:= REsult + 'Example: mp3numcds = 1';
end;

function TConditionMP3ENumDisks.Match(r: TPazo): Boolean;
begin
  Result:= False;
  if r.rls is TMP3Release then
    if parami <> -1 then
      if TMP3Release(r.rls).Numdisks = parami then
        Result:= True;
end;

class function TConditionMP3ENumDisks.Name: string;
begin
  Result:= 'mp3numdisks';
end;

class function TConditionMP3ENumDisks.Operator: string;
begin
  Result:= '=';
end;

{ TConditionMP3GEtNumDisks }

class function TConditionMP3GEtNumDisks.Description: string;
begin
  Result:= 'Returns true if number of CDs are less then the specified'+#13#10;
  Result:= REsult + 'Example: mp3numcds >= 3';
end;

function TConditionMP3GEtNumDisks.Match(r: TPazo): Boolean;
begin
  Result:= False;
  if r.rls is TMP3Release then
    if parami <> -1 then
      if TMP3Release(r.rls).Numdisks >= parami then
        Result:= True;
end;

class function TConditionMP3GEtNumDisks.Name: string;
begin
  Result:= 'mp3numdisks';
end;

class function TConditionMP3GEtNumDisks.Operator: string;
begin
  Result:= '>=';
end;

{ TConditionMP3GtNumDisks }

class function TConditionMP3GtNumDisks.Description: string;
begin
  Result:= 'Returns true if number of CDs are less then the specified'+#13#10;
  Result:= REsult + 'Example: mp3numcds > 1';
end;

function TConditionMP3GtNumDisks.Match(r: TPazo): Boolean;
begin
  Result:= False;
  if r.rls is TMP3Release then
    if parami <> -1 then
      if TMP3Release(r.rls).Numdisks > parami then
        Result:= True;
end;

class function TConditionMP3GtNumDisks.Name: string;
begin
  Result:= 'mp3numdisks';
end;

class function TConditionMP3GtNumDisks.Operator: string;
begin
  Result:= '>';
end;

{ TConditionMP3VA }

class function TConditionMP3VA.Description: string;
begin
  Result:= 'Returns true if the mp3 rip is a compilation. (VA)';
end;

function TConditionMP3VA.Match(r: TPazo): Boolean;
begin
  Result:= False;
  if (r.rls is TMP3Release) then
    Result:= TMP3Release(r.rls).mp3_va;
end;

class function TConditionMP3VA.Name: string;
begin
   Result:= 'mp3va';
end;

{ TConditionAgeGt }

class function TConditionAgeGt.Description: string;
begin
  Result:= 'This is useful for filtering old stuffs scanned by autodirlist in a not dated directory.'+ #13#10;
  Result:= Result + 'It expects the parameter in seconds. Example: if age > 86400 then DROP'+#13#10;
end;

function TConditionAgeGt.Match(r: TPazo): Boolean;
var i: Integer;
begin
  Result:= False;
  i:= r.Age;
  if i = -1 then exit;
  if i > parami then Result:= True;
end;

class function TConditionAgeGt.Name: string;
begin
  Result:= 'age';
end;

class function TConditionAgeGt.Operator: string;
begin
  Result:= '>';
end;

{ TConditionAgeLt }

class function TConditionAgeLt.Description: string;
begin
  Result:= 'This is useful for filtering old stuffs scanned by autodirlist in a not dated directory.'+ #13#10;
  Result:= Result + 'It expects the parameter in seconds. For example, we dont want 0sec stuffs with our leech account of HQ: if source @ HQ && age < 900 then DROP'+#13#10;
end;

function TConditionAgeLt.Match(r: TPazo): Boolean;
var i: Integer;
begin
  Result:= False;
  i:= r.Age;
  if i = -1 then exit;
  if i < parami then Result:= True;
end;

class function TConditionAgeLt.Name: string;
begin
  Result:= 'age';
end;

class function TConditionAgeLt.Operator: string;
begin
  Result:= '<';
end;


{ TConditionNfoMGenre }

class function TConditionNfoMGenre.Description: string;
begin
  Result:= 'Checks for genre parsed from the nfo file. As its a stupid textfile, use masks.'+ #13#10;
  Result:= 'Genre string contains latin alphabet only, all other chars are replaced to spaces!'+ #13#10;
  Result:= Result + 'Example: if nfogenre =~ *Hip Hop* then ALLOW'+#13#10;
end;

function TConditionNfoMGenre.Match(r: TPazo): Boolean;
begin
  Result:= False;
  if r.rls is TNFORelease then
    Result:= mask.Matches(TNFORelease(r.rls).nfogenre);
end;

class function TConditionNfoMGenre.Name: string;
begin
  Result:= 'nfogenre';
end;

{ TConditionNotComplete }

class function TConditionNotComplete.Description: string;
begin
  Result:=          'Returns true, if the release is not yet complete at the specified site.'+#13#10;
  Result:= Result + 'This is the negated complete condition. It is true if the release is not notAllowed at the specified site and it is not pre or complete.'+#13#10;
  Result:= Result + 'Example: notcomplete @ SITENAME'+#13#10;
end;

function TConditionNotComplete.Match(r: TPazo): Boolean;
var x: TPazoSite;
begin
  Result:= False;
  x:= r.FindSite(param);
  if ((x <> nil) and (x.status <> rssNotAllowed) and (not x.Complete)) then
    Result:=  True;

end;

class function TConditionNotComplete.Name: string;
begin
  Result:= 'notcomplete';
end;

initialization
  RulesInit;
finalization
  RulesUninit;
end.

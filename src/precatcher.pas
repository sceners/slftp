unit precatcher;

interface

uses Classes, Contnrs, encinifile;

type
  TSection = class
    eventtype: string;
    section: string;
    words: TStringList;

    constructor Create;
    destructor Destroy; override;
  end;

  TSiteChan = class
    sitename: string;

    sections: TObjectList;

    constructor Create;
    destructor Destroy; override;
  end;


procedure PrecatcherReload();
procedure PrecatcherRebuild();
procedure PrecatcherStart;
procedure PrecatcherProcess(net, chan, nick, data: string);

var precatcher_debug: Boolean = False;
  precatcher_auto: Boolean;
  catcherFile: TEncStringlist;

implementation

uses SysUtils, sitesunit, Dateutils, kb, irc, ircblowfish, Masks, queueunit, mystrings,
  StrUtils;

type
  huntartunk_tipus = (sehun, racetool, ignorelist, replace, hunsections, mappings, channels, pretime);
  TMap = class
    origsection: string;
    newsection: string;
    mask: TMask;
    constructor Create(origsection, newsection, mask: string);
    destructor Destroy; override;
  end;

var
  catcherFilename, replacefromline: string;
  minimum_rlsname: Integer= 10;
  cd, skiprlses: THashedStringList;
  tagline, sectionlist, helper, ignorelista, replacefrom, replaceto: TStringList;
  huntartunk : huntartunk_tipus;
  mappingslist: TObjectList;

procedure mydebug(s: string);
begin
  if precatcher_debug then
    irc_Addtext(s);
end;


function csupaszit(s: string): string;
var i: Integer;
    skip: Integer;
begin
  Result:= '';
  skip:= 0;
  for i:= 1 to length(s) do
    if (skip = 0) then
    begin
      if (ord(s[i]) >= 32) then
      begin
        if (ord(s[i]) <> 255) then
        begin
          if (
           ((s[i] >= 'a') and (s[i] <= 'z'))
           or
           ((s[i] >= 'A') and (s[i] <= 'Z'))
           or
           Szam(s[i])
           or
           (s[i] = '(')
           or
           (s[i] = ')')
           or
           (s[i] = '_')
           or
           (s[i] = '-')
           or
           (s[i] = '.')
           or
           (s[i] = '&')
          )
          then
            Result:= Result + s[i]
          else
            Result:= Result + ' ';

        end
        else
          Result:= Result + ' ';
      end else
      begin
        if ((s[i] = #3) and (i < length(s) -2) and Szam(s[i+1]) and Szam(s[i+2])) then
          skip:= 2;
      end;
    end else
      dec(skip);
end;

function KibontasRiliz(var cdno: string): string;
const multicddirprefix : array[1..4] of string = ('cd', 'dvd', 'disc','disk');
var k, i, j: Integer;
    maxi, maxindex: Integer;
    maxs: string;
    szamok, ma8, ma4: string;
    y,m,d: Word;
    s: string;
begin
  cdno:= '';

  //leghosszabb szo amiben van - a riliz
  maxi := 0;
  maxindex:= 0;
  for i:= 0 to helper.Count -1 do
  begin
    if ((length(helper[i]) > maxi) and (0 <> Pos('-', helper[i]))) then
    begin
      maxi:= length(helper[i]);
      maxs:= helper[i];
      maxindex:= i;
    end;
  end;

  Result:= maxs;

  k:= length(Result);
  if(k >0) and (Result[k] = '.') then
  begin
    Delete(Result, k, 1);
    dec(k);
  end;
  if (k < minimum_rlsname) then Result:= '';


  DecodeDate(Today, y,m,d);
  ma8:= Format('%.4d%.2d%.2d', [y,m,d]);
  ma4:= Format('%.2d%.2d', [m,d]);
  for i:= 0 to maxindex do
  begin
    maxi:= length(helper[i]);
    // yyyymmdd yyyy-mmdd
    if (maxi in [4,8,9,10]) then
    begin
      szamok:= Csakszamok(helper[i]);
      if not (length(szamok) in [4,8]) then Continue;
      if ((length(szamok) = 4) and (szamok > '1231')) then Continue;

      if ((szamok <> ma4) and (szamok <> ma8)) then
      begin
        MyDebug('Backfill detected!: '+Result);
        irc_addtext('backfill detected! '+Result);
        skiprlses.Add(Result);
        Result:= '';
        exit;
      end;

    end;
  end;


  // na meg nezzuk meg hanyas cd-rol van szo
  for i:= 0 to helper.Count -1 do
  begin
      //1CD 99DVD
      j:= length(helper[i]);
      if (3 <= j) and (j <= 6) then
      begin
        s:= LowerCase(helper[i]);
        s:= Csere(s, ' ', '');
        s:= Csere(s, '_', '');
        s:= Csere(s, '-', '');

        for j:= 1 to 4 do
        begin
          if (1 = Pos(multicddirprefix[j], s)) then
          begin
            cdno:= IntToStr(StrToIntDef(Copy(s, Length(multicddirprefix[j])+1, 1000), 0));
            if cdno = '0' then cdno:= '';
            exit;
          end;
        end;
      end;
  end;
end;

procedure Focsupaszitas(data: string);
begin
    data:= csupaszit(data);
    helper.DelimitedText:= data;
end;
function ProcessRlsPretime: Integer;
var i, j, k, l: Integer;
    hibas: Boolean;
    pretime: LongWord;
    cdno, rls: string;
begin
  Result:= -1;
  pretime:= 0;
  i:= helper.IndexOf('pred');
  j:= helper.IndexOf('ago');
  if ((i <> -1) and (j <> -1) and (i + 1< j )) then
  begin
    hibas:= False;
    for k:= i+1 to j - 1 do
    begin
      //3y 43w 2d 16h 52m 39s
      l:= length(helper[k]);
      if (l > 1) then
      begin
        case helper[k][l] of
          'y': inc(pretime, StrToIntDef(Copy(helper[k], 1, l -1),0) * 31536000);
          'w': inc(pretime, StrToIntDef(Copy(helper[k], 1, l -1),0) * 604800);
          'd': inc(pretime, StrToIntDef(Copy(helper[k], 1, l -1),0) * 86400);
          'h': inc(pretime, StrToIntDef(Copy(helper[k], 1, l -1),0) * 3600);
          'm': inc(pretime, StrToIntDef(Copy(helper[k], 1, l -1),0) * 60);
          's': inc(pretime, StrToIntDef(Copy(helper[k], 1, l -1),0) );
        else
          hibas:= True;
        end;
      end;
    end;

    if not hibas then
    begin
      // kuldhetjuk pretime uzenetet
      rls:= KibontasRiliz(cdno);
      if (rls <> '') then
        Result:= pretime;
    end;
  end;
end;

function KibontasSection(rls, section: string): string;
var i: Integer;
    x: TMap;
begin
  Result:= section;
  if (Result = '') then
  begin
    for i:= 0 to sectionlist.Count-1 do
    begin
      if helper.IndexOf(sectionlist.ValueFromIndex[i]) <> -1 then
      begin
        Result:= sectionlist.Names[i];
        break;
      end;
    end;
  end;

  for i:= 0 to mappingslist.Count -1 do
  begin
    x:= TMap(mappingslist[i]);
    if ((x.origsection = '') or (x.origsection = Result)) then
    begin
      if (x.mask.Matches(rls)) then
      begin
        Result:= x.newsection;
        exit;
      end;
    end
  end;
end;
function KibontasGenre(): string;
var i: Integer;
    s: string;
begin
  s:= helper.DelimitedText;
  // keressuk meg a genret.
  for i:= 0 to mp3genres.Count-1 do
  begin
    if (
        (0 < Pos(mp3genres[i], s))
        or
        (0 < Pos(Csere (mp3genres[i], ' ', ''), s))
       )
    then
    begin
      Result:= mp3genres[i];
      exit;
    end;
  end;
end;

procedure ProcessReleaseVege(sitename, event, section: string);
var
    genre: string;
    fullkommand: string;
    rls: string;
    i: Integer;
    cdno: string;
    s: string;
    j, k: Integer;
begin
        // megvan, mar csak ki kell bontani a riliznevet
        rls:= KibontasRiliz(cdno);
        MyDebug('Rls: '+rls+' section: '+section);
        if rls <> '' then
        begin
          if (skiprlses.IndexOf(rls) <> -1) then exit;

          i:= ProcessRlsPretime;
          if i <> -1 then
          begin
            kb_Pretime(sitename, section, rls, i);
          end;

          if event = 'PRETIME' then exit;

          // elso korben megnezzuk van e ignoreword ra
          s:= Csere(helper.DelimitedText, rls, '');

          for i:= 0 to ignorelista.Count -1 do
           if AnsiContainsText(s, ignorelista[i]) then
           begin
             MyDebug('Nukeword '+ignorelista[i]+' found in '+rls);
             skiprlses.Add(rls);
             exit;
           end;

          if replacefrom.Count = replaceto.Count then
            for i:= 0 to replacefrom.Count -1 do
              s:= Csere(s, replacefrom[i], replaceto[i]);
           

          helper.DelimitedText:= s;
          j:= -1;
          for i:= 0 to tagline.Count -1 do
          begin
            j:= helper.IndexOf(tagline[i]);
            if j <> -1 then
              Break;
          end;

          if j <> -1 then
          begin
            k:= helper.Count - j;
            for i:= 1 to k do
              helper.Delete(j);
          end;


          section:= KibontasSection(rls, section);
          if section = '' then
          begin
            irc_Addtext('No section?! '+sitename+'@'+rls);
            exit;
          end;

          genre:= '';
          if (1 = Pos('MP3', section)) then
            genre:= KibontasGenre();

          (* we dont care about this anymore
          if cdno = '' then
          begin
            if (helper.IndexOf('Subs') > 0) then
              cdno:= 'Subs'
            else
            if (helper.IndexOf('Sample') > 0) then
              cdno:= 'Sample'
            else
            if (helper.IndexOf('Covers') > 0) then
              cdno:= 'Sample'
            else
            if (helper.IndexOf('Cover') > 0) then
              cdno:= 'Covers';
          end;
          *)

          if (event = '') then
          begin
            //kitalaljuk hogy az event new pre vagy complete
            if (helper.IndexOf('pre') <> -1) then event := 'PRE'
            else
            if (helper.IndexOf('complete') <> -1) then event := 'COMPLETE'
            else
            if (helper.IndexOf('completed') <> -1) then event := 'COMPLETE'
            else
            if (helper.IndexOf('done') <> -1) then event := 'COMPLETE'
            else
            event := 'NEWDIR';
          end;

          fullkommand:= sitename+'|'+section+'|'+genre+'|'+event+'|'+rls+'|'+cdno;

          kb_Add(sitename, section, genre, event, rls, cdno, not precatcher_auto);

        end;
end;

procedure PrecatcherProcessB(net, chan, nick, data: string);
var i, j: Integer;
    sc: TSiteChan;
    ss: TSection;
    mind: Boolean;
begin
  i:= cd.IndexOf(net+chan+nick);
  if i <> -1 then
  begin
    MyDebug('PRECATCHER: '+chan+' '+nick+' '+data);
    sc:= TSiteChan(cd.Objects[i]);

    FoCsupaszitas(data);

    for i:= 0 to sc.sections.Count -1 do
    begin
      ss:= TSection(sc.sections[i]);
      mind:= True;
      for j:= 0 to ss.words.Count-1 do
      begin
        if (helper.IndexOf(ss.words[j]) = -1) then
        begin
          mind:= False;
          Break;
        end;
      end;

      if (mind) then
      begin
        ProcessReleaseVege(sc.sitename, ss.eventtype, ss.section);
        exit;
      end;
    end;

    ProcessReleaseVege(sc.sitename, '', '');

  end;
end;
procedure PrecatcherProcess(net, chan, nick, data: string);
begin
  queue_lock.Enter;
  PrecatcherProcessB(net, chan, nick, data);
  queue_lock.Leave;
end;

function ProcessChannels(s: string): Boolean;
var network, chan, nick, sitename, words: string;
    sci: Integer;
    sc: TSiteChan;
    section: TSection;
    i, j: Integer;
    nickc: Integer;
    nickt: string;
begin
  Result:= False;
  if (length(s) = 0) then exit;

  if (Count(';', s) < 3) then exit;


  network:= SubString(s, ';', 1);
  chan:= SubString(s, ';', 2);
  nickt:= SubString(s, ';', 3);
  sitename:= SubString(s, ';', 4);

  if(chan[1] <> '#') then exit;

  (*
  // most validalnunk kell a networkot es a chant...
  irc_lock.Enter;
  if nil = FindIrcnetwork(network) then
  begin
    irc_lock.Leave; // skip, as network does not exist
    exit;
  end;
  if nil = FindIrcBlowfish(network, chan, False) then
  begin
    irc_lock.Leave;
    exit;
  end;
  irc_lock.Leave;
  *)
  
  nickc:= Count(',', nickt);

  for j:= 1 to nickc+1 do
  begin
    nick:= SubString(nickt, ',', j);
    sci:= cd.IndexOf(network+chan+nick);
    if( sci = -1 ) then
    begin
      sc:= TSiteChan.Create();
      sc.sitename:= sitename;
      cd.AddObject(network+chan+nick, sc);
    end else
      sc:= TSiteChan(cd.Objects[sci]);

    if ((SubString(s, ';', 5) = '')and(SubString(s, ';', 7) = '')) then Continue;

    section:= TSection.Create;
    section.section:= SubString(s, ';', 7);
    section.eventtype:= SubString(s, ';', 5);

    words:= SubString(s, ';', 6);

    if (words <> '') then
      for i:= 1 to Count(',', words)+1 do
        section.words.Add(SubString(words,',',i));

    sc.sections.Add(section);
  end;
  Result:= True;
end;

procedure PrecatcherRebuild();
var i: Integer;
begin
  cd.Clear;

    i:= 0;
    while (i < catcherFile.Count) do
    begin
      if not ProcessChannels(catcherFile[i]) then
      begin
        catcherFile.Delete(i);
        dec(i);
      end;
      inc(i);
    end;
    catcherFile.SaveToFile(catcherFilename);
end;

procedure ProcessRaceTool(s: string);
begin
  if (SubString(s, '=', 1) = 'minimum_rlsname') then
    minimum_rlsname:= StrToIntDef(SubString(s, '=', 2), 10);
end;

procedure ProcessIgnoreList(s: string);
begin
  if (SubString(s, '=', 1) = 'nukewords') then
    ignorelista.DelimitedText:= SubString(s, '=', 2)
  else
  if (SubString(s, '=', 1) = 'tagline') then
    tagline.DelimitedText:= SubString(s, '=', 2)

end;

procedure ProcessReplace(s: string);
var i, db: Integer;
    replacetoline: string;
begin
  if (SubString(s, '=', 1) = 'replacefrom') then
    replacefromline:= trim(SubString(s, '=', 2))
  else
  if (SubString(s, '=', 1) = 'replaceto') then
  begin
    replacetoline:= trim(SubString(s, '=', 2));
    db:= Count(';', replacefromline);
    for i:= 1 to db+1 do
    begin
      replacefrom.Add( SubString(replacefromline, ';', i) );
      replaceto.Add( replacetoline );
    end;
  end;
end;


procedure ProcessSections(s: string);
var v, vv, section: string;
    i: Integer;
begin
  section:= SubString(s, '=', 1);
  if (section <> '') then
  begin
    v:= SubString(s, '=', 2);
    for i:= 1 to Count(' ', v)+1 do
    begin
      vv:= Trim(SubString(v, ' ', i));
      if (vv <> '') then
        sectionlist.Add(section+'='+vv);
    end;
  end;
end;

procedure ProcessMappings(s: string);
var x: TMap;
    db, i: Integer;
    ss: string;
begin
  if Count(';', s) = 2 then
  begin
    ss:= SubString(s, ';', 3);
    db:= Count(',', ss);
    for i:= 1 to db+1 do
    begin
      x:= TMap.Create(SubString(s, ';', 1), SubString(s, ';', 2), SubString(ss, ',', i));
      mappingslist.Add(x);
    end;
  end;
end;



procedure ProcessConfigLine(s: string);
begin
  if s = '[racetool]' then
    huntartunk:= racetool
  else
  if s = '[ignorelist]' then
    huntartunk:= ignorelist
  else
  if s = '[replace]' then
    huntartunk:= replace
  else
  if s = '[sections]' then
    huntartunk:= hunsections
  else
  if s = '[mappings]' then
    huntartunk:= mappings
  else
  if s = '[channels]' then
    huntartunk:= channels
  else
  if s = '[pretime]' then
    huntartunk:= pretime;

  case huntartunk of
    racetool: ProcessRaceTool(s);
    ignorelist: ProcessIgnoreList(s);
    replace: ProcessReplace(s);
    hunsections: ProcessSections(s);
    mappings: ProcessMappings(s);
  end;
end;


procedure PrecatcherReload();
var f: TextFile;
    s: string;
    i: Integer;
begin
  AssignFile(f, ExtractFilePath(ParamStr(0))+'slftp.precatcher');
{$I-} Reset(f); {$I+}
  if IOResult = 0 then
  begin
    while (not Eof(f)) do
    begin
      ReadLn(f,s);
      ProcessConfigLine(s);
    end;
    CloseFile(f);
  end;
  sections.Clear;
  for i:= 0 to sectionlist.Count -1 do
    if sections.Indexof(sectionlist.Names[i]) = -1 then
      sections.Add(sectionlist.Names[i]);

end;


procedure Precatcher_Init;
begin

  cd:= THashedStringList.Create;

  helper:= TStringList.Create;
  helper.CaseSensitive:= False;
  helper.Delimiter:= ' ';
  helper.QuoteChar:= '"';
  ignorelista:= TStringList.Create;
  ignorelista.Delimiter:= ' ';
  ignorelista.QuoteChar:= '"';
  tagline:= TStringList.Create;
  tagline.Delimiter:= ' ';
  tagline.QuoteChar:= '"';
  sectionlist:= TStringList.Create;
  mappingslist:= TObjectList.Create;
  skiprlses:= THashedStringList.Create;

  replacefrom:= TStringList.Create;
  replacefrom.Duplicates:= dupAccept;
  replaceto:= TStringList.Create;
  replaceto.Duplicates:= dupAccept;

  huntartunk := sehun;


  // ezt itt most csak azert hogy jo sorrendben hivodjanak meg az inicializaciok
  catcherFilename:= ExtractFilePath(ParamStr(0))+'slftp.chans';
  catcherFile:= TEncStringList.Create;
end;

procedure Precatcher_UnInit;
begin
  helper.Free;
  ignorelista.Free;

  sectionlist.Free;
  mappingslist.Free;
  skiprlses.Free;
  tagline.Free;
  replacefrom.Free;
  replaceto.Free;

  catcherFile.Free;

  cd.Free;
end;


{ TMap }

constructor TMap.Create(origsection, newsection, mask: string);
begin
  self.origsection:= origsection;
  self.newsection:= newsection;
  self.mask:= TMask.Create(mask);
end;

destructor TMap.Destroy;
begin
  mask.Free;
  inherited;
end;

constructor TSection.Create;
begin
  words:= TStringList.Create;
end;

destructor TSection.Destroy;
begin
  words.Free;
  inherited;
end;

constructor TSiteChan.Create;
begin
  sections:= TObjectList.Create;
end;

destructor TSiteChan.Destroy;
begin
  sections.Free;
  inherited;
end;

procedure PrecatcherStart;
begin
  queue_lock.Enter;
  PrecatcherReload;

  precatcher_auto:= sitesdat.ReadBool('precatcher', 'auto', False);
  catcherFile.LoadFromFile(catcherFileName);
  PrecatcherReBuild;
  queue_lock.Leave;
end;

initialization
  Precatcher_Init;
finalization
  Precatcher_Uninit;
end.

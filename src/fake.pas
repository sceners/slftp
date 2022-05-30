unit fake;

// todo implement

interface

uses Classes, SysUtils, kb;

procedure FakeStart;
procedure FakeCheck(r: TRelease);

implementation

uses configunit, mystrings, StrUtils;

type
  TFakeSettings = class
      enabled: Boolean;
      fake_min_release_length: Integer;
      fake_few_different_chars: Integer;
      fake_many_different_chars: Integer;
      fake_many_dots: Integer;
      fake_many_short_words_length: Integer;
      fake_many_short_words_count: Integer;
      fake_banned_words: TStringList;
      fake_many_vocal: Integer;
      fake_groups: TStringList;

      constructor Create;
      destructor Destroy; override;
     end;

var fakes: TStringList;

resourcestring
  sFakeSection='fake';

procedure ReadFakeSettings;
var s: string;
    i, j: integer;
    f: TFakeSettings;
begin
  fakes.Text:= sections.Text;
  fakes.Insert(0, '');
  for i:= 0 to fakes.Count -1 do
  begin
    f:= TFakeSettings.Create;


    f.enabled:= config.ReadBool(sFakeSection,'fake_'+fakes[i]+'_enabled', False);

    if f.enabled then
    begin
      f.fake_min_release_length:= config.ReadInteger(sFakeSection,'fake_'+fakes[i]+'_min_release_length', 10);
      f.fake_few_different_chars:= config.ReadInteger(sFakeSection,'fake_'+fakes[i]+'_few_different_chars', 8);
      f.fake_many_different_chars:= config.ReadInteger(sFakeSection,'fake_'+fakes[i]+'_many_different_chars', 18);
      f.fake_many_dots:= config.ReadInteger(sFakeSection,'fake_'+fakes[i]+'_many_dots', 8);
      f.fake_many_short_words_length:= config.ReadInteger(sFakeSection,'fake_'+fakes[i]+'_many_short_words_length', 2);
      f.fake_many_short_words_count:= config.ReadInteger(sFakeSection,'fake_'+fakes[i]+'_many_short_words_count', 3);
      f.fake_banned_words.DelimitedText:= config.ReadString(sFakeSection, 'fake_'+fakes[i]+'_banned_words', 'scene auto deluser');
      f.fake_many_vocal:= config.ReadInteger(sFakeSection, 'fake_'+fakes[i]+'_many_vocal', 10);

      for j:= 1 to 100 do
      begin
        s:= config.ReadString(sFakeSection, 'fake_'+fakes[i]+'_groups'+IntToStr(j), '');
        if s = '' then
          Break;

        if j = 1 then
         f.fake_groups.DelimitedText:= s
        else
         f.fake_groups.DelimitedText:= f.fake_groups.DelimitedText+' '+s;
      end;

    end;
    fakes.Objects[i]:= f;
  end;


end;

procedure FakeStart;
begin
  ReadFakeSettings;
end;

procedure FakesInit;
begin
  fakes:= TStringList.Create;
end;

procedure FakesUninit;
var i: Integer;
begin
  for i:= 0 to fakes.Count -1 do
  begin
    fakes.Objects[i].Free;
    fakes.Objects[i]:= nil;
  end;
  fakes.Free;
end;

{ TFakeSettings }

constructor TFakeSettings.Create;
begin
  fake_banned_words:= TStringList.Create;
  fake_groups:= TStringList.Create;
end;

destructor TFakeSettings.Destroy;
begin
  fake_banned_words.Free;
  fake_groups.Free;

  inherited;
end;


(*
'Short rls',                // 1
[19:26:52] [Ar04n]                                            'Few different chars',      // 2
[19:26:52] [Ar04n]                                            'Many different chars',     // 3
[19:26:52] [Ar04n]                                            'Many short words',         // 4
[19:26:53] [Ar04n]                                            'Many dots',                // 5
[19:26:55] [Ar04n]                                            'Banned char in rls',       // 6
[19:26:55] [Ar04n]                                            'Number is 1. char',        // 7
[19:26:57] [Ar04n]                                            'Mexican wave',             // 8
[19:26:57] [Ar04n]                                            'Many vocal/consonant',     // 9
[19:26:59] [Ar04n]                                            'Error in round brackets',  // 10
[19:27:01] [Ar04n]                                            'Number in word',           // 11
[19:27:01] [Ar04n]                                            'Banned word',              // 12
[19:27:03] [Ar04n]                                            'Banned+wildcard',          // 13
[19:27:05] [Ar04n]                                            '3 double chars in a word', // 14
[19:27:05] [Ar04n]                                            'CUE/DIR/NFO/TRACK FIX',    // 15
[19:27:07] [Ar04n]                                            'Repeating in rls',         // 16
[19:27:07] [Ar04n]                                            'Invalid grp',              // 17
[19:27:09] [Ar04n]                                            'wtf not mp3?',             // 18
[19:27:11] [Ar04n]                                            'Not realgrp!'              // 19
*)

procedure FakeCheckI(r: TRelease; f: TFakeSettings);
var
    s,s2: string;
    i, j: Integer;
    rovid: Integer;
begin
  r.fake:= True;

  if (f.fake_groups.Count > 0) then
  begin
    if (f.fake_groups.IndexOf(r.groupname) = -1) then
      r.knowngroup:= grp_unknown
    else
      r.knowngroup:= grp_known;
  end else
    r.knowngroup:= grp_notconfigured;
  
  if length(r.rlsname) < f.fake_min_release_length then
  begin
    r.fakereason:= 'Too short.';
    exit;
  end;



  if(Lowercase(Copy(r.rlsname,1,3)) = 'mp3') then
  begin
    r.fakereason:= 'begins with mp3 :) brz protection';
    exit;
  end;

  if (r.maganhangzok >= f.fake_many_vocal) then
  begin
    r.fakereason:= 'Many vocal/consonant '+IntToStr(r.maganhangzok);
    exit;
  end;

  if (r.karakterszam <= f.fake_few_different_chars) then
  begin
    r.fakereason:= 'Few different chars '+IntToStr(r.karakterszam);
    exit;
  end;
  if (r.karakterszam >= f.fake_many_different_chars) then
  begin
    r.fakereason:= 'Many different chars '+IntToStr(r.karakterszam);
    exit;
  end;
  if (r.dots >= f.fake_many_dots) then
  begin
    r.fakereason:= 'Many dots'+IntToStr(r.dots);
    exit;
  end;

  if (r.groupname = '') then
  begin
    r.fakereason:= 'Invalid groupname';
    exit;
  end;

  rovid:= 0;
  for i:= 0 to r.words.Count -1 do
  begin
    if ((i < r.words.Count -1) and ((r.words[i]='Ltd') or (r.words[i]='Ed'))) then
      Continue;
    if (length(r.words[i]) <= f.fake_many_short_words_length) then
      inc(rovid);
  end;

  if rovid >= f.fake_many_short_words_count then
  begin
    r.fakereason:= 'Many short words';
    exit;
  end;

  s:= LowerCase(r.rlsname);
  s:= Csere(s, '3', 'e');
  s:= Csere(s, '1', 'i');
  s:= Csere(s, '4', 'a');

  //kiszedjuk ismetlodo botuket
  s2:= '';
  for i:= 1 to length(s) do
    if ((i = 1) or (s[i-1] <> s[i])) then
      s2:= s2+ s[i];

  s:= s2;
  s2:= ReverseString(s);


  for i:= 0 to f.fake_banned_words.Count -1 do
  begin
    j:= Pos(f.fake_banned_words[i], s);
    if ((j = 1) or ((j > 1) and (s[j-1] in [' ','_','-','.']))) then
    begin
      r.fakereason:= 'Banned word: '+f.fake_banned_words[i];
      exit;
    end;
    j:= Pos(f.fake_banned_words[i], s2);
    if ((j = 1) or ((j > 1) and (s2[j-1] in [' ','_','-','.']))) then
    begin
      r.fakereason:= 'Banned word: '+f.fake_banned_words[i];
      exit;
    end;
  end;



  s:= '';
  for i:= 0 to r.words.Count -1 do
  begin
    for j:= 1 to length(r.words[i]) do
    begin
      if ((0 = Pos(r.words[i][j], s)) and (not Szam(r.words[i][j]))) then
      begin
        s:= s + r.words[i][j];

        if ((0 <> Pos(r.words[i][j]+r.words[i][j]+r.words[i][j], r.words[i])) and (-1 = sections.IndexOf(r.words[i]))) then
        begin
          r.fakereason:= '3 same chars in a word';
          Exit;
        end;
      end;
    end;
  end;


//[19:27:07] [Ar04n]                                            'Repeating in rls',         // 16
  r.fake:= False;
end;

procedure FakeCheckMP3(r: TMP3Release; f: TFakeSettings);
var i, j, k: Integer;
    johetbetu, johetszam: Boolean;
    s: string;
begin

  r.fake:= True;

  for i:= 0 to r.words.Count -2 do
  begin
    if (r.mp3_number_of = r.words[i]) then
      Break;

    j:= SzamokSzama(r.words[i]);
    k:= length(r.words[i]);

    if ((j >0) and (k = j + 2)) then
    begin
      s:= LowerCase(Copy(r.words[i], k-1,2));

      if ((-1 = StrToIntDef(s, -1)) and (not ((s = 'th') or (s = 'rd') or (s  = 'nd')))) then
      begin
        r.fakereason:= 'Number in word: '+r.words[i];
        exit;
      end;
    end;

    if ((j > 0) and (k <> j)) then
    begin
      // katalogusszamot ki kell meg hagyni
      johetbetu:= True;
      johetszam:= True;

      for k:= 1 to length(r.words[i]) do
      begin
        if (Szam(r.words[i][k])) then
        begin
          if johetszam then
            johetbetu:= False
          else
          begin
            r.fakereason:= 'Number in word: '+r.words[i];
            exit;
          end;
        end
        else
        begin
          if not johetbetu then
          begin
            r.fakereason:= 'Number in word: '+r.words[i];
            exit;
          end;
        end;
      end;
    end;
  end;

  r.fake:= False;
end;

procedure FakeCheck(r: TRelease);
var i: integer;
begin
  r.fake:= False;
  if TFakeSettings(fakes.Objects[0]).enabled then
    FakeCheckI(r, TFakeSettings(fakes.Objects[0]));

  if not r.fake then
  begin
    //generalisan nem fake, most megnezzuk hogy szekcionalisan az e

    i:= fakes.IndexOf(r.section);
    if i <> -1 then
      if TFakeSettings(fakes.Objects[i]).enabled then
      begin
        FakeCheckI(r, TFakeSettings(fakes.Objects[i]));

        // most jonnek a section fuggo plusz ellenorzesek

        if not r.fake then
        begin
          if r.section = 'MP3' then
            FakeCheckMP3(r as TMP3Release, TFakeSettings(fakes.Objects[i]));
        end;
      end;
  end;
end;


initialization
  FakesInit;

finalization
  FakesUninit;

end.


unit mystrings;

interface


function LeftStr (const source: string; count: integer): string;
function RightStr (const source: string; count: integer): string;
function MinMax(aValue, minimal, maximum: integer): integer;
function SubString (const s, seperator: string; index: integer): string;
function Csere (const source, mit, mire:string):string;
function AtConvert(source: string; style: integer): string;
function RightStrv2 (const source: string; count: integer): string;
function myEncode (what: string): String;//spaceket  csereli at
function myDecode (what: string): String;
function CleanString (mit: String):String;
function Count(const mi, miben: string):Integer;
function RPos(SubStr: Char; Str: String): Integer;
function FillCharL(what, t: Integer;whit: Char): String;
function GetLastDir(g: string): string;
function ExtractUrlFileName(url:string):string;
function ExtractFileNameWithoutExt(fname:string):string;
function BufStr (B: array of byte; APos, ALen : integer) : string;
procedure StrBuf (var B: array of byte; APos, ALen : integer; const AStr : string);
function FillCharR(w: string; ig: Integer; withc: Char): string;
function ReadBetweenSeperators(s, sep1,sep2: string; var from: Integer):string;
function PatternCount(s: string): Integer;
function GetPattern(s: string; which: Integer): string;
procedure GetPadding(s: string; var sep1, sep2: string; which: Integer);
function validemail(em: string): Boolean;
function MakeStringLeft(mi, mivel: string; c: Integer): string;
function MakeStringCenter(mi, mivel: string; c: Integer): string;
function MakeStringRight(mi, mivel: string; c: Integer): string;
function MakeFullPath(s: string):string;
function GetByte(i, b: LongWord): Byte;
function GetInteger(b1,b2,b3,b4:Byte): LongWord;
function UrlEncode(const DecodedStr: String; Pluses: Boolean): String; overload;
function UrlEncode(const DecodedStr: String): String; overload;
function UrlDecode(const EncodedStr: String): String;
function MyToday: string;
function MyDateToStr(x: TDateTime): string;
function MyStrToDate(x: string): TDateTime;
function NoToTime(x: Integer): string; overload;
function NoToTime(s: string): string; overload;
function Szovegge(szam: Integer): string; overload;
function Szovegge(d: Double): string; overload;
function myStrToFloat(s: string): Double; overload;
function myStrToFloat(s: string; def: Double): Double; overload;
function CheckTAXNumber(TAxNumber: string; BornDate: TDateTime = 0): Boolean;
function CheckCompanyTaxNumber(TaxNumber: string):Integer;
function IsValidEmail(const Value: string): boolean;
procedure MyWriteLn(s: string);
function MyCopy(b: array of byte; index, len: Integer): string;
function myRand(mini, maxi: Integer): Integer;
function ParseResponseCode(s: string): Integer;

{$IFDEF MSWINDOWS}
function GetWinDir: string;
function GetTempDir:string;
function GetContentType(fname: string): string;
{$ENDIF}
function MyIncludeTrailingSlash(s: string): string;
procedure ParsePasvString(s: string; var host: string; var port: Integer);

function Szam(c: char): Boolean;
function Szamokszama(s: string): Integer;
function CsakSzamok(s: string): string;

implementation

uses SysUtils, math
{$IFDEF MSWINDOWS}
, registry, Windows
{$ENDIF}
, DateUtils;

procedure StrBuf (var B: array of byte; APos, ALen : integer; const AStr : string);
  var
   Len : integer;
  begin
   Len := Length (AStr);
   if Len > ALen
    then Len := ALen;
   Move (AStr [1], b [APos], Len);
   if Len < ALen
    then FillChar (b [APos + Len], ALen - Len, $00);
  end;

function BufStr (B: array of byte; APos, ALen : integer) : string;
begin
   SetString (Result, nil, ALen);
   Move (b [APos], Result [1], ALen);
   if Pos (#0, Result) > 0 then
     Result := copy (Result, 1, Pos (#0, Result) - 1);
   Result := TrimRight (Result);
end;

{$IFDEF MSWINDOWS}
function GetWinDir:string;
var a: array[1..255] of Byte;
    i: Integer;
begin
  i:= GetWindowsDirectory(@a,255);
  Result:=BufStr(a,0,i);
end;

function GetTempDir:string;
var a: array[1..255] of Byte;
    i: Integer;
begin
  i:= GetTempPath(255,@a);
  Result:=BufStr(a,0,i);
end;
{$ENDIF}

function Count(const mi, miben: string):Integer;
var s: string;
    i: Integer;
begin
  s:= '';
  Result:= 0;
  for i:= 1 to length(miben) do
  begin
    s:= s + miben[i];
    if 0 < Pos(mi,s) then
    begin
      inc(Result);
      s:= '';
    end;
  end;
end;

function LeftStr (const source: string; count: integer): string;
var i: integer;
begin
  Result:= '';
  for i:= 1 to count do
    Result:= Result + source[i];
end;

function RightStr (const source: string; count: integer): string;
var i: integer;
begin
  Result:= '';
  for i:= length(source)-count+1 to length(source) do
    Result:= Result + source[i];
end;

function RightStrv2 (const source: string; count: integer): string;
var i: integer;
begin
  Result:= '';
  for i:= count+1 to length(source) do
    Result:= Result + source[i];
end;


function MinMax(aValue, minimal, maximum: integer): integer;
begin
  if aValue < minimal then
    Result:= minimal else
  if aValue > maximum then
    Result:= maximum else
    Result:= aValue;
end;


(*
function SubString (const s, seperator: string; index: integer): string;
var ok: boolean;
    i: integer;
    szamlalo: integer;
begin
  ok:= false; i:= 0; Result:= ''; szamlalo:= 0;

  while not ok do
  begin
    if i = length(s) then ok:= True
    else
    begin
      inc (i);
      Result:= Result + s[i];
      if ((length(Result) - length(Seperator)+1) <> 0) and (length(Result) - length(Seperator) +1 = Pos (Seperator, Result)) then //szoveg vegen
      begin
        inc (szamlalo);
        if szamlalo = index then
        begin
          ok:= True;
          Delete (Result, (length(Result) - length(Seperator)+1),length(Seperator));
        end else
          Result:= '';
      end;
    end;
  end;

end;
*)

function SubString (const s, seperator: string; index: integer): string;
var akts: string;
    sz: integer;
    i,l: Integer;
begin
  akts:= s;
  sz:= 0;
  Result:= '';
  l:= length(seperator);
  repeat
    i:= Pos(seperator, akts);
    if i <> 0 then
    begin
      if sz + 1 = index then
      begin
        // ezt kerestuk
        Result:= Copy(akts, 1, i-1);
        exit;
      end;

      akts:= Copy(akts, i+l, 10000);
      inc(sz);
    end else
    begin
      // nincs tobb talalat.
      if sz + 1 = index then
        Result:= akts;
      exit;
    end;
  until False;
end;

function Csere (const source, mit, mire:string):string;
{var i, j: integer;
    temp: string;}
begin
  Result:= StringReplace(source,mit, mire, [rfReplaceAll, rfIgnoreCase]);
{  Result:= ''; temp:= '';
  for i:= 1 to length (source) do
  begin
    Result:= Result + source[i];
    j:= Pos (mit, Result);
    If j <> 0 then
    begin
      delete (Result, j, length(mit));
      insert (mire, Result, j);
    end;
  end;}
end;

function AtConvert(source: string; style: integer): string;
var i: integer;
    nemkell: boolean;
begin
  Result:= source;
  case style of
    1: Result:= AnsiLowerCase (source);
    2: begin
         Result:= '';
         nemkell:= false;
         for i:= 1 to length (source) do
         begin
           if (i+1 <= length(source)) and (source[i] in [' ', '-', '.', '_','(','?','!']) then
           begin
             Result:= Result + source[i];
             source[i+1]:= AnsiUpperCase(source[i+1])[1];
             nemkell:= true;
           end else
           if (i = 1) then
             Result:= Result + AnsiUpperCase(source[i]) 
           else
           begin
             if nemkell then
             begin
               Result:= Result + source[i];
               nemkell:= false;
             end else
               Result:= Result + AnsiLowerCase(source[i]);
           end;
         end;
       end;
    3: Result:= AnsiUpperCase (source);
    4: begin
         Result:= AnsiLowerCase (source);
         if length(Result) > 0 then
           Result[1]:= AnsiUpperCase (Result)[1];
       end;
  end;
end;

function myDecode (what: string): String;
begin
  Result:= Csere (what, ' ', '\éáûûáé/');
end;

function myEncode (what: string): String;
begin
  Result:= Csere (what,'\éáûûáé/' ,' ');
end;

//lecsereli az osszes nemfajlnevkaraktert
function CleanString (mit: String):String;
begin
  mit:= Csere (mit, '/', '-');
  mit:= Csere (mit, ':', '-');
  mit:= Csere (mit, '?', '');
  mit:= Csere (mit, '<', '');
  mit:= Csere (mit, '>', '');
  mit:= Csere (mit, '"', '');
  mit:= Csere (mit, '*', '');
  mit:= Csere (mit, #0, '');
  Result:= mit;
end;

function RPos(SubStr: Char; Str: String): Integer;
var m, i: Integer;
begin
  Result:= 0;
  m:= length(Str);
  for i:= 1 to m do
    if Str[i] = SubStr Then Result:= i;
end;


function FillCharL(what, t: Integer;whit: Char): String;
var i: Integer;
begin
  Result:= IntToStr(what);
  for i:= 0 to t - length(Result) - 1 do
    Result:= whit+Result;
end;

function GetLastDir(g: string): string;
begin
  if ((length(g) > 0) and (g[length(g)] = '\')) then
    Delete(g,length(g),1);
  Result:= RightStrv2(g,RPos('\',g));
end;

function ExtractUrlFileName(url:string):string;
var i: Integer;
begin
  Result:= '';
  i:= RPos('/', url);
  if i > 5 then
    Result:= Copy(url, i+1, 200);
end;

function ExtractFileNameWithoutExt(fname:string):string;
var tmp: string;
begin
  tmp:= ExtractFileName(fname);
  Result:= Copy(tmp,1,length(tmp)-length(ExtractFileExt(fname)));
end;

function FillCharR(w: string; ig: Integer; withc: Char):string;
var i: Integer;
begin
  Result:= w;
  for i:= length(w) to ig do
    Result:= Result + withc;
end;

function ReadBetweenSeperators(s, sep1,sep2: string; var from: Integer):string;
var tmp, tmp2: string;
    k, tmpv, v: Integer;
    ok: Boolean;
begin
  tmp:= Copy(s,from,length(s));
  if sep1 <> '' then
    k:= Pos(sep1,tmp) + length(sep1)
  else
    k:= 1;
  if k = 0 then k:= 1;
  v:= 0;
  tmpv:= 0;
  ok:= True;
  tmp2:= tmp;
  while ok do
  begin
    tmp2:= Copy(tmp,v+1,length(tmp));
    if sep2 <> '' then
      tmpv:= Pos(sep2,tmp2)
    else
    begin
      v:= length(tmp) + 1;
      ok:= False;
    end;
    if tmpv = 0 then
    begin
      ok:= False;
      v:= length(tmp) + 1;
    end;
    inc(v, tmpv);
    if v >= k then
      ok:= False;
  end;

  from:= v;
  Result:= Copy(tmp, k, v-k);
end;

function PatternCount(s: string): Integer;
var fOk: Boolean;
    i: Integer;
begin
  fOk:= False;
  Result:= 0;
  for i:= 1 to length(s) do
  begin
    case s[i] of
      '<': fOk:= True;
      '>': if fOk then begin fOk:= False; inc(Result); end;
    end;
  end;
end;

function GetPattern(s: string; which: Integer): string;
var fOk: Boolean;
    i, holtartunk: Integer;
    tmp: string;
begin
  fOk:= False;
  tmp:= '';
  Result:= '';
  holtartunk:= 0;
  for i:= 1 to length(s) do
  begin
    if fOk then
      tmp:= tmp + s[i];
    case s[i] of
      '<': begin fOk:= True; tmp:= '<'; end;
      '>': if fOk then
           begin
             fOk:= False;
             inc(holtartunk);
             if holtartunk = which then
               Result:= tmp;
           end;
    end;
  end;
end;

procedure GetPadding(s: string; var sep1, sep2: string; which: Integer);
var fOk, fSep1, fSep2: Boolean;
    i, holtartunk: Integer;
    tmp: string;
begin
  fSep1:= True;
  fSep2:= False;
  fOk:= False;
  sep1:= ''; sep2:= '';
  tmp:= '';
  holtartunk:= 0;
  for i:= 1 to length(s) do
  begin
    if (fSep1) and (s[i] <> '<') then
      sep1:= sep1 + s[i];

    if (fSep2) and (s[i] <> '<') then
      sep2:= sep2 + s[i];

    case s[i] of
      '<': begin
             fSep1:= False; fOk:= True;
             if holtartunk >= which then
             begin
               fSep1:= False; fSep2:= False;
             end;
           end;
      '>': if fOk then
           begin
             inc(holtartunk);
             if holtartunk = which then
               fSep2:= True
             else
             if holtartunk < which then
             begin
               fSep1:= True;
               sep1:= '';
             end;
             fOk:= False;
           end;
    end;
  end;
end;


function validemail(em: string): Boolean;
var i1, i2: Integer;
begin
  i1:= Pos('@',em);
  i2:= RPos('.',em);
  if ((i1 = 0) or (i2 = 0) or (i1 + 1 >= i2)) then
    Result:= False
  else
    Result:= True;
end;


function MakeStringLeft(mi, mivel: string; c: Integer): string;
var i: Integer;
begin
  Result:= Copy(mi,1,c);
  for i:= length(Result)+1 to c do
    Result:= Result + mivel;
end;

function MakeStringCenter(mi, mivel: string; c: Integer): string;
var s: Integer;
begin
  Result:= Copy(mi,1,c);
  s:= length(Result);
  Result:= MakeStringLeft(Result, ' ',(c -s) div 2 + s);
  Result:= MakeStringRight(Result, ' ',c);
end;

function MakeStringRight(mi, mivel: string; c: Integer): string;
var i: Integer;
begin
  Result:= Copy(mi,1,c);
  for i:= 1 to (c-length(Result)) do
    Result:= mivel + Result;
end;


function MakeFullPath(s: string):string;
var x: Integer;
begin
  Result:= s;
  x:= length(Result);
  if x <> 0 then
    if s[x] <> '\' then
      Result:= s+'\';
end;

//visszaadja i b-ik bajtjat
function GetByte(i, b: LongWord): Byte;
var mask: LongWord;
begin
  mask:= Round(IntPower(2,b*8)-1 - ((IntPower(2,(b-1)*8)) - 1));
  Result:= (i and mask) shr ((b -1)*8);
end;

//a negy megadott bajtbol keszit egy integert
function GetInteger(b1,b2,b3,b4:Byte): LongWord;
begin
  Result:= b4;
  Result:= Result shl 8;
  Result:= Result + b3;
  Result:= Result shl 8;
  Result:= Result + b2;
  Result:= Result shl 8;
  Result:= Result + b1;
end;

function UrlEncode(const DecodedStr: String; Pluses: Boolean): String;
var
  I: Integer;
begin
  Result := '';
  if Length(DecodedStr) > 0 then
    for I := 1 to Length(DecodedStr) do
    begin
      if not (DecodedStr[I] in ['0'..'9', 'a'..'z',
                                       'A'..'Z', ' ']) then
        Result := Result + '%' + IntToHex(Ord(DecodedStr[I]), 2)
      else if not (DecodedStr[I] = ' ') then
        Result := Result + DecodedStr[I]
      else
        begin
          if not Pluses then
            Result := Result + '%20'
          else
            Result := Result + '+';
        end;
    end;
end;

function UrlEncode(const DecodedStr: String): String;
begin
  Result:= URLEncode(DecodedStr, True);
end;


function HexToInt(HexStr: String): Int64;
var RetVar : Int64;
    i : byte;
begin
  HexStr := UpperCase(HexStr);
  if HexStr[length(HexStr)] = 'H' then
     Delete(HexStr,length(HexStr),1);
  RetVar := 0;

  for i := 1 to length(HexStr) do begin
      RetVar := RetVar shl 4;
      if HexStr[i] in ['0'..'9'] then
         RetVar := RetVar + (byte(HexStr[i]) - 48)
      else
         if HexStr[i] in ['A'..'F'] then
            RetVar := RetVar + (byte(HexStr[i]) - 55)
         else begin
            Retvar := 0;
            break;
         end;
  end;

  Result := RetVar;
end;


function UrlDecode(const EncodedStr: String): String;
var
  I: Integer;
begin
  Result := '';
  if Length(EncodedStr) > 0 then
  begin
    I := 1;
    while I <= Length(EncodedStr) do
    begin
      if EncodedStr[I] = '%' then
        begin
          Result := Result + Chr(HexToInt(EncodedStr[I+1]
                                       + EncodedStr[I+2]));
          I := Succ(Succ(I));
        end
      else if EncodedStr[I] = '+' then
        Result := Result + ' '
      else
        Result := Result + EncodedStr[I];

      I := Succ(I);
    end;
  end;
end;



{$IFDEF MSWINDOWS}
function GetContentType(fname: string): string;
var x: TRegistry;
begin
  x:= TRegistry.Create;
  x.RootKey:= HKEY_CLASSES_ROOT;
  Result:= 'application/octet-stream';
  try
    x.OpenKey('\'+ExtractFileExt(fname),false);
    Result:= x.ReadString('Content Type');
  finally
    x.Free;
  end;
end;

{$ENDIF}

function MyToday: string;
var y,m,d:Word;
begin
  DecodeDate(Now, y, m, d);
  Result:= Format('%.4d-%.2d-%.2d', [y, m, d]);
end;

function MyDateToStr(x: TDateTime): string;
begin
  Result:= FormatDateTime('yyyy-mm-dd hh:nn:ss', x)
end;

function MyStrToDate(x: string): TDateTime;
var y, m, d,h, mm, s: Integer;
begin
  y:= StrToIntDef(Copy(x, 1, 4), 2004);
  m:= StrToIntDef(Copy(x, 6, 2), 02);
  d:= StrToIntDef(Copy(x, 9, 2), 17);
  h:= StrToIntDef(Copy(x, 12, 2), 0);
  mm:= StrToIntDef(Copy(x, 15, 2), 0);
  s:= StrToIntDef(Copy(x, 18, 2), 0);
  Result:= EncodeDateTime(y,m,d, h, mm, s, 0);
end;


function NoToTime(x: Integer): string;
begin
  Result:= IntToStr(8 + (x div 2))+':';
  if (x mod 2 = 0) then
    Result:= Result + '00'
  else
    Result:= Result + '30';
end;

function NoToTime(s: string): string;
begin
  Result:= NoToTime(StrToInt(s))+'-'+NoToTime(StrToInt(s)+1);
end;


procedure betuzz(var s: string; number: Integer);
const kicsik: array[0..8] of string = ('egy','kettõ','három','négy','öt','hat','hét','nyolc','kilenc');
var num: Integer;
begin

  num:= number;
  if (num div 100 <> 0) then
  begin
     if (num div 100 <> 1) then
		 begin
       s:= s + kicsik[(num div 100) - 1];
     end;
     s:= s + 'száz';
     num:= num mod 100;
	end;
  
  if (num div 10 <> 0) then
  begin
    case (num div 10) of
      9: s:= s+'kilencven';
			8: s:= s+'nyolcvan';
			7: s:= s+'hetven';
			6: s:= s+'hatvan';
			5: s:= s+'ötven';
			4: s:= s+'negyven';
			3: s:= s+'harminc';
			2:
			         if (num mod 10 <> 0) then
                  s:= s+ 'huszon'
               else
                  s:= s+ 'húsz';
			1:
			         if (num mod 10 <> 0) then
                  s:= s + 'tizen'
           	 	 else
                  s:= s + 'tíz';
    end; //end of case
	end;

  if (num mod 10 <> 0) then s:= s + kicsik[(num mod 10) - 1];

end;


function Szovegge(szam: Integer): string;
const SZMAX = 4;
type
  TCuccok = record
    ertek: Integer;
    s: string
  end;
  TTablazat = array[1..SZMAX] of TCuccok;

const ertekek : TTablazat = (
                      (ertek:1000000000; s:'milliárd'),
                      (ertek:1000000;   s:'millió'),
                      (ertek:1000;     s:'ezer'),
                      (ertek:1; s:'')
                             );
var orig, i: Integer;
    betukkel: string;
begin
 Result:= '';
 if szam < 0 then
 begin
   szam:= szam * -1;
   Result:= 'mínusz ';
 end;

 orig:= szam;
 for i:=1 to SZMAX do
 begin
   if (szam div ertekek[i].ertek <> 0) then
   begin
     betukkel:= '';
  	 betuzz(betukkel, szam div ertekek[i].ertek);
     Result:= Result + betukkel + ertekek[i].s;
  	 szam:= szam mod ertekek[i].ertek;
     if (i <> SZMAX) and (szam > 0) and (orig > 2000) then
       Result:= Result + '-';
   end;
 end;

end;

function Szovegge(d: Double): string;
var a: Integer;
begin
  a:= Round(d);
  Result:= Szovegge(a);
end;


function myStrToFloat(s: string; def: Double): Double;
var x: string;
    d: Integer;
    e: Integer;
begin
  Result:= def;
  if s = '' then exit;
  s:= Csere(s, ',', '.');
  d:= Count('.', s);
  if (d <= 1) then
  begin
    Result:= StrToIntDef(SubString(s, '.', 1), 0);
    if d = 1 then
    begin
      x:= SubString(s, '.', 2);
      if Result < 0 then e:= -1 else e:= 1;
      Result:= Result+ e * StrToIntDef(x,0)/Power(10,length(x));
    end;
  end;
end;

function myStrToFloat(s: string): Double;
begin
  Result:= myStrToFloat(s, -1);
end;

function CheckTAXNumber(TAxNumber: string; BornDate: TDateTime = 0): Boolean;
var index, napok_szama, crc: integer;
begin
try
if (Length(TaxNumber) <> 10) then Result := false
else begin
Result:=True;
if BornDate<>0 then
begin
napok_szama := Trunc(BornDate - EncodeDate(1867, 1, 1));
if (StrToInt(copy(TaxNumber, 2, 5)) <> napok_szama) then Result := False;
end;
if Result then
begin
crc := 0;
index := 1;
while (index < Length(TaxNumber)) do begin
crc := crc + (StrToInt(copy(TaxNumber, index, 1)) * index);
index := index + 1;
end;
crc := (crc - StrToInt(copy(TaxNumber, 10, 1))) mod 11;
result := crc = 0;
end;
end;
except
Result := False;
end;
end;

function CheckCompanyTaxNumber(TaxNumber: string):Integer;
{************************************************
* Adószám ellenõrzése
* Visszatérési érték:
* - 0: Jó adószám
* - -1: Rossz a kapott érték hossza (csak 11 /elválasztás nélkül/ vagy 13 /elválasztással/ karakter lehet)
* - -2: A kapott érték nem csak számjegyet tartalmaz (kivéve: elválasztás)
* - -3: A 9. helyen nem 1,2 vagy 3 szerepel (adómentes, adóköteles,EVA)
* - -4: Az utolsó két számjegy nem a következõk egyike: 02-20, 22-44, 41
* - -5: A kapott érték CDV hibás
************************************************}
const
aCDV:array[1..4] of integer = (9,7,3,1);
var i: int64;
j: integer;
nCDV: integer;
cTemp: string;
begin
if not (length(TaxNumber) in [11,13]) then
begin
Result := -1;
exit;
end;
if Length(TaxNumber)=11 then
begin
if not TryStrToInt64(TaxNumber,i) then
begin
Result := -2;
exit;
end;
cTemp := TaxNumber;
end
else
begin
cTemp := copy(TaxNumber,1,8) + copy(TaxNumber,10,1) + copy(TaxNumber,12,2);
if not TryStrToInt64(cTemp,i) then
begin
Result := -2;
exit;
end;
end;
if not (cTemp[9] in ['1','2','3']) then
begin
Result := -3;
exit;
end;
nCDV := StrToInt(copy(cTemp,10,2));
if not(((nCDV>1) and (nCDV<21)) or ((nCDV>21) and (nCDV<45)) or (nCDV=51)) then
begin
Result := -4;
exit;
end;
nCDV := 0;
for j:=1 to 7 do
begin
nCDV := nCDV + StrToInt(cTemp[j])*aCDV[((j-1) mod 4)+1];
end;
if StrToInt(cTemp[8]) <> ((10-(nCDV mod 10)) mod 10) then
begin
Result := -5;
exit;
end;
Result := 0;
end;

function IsValidEmail(const Value: string): boolean;
  function CheckAllowed(const s: string): boolean;
  var
    i: integer;
  begin
    Result:= false;
    for i:= 1 to Length(s) do
    begin
      // illegal char in s -> no valid address
      if not (s[i] in ['a'..'z','A'..'Z','0'..'9','_','-','.']) then
        Exit;
    end;
    Result:= true;
  end;
var
  i: integer;
  namePart, serverPart: string;
begin // of IsValidEmail
  Result:= false;
  i:= Pos('@', Value);
  if (i = 0) or (pos('..', Value) > 0) then
    Exit;
  namePart:= Copy(Value, 1, i - 1);
  serverPart:= Copy(Value, i + 1, Length(Value));
  if (Length(namePart) = 0)         // @ or name missing
    or ((Length(serverPart) < 4))   // name or server missing or
    then Exit;                      // too short
  i:= Pos('.', serverPart);
  // must have dot and at least 3 places from end
  if (i < 2) or (i > (Length(serverPart) - 2)) then
    Exit;
  Result:= CheckAllowed(namePart) and CheckAllowed(serverPart);
end;

procedure MyWriteLn(s: string);
{$IFDEF DEBUG}var f: TextFile;{$ENDIF}
begin
{$IFDEF DEBUG}
  s:= FormatDateTime('hh:nn:ss.zzz', Now())+': '+s;
  AssignFile(f, 'szamlazo.log');
  if (FileExists('szamlazo.log')) then Append(f) else Rewrite(f);
  WriteLn(f,s);
  CloseFile(f);
{$ENDIF}
end;


function MyCopy(b: array of byte; index, len: Integer): string;
var i: Integer;
begin
  Result:= '';
  for i:= index to index+len -1 do
    Result:= Result+Chr(b[i]);
end;

function myRand(mini, maxi: Integer): Integer;
begin
  Result:= Random(maxi-mini+1)+mini;
end;

function ParseResponseCode(s: string): Integer;
var p: Integer;
begin
  Result:= 0;
  s:= Trim(s);
  p:= RPos(#13, s);
  if (p <= length(s)-5) then
  begin
    inc(p);
    if (s[p] in [#13, #10]) then inc(p);

    Result:= StrToIntDef(Copy(s, p, 3), 0);
    if s[p+3] <> ' ' then inc(Result, 1000);
  end;
end;

function MyIncludeTrailingSlash(s: string): string;
begin
  if length(s) > 0 then
  begin
    Result:= s;
    if Result[length(s)] <> '/' then
      Result:= Result + '/';
  end else
    Result:= '/';
end;

procedure ParsePasvString(s: string; var host: string; var port: Integer);
begin
  s:= Copy(s, Pos('(', s)+1, 10000);
  s:= Copy(s, 1, Pos(')', s)-1);
  host:= SubString(s, ',', 1)+'.'+
         SubString(s, ',', 2)+'.'+
         SubString(s, ',', 3)+'.'+
         SubString(s, ',', 4);
  port:= StrToIntDef(SubString(s, ',', 5), 0)*256+StrToIntDef(SubString(s, ',', 6), 0);
end;

function Szam(c: char): Boolean;
begin
  Result:= ((c >= '0') and (c <= '9'))
end;
function Szamokszama(s: string): Integer;
var i: Integer;
begin
  Result:= 0;
  for i:= 1 to length(s) do
    if(Szam(s[i])) then
      inc(Result);
end;
function CsakSzamok(s: string): string;
var i: Integer;
begin
  Result:= '';
  for i:= 1 to length(s) do
    if not (s[i] in ['/','-','0'..'9']) then
      exit
    else
    if(Szam(s[i])) then
      Result:= Result + s[i];
end;

end.

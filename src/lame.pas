unit lame;

interface

function MP3Info(filename: string): string;
function Lame_Check(var buffer: array of Byte; offset: Integer; var dest_info: string): Integer;
function ID3_Check(var buffer: array of Byte; var dest_info: string): Integer;

implementation

uses Classes, SysUtils, mystrings;

const
  LAME_BUFFER_SIZE = 16384;
  ID3_BUFFER_SIZE = 128;

  genres : Array[0..147] of string = (
 'Blues',
 'Classic Rock',
 'Country',
 'Dance',
 'Disco',
 'Funk',
 'Grunge',
 'Hip-Hop',
 'Jazz',
 'Metal',
 'New Age',
 'Oldies',
 'Other',
 'Pop',
 'R&B',
 'Rap',
 'Reggae',
 'Rock',
 'Techno',
 'Industrial',
 'Alternative',
 'Ska',
 'Death Metal',
 'Pranks',
 'Soundtrack',
 'Euro-Techno',
 'Ambient',
 'Trip-Hop',
 'Vocal',
 'Jazz+Funk',
 'Fusion',
 'Trance',
 'Classical',
 'Instrumental',
 'Acid',
 'House',
 'Game',
 'Sound Clip',
 'Gospel',
 'Noise',
 'AlternRock',
 'Bass',
 'Soul',
 'Punk',
 'Space',
 'Meditative',
 'Instrumental Pop',
 'Instrumental Rock',
 'Ethnic',
 'Gothic',
 'Darkwave',
 'Techno-Industrial',
 'Electronic',
 'Pop-Folk',
 'Eurodance',
 'Dream',
 'Southern Rock',
 'Comedy',
 'Cult',
 'Gangsta',
 'Top 40',
 'Christian Rap',
 'Pop/Funk',
 'Jungle',
 'Native American',
 'Cabaret',
 'New Wave',
 'Psychadelic',
 'Rave',
 'Showtunes',
 'Trailer',
 'Lo-Fi',
 'Tribal',
 'Acid Punk',
 'Acid Jazz',
 'Polka',
 'Retro',
 'Musical',
 'Rock & Roll',
 'Hard Rock',
 'Folk',
 'Folk-Rock',
 'National Folk',
 'Swing',
 'Fast Fusion',
 'Bebob',
 'Latin',
 'Revival',
 'Celtic',
 'Bluegrass',
 'Avantgarde',
 'Gothic Rock',
 'Progressive Rock',
 'Psychedelic Rock',
 'Symphonic Rock',
 'Slow Rock',
 'Big Band',
 'Chorus',
 'Easy Listening',
 'Acoustic',
 'Humour',
 'Speech',
 'Chanson',
 'Opera',
 'Chamber Music',
 'Sonata',
 'Symphony',
 'Booty Bass',
 'Primus',
 'Porn Groove',
 'Satire',
 'Slow Jam',
 'Club',
 'Tango',
 'Samba',
 'Folklore',
 'Ballad',
 'Power Ballad',
 'Rhythmic Soul',
 'Freestyle',
 'Duet',
 'Punk Rock',
 'Drum Solo',
 'A capella',
 'Euro-House',
 'Dance Hall',
  'Goa',
                'Drum & Bass',
                'Club-House',
                'Hardcore',
                'Terror',
                'Indie',
                'BritPop',
                'Negerpunk',
                'Polsk Punk',
                'Beat',
                'Christian Gangsta Rap',
                'Heavy Metal',
                'Black Metal',
                'Crossover',
                'Contemporary Christian',
                'Christian Rock',
                'Merengue',
                'Salsa',
                'Thrash Metal',
                'Anime',
                'JPop',
                'Synthpop'

  );

  vbr_methods : Array[0..3] of string = (
  'abr',
  'vbr_old/vbr_rh',
  'vbr_mrth',
  'vbr_mt'
  );

function SyncSafeIntToNormal(buffer: array of byte): Cardinal;
var re, b1, b2, b3, b4: Cardinal;
begin
//memcpy(&re, buffer, 4);  ez nem jo endian miatt */
	re := (buffer[0] shl 24) or (buffer[1] shl 16) or (buffer[2] shl 8) or (buffer[3] shl 0);

	//most meg at kell konvertalni.*/
	b1 := (re and $FF000000) shr 3;
	b2 := (re and $00FF0000) shr 2;
	b3 := (re and $0000FF00) shr 1;
	b4 := (re and $000000FF) shr 0;

	Result:= b1 or b2 or b3 or b4;

end;


(* returns:
 *  0: header does not violate any rules
 * -1: header violates the rules
 * >0: need to seek
 *
 * dest_info : if not null, text info about the lame info
 *)
function Lame_Check(var buffer: array of Byte; offset: Integer; var dest_info: string): Integer;
var lame_version: string;
	  vbr_method, lame_minor_version: Cardinal;
    id3v2_size: Integer;
begin
  Result:= -1;
  
	if((buffer[offset+0] = $49)and(buffer[offset+1] = $44) and (buffer[offset+2] = $33)) then
	begin
		id3v2_size := SyncSafeIntToNormal(buffer[offset+6]);

		if (buffer[offset+5] and 16 <> 0) then // if footer is present */
			inc(id3v2_size, 20)
		else
			inc(id3v2_size, 10);

		// lehet nem kell syncelni ha*/
		if (id3v2_size + 400 < LAME_BUFFER_SIZE) then
    begin
			Result:= Lame_Check(buffer, id3v2_size, dest_info);
      exit;
    end;


		Result:= id3v2_size;
    exit;
	end;


	if ( (buffer[offset+0] = $ff) and ((buffer[offset+1] = $fb ) or (buffer[offset+1] = $fa)) ) then
	begin
		//Mpeg1 Layer III header detected */
		if('Xing' <> MyCopy(buffer, offset+$24, 4)) then
    begin
		  dest_info:= 'LAME: No Xing header found';
      exit;
		end;

		// checking LAME header
//    SetLength(lame_version, 15); 
		lame_version:= MyCopy(buffer, offset+$9c, 9);
		lame_minor_version := (buffer[offset+$A5] and $F0) shr 4;
		lame_version[9]:= '.';
    lame_version:= lame_version + Chr(lame_minor_version + 48);


		vbr_method := (buffer[offset+$A5] and $0F);
		if ((vbr_method < 2) or (vbr_method > 5)) then
		begin
		  dest_info:= 'LAME: Broken vbr_method in header';
      exit;
		end;


		if(lame_version = 'LAME3.97.0') then
    begin
			// vbr quality jon */

      dest_info:= Format('%s %s %u %u %u %u %u %u',
        [lame_version, vbr_methods[vbr_method - 2],
        buffer[offset+$9b], buffer[offset+$A6], ((buffer[offset+$AF] and $F0) shr 4), (buffer[offset+$AF] and $0F), buffer[offset+$B0],  buffer[offset+$B4]]);

			Result:= 0;
      exit;
		end
		else
		if (lame_version = 'LAME3.90.0') then
    begin

			if ((buffer[offset+$b6] = 3) and (buffer[offset+$b7] = 233)) then
			begin
         dest_info:= lame_version+' '+vbr_methods[vbr_method - 2]+' APS';
			   Result:= 0;
         exit;
			end;
    end;

     dest_info:= lame_version+' '+ vbr_methods[vbr_method - 2];

		Result:= 0;
    exit;

	end;


	dest_info:= 'LAME: No MPEG1 Layer III header detected';
	Result:= -1;
end;



(* returns:
 *  0: header does not violate any rules
 * -1: header violates the rules
 *
 * dest_info : if not null, text info about the lame info
 *)
function ID3_Check(var buffer: array of Byte; var dest_info: string): Integer;
var genre: string;
begin
	//TAG*/
  genre:= 'no genre';
	if((buffer[0] = $54)and(buffer[1] = $41)and(buffer[2] = $47)) then
	begin
    //(buffer[127] >= 0) and
		if ( (buffer[127] <= 147)) then
			genre := genres[buffer[127]];

		//ir3v1.1 detected*/
		if ((buffer[125] <> 0) or (buffer[126] = 0)) then
			dest_info:= 'ID3v1.0 '+ genre
		else
      dest_info:= 'ID3v1.1 '+ genre;

		Result:= 0;
    exit;

	end;

	dest_info:= 'ID3: No ID3v1 detected';
	Result:= -1;
end;

function MP3Info(filename: string): string;
var i: Integer;
    buf1: array[0..LAME_BUFFER_SIZE-1] of Byte;
    buf2: array[0..ID3_BUFFER_SIZE-1] of Byte;
    s: Integer;
    re1, re2: string;
    fd: TFileStream;
begin
  try
    fd:= TFileStream.Create(filename, fmOpenRead);
    try
  	 while(true) do
     begin
       s:= fd.Read(buf1, LAME_BUFFER_SIZE);
		   if (s < LAME_BUFFER_SIZE) then
		   begin
			   Result:= 'ERROR: IO error';
			   exit;
		   end;

       i := Lame_Check(buf1, 0, re1);
		   if (i > 0) then
			   fd.Seek(i, soFromBeginning)
		   else
			   break;
		 end;

     fd.Seek(-ID3_BUFFER_SIZE, soFromEnd);
     s:= fd.Read(buf2, ID3_BUFFER_SIZE);
 		 if (128 = s) then
  	 begin
	     ID3_Check(buf2, re2);
       Result:= re1+' / '+re2;
     end else
       Result:= 'ERROR: IO error';
       
    finally
      fd.Free;
    end;
	except
		Result:= 'ERROR: Couldnt open '+ filename;
  end;
end;


end.

unit myblowfish;

interface

uses SysUtils, Classes, Blowfish, md5, ZLib;

procedure EncryptStreamToStream(input, ostream: TStream; Key: array of byte; compressstream: Boolean = False);
procedure EncryptStreamToFile(input: TStream; output: string; Key: array of byte; compressstream: Boolean = False);
procedure EncryptFileToFile(input: string; output: string; Key: array of byte; compressstream: Boolean = False);
procedure DecryptStreamToStream(istream, output: TStream; Key: array of byte; decompressstream: Boolean = False);
procedure DecryptFileToStream(input: string; output: TStream; Key: array of byte; decompressstream: Boolean = False);
procedure DecryptFileToFile(input: string; output: string; Key: array of byte; decompressstream: Boolean = False);

implementation

const
  IV: array[0..7] of byte= ($11, $22, $33, $44, $55, $66, $77, $88);
  BUFSIZE = 16384; // ez 8 tobbszorose kell hogy legyen

procedure EncryptStreamToStream(input, ostream: TStream; Key: array of byte; compressstream: Boolean = False);
var read, aktread: Integer;
    buf: array[1..BUFSIZE] of char;
    istream: TMemoryStream;
    zl: TCompressionStream;
    KeyData: TBlowfishData;
    i, iteraciok: Integer;
    size: Int64;
begin
  BlowfishInit(KeyData,@Key,Length(Key),@IV);

  input.Position:= 0;
  istream:= TMemoryStream.Create;
  if compressstream then
  begin
    zl:= TCompressionStream.Create(clFastest, istream);
    zl.CopyFrom(input, input.Size);
    zl.Free;
  end
  else
    istream.CopyFrom(input, input.Size);

  try
    // eltaroljuk a meretet eloszor
    size:= istream.Size;
    BlowfishEncryptCBC(KeyData,@size,@buf);
    ostream.Write(buf, 8);

    istream.Position:= 0;
    read:= 0;
    while read < istream.Size do
    begin
      aktread:= istream.Read(buf, BUFSIZE);
      iteraciok:= (aktread div 8);
      if aktread mod 8 <> 0 then
      begin
        for i:= aktread mod 8+1 to 8 do
          buf[iteraciok*8+i]:= #0;
        inc(iteraciok);
      end;
      for i:= 1 to iteraciok do
        BlowfishEncryptCBC(KeyData,@buf[(i-1)*8+1],@buf[(i-1)*8+1]);
      ostream.Write(buf, iteraciok*8);

      inc(read, aktread);
    end;
  finally
    istream.Free;

    BlowfishBurn(KeyData);

  end;
end;

procedure EncryptStreamToFile(input: TStream; output: string; Key: array of byte; compressstream: Boolean = False);
var
    ostream: TFileStream;
begin
  ostream:= TFileStream.Create(output, fmCreate or fmOpenWrite);
  try
    EncryptStreamToStream(input, ostream, Key, compressstream);
  finally
    ostream.Free;
  end;
end;
procedure EncryptFileToFile(input: string; output: string; Key: array of byte; compressstream: Boolean = False);
var x: TFileStream;
begin
  if input = output then
  begin
    RenameFile(input,input+'.tmp');
    input:= input+'.tmp';
  end;

  x:= TFileStream.Create(input, fmOpenRead);
  try
    EncryptStreamToFile(x, output, Key, compressstream);
  finally
    x.Free;
  end;
end;
procedure DecryptStreamToStream(istream, output: TStream; Key: array of byte; decompressstream: Boolean = False);
var read, aktread: Integer;
    buf: array[1..BUFSIZE] of char;
    ostream: TMemoryStream;
    zl: TDecompressionStream;
    KeyData: TBlowfishData;
    i, iteraciok: Integer;
    size: Int64;
begin
  BlowfishInit(KeyData,@Key,Length(Key),@IV);

  ostream:= TMemoryStream.Create;

  try
    // kiolvassuk a meretet eloszor
    // eltaroljuk a meretet eloszor
    istream.Read(size, 8);
    BlowfishDecryptCBC(KeyData,@size,@size);

    read:= 8;
    while read < istream.Size do
    begin
      aktread:= istream.Read(buf, BUFSIZE);
      iteraciok:= (aktread div 8);
      if aktread mod 8 <> 0 then inc(iteraciok);
      for i:= 1 to iteraciok do
        BlowfishDecryptCBC(KeyData,@buf[(i-1)*8+1],@buf[(i-1)*8+1]);
      inc(read, aktread);

      if read - 8 > size then
        ostream.Write(buf, ((aktread-1) div 8)*8+(size mod 8))
      else
        ostream.Write(buf, aktread);

    end;

    ostream.Position:= 0;
    if decompressstream then
    begin
      zl:= TDecompressionStream.Create(ostream);
      aktread:= 1;
      while aktread <> 0 do
      begin
       aktread:= zl.Read(buf, BUFSIZE);
       if aktread > 0 then
         output.Write(buf, aktread);
      end;
      zl.Free;
    end
    else
      output.CopyFrom(ostream, ostream.Size);

    output.Position:= 0;
  finally
    ostream.Free;
  end;
end;
procedure DecryptFileToStream(input: string; output: TStream; Key: array of byte; decompressstream: Boolean = False);
var istream: TFileStream;
begin
  istream:= TFileStream.Create(input, fmOpenRead);
  try
    DecryptStreamToStream(istream, output, Key, decompressstream);
  finally
    istream.Free;
  end;
end;
procedure DecryptFileToFile(input: string; output: string; Key: array of byte; decompressstream: Boolean = False);
var x: TFileStream;
begin
  if input = output then
  begin
    RenameFile(input,input+'.tmp');
    input:= input+'.tmp';
  end;

  x:= TFileStream.Create(output, fmCreate or fmOpenWrite);
  try
    DecryptFileToStream(input, x, Key, decompressstream);
  finally
    x.Free;
  end;
end;



end.

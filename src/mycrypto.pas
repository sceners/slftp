unit mycrypto;

interface

uses Classes, md5;

function OpensslVersion: string;
function OpensslShortVersion: string;
function GenPem(certpath: string; keylen: Integer; commonname: string): Boolean;
procedure MycryptoStart(pp: TMD5Digest);
procedure MycryptoStop;
function DecryptUDP(AData: TStream): string;
function EncryptUDP(s: string): string;

implementation

uses SysUtils, Blowfish, IdSSLOpenSSL, IdSSLOpenSSLHeaders, helper, configunit, debugunit,
  Math, mystrings;

const section = 'crypto';
      UDP_MIN_PADDING = 8;
      UDP_MAX_PADDING = 32;
      MAX_UDP_PACKET = 16384;

var KeyData: TBlowfishData;

function OpensslVersion: string;
begin
  Result:= Format('%s %s %s %s',[
    IdSSLeayversion(OPENSSL_SSLEAY_VERSION),
    IdSSLeayversion(OPENSSL_SSLEAY_CFLAGS),
    IdSSLeayversion(OPENSSL_SSLEAY_BUILT_ON),
    IdSSLeayversion(OPENSSL_SSLEAY_PLATFORM)]);
end;
function OpensslShortVersion: string;
begin
  Result:= Copy(IdSSLeayversion(OPENSSL_SSLEAY_VERSION), 9, 6);
end;

function GenPem(certpath: string; keylen: Integer; commonname: string): Boolean;
var b, r, xn, x, xr, xne, evp: Pointer;
begin
  Result:= False;

  b:= IdBIOnewfile(PChar(certpath), 'w');
  if( b = nil) then exit;

  r:= IdRSAgeneratekey(keylen, 65537, nil, nil);
  if( r = nil) then
  begin
    IdBIOfree(b);
    exit;
  end;

  xr := IdX509REQnew();
  if( xr = nil) then
  begin
    IdRSAfree(r);
    IdBIOfree(b);
    exit;
  end;

  xn := IdX509NAMEnew();
  if(xn = nil) then
  begin
    IdBIOfree(b);
    IdRSAfree(r);
    IdX509REQfree(xr);
    exit;
  end;

  xne := IdX509NAMEENTRYcreatebytxt(nil, 'CN', OPENSSL_V_ASN1_APP_CHOOSE, PChar(commonname), Length(commonname));
  if (xne = nil) then
  begin
    IdBIOfree(b);
    IdRSAfree(r);
    IdX509REQfree(xr);
    IdX509NAMEfree(xn);
    exit;
  end;

  IdX509NAMEaddentry(xn, xne, 0, 0);
  IdX509REQsetsubjectname(xr, xn);

  evp := IdEVPPKEYnew();
  if(evp = nil) then
  begin
    IdBIOfree(b);
    IdRSAfree(r);
    IdX509REQfree(xr);
    IdX509NAMEfree(xn);
    exit;
  end;


  if (0 = IdEVPPKEYset1RSA(evp,r)) then
  begin
      IdBIOfree(b);
      IdRSAfree(r);
      IdX509REQfree(xr);
      IdX509NAMEfree(xn);
      IdEVPPKEYfree(evp);

      exit;
  end;

  if (0 = IdX509REQsetpubkey(xr, evp)) then
  begin
      IdBIOfree(b);
      IdRSAfree(r);
      IdX509REQfree(xr);
      IdX509NAMEfree(xn);
      IdEVPPKEYfree(evp);
      exit;
  end;

  if (0 = IdX509REQsign(xr, evp, IdEVPsha256())) then
  begin
    IdX509REQfree(xr);
    IdX509NAMEfree(xn);
    IdBIOfree(b);
    IdRSAfree(r);
    IdEVPPKEYfree(evp);
    exit;
  end;

  // na mar nincs sok hatra
  x := IdX509REQtoX509(xr, 3000, evp);
  if (x = nil) then
  begin
    IdBIOfree(b);
    IdRSAfree(r);
    IdX509REQfree(xr);
    IdX509NAMEfree(xn);
    IdEVPPKEYfree(evp);
    exit;
  end;

  
  IdPEMwritebioRSAPrivateKey(b, r, nil, nil, 0, nil, nil);
  IdPEMwritebioX509(b, x);



  IdX509free(x);
  IdX509REQfree(xr);
  IdX509NAMEfree(xn);
  IdBIOfree(b);
  IdRSAfree(r);
  IdEVPPKEYfree(evp);

  Result:= True;
end;

procedure MycryptoStart(pp: TMD5Digest);
const IV: array[0..7] of Byte = (0,0,0,0,0,0,0,0);
var cert: string;
begin
  cert:= config.ReadString(section, 'certificate', 'slftp.pem');
  if not FileExists(cert) then
  begin
    Debug(dpError, section, 'Certificate not found, generating new one');
    GenPem(cert, config.ReadInteger(section, 'keylen', 2048), MyGetusername());
  end;


  BlowfishInit(KeyData, @pp.v, SizeOf(pp.v), @iv);
end;

procedure MycryptoStop;
begin
//nothing to do here
  BlowfishBurn(KeyData);
end;


function DecryptUDP(AData: TStream): string;
var p: Byte;
    block: array[0..MAX_UDP_PACKET-1] of Byte;
    l: Integer;
begin
  Result:= '';

  l:= AData.Size;
  if l > MAX_UDP_PACKET then exit;
  AData.Read(block, l);

  BlowfishReset(KeyData);
  BlowfishDecryptCFB(KeyData, @block, @block, l);
  p:= block[0];
  if (p >= UDP_MIN_PADDING) and (p <= UDP_MAX_PADDING) then
    Result:= Mycopy(block, p, l-p-1);
end;

function EncryptUDP(s: string): string;
var p: Byte;
    block: array[0..MAX_UDP_PACKET-1] of Char;
begin
  Result:= '';

  if Length(s) + UDP_MAX_PADDING > MAX_UDP_PACKET then exit;

  p:= Byte(RandomRange(UDP_MIN_PADDING, UDP_MAX_PADDING));
  block[0]:= Char(p);
  Move(s[1], block[p], length(s));

  BlowfishReset(KeyData);
  BlowfishEncryptCFB(KeyData, @block, @block, p+1+length(s));
  Result:= Copy(block, 1, p+1+length(s));
end;

procedure MyCryptoInit;
begin
  Randomize;
end;

initialization
  MyCryptoInit;
end.

program precatchtester;

{$APPTYPE CONSOLE}

uses
  configunit,
  sitesunit,
  precatcher,
  SysUtils;

begin
  if ReadSites(passphrase) then
  begin
    PrecatcherStart;
    PrecatcherProcess('LINKNET', '#amazing-m', 'amazd', '[10MP3] [update] -> The_Yellow_Moon_Band-Travels_Into_Several_Remote_Nations_Of_The_World-2009-DV8 [Instrumental Rock LAME3.97 V2].');
  end;
end.

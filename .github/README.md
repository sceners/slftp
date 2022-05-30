# slFtp
slFtp is an open-source, multithreaded FTP client with native Linux and Windows support, designed for the "scene".

#### Written in 2009 March.

[Original package](https://defacto2.net/f/ac2ceff)

---

Features:
- FTP client, including sitemanager, SSL/TLS support, SSLFXP 
  (turned on automaticly if needed), per site IO/connect timeouts
- XDUPE support
- "Newdir race", multi dir support
- Highly configurable skiplists
- Dynamically rebuild transfer chains based on allowed/complete status of sites
- Condition based rule sets for sites/sections with ~40 conditions, 
  including MP3 genre, year, language, number of disks, rlsname masks, etc.
- Full IRC support (with multiple networks, chans, SSL, blowfish)
- Highly configurable precatcher
- Genre support for MP3 (including IRC based and dirlist based)
- Genre support for MDVDR/MV (by fetching and parsing nfo file)
- Fake checking with many builtin rules
- Auto based on IRC/dirlisting
- Prebot functionality, including LAME/MPEG header checks, batch support,
  lame checking/spreading/pre is done by one single command
  (available on group request only)
- Affil/user lists, displaying free slots  
- Admin backends (currently IRC is implemented only)
- SOCKS5 support (with anonymous and username/password based authentication)
- Ident server support on Windows

Features coming:
- Support for limiting number of uploads based on sfv
- TVRage support
- iMDB support
- Rebuild routing table based on latest speed stats
- Scanning sections / auto request filling
- Some click frontend on Windows maybe
- (Proper) documentation, help is needed as I am lazy
- Kill all humans

Join #slftp@LiNKNET

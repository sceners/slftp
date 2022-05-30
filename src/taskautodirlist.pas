unit taskautodirlist;

interface

uses tasksunit;

type TAutoDirlistTask = class(TTask)
     private
     public
       constructor Create(site: string);
       function Execute(slot: Pointer): Boolean; override;
       function Name: string; override;
     end;

implementation

uses configunit, sitesunit, kb, queueunit, mystrings, dateutils, dirlist, SysUtils, irc, debugunit;

const section = 'autodirlist';

{ TAutoSectionTask }

constructor TAutoDirlistTask.Create(site: string);
begin
  inherited Create(site, tAutoDirlist);
end;


function TAutoDirlistTask.Execute(slot: Pointer): Boolean;
label ujra;
var s: TSiteSlot;
    i, j: Integer;
    l: TAutoDirlistTask;
    ss, section, sectiondir: string;
    dl: TDirList;
    de: TDirListEntry;

  procedure UjraAddolas;
  begin
    // megnezzuk, kell e meg a taszk
    i:= s.RCInteger('autodirlist', 0);
    if i > 0 then
    begin
      queue_lock.Enter;
      l:= TAutoDirlistTask.Create(site1);
      l.startat:= IncSecond(Now, i);
      l.dontremove:= True;
      AddTask(l);
      queue_lock.Leave;
    end;
  end;

begin
  Result:= False;
  s:= slot;
  debugunit.Debug(dpMessage, section, Name);

    // megnezzuk, kell e meg a taszk
    if s.RCInteger('autodirlist', 0) = 0 then
    begin
      ready:= True;
      Result:= True;
      exit;
    end;

ujra:
  if s.status <> ssOnline then
    if not s.ReLogin then
    begin
      ujraaddolas();
      readyerror:= True;
      exit;
    end;


    // implement the task itself
    ss:= s.RCString('autodirlistsections', '');
    for i:= 1 to 1000 do
    begin
      section:= SubString(ss, ' ', i);
      if section = '' then break;
      sectiondir:= s.site.sectiondir[section];
      if sectiondir <> '' then
      begin
        if not s.Dirlist(sectiondir, True) then // daydir might have change
        begin
          if s.Status = ssDown then
            goto ujra;
          continue;
        end;

        // sikeres dirlist, fel kell dolgozni az elemeit
        dl:= TDirlist.Create(nil, nil, s.lastResponse);
        try
          for j:= 0 to dl.entries.Count-1 do
          begin
            de:= TDirlistEntry(dl.entries[j]);
            if ((de.Directory) and (0 = pos('nuked', de.filenamelc))) then
            begin
              if (SecondsBetween(Now(), de.timestamp) < config.readInteger(section, 'dropolder', 86400)) then
              begin
                queue_lock.Enter;
                kb_add(site1, section, '', 'NEWDIR', de.filename, '', False, False, de.timestamp);
                queue_lock.Leave;
              end;
            end;
          end;
        finally
          dl.Free;
        end;
      end;
    end;

    ujraaddolas();

  Result:= True;
  ready:= True;
end;

function TAutoDirlistTask.Name: string;
begin
  Result:= 'AUTODIRLIST '+site1+ScheduleText;
end;

end.

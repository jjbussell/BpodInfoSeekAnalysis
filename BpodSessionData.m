%% GOALS

%{
need to put data in a structure to facilitate calcs/plots of

% numTrials
% water
% numtrials of each type


% outcomes across trials per day
% % error
% licks in diff trial epochs
% % choice / pref (by side)
% leaving
% reaction time
% image time stamp

so structurce with row for each trial
fields: mouse, day, session, trial outcome,
 licks rel to trial start,image
events, port exit events/state txn

% good to preserve data in easy to understand original format and just have
script that can run reproducibly on it

load in files, record names, store date, mouse, protocol, time, ntrials as
metadata and rawevents (a.files with length of numfiles)


%}


%%

clear all;
close all;

%% LOAD DATA

loadData = 1;
% loadData = 0;

if loadData == 1
    fname = 'infoSeekBpodData.mat';
    load(fname); % opens structure "a" with previous data, if available
    for fn = 1:numel(a.files)
        names{fn} = a.files(fn).name; 
    end
end

%% LOAD NEW DATA

% select folder with new data file(s) to load
pathname=uigetdir;
files=dir([pathname,'/*.mat']);
numFiles = size(files,1);

ff = 3;

for ff = 1:numFiles

    clearvars -except a names pathname files session numFiles ff loadData;

    filename = files(ff).name;

    filepath = fullfile(pathname,filename);
    
    % need to check for duplicates!!!
    
    if loadData == 1
        if sum(strcmp(filename,names)) > 0
            disp(fprintf(['Skipping duplicate file ' filename]));
            files(ff) = [];
            ff = ff+1;
            filename = files(ff).name;
            numFiles = numFiles - 1;
        end
        f = numel(a.files) + ff;
    else
        f = ff;
    end    
    
    
    breaks = strfind(filename,'_');
    
%     b.filename(f,1) = cellstr(filename);
    mouse = cellstr(filename(1:breaks(1)-1));
%     b.protocol(f,1) = cellstr(filename(breaks(1)+1:breaks(2)-1));
    day = cellstr(filename(breaks(2)+1:breaks(3)-1));
%     day = filename(breaks(2)+1:breaks(3)-1);
%     b.startTime(f,1) = cellstr(filename(breaks(3)+1:strfind(filename,'.')-1));    
    
    % Pull raw data from matfile
    load(filepath);    
%     b.data{f,1} = SessionData;
    
%     % Break down session data into per-file variables
%     sessionVariables = {'nTrials','SettingsFile','TrialSettings','Notes',...
%         'TrialCounts','EventNames','TrialTypes','Outcomes','TrialStartTimestamp','TrialEndTimestamp','RawEvents'};
%     
%     for i = 1:numel(sessionVariables)
%         name = sessionVariables{i};
%        if isfield(SessionData,name)
%           b.(name){f,1} = SessionData.(name);
%        else
%           b.(name){f,1} = []; 
%        end
%     end
    
    % Session-level data    
    session(ff,1).name = filename;
    session(ff,1).date = filename(breaks(2)+1:breaks(3)-1);
    session(ff,1).mouse = filename(1:breaks(1)-1);
    session(ff,1).protocol = filename(breaks(1)+1:breaks(2)-1);
    session(ff,1).time =filename(breaks(3)+1:strfind(filename,'.')-1);
    session(ff,1).settings = SessionData.SettingsFile.GUI;
    session(ff,1).eventNames = SessionData.EventNames;
    session(ff,1).nTrials = SessionData.nTrials;
    

    
    % Trial-level data
    for t = 1:SessionData.nTrials
       b.file(t,1) = f; 
       b.mouse(t,1) = mouse;
       b.day(t,1) = day;
    end
    
    if numel(SessionData.TrialSettings)~=SessionData.nTrials
%         print('trial settings error ');
        filename
    end
    
    if isfield(SessionData.TrialSettings,'GUI')
       b.trialSettings = [SessionData.TrialSettings(:).GUI]';
    end
        
    b.trialSettings = [SessionData.TrialSettings(:)];
%     b.trialSettings = [settings{:}]';
    b.trialType = SessionData.TrialTypes';
    b.startTime = SessionData.TrialStartTimestamp';
    b.endTime = SessionData.TrialEndTimestamp';
    b.outcome = SessionData.Outcomes';
    trialData = [SessionData.RawEvents(:).Trial];
    b.trialData = [trialData{:}]';
    b.file2(1:numel(b.trialType),1) = f;
    
    
    % STATES
    stateList = {'InterTrialInterval',...
            'CenterOdorPreload',...
            'StartTrial',...
            'WaitForCenter',...
            'CenterDelay',...
            'CenterOdor',...
            'CenterOdorOff',...
            'CenterPostOdorDelay',...
            'GoCue',...
            'Response',...
            'GracePeriod',...
            'WaitForOdorLeft',...
            'PreloadOdorLeft',...            
            'OdorLeft',...
            'OdorALeft',...
            'OdorBLeft',...
            'OdorCLeft',...
            'OdorDLeft',...
            'LeftOdorOff',...
            'RewardDelayLeft',...
            'DoorOpenCueLeft',...
            'DoorOpenGraceLeft',...
            'LeftPortCheck',...
            'LeftBigReward',...
            'LeftSmallReward',...
            'LeftNotPresent',...
            'WaitForOdorRight',...
            'PreloadOdorRight',...
            'OdorRight',...
            'OdorARight',...
            'OdorBRight',...
            'OdorCRight',...
            'OdorDRight',...
            'RightOdorOff',...
            'RewardDelayRight',...
            'DoorOpenCueRight',...
            'DoorOpenGraceRight',...
            'RightPortCheck',...
            'RightBigReward',...
            'RightSmallReward',...  
            'RightNotPresent',...
            'OutcomeDelivery',...
            'NoChoice',...
            'Incorrect',...
            'TimeoutOdor',...
            'TimeoutRewardDelay',...
            'TimeoutOutcome',...
            'TimeoutGraceLeft',...
            'TimeoutGraceRight',...
            'LeavingTimeout',...
            'EndTrial'};
        b.stateList = stateList;
    
    % make sure saving all event names, change events to break out to
    % select list, then expand those
    % when expanding states, delete unexpanded
%     b.eventList = session(ff).eventNames;
    eventList = {'GlobalTimer3_Start','GlobalTimer4_Start','GlobalTimer3_End',...
        'GlobalTimer4_End','Port1In','Port1Out','Port2In','Port2Out','Port3In','Port3Out'};
    for t = 1:SessionData.nTrials
        for s = 1:numel(stateList)
            if isfield(b.trialData(t).States,(stateList{s}))
                b.(stateList{s}){t,1} = b.trialData(t).States.(stateList{s});
            else
                b.(stateList{s}){t,1} = [];
            end
        end

        for e = 1:numel(eventList)
            if isfield(b.trialData(t).Events,(eventList{e}))
                b.(eventList{e}){t,1} = b.trialData(t).Events.(eventList{e});
            else
               b.(eventList{e}){t,1} = [];
            end
        end
    end
    
    
    % Add this file's data to struct 'a'
    if exist('a','var') == 0
        a = b;
        
    else
        if isfield(a,'file2') == 0
            a.file2 = b.file2;
        else
            a.file2 = [a.file2; b.file2];
        end
       a.file = [a.file; b.file];
       a.mouse = [a.mouse; b.mouse];
       a.day = [a.day; b.day];
       
%        if or(sum(ismember(fields(a.trialSettings),fields(b.trialSettings))==0)>0,sum(ismember(fields(b.trialSettings),fields(a.trialSettings))==0)>0)
           if sum(ismember(fields(a.trialSettings),fields(b.trialSettings))==0)>0 % if current file is missing a field in other files
               afields=fields(a.trialSettings);
               fieldnames = afields(ismember(fields(a.trialSettings),fields(b.trialSettings))==0);
               for i = 1:numel(fieldnames)
                   for n = 1:size(b.trialSettings,1)
                    b.trialSettings(n).(fieldnames{i})=[];
                   end
               end
           end
           if sum(ismember(fields(b.trialSettings),fields(a.trialSettings))==0)>0
               bfields=fields(b.trialSettings);
               fieldnames = bfields(ismember(fields(b.trialSettings),fields(a.trialSettings))==0);    
               for i = 1:numel(fieldnames)
                   for n = 1:size(a.trialSettings,1)
                    a.trialSettings(n).(fieldnames{i})=[];
                   end
               end             
           end
%        end
       a.trialSettings = [a.trialSettings; b.trialSettings];
       
       a.trialType = [a.trialType; b.trialType];
       a.startTime = [a.startTime; b.startTime];
       a.endTime = [a.endTime; b.endTime];
       a.outcome = [a.outcome; b.outcome];
       a.trialData = [a.trialData; b.trialData];
%        if isrow(b.eventList)
%            b.eventList = b.eventList'
%        end
%        a.eventList = unique([a.eventList; b.eventList]);
       for s = 1:numel(stateList)
           if isfield(b,(stateList{s}))
               if isfield(a,(stateList{s}))
                    a.(stateList{s}) = [a.(stateList{s}); b.(stateList{s})];
               else
                   a.(stateList{s}) = b.(stateList{s});
               end
           end
       end
%        allEvents = unique([[session(:).eventNames] eventList]);
       a.eventList = unique([session(:).eventNames]);
       for e = 1:numel(a.eventList)
           event = a.eventList{e};
           if isfield(b,(event))
               if isfield(a,(event))
                    a.(event) = [a.(event); b.(event)];
               else
                   a.(event) = b.(event);
               end
           end
       end       
    end 
    
end % end for each file

if exist('a','var') == 0
    a.files = session;
elseif exist('a','var') == 1 & isfield(a,'files') == 0
   a.files = session;
else       
    a.files = [a.files; session];
end


% save('infoSeekBpodData.mat','a');
% % uisave({'a'},'infoSeekFSMData.mat');
% 
% save(['infoSeekFSMBpodData' datestr(now,'yyyymmdd')],'a');


%%

% change this to be a hardcoded list of fields to go forward with (from
% protocol)

% try if file has field

% if so, add SessionData.Field for that file to a.field (do this within
% file loop

% then, unpack per-trial data

% fields = fieldnames(a.data);
% for i = 1:length(fieldnames(a.data))
%     a.(fields{i}) = [a.data(:).(fields{i})]';    
% end

% a.trialCt = [a.data(:).nTrials];

save('infoSeekBpodData.mat','a','-v7.3');
% uisave({'a'},'infoSeekFSMData.mat');

save(['infoSeekBpodData' datestr(now,'yyyymmdd')],'a','-v7.3');



    
    
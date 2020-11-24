%% CLEAR

clear all;
close all;

%% LOAD FILE

clear;
[filename,pathname]=uigetfile('*.*', 'Pick file to load');
fname=fullfile(pathname,filename);
load(fname);

%% SESSION SUMMARY

sessionSummary = {};
sessionSummary{1} = filename;
breaks = strfind(filename,'_');
sessionSummary{2} = filename(breaks(2)+1:breaks(3)-1);

%% SETTINGS
% settings=SessionData.SettingsFile.GUI;
settings = SessionData.TrialSettings(end);
settingsnames = fields(settings);
settingsct = numel(fields(settings));

for i = 1:settingsct
   sessionSummary{end+1} = settings.(settingsnames{i});
end


%% TRIAL COUNT

trialCt = SessionData.nTrials;
sessionSummary{end+1} = SessionData.nTrials;

%% SESSION LENGTH

sessionSummary{end+1} = SessionData.TrialEndTimestamp(end)/60; % time in seconds from session start

%% OUTCOMES
outcomes = SessionData.Outcomes;
[outcomeCounts,outcomeBins] = histcounts(outcomes,[0.5:1:21.5]);

%% TRIAL DATA

trialData = [SessionData.RawEvents(:).Trial];
trialData = [trialData{:}]';

for t = 1:SessionData.nTrials
    infoSide = SessionData.TrialSettings(t).InfoSide;
    infoBigDrops(t,1) = SessionData.TrialSettings(t).InfoBigDrops;
    infoSmallDrops(t,1) = SessionData.TrialSettings(t).InfoSmallDrops;
    randBigDrops(t,1) = SessionData.TrialSettings(t).RandBigDrops;
    randSmallDrops(t,1) = SessionData.TrialSettings(t).RandSmallDrops;
    states{t} = trialData(t).States;
    events{t} = trialData(t).Events;
    centerEntries(t,1) = size(states{t}.CenterDelay,1);
end

%% TRIAL INITIATION

sessionSummary{end+1} = SessionData.nTrials/sum(centerEntries);
trialTypes = SessionData.TrialTypes;
for tt = 1:3
   centerCorr(tt) = sum(trialTypes==tt)/sum(centerEntries(trialTypes==tt));
   trialStarts(tt) = sum(trialTypes==tt);
end
for tt = 1:3
    sessionSummary{end+1} = centerCorr(tt);
end
for tt = 1:3
    sessionSummary{end+1} = trialStarts(tt);
end

%% TRIAL COUNTS, % INFO, % CORRECT

infoForced = ismember(outcomes,[11 12 13 14]);
randForced = ismember(outcomes,[17 18 19 20]);
infoChoice = ismember(outcomes,[2 3 4 5]);
randChoice = ismember(outcomes,[6 7 8 9]);

sessionSummary{end+1} = sum(infoForced);
sessionSummary{end+1} = sum(randForced);
sessionSummary{end+1} = sum(infoChoice);
sessionSummary{end+1} = sum(randChoice);

if sum(trialTypes == 1)>0
    sessionSummary{end+1} = sum(infoChoice)/(sum(infoChoice)+sum(randChoice));
else
    sessionSummary{end+1} = NaN;
end

correct = ~ismember(outcomes,[1,10,16,15,21,]); % leaving is okay
sessionSummary{end+1} = sum(correct)/trialCt;

%% REWARDS

dropSize = 4;
infoBig = ismember(outcomes,[2 11]);
infoSmall = ismember(outcomes,[4 13]);
randBig = ismember(outcomes,[6 17]);
randSmall = ismember(outcomes,[8 19]);
infoRewards = (sum(infoBig * infoBigDrops) + sum(infoSmall * infoSmallDrops))*dropSize;
randRewards = (sum(randBig * randBigDrops) + sum(randSmall * randSmallDrops))*dropSize;
totalRewards = infoRewards+randRewards;
sessionSummary{end+1} = infoRewards;
sessionSummary{end+1} = randRewards;
sessionSummary{end+1} = totalRewards;

%% PLOTS

PlotOutcomes;

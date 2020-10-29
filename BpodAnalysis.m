%%

% reversals
% stats
% LICKS!!!!


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  ANALYSIS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% EXPAND MULTIPLE STATE OCCURRANCES

% state = a.WaitForCenter;
% state = a.WaitForOdorLeft;

for s = 1:numel(a.stateList)

    statename = a.stateList{s};
    state = a.(a.stateList{s});
% multicheck = cell2mat(cellfun(@(x) size(x,1),state,'UniformOutput',false));
% if(sum(multicheck>1)>0)
%     multistates = 1
% end

    maxLength = max(cellfun(@numel,state));

    result=cellfun(@(x) [reshape(x,1,[]),NaN(1,maxLength-numel(x))],state,'UniformOutput',false);
    result2=vertcat(result{:});

%     statename='WaitForOdorLeft';
    state = [];
    a.(statename) = result2;
    result = [];
    result2 = [];
end


%% EXPAND EVENTS

% eventsToExpand = {'GlobalTimer3_Start','GlobalTimer4_Start','GlobalTimer3_End','GlobalTimer4_End'};
% % eventList = a.eventList;
% eventList = eventsToExpand;
eventList = {'GlobalTimer3_Start','GlobalTimer4_Start','GlobalTimer3_End',...
    'GlobalTimer4_End','Port1In','Port1Out','Port2In','Port2Out','Port3In','Port3Out'};

for e = 1:numel(eventList)

    eventname = eventList{e};
    event = a.(eventList{e});

    maxLength = max(cellfun(@numel,event));

    result=cellfun(@(x) [reshape(x,1,[]),NaN(1,maxLength-numel(x))],event,'UniformOutput',false);
    result2=vertcat(result{:});

%     statename='WaitForOdorLeft';
    event = [];
    a.(eventname) = result2;
    result = [];
    result2 = [];
end


%% INFOSIDE

a.infoSide = [a.trialSettings.InfoSide]';
a.trialTypes = [a.trialSettings.TrialTypes]';

%% TRIAL COUNT

a.trialCt = numel(a.trialType);

%% DAY AND MOUSE

a.day2 = reshape([a.day{:}],[8],[])';
datevec=[a.files(:).date];
a.fileDayCell=cellstr(reshape(datevec,[8],[])');
days=unique(a.fileDayCell);
mousevec=[a.files(:).mouse];
a.fileMouseCell=cellstr(reshape(mousevec,[],[numel(a.files)])');

% find(ismember(days,a.filedays))

a.mouseList = unique(a.mouse);
a.mouseCt = numel(a.mouseList);

for m = 1:a.mouseCt
   a.mice(:,m) = strcmp(a.mouse,a.mouseList(m)) == 1;
   mouseFileIdx = strcmp(a.fileMouseCell,a.mouseList{m});
   a.mouseDays{m} = unique(a.fileDayCell(mouseFileIdx)); % sorts
   a.mouseDayCt(m) = size(a.mouseDays{m},1);
   mouseFirstDay = find(strcmp(a.mouse,a.mouseList{m})& strcmp(a.day,a.mouseDays{m}(1)),1);
   a.initinfoside(m) = a.infoSide(mouseFirstDay);
end

for f = 1:numel(a.files)
   a.fileMouse(f,1) = find(strcmp(cellstr(a.files(f).mouse),a.mouseList));
   a.fileDay(f,1) = find(strcmp(cellstr(a.files(f).date),a.mouseDays{a.fileMouse(f)}));
   a.fileTrialTypes(f,1) = a.files(f).settings.TrialTypes;
end

for t = 1:a.trialCt
   a.mouseDay(t,1) = a.fileDay(a.file(t)); 
end

for m = 1:a.mouseCt
    a.mouseTrialTypes{m,1} = a.fileTrialTypes(a.fileMouse == m);
end

%% INITIAL INFO SIDE

% infoSide = 0, info left

a.initinfoside_info = -ones(a.trialCt,1); % initinfoside_info all trials by info-ness. 1 if initinfoside, -1 if reversed
a.initinfoside_side = ones(a.trialCt,1); % initinfoside_side all trials

for m = 1:a.mouseCt
    ok = a.mice(:,m) == 1;
    a.initinfoside_info(a.infoSide == a.initinfoside(m) & ok == 1) = 1;
end

%% CHOICE AND CHOICE TIME

% choice is waitforodorleft,waitforodorright,incorrect,nochoice

a.choice = NaN(a.trialCt,1);

a.leftChoice = a.WaitForOdorLeft(:,1);
a.rightChoice = a.WaitForOdorRight(:,1);
a.incorrectChoice = a.Incorrect(:,1);
a.noChoice = a.NoChoice(:,1);
a.incorrect = ~isnan(a.incorrectChoice);

% CORRECT = CHOSE CORRECTLY (includes NP but not no choice or incorrect)
a.correct = ~isnan(a.leftChoice)|~isnan(a.rightChoice); % doesn't include no choice or incorrect

% time of choice
a.choice(~isnan(a.leftChoice)) = a.leftChoice(~isnan(a.leftChoice));
a.choice(~isnan(a.rightChoice)) = a.rightChoice(~isnan(a.rightChoice));
a.choice(~isnan(a.incorrectChoice)) = a.incorrectChoice(~isnan(a.incorrectChoice));
a.choice(~isnan(a.noChoice)) = a.noChoice(~isnan(a.noChoice));

%% INFO (CHOICE OF INFO) includes incorrect but not nochoice

% This is a.choiceCorr (but includes incorrect)

a.info = NaN(a.trialCt,1);
a.info((a.infoSide == 0) & ~isnan(a.leftChoice)) = 1;
a.info((a.infoSide == 0) & ~isnan(a.rightChoice)) = 0;
a.info((a.infoSide == 1) & ~isnan(a.rightChoice)) = 1;
a.info((a.infoSide == 1) & ~isnan(a.leftChoice)) = 0;
a.info((a.trialType == 2) & ~isnan(a.incorrectChoice)) = 0;
a.info((a.trialType == 3) & ~isnan(a.incorrectChoice)) = 1;

a.choice_all = a.info; % choice relative to initial info side, all trials
reverseFlag = a.initinfoside_info == -1;
a.choice_all(reverseFlag) = ~a.choice_all(reverseFlag);

%% REACTION TIME AND TRIAL LENGTH

% IN SECONDS

a.rxn = a.choice-a.GoCue(:,1);

a.trialLengthTotal = a.endTime - a.startTime;
a.trialLength = a.endTime - a.GoCue(:,1) + a.startTime;
a.trialLengthCenterEntry = a.endTime - a.CenterDelay(:,1) + a.startTime;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TRIAL CHOICE TYPES (includes NP but not no choice or incorrect)

a.choiceTypeNames = {'InfoForced','RandForced','Choice'};
a.choiceTypeCts = [sum(a.trialType == 2) sum(a.trialType == 3) sum(a.trialType == 1)];
a.infoForced = a.trialType == 2 & a.correct == 1;
a.randForced = a.trialType == 3 & a.correct == 1;
a.infoChoice = a.trialType == 1 & a.correct == 1 & a.info == 1;
a.randChoice = a.trialType == 1 & a.correct == 1 & a.info == 0;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ALL CORRECT TRIALS (INCLUDES NOT PRESENT)

infoBig = [2,3,11,12];
infoSmall = [4,5,13,14];
randBig = [6,7,17,18];
randSmall = [8,9,19,20];

a.infoBig = ismember(a.outcome,infoBig);
a.infoSmall = ismember(a.outcome,infoSmall);
a.randBig = ismember(a.outcome,randBig);
a.randSmall = ismember(a.outcome,randSmall);;

a.typeNames = {'Info Water','Info None','Rand Water','Rand None'};
a.typeSizes = [sum(a.infoBig) sum(a.infoSmall) sum(a.randBig) sum(a.randSmall)];

a.choiceCorrTrials = a.trialType == 1 & a.correct == 1;
a.forcedCorrTrials = a.trialType ~= 1 & a.correct == 1;
a.infoCorrTrials = a.info == 1 & a.correct == 1;
a.randCorrTrials = a.info == 0 & a.correct == 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ERRORS

a.centerEntryCount = sum(~isnan(a.CenterOdor),2)/2;
a.completeInitiation = a.centerEntryCount == 1;

% doesn't include NP (NP info small is not an error)
a.infoCorrCodes = [11 13 14];
a.infoIncorrCodes = [10 12 15];
a.randCorrCodes = [17 19];
a.randIncorrCodes = [16 18 20 21];
a.choiceCorrCodes = [2 4 5 6 8];
a.choiceIncorrCodes = [1 3 7 9];    

a.infoForcedCorr = ismember(a.outcome,a.infoCorrCodes);
a.infoForcedIncorr = ismember(a.outcome,a.infoIncorrCodes);
a.randForcedCorr = ismember(a.outcome,a.randCorrCodes);
a.randForcedIncorr = ismember(a.outcome,a.randIncorrCodes);
a.choiceCorr = ismember(a.outcome,a.choiceCorrCodes);
a.choiceIncorr = ismember(a.outcome,a.choiceIncorrCodes);
a.infoChoiceCorr = ismember(a.outcome,[2 4 5]);
a.randChoiceCorr = ismember(a.outcome,[6 7]);

a.choiceCorrTypeNames = {'InfoForced','RandForced','InfoChoice',...
    'RandChoice'};
a.choiceTypeCtsCorr = [sum(a.infoForcedCorr) sum(a.randForcedCorr) sum(a.infoChoiceCorr) sum(a.randChoiceCorr)];

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOT PRESENT

a.infoForcedNP = ismember(a.outcome,[12 14]);
a.randForcedNP = ismember(a.outcome,[18 20]);
a.choiceInfoNP = ismember(a.outcome,[3 5]);
a.choiceRandNP = ismember(a.outcome,[7 9]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% REWARD

dropSize = 4; % microliters per drop

a.infoBigReward = [a.trialSettings.InfoBigDrops]' * 4;
a.infoSmallReward = [a.trialSettings.InfoSmallDrops]' * 4;
a.randBigReward = [a.trialSettings.RandBigDrops]' * 4;
a.randSmallReward = [a.trialSettings.RandSmallDrops]' * 4;

a.leftDrops = a.eventsExpanded.GlobalTimer3_End - a.eventsExpanded.GlobalTimer3_Start;
a.leftRewardDrops = NaN(size(a.leftDrops));
a.leftRewardDrops(a.leftDrops>0.01) = 1;
a.leftReward = sum(a.leftRewardDrops,2)*dropSize;
a.rightDrops = a.eventsExpanded.GlobalTimer4_End - a.eventsExpanded.GlobalTimer4_Start;
a.rightRewardDrops = NaN(size(a.rightDrops));
a.rightRewardDrops(a.rightDrops>0.01) = 1;
a.rightReward = sum(a.rightRewardDrops,2)*dropSize;
a.reward = nansum([a.leftReward, a.rightReward],2);

%% OUTCOMES

a.outcomeLabels = {'ChoiceNoChoice','ChoiceInfoBig','ChoiceInfoBigNP',...
    'ChoiceInfoSmall','ChoiceInfoSmallNP','ChoiceRandBig','ChoiceRandBigNP',...
    'ChoiceRandSmall','ChoiceRandSmallNP','InfoNoChoice','InfoBig',...
    'InfoBigNP','InfoSmall','InfoSmallNP','InfoIncorrect','RandNoChoice',...
    'RandBig','RandBigNP','RandSmall','RandSmallNP',...
    'RandIncorrect'};

for m = 1:a.mouseCt
   ok = strcmp(a.mouse,a.mouseList{m});
   a.mouseOutcomes(m,:) = histcounts(a.outcome(ok),(0.5:1:21.5)); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DAY SUMMARY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for m = 1:a.mouseCt
    for d = 1:a.mouseDayCt(m)
        ok = a.mouseDay == d & a.mice(:,m) == 1 & a.correct == 1;
        okAll = a.mouseDay == d & a.mice(:,m) == 1; 
        a.daySummary.mouse{m,d} = m;
        a.daySummary.day{m,d} = d;
        a.daySummary.outcome{m,d} = a.outcome(okAll ==1);    
        a.daySummary.infoForced{m,d} = sum(a.infoForcedCorr(ok));
        a.daySummary.infoChoice{m,d} = sum(a.infoChoiceCorr(ok));
        a.daySummary.randForced{m,d} = sum(a.randForcedCorr(ok));
        a.daySummary.randChoice{m,d} = sum(a.randChoiceCorr(ok));
        a.daySummary.infoBig{m,d} = sum(a.infoBig(ok));
        a.daySummary.infoSmall{m,d} = sum(a.infoSmall(ok));
        a.daySummary.randBig{m,d} = sum(a.randBig(ok));
        a.daySummary.randSmall{m,d} = sum(a.randSmall(ok));
        
        a.daySummary.trialCt{m,d} = sum(okAll);
        a.daySummary.totalCorrectTrials{m,d} = sum(a.correct(okAll));
        a.daySummary.totalWater{m,d} = sum(a.reward(okAll));
        a.daySummary.percentInfo{m,d} = nanmean(a.infoCorrTrials(ok & a.trialType == 1 & a.correct == 1 & a.trialTypes == 5));
        a.daySummary.percentIIS{m,d} = nanmean(a.choice_all(ok & a.trialType == 1 & a.correct == 1 & a.trialTypes == 5));
                
        a.daySummary.rxnInfoForced{m,d} = nanmean(a.rxn(a.infoForcedCorr & ok));
        a.daySummary.rxnInfoChoice{m,d} = nanmean(a.rxn(a.infoChoiceCorr & ok));
        a.daySummary.rxnRandForced{m,d} = nanmean(a.rxn(a.randForcedCorr & ok));
        a.daySummary.rxnRandChoice{m,d} = nanmean(a.rxn(a.randChoiceCorr & ok));
        
        a.daySummary.trialLengthInfoForced{m,d} = nansum(a.trialLength(a.infoForcedCorr == 1 & ok == 1))/sum(~isnan(a.trialLength(a.infoForcedCorr == 1 & ok == 1)));
        a.daySummary.trialLengthInfoChoice{m,d} = nansum(a.trialLength(a.infoChoiceCorr == 1 & ok == 1))/sum(~isnan(a.trialLength(a.infoChoiceCorr == 1 & ok == 1)));
        a.daySummary.trialLengthRandForced{m,d} = nansum(a.trialLength(a.randForcedCorr == 1 & ok == 1))/sum(~isnan(a.trialLength(a.randForcedCorr == 1 & ok == 1)));
        a.daySummary.trialLengthRandChoice{m,d} = nansum(a.trialLength(a.randChoiceCorr == 1 & ok == 1))/sum(~isnan(a.trialLength(a.randChoiceCorr == 1 & ok == 1)));        
        
        a.daySummary.rewardRateInfoForced{m,d} = nansum(a.reward(a.infoForced == 1 & okAll == 1)) / (nansum(a.trialLengthCenterEntry(a.infoForced == 1 & okAll == 1))/60);
        a.daySummary.rewardRateRandForced{m,d} = nansum(a.reward(a.randForced == 1 & okAll == 1)) / (nansum(a.trialLengthCenterEntry(a.randForced == 1 & okAll == 1))/60);
        a.daySummary.rewardRateChoice{m,d} = nansum(a.reward(a.trialType == 1 & okAll == 1)) / (nansum(a.trialLengthCenterEntry(a.trialType == 1 & okAll == 1))/60);
        a.daySummary.rewardRateInfo{m,d} = nansum(a.reward(a.info == 1 & okAll == 1)) / (nansum(a.trialLengthCenterEntry(a.info == 1 & okAll == 1))/60);
        a.daySummary.rewardRateRand{m,d} = nansum(a.reward(a.info == 0 & okAll == 1)) / (nansum(a.trialLengthCenterEntry(a.info == 0 & okAll == 1))/60);        

        outcomes = a.outcome(okAll ==1);
        a.daySummary.infoCorr{m,d} = sum(ismember(outcomes,a.infoCorrCodes))/(sum(ismember(outcomes,a.infoCorrCodes))+sum(ismember(outcomes,a.infoIncorrCodes)));
        a.daySummary.infoIncorr{m,d} = sum(ismember(outcomes,a.infoIncorrCodes))/(sum(ismember(outcomes,a.infoCorrCodes))+sum(ismember(outcomes,a.infoIncorrCodes)));
        a.daySummary.randCorr{m,d} = sum(ismember(outcomes,a.randCorrCodes))/(sum(ismember(outcomes,a.randCorrCodes))+sum(ismember(outcomes,a.randIncorrCodes)));
        a.daySummary.randIncorr{m,d} = sum(ismember(outcomes,a.randIncorrCodes))/(sum(ismember(outcomes,a.randCorrCodes))+sum(ismember(outcomes,a.randIncorrCodes)));
        a.daySummary.choiceCorr{m,d} = sum(ismember(outcomes,a.choiceCorrCodes))/(sum(ismember(outcomes,a.choiceCorrCodes))+sum(ismember(outcomes,a.choiceIncorrCodes)));                
        a.daySummary.choiceIncorr{m,d} = sum(ismember(outcomes,a.choiceIncorrCodes))/(sum(ismember(outcomes,a.choiceCorrCodes))+sum(ismember(outcomes,a.choiceIncorrCodes)));        
    
    end
end

%% COMPLETE/IN PORT

for m = 1:a.mouseCt
    ok = a.mice(:,m) == 1;
    mouseOutcomes = a.outcome(ok);
%     mouseInitialOutcomes = a.outcome(a.mice(:,m)==1 & a.reverse==1);
    % info choice big
    a.incomplete(m,1) =  sum(mouseOutcomes == 3)/sum(ismember(mouseOutcomes,[2 3]));
    % info choice small
    a.incomplete(m,2) =  sum(mouseOutcomes == 5)/sum(ismember(mouseOutcomes,[4 5]));
    % rand choice big
    a.incomplete(m,3) = sum(ismember(mouseOutcomes, [7]))/sum(ismember(mouseOutcomes, [6 7]));
    % rand choice small
    a.incomplete(m,4) =  sum(mouseOutcomes == 9)/sum(ismember(mouseOutcomes,[8 9]));    
    % info big
    a.incomplete(m,5) =  sum(mouseOutcomes == 12)/sum(ismember(mouseOutcomes,[11 12]));    
    % info small
    a.incomplete(m,6) =  sum(mouseOutcomes == 14)/sum(ismember(mouseOutcomes,[13 14]));
%     a.initialIncomplete(m,1) = sum(mouseInitialOutcomes == 14)/sum(ismember(mouseInitialOutcomes,[13 14]));
    % rand big
    a.incomplete(m,7) =  sum(mouseOutcomes == 18)/sum(ismember(mouseOutcomes,[17 18]));
    % rand small
    a.incomplete(m,8) =  sum(mouseOutcomes == 20)/sum(ismember(mouseOutcomes,[19 20]));
    for d = 1:a.mouseDayCt(m)
        mouseOutcomes = a.daySummary.outcome{m,d};
        a.dayIncomplete{1,d,m} = sum(mouseOutcomes == 3)/sum(ismember(mouseOutcomes,[2 3]));
        a.dayIncomplete{2,d,m} = sum(mouseOutcomes == 5)/sum(ismember(mouseOutcomes,[4 5]));
        a.dayIncomplete{3,d,m} = sum(mouseOutcomes == 7)/sum(ismember(mouseOutcomes, [6 7]));
        a.dayIncomplete{4,d,m} = sum(mouseOutcomes == 9)/sum(ismember(mouseOutcomes,[8 9]));    
        a.dayIncomplete{5,d,m} = sum(mouseOutcomes == 12)/sum(ismember(mouseOutcomes,[11 12]));    
        a.dayIncomplete{6,d,m} = sum(mouseOutcomes == 14)/sum(ismember(mouseOutcomes,[13 14]));
        a.dayIncomplete{7,d,m} = sum(mouseOutcomes == 18)/sum(ismember(mouseOutcomes,[17 18]));
        a.dayIncomplete{8,d,m} = sum(mouseOutcomes == 20)/sum(ismember(mouseOutcomes,[19 20]));
    end
end


%% PORT OCCUPANCY

win = 0.050; % bins in ms
bins = [-1:win:15];

portnames = {'Port1In','Port1Out','Port2In','Port2Out','Port3In','Port3Out'};

for p = 1:numel(portnames)
    portname = portnames{p};
    port = a.(portname);
    maxLength = max(cellfun(@numel,port));
    result=cellfun(@(x) [reshape(x,1,[]),NaN(1,maxLength-numel(x))],port,'UniformOutput',false);
    result2=vertcat(result{:});
    a.([portname,'Exp']) = result2;
    result = [];
    result2 = [];
end

% mouse may already be in a port at trial start -- condition
% mouse may be in port when trial ends
% mouse may be in port when file ends

% these all will make either the number of entries or exits not match
% OR exits come after entries in time

% if mouse in port at trial start, first in>first out-->set first in to
% trial start and slide over
% if mouse in port when trial ends, fewer outs than ins-->add out = trial
% end


portInNames = {'Port1InExp','Port2InExp','Port3InExp'};
portOutNames = {'Port1OutExp','Port2OutExp','Port3OutExp'};
portMeanNames = {'meanPort1Dwell','meanPort2Dwell','meanPort3Dwell'};
portDwellNames = {'port1Dwell','port2Dwell','port3Dwell'};
portNames = {'Port1','Port2','Port3'};
for p = 1:3
    inCounts = [];outCounts=[];moreOuts=[];moreIns=[];
    portInname = portInNames{p}; portOutname = portOutNames{p}; portMeanName = portMeanNames{p};
    portDwellName = portDwellNames{p};
    
    % if expanded array has different max events
    if size(a.(portOutname),2)~=size(a.(portInname),2)
       if  size(a.(portOutname),2)>size(a.(portInname),2)
          a.(portInname)(:,end+1) = NaN; 
       else
           a.(portOutname)(:,end+1) = NaN;
       end
    end
    a.(portInname)(:,end+1) = NaN;
    a.(portOutname)(:,end+1) = NaN;
    
    %already In
    alreadyIn = find(a.(portOutname)(:,1)-a.(portInname)(:,1)<0);
    for i = 1:numel(alreadyIn)
       a.(portInname)(alreadyIn(i),2:end) = a.(portInname)(alreadyIn(i),1:end-1);
       a.(portInname)(alreadyIn(i),1) = 0;
    end
    
    % no exit
    inCounts = sum(~isnan(a.(portInname)),2);
    outCounts = sum(~isnan(a.(portOutname)),2);
    moreIns = find((outCounts-inCounts)<0);
%     a.(portOutname)(moreOuts,1:end-1) = a.(portOutname)(moreOuts,2:end); % if more outs,
    for m = 1:numel(moreIns)
        noExit = outCounts(moreIns(m))+1; 
        a.(portOutname)(moreIns(m),noExit) = a.endTime(moreIns(m)) - a.startTime(moreIns(m));
    end    
    
    % already in but nothing to subtract
    inCounts = sum(~isnan(a.(portInname)),2);
    outCounts = sum(~isnan(a.(portOutname)),2);
    moreOuts = find((outCounts-inCounts)>0); % extra leaving because mouse was already in port at start
    for m = 1:numel(moreOuts)
        a.(portInname)(moreOuts(m),inCounts(moreOuts(m))+1) = 0;
    end
        
    noMatch = ~(a.(portOutname)>a.(portInname));
    noMatch(and(isnan(a.(portOutname)),isnan(a.(portInname))))=0;
    
    a.(portDwellName) = (a.(portOutname)(:)) - (a.(portInname)(:));
    a.(portMeanName) = mean((a.(portOutname)(:)) - (a.(portInname)(:)),'omitnan');
    
    a.(portNames{p}) = zeros(numel(a.file),numel(bins));

    % NEED TO CHANGE THESE TIMES TO BE RELATIVE TO GO CUE!
    for t = 1:numel(a.file)
       entries = a.(portInname)(t,~isnan(a.(portInname)(t,:)))-a.GoCue(t,2);
       exits = a.(portOutname)(t,~isnan(a.(portOutname)(t,:)))-a.GoCue(t,2);
       for e = 1:numel(entries)
           binIn = find(bins-entries(e)>0,1);
           binOut = find(bins-exits(e)>0,1)-1;
           a.(portNames{p})(t,(binIn:binOut))=1;
       end
    end        
end

%% PORTS BY INFO VS RANDOM

a.infoPort = zeros(size(a.Port2));
a.randPort = zeros(size(a.Port2));
infoLeft = a.infoSide == 0;
infoRight = a.infoSide == 1;

a.infoPort(infoLeft,:) = a.Port1(infoLeft,:);
a.infoPort(infoRight,:) = a.Port3(infoRight,:);
a.randPort(infoLeft,:) = a.Port3(infoLeft,:);
a.randPort(infoRight,:) = a.Port1(infoRight,:);

%%
save('infoSeekBpodDataAnalyzed.mat','a');
% uisave({'a'},'infoSeekBpodDataAnalyzed.mat');

save(['infoSeekBpodDataAnalyzed' datestr(now,'yyyymmdd')],'a');




































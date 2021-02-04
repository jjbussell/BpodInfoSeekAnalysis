%%

% LICKS!!!!
% mean pref

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
   a.initinfoside(m,1) = a.infoSide(mouseFirstDay);
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

% initside = a.initinfoside_info(a.correct==1);
% a.choice_all = a.info(a.correct==1); % choice relative to initial info side, all trials
a.choice_all = a.info; 
reverseFlag = a.initinfoside_info == -1 & a.correct==1;
a.choice_all(reverseFlag) = ~a.choice_all(reverseFlag);

a.choiceTrials = a.trialTypes==5 & a.trialType == 1;

%% REWARD PARAMS

a.infoBigDrops = [a.trialSettings.InfoBigDrops]';
a.infoSmallDrops = [a.trialSettings.InfoSmallDrops]';
a.randBigDrops = [a.trialSettings.RandBigDrops]';
a.randSmallDrops = [a.trialSettings.RandSmallDrops]';
a.infoProb = [a.trialSettings.InfoRewardProb]';
a.randProb = [a.trialSettings.RandRewardProb]';
a.rewardParams = [a.infoBigDrops a.infoSmallDrops a.randBigDrops...
    a.randSmallDrops a.infoProb a.randProb];

a.odorDelay = [a.trialSettings.OdorDelay]';
a.rewardDelay = [a.trialSettings.RewardDelay]';

%% SIDE ODOR

a.odorAtrials = (~isnan(a.leftChoice) & ~isnan(a.OdorALeft(:,1))) | (~isnan(a.rightChoice) & ~isnan(a.OdorARight(:,1)));
a.odorBtrials = (~isnan(a.leftChoice) & ~isnan(a.OdorBLeft(:,1))) | (~isnan(a.rightChoice) & ~isnan(a.OdorBRight(:,1)));
a.odorCtrials = (~isnan(a.leftChoice) & ~isnan(a.OdorCLeft(:,1))) | (~isnan(a.rightChoice) & ~isnan(a.OdorCRight(:,1)));
a.odorDtrials = (~isnan(a.leftChoice) & ~isnan(a.OdorDLeft(:,1))) | (~isnan(a.rightChoice) & ~isnan(a.OdorDRight(:,1)));

%% REVERSAL

a.reverseDay = cell(a.mouseCt,3);
a.reverse = NaN(numel(a.file),1);
a.choiceMice = zeros(a.mouseCt,1);
a.reverseMice = zeros(a.mouseCt,1);
a.reverseTypes = [1 -1 2 -2];

for m = 1:a.mouseCt
    ok = a.mice(:,m)==1 ; 
    mouseTrials = find(ok);
    mouseTrialTypes = a.trialTypes(ok);
    mouseFile = a.file(ok);
    mouseParams = a.rewardParams(ok,:);
    if sum(mouseTrialTypes == 5) > 0 % if mouse has done choices
        a.choiceMice(m,1) = 1;
%         mouseFileCt(m,1) = sum(a.fileMouse == m);
%         mouseFileTypes = a.fileTrialTypes(a.fileMouse == m);
%         mouseFilesIdx = find(a.fileMouse == m);
%         mouseFileDays = a.fileDay(a.fileMouse == m);    
%         [sortedMouseFileDays,mouseDateIdx] = sort(mouseFileDays); % day for each of that mouse's files
%         sortedMouseFiles=mouseFilesIdx(mouseDateIdx);

        mouseDays = a.mouseDay(ok);
        [sortedMouseDays, a.mouseDayIdx{1,m}] = sort(a.mouseDay(ok));
        mouseDayIdx = a.mouseDayIdx{1,m}; % idx into mouse's unsorted trials to sort by day
        mouseTrialsIdx = mouseTrials(mouseDayIdx); % idx into all trials of mouse's sorted trials
        a.mouseTrialsIdx{m} = mouseTrialsIdx;
        sortedMouseTrialTypes = mouseTrialTypes(mouseDayIdx);
        sortedMouseFile = mouseFile(mouseDayIdx);
        firstChoiceIdx = find(sortedMouseTrialTypes == 5,1,'First'); % idx into sorted -- for mouseTrialsIdx b/c it's sorted
        lastChoiceIdx = find(sortedMouseTrialTypes == 5,1,'Last');
        firstChoice = mouseDayIdx(firstChoiceIdx); % idx into unsorted mouse's trials
        firstChoiceTrial = mouseTrialsIdx(firstChoiceIdx); % in all trials, first choice trial for this mouse
        a.firstChoiceDay(1,m) = sortedMouseDays(firstChoiceIdx);
       
        mouseInfoside = a.infoSide(ok);
        sortedMouseInfoside = mouseInfoside(mouseDayIdx);
%         sortedMouseInfosideChoice = sortedMouseInfoside(firstChoiceIdx:end);
        mouseInfoSideDiff=diff(sortedMouseInfoside);
        if ~isempty(find(mouseInfoSideDiff) ~= 0)
            a.reverseMice(m,1) = 1;
            sortedMouseParams = mouseParams(mouseDayIdx,:);
            sortedMouseParams = sortedMouseParams(firstChoiceIdx:end);
            paramChange = find(diff(sortedMouseParams,1,1)~=0,1,'first');
            if ~isempty(paramChange)
                lastRevTrial = paramChange; % into sorted trials
            else
                lastRevTrial = numel(mouseTrials);
            end
            reversesIdx = find(mouseInfoSideDiff~=0); % idx of first reverse trial in trials sorted by day 
            a.reversesIdx{m} = reversesIdx;
            reverses = mouseDayIdx(reversesIdx); % idx in unsorted mouse trials
            
            for r = 1:numel(reverses)
               a.reverseDay{m,r} = sortedMouseDays(reversesIdx(r))+1; % day of reverse 
            end
            a.lastParamDay(m,1) = sortedMouseDays(lastRevTrial);
            if numel(reverses)>1
                for r = 1:numel(reverses)-1
    %                 a.reverseDay{m,r} = mouseDays(reverses(r)+1); % last day before reverse
    %                 a.reverseDay{m,r} = sortedMouseDays(reversesIdx(r))+1; % day of reverse
                    if r==1
                        a.reverse(mouseTrialsIdx(firstChoiceIdx:reversesIdx(1))) = 1;
                        a.reverse(mouseTrialsIdx(reversesIdx(1)+1:reversesIdx(2))) = -1;
                    elseif r>1 & r<numel(reverses)-2
                        a.reverse(mouseTrialsIdx(reversesIdx(r)+1:reversesIdx(r+1))) = r;
                        a.reverse(mouseTrialsIdx(reversesIdx(r+1)+1:reversesIdx(r+2))) = -r;
                    else
                        a.reverse(mouseTrialsIdx(reversesIdx(r)+1:reversesIdx(r+1))) = r;
                        a.reverse(mouseTrialsIdx(reversesIdx(r+1)+1:lastRevTrial)) = -r;
                    end
                end
            else
                a.reverse(mouseTrialsIdx(firstChoiceIdx:reversesIdx(1))) = 1;
                a.reverse(mouseTrialsIdx(reversesIdx(1)+1:lastRevTrial)) = -1;
            end
            
%             % REACTION AND LICKS REL TO CURR INFO SIDE4r
%             okMouseTrials = zeros(numel(a.file),1);
%             okMouseTrials(mouseTrialsIdx);
%             ok1 = a.mice(:,m) == 1 & a.trialType == 2 & a.correct == 1 & a.reverse == 1;
%             ok1Idx = find(ok1);
%             okInfoPreRev = find(ok1==1,300,'last');
%             ok2 = a.mice(:,m) == 1 & a.trialType == 3 & a.correct == 1 & a.reverse == 1;
%             okRandPreRev = find(ok2==1,300,'last');
%             ok3 = a.mice(:,m) == 1 & a.trialType == 2 & a.correct == 1 & a.reverse == -1;
%             okInfoPostRev = find(ok3==1,300,'last');
%             ok4 = a.mice(:,m) == 1 & & a.trialType == 3 & a.correct == 1 & a.reverse == -1;
%             okRandPostRev = find(ok4==1,300,'last');
        else
            a.reverse(mouseTrialsIdx(firstChoiceIdx:lastChoiceIdx)) = 1;
        end
    end
end

a.choiceMice = find(a.choiceMice);

%% MOUSE CATEGORIES

dayDates = datetime(unique(a.day),'InputFormat','yyyyMMdd');
toDay = string(datetime(max(dayDates),'Format','yyyyMMdd'));
thisDay = a.day == toDay;
a.today = thisDay;
a.currentMiceList = unique(a.mouse(thisDay));
a.currentMice = find(ismember(a.mouseList,a.currentMiceList));


a.choiceMiceList = a.mouseList(a.choiceMice);
a.choiceMouseCt = numel(a.choiceMice);

a.reverseMice = find(a.reverseMice);
a.reverseMiceList  = a.mouseList(a.reverseMice);

a.imagingMice = zeros(a.mouseCt,1);

%% REACTION TIME AND TRIAL LENGTH

% IN SECONDS

a.rxn = a.choice-a.GoCue(:,1);
a.rxnSpeed = 1./a.rxn;
a.goodRxn = a.rxn<8000 & a.rxn>100;

a.trialLengthTotal = a.endTime - a.startTime;
a.trialLength = a.endTime - (a.GoCue(:,1) + a.startTime);
a.trialLengthCenterEntry = a.endTime - (a.CenterDelay(:,1) + a.startTime);

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

%% LEAVING TIMEOUT

a.timeoutGrace(:,1) = sum(~isnan(a.TimeoutGraceLeft),2)/2;
a.timeoutGrace(:,2) = sum(~isnan(a.TimeoutGraceRight),2)/2;
a.timeout = ~isnan(a.LeavingTimeout(:,1));
a.timeoutTime = NaN(a.trialCt,1);
a.timeoutTime(~isnan(a.timeout)) = a.LeavingTimeout(~isnan(a.timeout),2)-a.LeavingTimeout(~isnan(a.timeout),1);
for t = 1:a.trialCt
    if ~isempty(a.trialSettings(t).Timeout)
        a.timeoutParam(t,1) = a.trialSettings(t).Timeout;
    else
        a.timeoutParam(t,1) = 0;
    end
end

%% ERRORS

a.centerEntryCount = sum(~isnan(a.CenterOdor),2)/2;
a.completeInitiation = a.centerEntryCount == 1;

% doesn't include NP (NP info small is not an error)-->NOW IT DOES!
% how to check if timeout or not?!?

a.infoCorrCodes = [11 13];
a.infoIncorrCodes = [10 12 14 15];
a.randCorrCodes = [17 19];
a.randIncorrCodes = [16 18 20 21];
a.choiceCorrCodes = [2 4 6 8];
a.choiceIncorrCodes = [1 3 5 7 9];    

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

% NOT PRESENT

a.infoForcedNP = ismember(a.outcome,[12 14]);
a.randForcedNP = ismember(a.outcome,[18 20]);
a.choiceInfoNP = ismember(a.outcome,[3 5]);
a.choiceRandNP = ismember(a.outcome,[7 9]);
a.notPresent = ismember(a.outcome,[3 5 7 9 12 14 18 20]);

% ERRORTYPES
a.errorTypes = NaN(numel(a.file),1);

a.errorTypes(ismember(a.outcome,[2,4,6,8,11,13,17,19]))= 1; % correct
a.errorTypes(ismember(a.outcome,[1,10,16]))= 2; % no choice
a.errorTypes(ismember(a.outcome,[15,21]))= 3; % incorrect
a.errorTypes(ismember(a.outcome,[3,5,7,9,12,14,18,20]))= 4; % not present
a.errorTypes(a.timeout==1)= 5; % timeout

a.errorLabels = {'Correct','No Choice','Incorrect Choice','Not Present','Leaving Timeout'};

for m = 1:a.mouseCt
    ok = a.mice(:,m) == 1;
    mouseOutcomes = a.outcome(ok);
    mouseInitialOutcomes = a.outcome(a.mice(:,m)==1 & a.reverse==1);
    % info choice big
    a.incomplete(m,1) =  sum(mouseOutcomes == 3)/sum(ismember(mouseOutcomes,[2 3]));
    % info choice small
    a.incomplete(m,2) =  sum(mouseOutcomes == 5)/sum(ismember(mouseOutcomes,[4 5]));
    % rand choice big
    a.incomplete(m,3) = sum(mouseOutcomes == 7))/sum(ismember(mouseOutcomes, [6 7]));
    % rand choice small
    a.incomplete(m,4) =  sum(mouseOutcomes == 9)/sum(ismember(mouseOutcomes,[8 9]));    
    % info big
    a.incomplete(m,5) =  sum(mouseOutcomes == 12)/sum(ismember(mouseOutcomes,[11 12]));    
    % info small
    a.incomplete(m,6) =  sum(mouseOutcomes == 14)/sum(ismember(mouseOutcomes,[13 14]));
    a.initialIncomplete(m,1) = sum(mouseInitialOutcomes == 14)/sum(ismember(mouseInitialOutcomes,[13 14]));
    % rand big
    a.incomplete(m,7) =  sum(mouseOutcomes == 18)/sum(ismember(mouseOutcomes,[17 18]));
    % rand small
    a.incomplete(m,8) =  sum(mouseOutcomes == 20)/sum(ismember(mouseOutcomes,[19 20]));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% REWARD

dropSize = 4; % microliters per drop

a.infoBigReward = [a.trialSettings.InfoBigDrops]' * 4;
a.infoSmallReward = [a.trialSettings.InfoSmallDrops]' * 4;
a.randBigReward = [a.trialSettings.RandBigDrops]' * 4;
a.randSmallReward = [a.trialSettings.RandSmallDrops]' * 4;

a.leftDrops = a.GlobalTimer3_End - a.GlobalTimer3_Start;
a.leftRewardDrops = NaN(size(a.leftDrops));
a.leftRewardDrops(a.leftDrops>0.01) = 1;
a.leftReward = nansum(a.leftRewardDrops,2)*dropSize;
a.rightDrops = a.GlobalTimer4_End - a.GlobalTimer4_Start;
a.rightRewardDrops = NaN(size(a.rightDrops));
a.rightRewardDrops(a.rightDrops>0.01) = 1;
a.rightReward = nansum(a.rightRewardDrops,2)*dropSize;
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
        a.daySummary.outcome{m,d} = a.outcome(okAll == 1);    
        a.daySummary.infoForced{m,d} = sum(a.infoForcedCorr(ok));
        a.daySummary.infoChoice{m,d} = sum(a.infoChoiceCorr(ok));
        a.daySummary.randForced{m,d} = sum(a.randForcedCorr(ok));
        a.daySummary.randChoice{m,d} = sum(a.randChoiceCorr(ok));
        a.daySummary.infoBig{m,d} = sum(a.infoBig(ok));
        a.daySummary.infoSmall{m,d} = sum(a.infoSmall(ok));
        a.daySummary.randBig{m,d} = sum(a.randBig(ok));
        a.daySummary.randSmall{m,d} = sum(a.randSmall(ok));
        
        a.daySummary.errors{m,d} = a.errorTypes(okAll == 1);
        
        a.daySummary.trialCt{m,d} = sum(okAll);
        a.daySummary.totalCorrectTrials{m,d} = sum(a.correct(okAll));
        a.daySummary.totalWater{m,d} = sum(a.reward(okAll));
        a.daySummary.percentInfo{m,d} = nanmean(a.infoCorrTrials(ok & a.trialType == 1 & a.trialTypes == 5));
        a.daySummary.percentIIS{m,d} = nanmean(a.choice_all(ok & a.trialType == 1 & a.trialTypes == 5));
                
        a.daySummary.rxnInfoForced{m,d} = nanmean(a.rxn(a.infoForcedCorr & ok));
        a.daySummary.rxnInfoChoice{m,d} = nanmean(a.rxn(a.infoChoiceCorr & ok));
        a.daySummary.rxnRandForced{m,d} = nanmean(a.rxn(a.randForcedCorr & ok));
        a.daySummary.rxnRandChoice{m,d} = nanmean(a.rxn(a.randChoiceCorr & ok));
        
        a.daySummary.rxnSpeedIdx{m,d} = (nanmean(a.rxnSpeed(ok & a.forcedCorrTrials == 1 & a.choice_all == 1)) - nanmean(a.rxnSpeed(ok & a.forcedCorrTrials == 1 & a.choice_all == 0)))/(nanmean(a.rxnSpeed(ok & a.forcedCorrTrials == 1 & a.choice_all == 1)) + nanmean(a.rxnSpeed(ok & a.forcedCorrTrials == 1 & a.choice_all == 0)));        
        
        a.daySummary.trialLengthInfoForced{m,d} = nansum(a.trialLength(a.infoForced == 1 & okAll == 1))/sum(~isnan(a.trialLength(a.infoForced == 1 & okAll == 1)));
        a.daySummary.trialLengthInfoChoice{m,d} = nansum(a.trialLength(a.infoChoice == 1 & okAll == 1))/sum(~isnan(a.trialLength(a.infoChoice == 1 & okAll == 1)));
        a.daySummary.trialLengthRandForced{m,d} = nansum(a.trialLength(a.randForced == 1 & okAll == 1))/sum(~isnan(a.trialLength(a.randForced == 1 & okAll == 1)));
        a.daySummary.trialLengthRandChoice{m,d} = nansum(a.trialLength(a.randChoice == 1 & okAll == 1))/sum(~isnan(a.trialLength(a.randChoice == 1 & okAll == 1)));        
        
        a.daySummary.maxDelay{m,d} = max(a.odorDelay(ok))+max(a.rewardDelay(ok));
        
        a.daySummary.maxTimeout{m,d} = max(a.timeoutParam(ok));
        a.daySummary.timeoutCount{m,d} = sum(a.timeout(ok));
        a.daySummary.timeout{m,d} = a.daySummary.timeoutCount{m,d}/a.daySummary.totalCorrectTrials{m,d}; % of all trials
        a.daySummary.timeoutTime{m,d} = nansum(a.timeoutTime(ok)); %seconds
        
        a.daySummary.ARewards{m,d} = nansum(a.reward(a.odorAtrials==1 & ok==1))/nansum(a.odorAtrials & ok);
        a.daySummary.BRewards{m,d} = nansum(a.reward(a.odorBtrials==1 & ok==1))/nansum(a.odorBtrials & ok);
        a.daySummary.CRewards{m,d} = nansum(a.reward(a.odorCtrials==1 & ok==1))/nansum(a.odorCtrials & ok);
        a.daySummary.DRewards{m,d} = nansum(a.reward(a.odorDtrials==1 & ok==1))/nansum(a.odorDtrials & ok);
        a.daySummary.randBigRewards{m,d} = nansum(a.reward(a.randBig==1 & ok==1))/nansum(a.randBig & ok);
        a.daySummary.randSmallRewards{m,d} = nansum(a.reward(a.randSmall==1 & ok==1))/nansum(a.randSmall & ok);
        
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

        
        a.daySummary.infoBigNP{m,d} = sum(ismember(outcomes,[3 12]))/sum(ismember(outcomes,[2 3 11 12]));
        a.daySummary.infoSmallNP{m,d} = sum(ismember(outcomes,[5 14]))/sum(ismember(outcomes,[4 5 13 14]));
        a.daySummary.randBigNP{m,d} = sum(ismember(outcomes,[7 18]))/sum(ismember(outcomes,[6 7 17 18]));
        a.daySummary.randSmallNP{m,d} = sum(ismember(outcomes,[9 20]))/sum(ismember(outcomes,[8 9 19 20]));
        a.daySummary.leavingIDX{m,d} = sum(ismember(outcomes,[5 14]))/sum(ismember(outcomes,[5 14 9 20]));
    end
end



%% PORT OCCUPANCY

win = 0.050; % bins in ms
bins = [-1:win:15];
a.bins=bins;
a.win = win;

% portnames = {'Port1In','Port1Out','Port2In','Port2Out','Port3In','Port3Out'};
% 
% for p = 1:numel(portnames)
%     portname = portnames{p};
%     port = a.(portname);
%     maxLength = max(cellfun(@numel,port));
%     result=cellfun(@(x) [reshape(x,1,[]),NaN(1,maxLength-numel(x))],port,'UniformOutput',false);
%     result2=vertcat(result{:});
%     a.([portname,'Exp']) = result2;
%     result = [];
%     result2 = [];
% end

% mouse may already be in a port at trial start -- condition
% mouse may be in port when trial ends
% mouse may be in port when file ends

% these all will make either the number of entries or exits not match
% OR exits come after entries in time

% if mouse in port at trial start, first in>first out-->set first in to
% trial start and slide over
% if mouse in port when trial ends, fewer outs than ins-->add out = trial
% end


portInNames = {'Port1In','Port2In','Port3In'};
portOutNames = {'Port1Out','Port2Out','Port3Out'};
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



%% TO ADD

%{
later opto, imaging, values, licking!!
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% MEAN CHOICES / STATS AND CHOICE RANGES - FIX

trialsToCount = 300;

if ~isempty(a.choiceMice)
    
    a.meanChoice = NaN(a.mouseCt,3);
    a.choiceCI = NaN(a.mouseCt,2);
    a.prefCI = NaN(a.mouseCt,2);
    a.pref = NaN(a.mouseCt,8);
    a.beta = NaN(a.mouseCt,2);
       
   for mm = 1:a.choiceMouseCt
       m = a.choiceMice(mm);
       
       ok = a.mice(:,m) == 1 & a.trialType == 1 & a.trialTypes == 5 & a.correct == 1;
       okidx = find(ok);
       [~,sortidx] = sort(a.mouseDay(ok==1));
       oksorted = okidx(sortidx);
       
       % that mouse's choice trials
       choicesIIS = a.choice_all(ok); % includes choice training??
       choicesIIS = choicesIIS(sortidx);
       choices = a.info(ok);
       choices = choices(sortidx);
       reverses = a.reverse(ok);
       reverses = reverses(sortidx);

       preReverseTrials = find(reverses == 1,trialsToCount,'last');
       [a.pref(m,1),a.prefCI(m,1:2)] = binofit(sum(choicesIIS(preReverseTrials)==1),numel(choicesIIS(preReverseTrials)));
       [a.pref(m,3),a.prefCI(m,3:4)] = binofit(sum(choices(preReverseTrials)==1),numel(choices(preReverseTrials))); 
       if ismember(m,a.reverseMice)
         postReverseTrials = find(reverses == -1,trialsToCount,'last'); % during reverse
         [a.pref(m,2),a.prefRevCI(m,1:2)] = binofit(sum(choicesIIS(postReverseTrials)==1),numel(choicesIIS(postReverseTrials)));
         [a.pref(m,4),a.prefRevCI(m,3:4)] = binofit(sum(choices(postReverseTrials)==1),numel(choices(postReverseTrials)));
         if sum(reverses == 2) > 0
             reReverseTrials = find(reverses == 2,trialsToCount,'last'); % during reverse
             [a.pref(m,5),a.prefReRevCI(m,1:2)] = binofit(sum(choicesIIS(reReverseTrials)==1),numel(choicesIIS(reReverseTrials)));
             [a.pref(m,6),a.prefReRevCI(m,3:4)] = binofit(sum(choices(reReverseTrials)==1),numel(choices(reReverseTrials)));             
         end
         if sum(reverses == -2) > 0
             reverse2Trials = find(reverses == -2,trialsToCount,'last'); % during reverse
             [a.pref(m,7),a.pref2RevCI(m,1:2)] = binofit(sum(choicesIIS(reverse2Trials)==1),numel(choicesIIS(reverse2Trials)));
             [a.pref(m,8),a.pref2RevCI(m,3:4)] = binofit(sum(choices(reverse2Trials)==1),numel(choices(reverse2Trials)));
         end
       end

       choicePreRev = a.choice_all(ok & a.reverse == 1);
       [a.meanChoice(m,1),a.choiceCI(m,1:2)] = binofit(sum(choicePreRev==1),numel(choicePreRev));
       
       % FOR FIRST REVERSE
       if ismember(m,a.reverseMice)
           choicePostRev = a.choice_all(ok & a.reverse==-1);
           [a.meanChoice(m,2),a.choiceRevCI(m,1:2)] = binofit(sum(choicePostRev==1),numel(choicePostRev));
           
           % FOR ALL REVERSES
           x = [a.initinfoside_side(ok & a.reverse~=0) a.initinfoside_info(ok & a.reverse~=0)];
           y = a.choice_all(ok & a.reverse~=0);
           [~,~,a.stats(m)] = glmfit(x,y,'binomial','link','logit','constant','off');
           a.beta(m,:) = a.stats(m).beta;
           a.betaP(m,:) = a.stats(m).p;
           a.betaSE(m,:) = a.stats(m).se;
       end
       
       a.meanChoice(m,3) = m;
 
   end

   % pref(:,1) for up to 300 trials, mean choice for all
    a.meanChoice = a.meanChoice(a.meanChoice(:,3)>0,:);
    a.choiceCI = a.choiceCI(a.choiceCI(:,1)>0,:);
   
    allChoices = a.choiceCorr(a.choiceCorrTrials & a.reverse == 1);
    [a.overallPref,a.overallCI] = binofit(sum(allChoices == 1),numel(allChoices));
    clear allChoices;
end

%% OVERALL CHOICES BY SIDE

if numel(a.reverseMice)>0
    for m = 1:a.mouseCt
       ok = a.mice(:,m) == 1 & a.trialType == 1 & a.trialTypes == 5 & a.reverse~= 0 & a.correct == 1; % need to match params
       a.overallChoice(m,1) = mean(a.info(ok & a.infoSide == 0)); % info side = 0
       a.overallChoice(m,2) = mean(a.info(ok & a.infoSide == 1)); % info side = 1
       a.overallChoice(m,3) = mean(a.info(ok & a.infoSide == a.initinfoside(m,1)));
       a.overallChoice(m,4) = mean(a.info(ok & a.infoSide ~= a.initinfoside(m,1)));
    end
 a.overallChoice(:,5) = nanmean(a.overallChoice(:,[1 2]),2);
 a.overallChoicePercent = a.overallChoice(:,5)*100;
 a.overallChoiceP = signrank(a.overallChoicePercent-50);
end


%% SORT BY INFO PREFERENCE
if sum(a.choiceMice)>0
    [a.sortedChoice,a.sortIdx] = sortrows(a.meanChoice(~isnan(a.meanChoice(:,1)),:),1);
    a.sortedMouseList = a.choiceMiceList(a.sortIdx);
    a.sortedCI = a.choiceCI(a.sortIdx,:);
    % STATS

    a.icp_all = a.sortedChoice(:,1)*100;    
%     a.icp_all = a.meanChoice(1:end-1,1)*100;    
    a.overallP = signrank(a.icp_all-50);
        
end

%% TO DO
%{
reversalrxn
preRevRxnSpeed
meanReversalMultiPrefs
reversalPrefs
a.reversalRxnInfo
reversalRewardRateIdx
a.reversalRewardRateInfo
a.rewardRate
rewarddiff
rxnmean
%}

%% EARLY LICKS AND REACTION SPEED BY REVERSAL

% NEED TO FINISH

% use trials to count

%%
% RELATIVE TO CURRENT INFO SIDE

if ~isempty(a.reverseMice)
    for m=1:a.mouseCt  
        ok1 = a.mice(:,m) == 1 & a.trialType == 2 & a.correct == 1 & a.reverse == 1;
        ok1Idx = find(ok1);
        [~,sort1idx] = sort(a.mouseDay(ok1==1));
        ok1sorted = ok1Idx(sort1idx);    
        okInfoPreRevIdx = find(ok1sorted,300,'last');
        okInfoPreRev = ok1sorted(okInfoPreRevIdx);
        ok2 = a.mice(:,m) == 1 & a.trialType == 3 & a.correct == 1 & a.reverse == 1;
        ok2Idx = find(ok2);
        [~,sort2idx] = sort(a.mouseDay(ok2==1));
        ok2sorted = ok2Idx(sort2idx);     
        okRandPreRevIdx = find(ok2sorted,300,'last');
        okRandPreRev = ok2sorted(okRandPreRevIdx);
        ok3 = a.mice(:,m) == 1 & a.trialType == 2 & a.correct == 1 & a.reverse == -1;
        ok3Idx = find(ok3);
        [~,sort3idx] = sort(a.mouseDay(ok3==1));
        ok3sorted = ok3Idx(sort3idx);     
        okInfoPostRevIdx = find(ok3sorted,300,'last');
        okInfoPostRev = ok3sorted(okInfoPostRevIdx);
        ok4 = a.mice(:,m) == 1 & a.trialType == 3 & a.correct == 1 & a.reverse == -1;
        ok4Idx = find(ok4);
        [~,sort4idx] = sort(a.mouseDay(ok4==1));
        ok4sorted = ok4Idx(sort4idx); 
        okRandPostRevIdx = find(ok4sorted,300,'last');
        okRandPostRev = ok4sorted(okRandPostRevIdx);
       % pre-reverse, INFO
    %    a.preRevEarlyLicks(m,1) = mean(a.earlyLicks(okInfoPreRev));
       a.preRevRxnSpeed(m,1) = mean(a.rxnSpeed(okInfoPreRev));
       a.preRevRxn(m,1) = mean(a.rxn(okInfoPreRev));
       % pre-reverse, NO INFO
    %    a.preRevEarlyLicks(m,2) = mean(a.earlyLicks(okRandPreRev));
       a.preRevRxnSpeed(m,2) = mean(a.rxnSpeed(okRandPreRev));
       a.preRevRxn(m,2) = mean(a.rxn(okRandPreRev));
       % pre-reverse diff p-val
    %    [~,a.preRevEarlyLicks(m,3)] = ttest2(a.earlyLicks(okInfoPreRev),a.earlyLicks(okRandPreRev));
       [~,a.preRevRxnSpeed(m,3)] = ttest2(a.rxnSpeed(okInfoPreRev),a.rxnSpeed(okRandPreRev));
       % post-reverse, INFO
    %    a.postRevEarlyLicks(m,1) = mean(a.earlyLicks(okInfoPostRev));
       a.postRevRxnSpeed(m,1) = mean(a.rxnSpeed(okInfoPostRev));
       a.postRevRxn(m,1) = mean(a.rxn(okInfoPostRev));
       % post-reverse, NO INFO
    %    a.postRevEarlyLicks(m,2) = mean(a.earlyLicks(okRandPostRev));
       a.postRevRxnSpeed(m,2) = mean(a.rxnSpeed(okRandPostRev));
       a.postRevRxn(m,2) = mean(a.rxn(okRandPostRev));
       % post-reverse diff p-val
    %    [~,a.postRevEarlyLicks(m,3)] = ttest2(a.earlyLicks(okInfoPostRev),a.earlyLicks(okRandPostRev));
       [~,a.postRevRxnSpeed(m,3)] = ttest2(a.rxnSpeed(okInfoPostRev),a.rxnSpeed(okRandPostRev));   
       % pre-reverse
    %    a.earlyLickIdx(m,1) = (a.preRevEarlyLicks(m,1)-a.preRevEarlyLicks(m,2))/(a.preRevEarlyLicks(m,1)+a.preRevEarlyLicks(m,2));
       a.rxnSpeedIdx(m,1) = (a.preRevRxnSpeed(m,1)-a.preRevRxnSpeed(m,2))/(a.preRevRxnSpeed(m,1)+a.preRevRxnSpeed(m,2));
       % post-reverse
    %    a.earlyLickIdx(m,2) = (a.postRevEarlyLicks(m,1)-a.postRevEarlyLicks(m,2))/(a.postRevEarlyLicks(m,1)+a.postRevEarlyLicks(m,2));
       a.rxnSpeedIdx(m,2) = (a.postRevRxnSpeed(m,1)-a.postRevRxnSpeed(m,2))/(a.postRevRxnSpeed(m,1)+a.postRevRxnSpeed(m,2)); 
    end

end
% 
% %%
% for m = 1:a.mouseCt
%     infoBigProb = [];
%     randBigProb = [];
%     for d = 1:a.mouseDayCt(m)
%         infoBigProb(d) = a.daySummary.infoBigProb{m,d};
%         randBigProb(d) = a.daySummary.randBigProb{m,d};
%     end
%     a.infoBigProbs{m,1} = infoBigProb;
%     a.randBigProbs{m,1} = randBigProb;
% end
% 
%% DAYS AROUND REVERSES

if ~isempty(a.reverseMice)

    a.reversalDays = NaN(numel(a.reverseMice),4);

    for m = 1:numel(a.reverseMice)
        mm=a.reverseMice(m);
        a.reversalDays(m,1) = a.reverseDay{mm,1}-1; % day prior to 1st reversal
        if size(cell2mat(a.reverseDay(mm,:)),2) > 1
            if ~isempty(a.reverseDay{mm,2})
            a.reversalDays(m,2) = a.reverseDay{mm,2}-1; % day prior to second reversal

            % last day of second reversal (either r+3/last day or last day before get
            % ready for values)
            % use a.lastParamDay for value mice!
%             if ~ismember(mm,a.valueMice)
                if ~isempty(a.reverseDay{mm,3})
                    a.reversalDays(m,3) = a.reverseDay{mm,3}-1; % day prior to third reversal
                    a.reversalDays(m,4) = a.mouseDayCt(mm); % no? WHAT ABOUT VALUE?!?
                
                else
                
                    if a.reverseDay{mm,2}+3 >= a.mouseDayCt(mm)
                        a.reversalDays(m,3) = a.mouseDayCt(mm);
                    else
                        a.reversalDays(m,3) = a.reverseDay{mm,2}+3;
                    end
                end
%             else
%                 mmm = find(a.valueMice == mm);
%                 mouseValueDays = a.mouseValueDays{mmm,1};
%                 if ismember(mmm,a.valueMiceInfo)
%                     mouseProbDays = a.infoBigProbs{mm,1};
%                 else
%                     mouseProbDays = a.randBigProbs{mm,1};
%                 end
%                 mouseValues = mouseProbDays(mouseValueDays);
%                 if sum(mouseValues > 25) > 0
%                     a.reversalDays(m,3) = find(mouseProbDays==25,1,'last');
%                 else
%                     a.reversalDays(m,3) = mouseValueDays(1);
%                 end
%               end
            end
        end
    end
end % TAKE THIS OUT WHEN ADD BELOW

%% CHOICE, RXN SPEED, EARLY LICKS, AND REWARD RATE AROUND REVERSALS BY IIS

if ~isempty(a.reverseMice)
    a.reversalPrefs = NaN(numel(a.reverseMice),3);
    a.reversalRxn = NaN(numel(a.reverseMice),3);
%     a.reversalLicks = NaN(numel(a.reverseMice),3);
    a.reversalMultiPrefs = NaN(numel(a.reverseMice),8);
    for m = 1:numel(a.reverseMice)
        mm = a.reverseMice(m);
        for n = 1:3
            if ~isnan(a.reversalDays(m,n))
                day = a.reversalDays(m,n);
            else
                if n>1 & a.mouseDayCt(mm)>a.reversalDays(m,n-1)
%                     day = a.reversalDays(m,n-1)+3;
                    day = a.mouseDayCt(mm);
                else
                    day = 0;
                end
            end
            if ~isnan(a.reversalDays(m,n))
                a.reversalPrefs(m,n) = a.daySummary.percentIIS{mm,day};
                if n == 1
                    for k = 1:4
%                         if ~isempty(a.daySummary.percentIIS{mm,a.reversalDays(m,n)+k-1})
                        if a.mouseDayCt(mm)>(day+k-1)
                            a.reversalMultiPrefs(m,k) = a.daySummary.percentIIS{mm,a.reversalDays(m,n)+k-1};
                        end
                    end
                elseif n==2
                    for k = 1:4
%                         if ~isempty(a.daySummary.percentIIS{mm,a.reversalDays(m,n)+k-1})
                        if a.mouseDayCt(mm)>(day+k-1)
                            a.reversalMultiPrefs(m,k+4) = a.daySummary.percentIIS{mm,a.reversalDays(m,n)+k-1};
                        end
                    end
                end
            else
                if n>1 & day>0
                    a.reversalPrefs(m,n) = a.daySummary.percentIIS{mm,day};
                end
            end
            if day > 0
    %             if isnan(a.daySummary.rxnSpeedIdx{m,a.reversalDays(m,n)})
    %                 a.reversalRxn(m,n) = a.daySummary.rxnSpeedIdx{m,a.reversalDays(m,n)-1};
    %             else
                    a.reversalRxn(m,n) = a.daySummary.rxnSpeedIdx{mm,day};
                    a.reversalRxnInfo(m,n) = a.daySummary.rxnInfoForced{mm,day};
                    a.reversalRxnRand(m,n) = a.daySummary.rxnRandForced{mm,day};
                    a.reversalRxnInfoChoice(m,n) = a.daySummary.rxnInfoChoice{mm,day};
                    a.reversalRxnRandChoice(m,n) = a.daySummary.rxnRandChoice{mm,day};                    
    %             end
    %             if isnan(a.daySummary.earlyLickIdx{m,a.reversalDays(m,n)})
    %                 a.reversalLicks(m,n) = a.daySummary.earlyLickIdx{m,a.reversalDays(m,n)-1};
    %             else
%                     a.reversalLicks(m,n) = a.daySummary.earlyLickIdx{mm,day};
%                     a.reversalInfoBigEarlyLicks(m,n) = a.daySummary.infoBigLicksEarly{mm,day};
%                     a.reversalInfoSmallEarlyLicks(m,n) = a.daySummary.infoSmallLicksEarly{mm,day};
%                     a.reversalRandCEarlyLicks(m,n) = a.daySummary.randCLicksEarly{mm,day};
%                     a.reversalRandDEarlyLicks(m,n) = a.daySummary.randDLicksEarly{mm,day};
%                     a.reversalInfoBigLicks(m,n) = a.daySummary.infoBigLicks{mm,day};
%                     a.reversalInfoSmallLicks(m,n) = a.daySummary.infoSmallLicks{mm,day};
%                     a.reversalRandCLicks(m,n) = a.daySummary.randCLicks{mm,day};
%                     a.reversalRandDLicks(m,n) = a.daySummary.randDLicks{mm,day};
    %             end
    %             a.reversalRewardRateIdx(m,n) = (a.daySummary.rewardRateInfoForced{m,a.reversalDays(m,n)}-a.daySummary.rewardRateRandForced{m,a.reversalDays(m,n)})/(a.daySummary.rewardRateInfoForced{m,a.reversalDays(m,n)}+a.daySummary.rewardRateRandForced{m,a.reversalDays(m,n)});
                  if n==2
                    a.reversalRewardRateIdx(m,n) = (a.daySummary.rewardRateRandForced{mm,day}-a.daySummary.rewardRateInfoForced{mm,day});
                    a.reversalRewardRateInfo(m,n) = a.daySummary.rewardRateRand{mm,day};
                    a.reversalRewardRateRand(m,n) = a.daySummary.rewardRateInfo{mm,day};
                  else
                    a.reversalRewardRateIdx(m,n) = (a.daySummary.rewardRateInfoForced{mm,day}-a.daySummary.rewardRateRandForced{mm,day});   
                    a.reversalRewardRateInfo(m,n) = a.daySummary.rewardRateInfo{mm,day};
                    a.reversalRewardRateRand(m,n) = a.daySummary.rewardRateRand{mm,day};
                  end
            end
        end
    end
end
    %%
if ~isempty(a.reverseMice)    
    if  ~isnan(a.reversalPrefs(:,2))
    
    a.meanReversalMultiPrefs = nanmean(a.reversalMultiPrefs);
    a.SEMReversalMultiPrefs = sem(a.reversalMultiPrefs);
    
%     a.meanReversalMultiPrefs = nanmean(a.reversalMultiPrefs(a.reversalMultiPrefs(:,1)>0.5,:));
%     a.SEMReversalMultiPrefs = sem(a.reversalMultiPrefs(a.reversalMultiPrefs(:,1)>0.5,:));

    a.reversalPrefs_stats = a.reversalPrefs*100;
    a.reversal1P = signrank(a.reversalPrefs_stats(:,1),a.reversalPrefs_stats(:,2));
    if ~isnan(a.reversalPrefs(:,3))
    a.reversal2P = signrank(a.reversalPrefs_stats(:,2),a.reversalPrefs_stats(:,3));
    a.reversalP = signrank(a.reversalPrefs_stats(:,1),a.reversalPrefs_stats(:,3));
    end

    a.reversalRxnP(1,1) = signrank(a.reversalRxn(:,1),a.reversalRxn(:,2));
    if ~isnan(a.reversalPrefs(:,3))
    a.reversalRxnP(1,2) = signrank(a.reversalRxn(:,2),a.reversalRxn(:,3));
    a.reversalRxnP(1,3) = signrank(a.reversalRxn(:,1),a.reversalRxn(:,3));
    end

%     a.reversalLicksP(1,1) = signrank(a.reversalLicks(:,1),a.reversalLicks(:,2));
%     if ~isnan(a.reversalPrefs(:,3))
%     a.reversalLicksP(1,2) = signrank(a.reversalLicks(:,2),a.reversalLicks(:,3));
%     a.reversalLicksP(1,3) = signrank(a.reversalLicks(:,1),a.reversalLicks(:,3));
%     end

    a.reversalRewardRateP(1,1) = signrank(a.reversalRewardRateIdx(:,1),a.reversalRewardRateIdx(:,2));
    if ~isnan(a.reversalPrefs(:,3))
    a.reversalRewardRateP(1,2) = signrank(a.reversalRewardRateIdx(:,2),a.reversalRewardRateIdx(:,3));
    a.reversalRewardRateP(1,3) = signrank(a.reversalRewardRateIdx(:,1),a.reversalRewardRateIdx(:,3));
    end

    if ~isnan(a.reversalPrefs(:,3))
    for p =1:3
        a.reversalPVals(1,p) = signrank(a.reversalPrefs_stats(:,p)-50);
        a.reversalRxnPVals(1,p) = signrank(a.reversalRxn(:,p));
%         a.reversalLicksPVals(1,p) = signrank(a.reversalLicks(:,p));
        a.reversalRewardRatePVals(1,p) = signrank(a.reversalRewardRateIdx(:,p));
    end
    end
    a.reversalRxnInfoRandP(1,1) = signrank(a.reversalRxnInfo(:,1),a.reversalRxnRand(:,1));
    a.reversalRewardRateInfoRandP(1,1) = signrank(a.reversalRewardRateInfo(:,1),a.reversalRewardRateRand(:,1));
    end
end


%% INFO vs RAND STATS OVERALL (not by day)

% do these need to be for correct??
% CHANGE BACK TO ONLY PREF DAYS!

for m=1:a.mouseCt
%     ok = a.mice(:,m)==1 & a.trialTypes == 5 & a.reverse~= 0& a.forcedCorrTrials == 1;
    ok = a.mice(:,m)==1 &  a.forcedCorrTrials == 1;
    a.rxnMean(m,1) = nanmean(a.rxn(ok & a.info==1 & a.correct==1));
    a.rxnMean(m,2) = nanmean(a.rxn(ok & a.info==0 & a.correct==1));
    a.rxnDiff(m,1) = a.rxnMean(m,1) - a.rxnMean(m,2);
    for i = 1:numel(a.reverseTypes)
       r = a.reverseTypes(i);
       a.rxnInfoRev(m,i) = nanmean(a.rxn(ok & a.reverse==r & a.info == 1 & a.correct==1));
       a.rxnRandRev(m,i) = nanmean(a.rxn(ok & a.reverse==r & a.info == 0 & a.correct==1));
    end
    
%     okAll = a.mice(:,m)==1 & a.reverse~= 0;
    okAll = a.mice(:,m)==1;
    a.rewardRate(m,1) = nansum(a.reward(a.info == 1 & okAll == 1)) / (nansum(a.trialLengthCenterEntry(a.info == 1 & okAll == 1))/1000/60);
    a.rewardRate(m,2) = nansum(a.reward(a.info == 0 & okAll == 1)) / (nansum(a.trialLengthCenterEntry(a.info == 0 & okAll == 1))/1000/60);
    a.rewardDiff(m,1) = a.rewardRate(m,1) - a.rewardRate(m,2);
end

%%
save('infoSeekBpodDataAnalyzed.mat','a','-v7.3');
% uisave({'a'},'infoSeekBpodDataAnalyzed.mat');

save(['infoSeekBpodDataAnalyzed' datestr(now,'yyyymmdd')],'a','-v7.3');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
































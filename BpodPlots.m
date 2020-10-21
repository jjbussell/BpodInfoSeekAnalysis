%% SAVEPATH

laptoppath = 'C:\Users\jbuss\Dropbox\BpodInfoseek\Data\Graphs';

if exist('D:\Dropbox\Data\Infoseek\Graphs')
  pathname = 'D:\Dropbox\Data\Infoseek\Graphs';
elseif exist(laptoppath)
    pathname = laptoppath;
else   
  pathname=uigetdir('','Choose save directory');
end

%% PLOTTING COLORS AND LABELS

purple = [121 32 196] ./ 255;
orange = [251 139 6] ./ 255;
cornflower = [100 149 237] ./ 255;
grey = [.8 .8 .8];

CCfinal = [0.2,0.2,0.2; %choice no choice
    0.474509803921569,0.125490196078431,0.768627450980392; %choice info big
    171/255,130/255,1; % choice info big NP
    0.9490, 0.8, 1.0; %choiceinfosmall
    238/255,224/255,229/255; %choiceinfoNPsmall    
    0.984313725490196,0.545098039215686,0.0235294117647059; %choice rand big
    245/255,222/255,179/255; % choice rand big NP
    1, 0.8, 0.0; %choice rand small
    244/255, 164/255, 96/255; %choice rand small NP
    0.6,0.6,0.6; %info no choice
    0,1,0; %info big
    152/255,251/255,152/255;% info big NP
    1,0,1; %infosmall
    1,192/255,203/255; %info small not present
    0.0,0.0,0.0; %infoincorrect
    0.2,0.2,0.2;% rand no choice
    0,0,1; %rand big
    135/255,206/255,1; % rand big NP
    0,1,1; %rand small
    187/255,1,1; %rand small NP
    0.0,0.0,0.0]; %rand incorrect

a.choiceLabels = {'ChoiceInfoBig','ChoiceInfoSmall','ChoiceRandBig',...
    'ChoiceRandSmall','InfoBig','InfoSmall','RandBig','RandSmall'};

a.outcomeLabels = {'ChoiceNoChoice','ChoiceInfoBig','ChoiceInfoBigNP',...
    'ChoiceInfoSmall','ChoiceInfoSmallNP','ChoiceRandBig','ChoiceRandBigNP',...
    'ChoiceRandSmall','ChoiceRandSmallNP','InfoNoChoice','InfoBig',...
    'InfoBigNP','InfoSmall','InfoSmallNP','InfoIncorrect','RandNoChoice',...
    'RandBig','RandBigNP','RandSmall','RandSmallNP',...
    'RandIncorrect'};


%% PLOT DAY SUMMARIES BY MOUSE FOR CURRENT MICE

for m = 1:a.mouseCt
    figure();
    
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 11 8.5];
    set(fig,'renderer','painters');
    set(fig,'PaperOrientation','landscape');
    
    ax = nsubplot(4,2,1,1);
    title(a.mouseList(m));
    ax.FontSize = 8;
%     set(ax,'units','inches');
%     ax.Position = [1 1 5 1];

    % if there's choice
%     if sum(isnan(cell2mat(a.daySummary.percentInfo(m,:)))) ~= a.mouseDayCt(m)
    if sum(a.mouseTrialTypes{m}==5) > 0
        ax.XTick = [0:5:a.mouseDayCt(m)];    
        ax.YTick = [0 0.25 0.50 0.75 1];
        ax.YLim = [-0.1 1.1];
        plot(0,0,'Marker','none');
        plot(1:a.mouseDayCt(m),[cell2mat(a.daySummary.percentInfo(m,:))],'Color',[.5 .5 .5],'LineWidth',2,'Marker','o','MarkerSize',3);
        plot([-10000000 1000000],[0.5 0.5],'k','xliminclude','off','color',[0.8 0.8 0.8],'LineWidth',1);  
        ylabel({'Info choice', 'probability'}); %ylabel({'line1', 'line2','line3'},)
    %     xlabel('Day');
        hold off;
    else
        if a.mouseDayCt(m)>10
            ax.XTick = [0:5:a.mouseDayCt(m)];
        end
%         ax.XLim = [1 a.mouseDayCt(m)]; 
        plot(1:a.mouseDayCt(m),cell2mat(a.daySummary.totalCorrectTrials(m,:)),'Color','k','LineWidth',1,'Marker','o','MarkerFaceColor','k','MarkerSize',2);
        ylabel('TotalCorrectTrials');
%         ax.YLim = [0 100];
%         ax.YTick = [0 25 50 75 100];
    %     ax.YColor = 'k';
        hold off;
    end
    
    
    ax = nsubplot(4,2,2,1);
    ax.FontSize = 8;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [0 2000];
    plot(cell2mat(a.daySummary.rxnInfoForced(m,:)),'Color',purple,'LineWidth',1);
    plot(cell2mat(a.daySummary.rxnInfoChoice(m,:)),'Color',purple,'LineWidth',1,'LineStyle',':');
    plot(cell2mat(a.daySummary.rxnRandForced(m,:)),'Color',orange,'LineWidth',1);
    plot(cell2mat(a.daySummary.rxnRandChoice(m,:)),'Color',orange,'LineWidth',1,'LineStyle',':');
    for r = 1:numel(cell2mat(a.reverseDay(m,:)))
        plot([a.reverseDay{m,r}-0.5 a.reverseDay{m,r}-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',1);
    end
    ylabel({'Reaction', 'Time (ms)'});
%     xlabel('Day');    
    leg = legend(ax,['Info' newline '-Forced'],['Info' newline '-Choice'],['No Info' newline '-Forced'],['No Info' newline '-Choice'],'Location','southoutside','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;
    
    ax = nsubplot(4,2,3,1);
    ax.FontSize = 8;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [0 inf];
    plot(cell2mat(a.daySummary.infoBigLicksEarly(m,:)),'Color','g','LineWidth',1);
    plot(cell2mat(a.daySummary.infoSmallLicksEarly(m,:)),'Color','m','LineWidth',1);
    plot(cell2mat(a.daySummary.randCLicksEarly(m,:)),'Color',cornflower,'LineWidth',1);
    plot(cell2mat(a.daySummary.randDLicksEarly(m,:)),'Color',cornflower,'LineWidth',1,'LineStyle',':');
%     plot(cell2mat(a.daySummary.randBigLicksEarly(m,:)),'Color','c','LineWidth',1);
%     plot(cell2mat(a.daySummary.randSmallLicksEarly(m,:)),'Color','b','LineWidth',1);
    for r = 1:numel(cell2mat(a.reverseDay(m,:)))
        plot([a.reverseDay{m,r}-0.5 a.reverseDay{m,r}-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',1);
    end
    ylabel({'Early', 'lick rate'});
%     xlabel('Day');
    if ismember(m,find(a.noneMice))
        leg = legend(ax,'Info-Rew','Info-No Rew','No Info - C','No Info - D','Location','southoutside','Orientation','horizontal');
    else
        leg = legend(ax,'Info-Big','Info-Small','No Info - C','No Info - D','Location','southoutside','Orientation','horizontal');
    end
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;

    ax = nsubplot(4,2,4,1);
    ax.FontSize = 8;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [0 inf];
    plot(cell2mat(a.daySummary.infoBigLicks(m,:)),'Color','g','LineWidth',1);
    plot(cell2mat(a.daySummary.infoSmallLicks(m,:)),'Color','m','LineWidth',1);
    plot(cell2mat(a.daySummary.randCLicks(m,:)),'Color',cornflower,'LineWidth',1);
    plot(cell2mat(a.daySummary.randDLicks(m,:)),'Color',cornflower,'LineWidth',1,'LineStyle',':');
    for r = 1:numel(cell2mat(a.reverseDay(m,:)))
        plot([a.reverseDay{m,r}-0.5 a.reverseDay{m,r}-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',1);
    end     
    ylabel({'Anticipatory', 'lick rate'});
    xlabel('Day');
    if ismember(m,find(a.noneMice))    
    leg = legend(ax,'Info-Rew','Info-No Rew','No Info - C','No Info - D','Location','southoutside','Orientation','horizontal');
    else
    leg = legend(ax,'Info-Big','Info-Small','No Info - C','No Info - D','Location','southoutside','Orientation','horizontal');
    end
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;
    
    ax = nsubplot(4,2,1,2);
%     title(a.mouseList(m));
    title(a.dayCell{find(a.fileMouse == m & a.fileDay == a.mouseDayCt(m),1,'first')});
    ax.FontSize = 8;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [0 inf];
    plot(cell2mat(a.daySummary.infoBigLicksWater(m,:)),'Color','g','LineWidth',1);
    plot(cell2mat(a.daySummary.infoSmallLicksWater(m,:)),'Color','m','LineWidth',1);
    plot(cell2mat(a.daySummary.randBigLicksWater(m,:)),'Color','b','LineWidth',1);
    plot(cell2mat(a.daySummary.randSmallLicksWater(m,:)),'Color','c','LineWidth',1);
%     plot(cell2mat(a.daySummary.randCLicksWater(m,:)),'Color','c','LineWidth'1);
%     plot(cell2mat(a.daySummary.randDLicksWater(m,:)),'Color','b','LineWidth',1);
    for r = 1:numel(cell2mat(a.reverseDay(m,:)))
        plot([a.reverseDay{m,r}-0.5 a.reverseDay{m,r}-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',1);
    end   
    ylabel({'Post-outcome', 'lick rate'});
%     xlabel('Day');
    if ismember(m,find(a.noneMice))
    leg = legend(ax,'Info-Rew','Info-No Rew','No Info - Rew','No Info - No Rew','Location','southoutside','Orientation','horizontal');
    else
    leg = legend(ax,'Info-Big','Info-Small','No Info - Big','No Info - Small','Location','southoutside','Orientation','horizontal');        
    end
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;
    
    ax = nsubplot(4,2,2,2);
    ax.FontSize = 8;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [0 inf];
    plot(cell2mat(a.daySummary.ARewards(m,:)),'Color','g','LineWidth',1);
    plot(cell2mat(a.daySummary.BRewards(m,:)),'Color','m','LineWidth',1);
    plot(cell2mat(a.daySummary.CRewards(m,:)),'Color',cornflower,'LineWidth',1);
    plot(cell2mat(a.daySummary.DRewards(m,:)),'Color',cornflower,'LineWidth',1,'LineStyle',':');
    plot(cell2mat(a.daySummary.randBigRewards(m,:)),'Color','c','LineWidth',1);
    plot(cell2mat(a.daySummary.randSmallRewards(m,:)),'Color','b','LineWidth',1);
    for r = 1:numel(cell2mat(a.reverseDay(m,:)))
        plot([a.reverseDay{m,r}-0.5 a.reverseDay{m,r}-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',1);
    end     
    ylabel({'Mean Reward', '(uL)'});
%     xlabel('Day');
    if ismember(m,find(a.noneMice))
    leg = legend(ax,['Info' newline '-Rew'],['Info' newline '-No Rew'],['No Info' newline '-C'],['No Info' newline '-D'],['No Info' newline '-Rew'],['No Info' newline '-No Rew'],'Location','southoutside','Orientation','horizontal');
    else
    leg = legend(ax,['Info' newline '-Big'],['Info' newline '-Small'],['No Info' newline '-C'],['No Info' newline '-D'],['No Info' newline '-Big'],['No Info' newline '-Small'],'Location','southoutside','Orientation','horizontal');        
    end
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;
    
%     ax = nsubplot(4,2,3,2);
%     ax.FontSize = 8;
%     ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
% %     ax.YLim = [6000 20000];
%     plot(cell2mat(a.daySummary.trialLengthEntryInfoForced(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerFaceColor',purple,'MarkerSize',3);
%     plot(cell2mat(a.daySummary.trialLengthEntryInfoChoice(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerFaceColor',purple,'MarkerSize',3,'LineStyle',':');
%     plot(cell2mat(a.daySummary.trialLengthEntryRandForced(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerFaceColor',orange,'MarkerSize',3);
%     plot(cell2mat(a.daySummary.trialLengthEntryRandChoice(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerFaceColor',orange,'MarkerSize',3,'LineStyle',':');
%     plot([a.reverseDay(m)-0.5 a.reverseDay(m)-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',4);
%     ylabel({'Trial', 'duration (ms)'});
% %     xlabel('Day');
%     leg = legend(ax,'Info Forced','Info Choice','No Info Forced','No Info Choice','Location','southoutside','Orientation','horizontal');
%     leg.Box = 'off';
%     leg.FontWeight = 'bold';
%     hold off;

    ax = nsubplot(4,2,3,2);
    ax.FontSize = 8;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
%     ax.YLim = [6000 20000];
    plot(cell2mat(a.infoIncorr(m,:)),'Color',purple,'LineWidth',1);
    plot(cell2mat(a.randIncorr(m,:)),'Color',orange,'LineWidth',1);
    plot(cell2mat(a.choiceIncorr(m,:)),'Color',[0.5 0.5 0.5],'LineWidth',1);
    if ismember(m,a.optoMice)
        om = find(a.optoMice == m);
        plot(a.laserDays{om,1},ones(1,length(a.laserDays{om,1})),'Color',[0 1 1],'LineStyle','none','Marker','o','MarkerFaceColor',[0 1 1],'MarkerSize',5);
    end 
    for r = 1:numel(cell2mat(a.reverseDay(m,:)))
        plot([a.reverseDay{m,r}-0.5 a.reverseDay{m,r}-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',1);
    end
    for d = 1:a.mouseDayCt(m)
        text(d+0.1,1.1,num2str(a.daySummary.totalTrials{m,d}),'Fontsize',5);
    end 
    ylabel('Error rate');
%     xlabel('Day');
    leg = legend(ax,'Info','No Info','Choice','Location','southoutside','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';
    hold off;

    ax = nsubplot(4,2,4,2);
    ax.FontSize = 8;
    ax.XTick = [0:5:max(cell2mat(a.daySummary.day(m,:)))];
    ax.YLim = [0 25];
    plot(cell2mat(a.daySummary.rewardRateInfoForced(m,:)),'Color',purple,'LineWidth',1);
    plot(cell2mat(a.daySummary.rewardRateRandForced(m,:)),'Color',orange,'LineWidth',1);
    plot(cell2mat(a.daySummary.rewardRateChoice(m,:)),'Color',[0.5 0.5 0.5],'LineWidth',1);
%     plot(cell2mat(a.daySummary.rewardRateInfoForced(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerFaceColor',purple,'MarkerSize',3);
%     plot(cell2mat(a.daySummary.rewardRateInfoChoice(m,:)),'Color',purple,'LineWidth',2,'Marker','o','MarkerEdgeColor',purple,'MarkerFaceColor','w','MarkerSize',3,'LineStyle',':');
%     plot(cell2mat(a.daySummary.rewardRateRandForced(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerFaceColor',orange,'MarkerSize',3);
%     plot(cell2mat(a.daySummary.rewardRateRandChoice(m,:)),'Color',orange,'LineWidth',2,'Marker','o','MarkerEdgeColor',orange,'MarkerFaceColor','w','MarkerSize',3,'LineStyle',':');
    for r = 1:numel(cell2mat(a.reverseDay(m,:)))
        plot([a.reverseDay{m,r}-0.5 a.reverseDay{m,r}-0.5],[-10000000 1000000],'k','yliminclude','off','xliminclude','off','LineWidth',1);
    end
%     plot(cell2mat(a.daySummary.infoBigLicksWater(m,:)),'Color','g','LineWidth',2,'Marker','o','MarkerFaceColor','g','MarkerSize',3,'Visible','off');
%     plot(cell2mat(a.daySummary.infoSmallLicksWater(m,:)),'Color','m','LineWidth',2,'Marker','o','MarkerFaceColor','m','MarkerSize',3,'Visible','off');
%     plot(cell2mat(a.daySummary.randBigLicksWater(m,:)),'Color','b','LineWidth',2,'Marker','o','MarkerFaceColor','b','MarkerSize',3,'Visible','off');
%     plot(cell2mat(a.daySummary.randSmallLicksWater(m,:)),'Color','c','LineWidth',2,'Marker','o','MarkerFaceColor','c','MarkerSize',3,'Visible','off');
%     plot(cell2mat(a.daySummary.CRewards(m,:)),'Color',cornflower,'LineWidth',2,'Marker','o','MarkerFaceColor',cornflower,'MarkerSize',3,'Visible','off');
%     plot(cell2mat(a.daySummary.DRewards(m,:)),'Color',cornflower,'LineWidth',2,'Marker','o','MarkerEdgeColor',cornflower,'MarkerSize',3,'LineStyle',':','Visible','off');
    ylabel({'Reward', 'Rate'});
    xlabel('Day');    
    leg = legend(ax,'Info','No Info','Choice','Location','southoutside','Orientation','horizontal');
    leg.Box = 'off';
    leg.FontWeight = 'bold';

%     leg = legend(ax,'Info Forced','Info Choice','No Info Forced','No Info Choice''Info-Rew','Info-No Rew','No Info - Rew','No Info - No Rew','No Info - C','No Info - D','Units','normalized','Position',[0.2 0.6 0.1 0.2],'Orientation','horizontal');
%     leg.Box = 'off';
%     leg.FontWeight = 'bold';

    hold off;

   
    saveas(fig,fullfile(pathname,a.mouseList{m}),'pdf');
%     close(fig);
    
end
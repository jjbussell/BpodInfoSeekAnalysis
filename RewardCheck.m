eventList = SessionData.EventNames;
for e = 1:numel(eventList)
    for t = 1:trialCt
        if isfield(events{t},(eventList{e}))
            allevents.(eventList{e}){t,1} = events{t}.(eventList{e});
    %                 b.(eventList{e}){t,2} = t;
    %                 b.(eventList{e}){t,3} = f;
        else
           allevents.(eventList{e}){t,1} = [];
    %                b.(eventList{e}){t,2} = t;
    %                b.(eventList{e}){t,3} = f; 
        end
    end
end
        
%% EXPAND EVENTS

eventsToExpand = {'GlobalTimer3_Start','GlobalTimer4_Start','GlobalTimer3_End','GlobalTimer4_End'};
% eventList = a.eventList;
eventList = eventsToExpand;

for e = 1:numel(eventList)

    eventname = eventList{e};
    event = allevents.(eventList{e});

    maxLength = max(cellfun(@numel,event));

    result=cellfun(@(x) [reshape(x,1,[]),NaN(1,maxLength-numel(x))],event,'UniformOutput',false);
    result2=vertcat(result{:});

%     statename='WaitForOdorLeft';
    eventsExpanded.(eventname) = result2;
    result = [];
    result2 = [];
end
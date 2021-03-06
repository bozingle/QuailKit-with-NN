% Algorithm developed by Farshad Bolouri
function [AnnotatedCalls,pos,TimeIntervals] = annotationsBBox(app)
TimeIntervals = cell(1,4);
pos = cell(1,4);
Calls = cell(1,4);
AnnotatedCalls = cell(1,4);

GT = dir(fullfile(app.dataPath,"GT"));
% Calcualte the current time interval (Online Mode)
if strcmp(app.ModeSwitch.Value,"Online")
    curtime = app.curLoadInterval*app.loadIntervalRate + app.curSubInterval*app.loadSubIntervalRate;
    time = curtime:1:(curtime+10);
end
%% Calculate the Positions
for i = 3 : 6
    Annotations = readmatrix(fullfile(app.dataPath,"GT",GT(i).name));
    TimeIntervals{i-2} = Annotations(:,5:8);
    
    if strcmp(app.ModeSwitch.Value,"Online")
        k =1;
        for j = 1 : size(TimeIntervals{i-2},1)
            if (TimeIntervals{i-2}(j,1) > time(1)) && (TimeIntervals{i-2}(j,1) < time(end))
                Calls{i-2}(k,:) = TimeIntervals{i-2}(j,:);
                k = k+1;
            end
        end
        
        if ~isempty(Calls{i-2})
            pos{i-2} = [Calls{i-2}(:,1) Calls{i-2}(:,3)...
                Calls{i-2}(:,2)-Calls{i-2}(:,1) ...
                Calls{i-2}(:,4)-Calls{i-2}(:,3)];
            
            AnnotatedCalls{i-2} = Calls{i-2}(:,1:2);
        end
        
        
    end
    
end

%% Drawing Bounding Boxes
if app.OffButton_2.Value == 1 && strcmp(app.ModeSwitch.Value,"Online")
    if ~isempty(pos{1})
        for row = 1:size(pos{1},1)
            rectangle(app.UIAxes,'Position',pos{1}(row,:),'EdgeColor','green','LineWidth',1.5)
        end
    end
    if ~isempty(pos{2})
        for row = 1:size(pos{2},1)
            rectangle(app.UIAxes_2,'Position',pos{2}(row,:),'EdgeColor','green','LineWidth',1.5)
        end
    end
    if ~isempty(pos{3})
        for row = 1:size(pos{3},1)
            rectangle(app.UIAxes_3,'Position',pos{3}(row,:),'EdgeColor','green','LineWidth',1.5)
        end
    end
    if ~isempty(pos{4})
        for row = 1:size(pos{4},1)
            rectangle(app.UIAxes_4,'Position',pos{4}(row,:),'EdgeColor','green','LineWidth',1.5)
        end
    end
end

end


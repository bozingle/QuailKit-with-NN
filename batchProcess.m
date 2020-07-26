function batchProcess(app)
    %% Batch Process
    matchedMatrix = [];
    CallsA = [];CallsB = [];CallsC = [];CallsD = [];
    app.curLoadInterval = 0; app.curSubInterval = 0;
    app.UpdateAudio(0);
    
    %Preallocate temps matrix
    temps = zeros(floor(app.Samples/app.loadSubIntervalRate),1);
    i = 1;
    while true && strcmp(app.ModeSwitch.Value,"Offline")
        [CallA,CallB,CallC,CallD] = QCallDetection(app);
        CallsA = [CallsA; CallA];CallsB = [CallsB; CallB];CallsC = [CallsC; CallC];CallsD = [CallsD; CallD];
        temps(i) = avg10sTemp(app.metPaths,app.loadIntervalRate*app.curLoadInterval+app.loadSubIntervalRate*app.curSubInterval);
        if (~isempty(CallA) + ~isempty(CallB) + ~isempty(CallC) + ~isempty(CallD))/4  >= 3/4
            matchedMatrix = [matchedMatrix GM_MatchCalls(CallA,CallB,CallC,CallD,GM_EstimateMaxTimeLag(readtable(app.metPaths(1)),...
                readtable(app.metPaths(2)),readtable(app.metPaths(3)),readtable(app.metPaths(4)),...
                temps(i)))];
        end
        totalSeconds = (app.curLoadInterval*app.loadIntervalRate + app.curSubInterval*app.loadSubIntervalRate) + 10;
        if totalSeconds*app.Fs < app.Samples && totalSeconds >= 0
            app.UpdateAudio(totalSeconds);
            app.NorecordingsloadedyetLabel.Text = "Batch Processing("+string(num2str(floor((totalSeconds*app.Fs/app.Samples)*10000)/100))+"/100%)";
            drawnow;
            i = i+1;
        else
            app.NorecordingsloadedyetLabel.Text = "Batch Processing("+string(num2str(floor((totalSeconds*app.Fs/app.Samples)*10000)/100))+"/100%)";
            drawnow;
            break;
        end
    end
    
    if strcmp(app.ModeSwitch.Value,"Offline")
        [localizations,c]= Localization(app, matchedMatrix,temps);
    end
    %% Record data   
    if strcmp(app.ModeSwitch.Value,"Offline")
        resultfile = fullfile(app.dataPath,"results.xlsx");
        
        T = {};
        T{1,2} = "Latitude"; 
        T{1,3} = "Longitude";
        for i = 2:size(app.micNames,2)+1
            T{i,1} = app.micNames(i-1);
            T{i,2} = app.micpos(i-1,1);
            T{i,3} = app.micpos(i-1,1);
        end
        writecell(T,resultfile,"Sheet","Microphone Positions(GPS)");
        
        T{1,2} = "Easting"; 
        T{1,3} = "Northing";
        micposUTM = ll2utm(app.micpos(:,1),app.micpos(:,2));
        for i = 2:size(app.micNames,2)+1
            T{i,2} = micposUTM(i-1,1);
            T{i,3} = micposUTM(i-1,1);
        end
        writecell(T,resultfile,"Sheet","Microphone Positions(UTM)");
        
        T = table(CallsA);
        T.Properties.VariableNames = "Time Detected";
        writetable(T,resultfile,"Sheet",app.micNames(1));
        T = table(CallsB);
        T.Properties.VariableNames = "Time Detected";
        writetable(T,resultfile,"Sheet",app.micNames(2));
        
        T = table(CallsC);
        T.Properties.VariableNames = "Time Detected";
        writetable(T,resultfile,"Sheet",app.micNames(3));
        
        T = table(CallsD);
        T.Properties.VariableNames = "Time Detected";
        writetable(T,resultfile,"Sheet",app.micNames(4));
        
        T = table((1:size(matchedMatrix,2))',matchedMatrix(1,:)',matchedMatrix(2,:)',matchedMatrix(3,:)',matchedMatrix(4,:)');
        T.Properties.VariableNames = ["Number Matched Call" {app.micNames(1);app.micNames(2);app.micNames(3);...
            app.micNames(4)}'];
        writetable(T,resultfile,"Sheet","matchedMatrix");
        
        T = table(localizations(:,1),localizations(:,2),localizations(:,3));
        T.Properties.VariableNames = ["Number Matched Call","Latitude", "Longitude"];
        writetable(T,resultfile,"Sheet","Localizations");
        
        %% Confusion Matrix
        [~,~,Annotated] = annotationsBBox(app);
        [TP,FP,FN] = confusionMat(Annotated,{CallsA,CallsB,CallsC,CallsD});
        T = table({app.micNames(1);app.micNames(2);app.micNames(3);...
            app.micNames(4)},TP',FP',FN','VariableNames',{'Microphones',...
            'TP','FP','FN'});
        writetable(T,resultfile,"Sheet","ConfusionMatrix");
    end
end
function avgTemp = avg10sTemp(metPaths, tensInterval)
    %Preallocate the array
    mictempavgs = zeros(1,4);
    
    % Iterate through metadata filepaths.
    for i = 1:length(metPaths)
        %Read data in
        metadata = readtable(metPaths(i));
        
        %Format time values
        times = str2double(split(string(metadata.TIME), ':'));
        times = 60^2*(times(:,1) - times(1,1)) + 60*(times(:,2)-times(1,2)) + times(:,3)-times(1,3);
        
        %Find the time indexes that concern us
        timedif = times - tensInterval;
        indices = intersect(find(timedif >= 0),find(timedif <= 10));
        
        %Average the temps
        mictempavg = mean(metadata.TEMP_C_(indices));
        
        %Append average to the avgs matrix
        mictempavgs(i) = mictempavg;
    end
    
    %Return full temp average
    avgTemp = mean(mictempavgs);
end
function batchProcess(app)
    %% Batch Process
    matchedMatrix = [];
    CallsA = [];CallsB = [];CallsC = [];CallsD = [];
    app.curLoadInterval = 0; app.curSubInterval = 0;
    app.UpdateAudio(0);
    while true
        [CallA,CallB,CallC,CallD] = QCallDetection(app);
        CallsA = [CallsA; CallA];CallsB = [CallsB; CallB];CallsC = [CallsC; CallC];CallsD = [CallsD; CallD];
        if (~isempty(CallA) + ~isempty(CallB) + ~isempty(CallC) + ~isempty(CallD))/4  >= 3/4
            matchedMatrix = [matchedMatrix GM_MatchCalls(CallA,CallB,CallC,CallD,GM_EstimateMaxTimeLag(readtable(app.metPaths(1)),...
                               readtable(app.metPaths(2)),readtable(app.metPaths(3)),readtable(app.metPaths(4))))];
        end
        totalSeconds = (app.curLoadInterval*app.loadIntervalRate + app.curSubInterval*app.loadSubIntervalRate) + 10;
        if totalSeconds <= app.Samples/app.Fs && totalSeconds >= 0
            app.UpdateAudio(totalSeconds);
            app.NorecordingsloadedyetLabel.Text = "Batch Processing("+string(num2str(floor((totalSeconds*app.Fs/app.Samples)*10000)/100))+"/100%)";
            drawnow;
        else
            break;
        end
    end
    localizations = Localization(app, matchedMatrix);

    %% Record data
    micNames = [];
    for i = 1:size(app.micPaths,2)
        temp = split(string(app.micPaths(i).name), '_');
        micNames = [micNames temp(1)];
    end
    
    resultfile = fullfile(app.dataPath,"results.xlsx");
    T = table(CallsA);
    T.Properties.VariableNames = "Time Detected";
    writetable(T,resultfile,"Sheet",micNames{1});
    T = table(CallsB);
    T.Properties.VariableNames = "Time Detected";
    writetable(T,resultfile,"Sheet",micNames{2});

    T = table(CallsC);
    T.Properties.VariableNames = "Time Detected";
    writetable(T,resultfile,"Sheet",micNames{3});

    T = table(CallsD);
    T.Properties.VariableNames = "Time Detected";
    writetable(T,resultfile,"Sheet",micNames{4});
    
    T = table((1:size(matchedMatrix,2))',matchedMatrix(1,:)',matchedMatrix(2,:)',matchedMatrix(3,:)',matchedMatrix(4,:)');
    T.Properties.VariableNames = ["Number Matched Call" micNames];
    writetable(T,resultfile,"Sheet","matchedMatrix");
    
    T = table(localizations(:,1),localizations(:,2),localizations(:,3));
    T.Properties.VariableNames = ["Number Matched Call","Latitude", "Longitude"];
    writetable(T,resultfile,"Sheet","Localizations");
end
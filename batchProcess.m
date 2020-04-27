function batchProcess(app)
    matchedMatrix = [];
    CallsA = [];CallsB = [];CallsC = [];CallsD = [];
    app.curLoadInterval = 0; app.curSubInterval = 0;
    app.Spectrograms = FBspectrogram(app);
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
        else
            break;
        end
    end
    localizations = Localization(app, matchedMatrix);
end
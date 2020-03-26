function app=HTdataAccess(app,mode)
    mode = lower(mode);
    if strcmp(mode, "write")
        app = Write(app);
    elseif strcmp(mode, "read")
        app = Read(app);
    end
end

function Write(handles)
    handles.Path.Spectrograms = fullfile(handles.Path.Recordings, handles.RecordingSelected,"Spectrogram");
    mkdir(handles.Path.Spectrograms);
    Mics=handles.MicDataList{2,2};
    activeMics=find([Mics{:,2}]);
    for k=activeMics
        S=handles.Data.S(:,:,k);
        F=handles.Data.F;
        t=handles.Data.t(k,:);
        micName = split(string(Mics{k,3}),".");
        micName = micName(1);
        save(fullfile(handles.Path.Spectrograms,micName+".mat"),'S','F','t');
    end
end
%Returns TimeSeries of data from chosen directory.
%If 4 audio files couldn't be found, this will return NaN.
function val = Read(app)

    if isempty(app.micPaths)
        mics = dir(fullfile(app.dataPath,"Mics"));
        % Attempt
        % mics = struct2cell(mics)';
        % mics = mics(:,1);

        %Quick and dirty for now.
        micPaths = [];
        for i = 1:length(mics)
            micName = split(convertCharsToStrings(mics(i).name), "__");
            micName = micName(1);
            ext = split(micName, '.');
            ext = ext(end);
            if micName ~= '.' && micName ~= '..' && ext ~= 'txt'
               micPaths = [micPaths mics(i)];
            end
        end
        app.micPaths = micPaths;
    end
    
    if length(app.micPaths) >= 4
        
        if isempty(app.TS)
            info=audioinfo(fullfile(app.dataPath,'Mics',app.micPaths(1).name));
            minSamples = info.TotalSamples;
            fs=info.SampleRate;
            for k=2:size(app.micPaths,2)
                info=audioinfo(fullfile(app.dataPath,'Mics',app.micPaths(k).name));
                minSamples = min(minSamples,info.TotalSamples);
            end
            
            app.Samples = minSamples;
            namespl = split(app.micPaths(1).name,["__","_","$","."]);
            app.Date = namespl(3)+" "+namespl(4);
            app.Date =datetime(app.Date,'InputFormat','yyyyMMdd HHmmss');
            ts=timeseries(zeros(app.loadIntervalRate*fs,2));
            app.TS =setuniformtime(ts,'StartTime',0,...
                'Interval',1/fs);
            app.TS.TimeInfo.StartDate=app.Date;
            app.Fs = fs;
            
            app.curLoadInterval = 0;
            app.curSubInterval = 0;
            
            app.initialLoadInterval = [1 app.Fs*app.loadIntervalRate];
            app.initialSubInterval = [1 app.Fs*app.loadSubIntervalRate];
            
            if app.initialLoadInterval(2) <= app.Samples
                app.loadInterval = app.initialLoadInterval;
            else
                app.loadInterval = [1 app.audioSamples];
            end
            app.subInterval = app.initialSubInterval;
            
            app.SubSamples = app.subInterval(2)*app.loadIntervalRate/app.loadSubIntervalRate;
        else
            app.TS=setuniformtime(app.TS,'StartTime',0,'Interval',1/app.Fs);
            app.TS.Time = app.TS.Time+(app.curLoadInterval-1)*app.loadIntervalRate;
        end
        
        app.AudioFilePlay = [];
%         app.AudioSignal = [];
        for k=1:size(app.micPaths,2)
            [raw,~]=audioread(fullfile(app.dataPath,'Mics',app.micPaths(k).name),app.loadInterval);
%             app.audioSamples(1:length(raw),2*k-1:2*k)= raw;
            
%            handles.Data.TS.Data(1:size(raw,1),k)=zscore(raw(:,handles.AudioChannel)); 
%             Fn = app.Fs/2;
%             Wp = 1000/Fn;
%             Ws = 3000/Fn;
%             raw = bandpass(raw,[Wp,Ws]);
            app.AudioFilePlay(1:size(raw,1),k) = (raw(:,1) + raw(:,2))/2;
            %app.AudioSignal(1:size(raw,1),k) = zscore(raw(:,1)) + zscore(raw(:,2));
        end

        
    else
        app.audioSamples = NaN;
    end

    val = app;
end
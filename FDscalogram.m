function Y = FDscalogram(app)
% Ave = cell(1,4);% t= cell(1,4);
% Channels = cell(2,4);

% Directories to save scalogram images and corresponding audio segments
micDir = fullfile(app.dataPath,"Data\",app.micNames,"Scalograms");
for m = 1:4
    mkdir(micDir(m));
end
filePath= {" "};
time1 = 0;
time2 = 2;
scalogramsTable = table(filePath,time1,time2);
scalogramsTable(1,:) = [];
T = table(filePath,time1,time2);
% audioDir = fullfile(dataPath,"AudioFiles\");
% mkdir(audioDir);

% Duration = bits / bps
%signal = app.AudioChannel{1};
%dur=length(signal(:,1))/app.Fs;

% Frequency Window and octaves
frequencyLimits=[1000 3200];
voicesPerOctave = 8;

%Time window and overlap in seconds
window = 2;
overlap = 1;
startingTime = app.curLoadInterval*app.loadIntervalRate + app.curSubInterval*app.loadSubIntervalRate;

if (strcmp(app.ModeSwitch.Value,"Offline") && strcmp(app.BatchProcessingTypeSwitch.Value, "Parallel"))
    
    %---------------Parallel Variables----------------
    Audio = app.AudioChannel;
    Fs = app.Fs;
    dur = app.loadIntervalRate;
    T = cell(1,4);
    %-------------------------------------------------
    
    parfor i = 1:size(Audio{1},2)

        x = [Audio{1}(:,i) Audio{2}(:,i)];
        T{i} = table(filePath,time1,time2);
        T{i}(1,:) = [];
        if window <= length(x)
            
            T{i} = generateScalograms(x, micDir(i), window,...
                overlap, frequencyLimits, voicesPerOctave, dur, Fs, i,...
                startingTime, T{i});
            
        end   
        
    end
    scalogramsTable = [scalogramsTable; T{1}; T{2}; T{3}; T{4}];
    
else
    for i = 1:size(app.AudioChannel{1},2)
        dur = 10;
        T(:,:) = [];
        try
            x = [app.AudioChannel{1}(app.subInterval(1):app.subInterval(2),i) ...
                app.AudioChannel{2}(app.subInterval(1):app.subInterval(2),i)];
        catch e
            x = [app.AudioChannel{1}(app.subInterval(1):end,i) ...
                app.AudioChannel{2}(app.subInterval(1):end,i)];
        end
        
        
        if window <= length(x)
            
            T = generateScalograms(x, micDir(i), window,...
                overlap, frequencyLimits, voicesPerOctave, dur, app.Fs, i,...
                startingTime, T);
            
        end
        
        scalogramsTable = [scalogramsTable; T];
    end
    
end
writetable(scalogramsTable, fullfile(app.dataPath,"Data\ScalogramsPath.txt"));
end

function T = generateScalograms(signal, scaloDir, window, overlap,...
    frequencyLimits, voicesPerOctave, dur, Fs, Mic, startingTime, T)
 
for k = 0.0001:overlap:dur+overlap
    set(gca, 'Visible', 'off');
    set(gca,'LooseInset',get(gca,'TightInset'));
    colorbar('off');
    X=signal((k*Fs):((k+window)*Fs));
    
    N=length(X);
    tquail=0:1/Fs:N/Fs-1/Fs;
    
    hold on
    
    xs=sort(X);
    mo=xs(1);
    for n=1:N
        mna(n)=mo+((1/n)*(xs(n)-mo));
        mo=mna(n);
    end
    
    xs=sort(X,'descend');
    mo=xs(1);
    for n=1:N
        mnd(n)=mo+((1/n)*(xs(n)-mo));
        mo=mnd(n);
    end
    
%     sorx=sort(X);
%     sigx=[mna flip(mnd)];

    t1 = datestr(seconds(k + startingTime),'HH-MM-SS');
    t2 = datestr(seconds(k + startingTime + window),'HH-MM-SS');
    
    title = strcat('Mic', int2str(Mic), '_From_', t1, '_to_', t2);
    frequencyLimits(1) = max(frequencyLimits(1),...
        cwtfreqbounds(numel(X),Fs));
    [WT,F] = cwt(X,Fs,'VoicesPerOctave',...
        voicesPerOctave,'FrequencyLimits',frequencyLimits);
    surf(tquail, F, abs(WT).^2,'edgecolor','none');
    view(0,90);
    axis tight;
    shading interp; colormap(parula(128));
    h = gcf;
    set(h, 'Visible', 'off');
    set(h,'color', 'none');
    filename=strcat(scaloDir,'\',title,'.png');
    
    % Save scalogram image
    exportgraphics(h,filename,'BackgroundColor','none','Resolution',300)
    T = [T; {filename, t1, t2}];
% %     filename=strcat(audioDir,title,'.wav');
% %     
% %     % Save audio segment
% %     audiowrite(filename,X,Fs)
%     close all
end

end
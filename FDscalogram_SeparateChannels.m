function scaloDir = FDscalogram(app)
% Ave = cell(1,4);% t= cell(1,4);
% Channels = cell(2,4);

% Directories to save scalogram images and corresponding audio segments
scaloDir = fullfile(app.dataPath,"Scalograms\");
mkdir(scaloDir);
% audioDir = fullfile(dataPath,"AudioFiles\");
% mkdir(audioDir);

% Duration = bits / bps
signal = app.AudioChannel{1};
%dur=length(signal(:,1))/app.Fs;

% Frequency Window and octaves
frequencyLimits=[1000 3200];
voicesPerOctave = 8;

%Time window and overlap in seconds
window = 2;
overlap = 1;

if (strcmp(app.ModeSwitch.Value,"Offline") && strcmp(app.BatchProcessingTypeSwitch.Value, "Parallel"))
    
    %---------------Parallel Variables----------------
    Audio = app.AudioChannel;
    Fs = app.Fs;
    Audio_1 = Audio{1};
    Audio_2 = Audio{2};
    %-------------------------------------------------
    
    parfor i = 1:size(Audio_1,2)
        
        dur = app.loadIntervalRate;
        
        for j = 1:2
            if j == 1
                if window <= length(Audio_1(:,i))

                    generateScalograms(Audio_1(:,i), scaloDir, window,...
                        overlap, frequencyLimits, voicesPerOctave, dur, Fs, i, j);
                    
                end
            else
                if window <= length(Audio_2(:,i))

                    generateScalograms(Audio_2(:,i), scaloDir, window,...
                        overlap, frequencyLimits, voicesPerOctave, dur, Fs, i, j);
                    
                end
            end
        end
        
    end
else
    for i = 1:size(app.AudioChannel{1},2)
        dur = 10;
        for j = 1:2
            
            try
                x = app.AudioChannel{j}(app.subInterval(1):app.subInterval(2),i);
            catch e
                x = app.AudioChannel{j}(app.subInterval(1):end,i);
            end
            
            
            if window <= length(x)
                
                generateScalograms(x, scaloDir, window,...
                    overlap, frequencyLimits, voicesPerOctave, dur, app.Fs, i, j);
                
            end
            

        end
        
    end
end

end

function Y = generateScalograms(signal, scaloDir, window, overlap,...
    frequencyLimits, voicesPerOctave, dur, Fs, Mic, Channel)
i = 1;
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

    t1 = datestr(seconds(k),'HH-MM-SS');
    t2 = datestr(seconds(k+window),'HH-MM-SS');
    
    title = strcat('Mic', int2str(Mic), '_Channel_', int2str(Channel), '_From_', t1, '_to_', t2);
    frequencyLimits(1) = max(frequencyLimits(1),...
        cwtfreqbounds(numel(X),Fs));
    [WT,F] = cwt(X,Fs,'VoicesPerOctave',...
        voicesPerOctave,'FrequencyLimits',frequencyLimits);
    helperCWTTimeFreqPlot(WT,tquail,F,'surf',...
        title,'Time(s)','Hz')
    
    h = gcf;
    set(h, 'Visible', 'off');
    filename=strcat(scaloDir,title,'.png');
    
    % Save scalogram image
    exportgraphics(h,filename,'BackgroundColor','none','Resolution',300)
    
%     filename=strcat(audioDir,title,'.wav');
%     
%     % Save audio segment
%     audiowrite(filename,X,Fs)
    close all
    i = i+1;
end

end
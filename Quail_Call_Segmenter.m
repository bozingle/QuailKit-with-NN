clear
close all
clc

% Settings for scalogram image output
set(gca, 'Visible', 'off');
set(gca,'LooseInset',get(gca,'TightInset'));
colorbar('off');

% Directories to save scalogram images and corresponding audio segments
scaloDir='C:\Users\Joel\Desktop\Scalogram_Generation\Scalograms';
audioDir='C:\Users\Joel\Desktop\Scalogram_Generation\audiofiles';

% Read recording file
[signal,samplerate]=audioread('C:\Users\Joel\Desktop\AVL Work\RecordData\10_00\Mics\SM304472_0+1_20181219_100000.wav');

% Duration = bits / bps
dur=length(signal)/samplerate;

% Frequency Window and octaves
frequencyLimits=[1000 3200];
voicesPerOctave = 8;

%Time window and overlap in seconds
window = 2;
overlap = 1;

for k = 0.0001:overlap:dur+overlap
    set(gca, 'Visible', 'off');
    set(gca,'LooseInset',get(gca,'TightInset'));
    colorbar('off');
    X=signal((k*samplerate):((k+window)*samplerate));
   
    N=length(X);
    tquail=0:1/samplerate:N/samplerate-1/samplerate;

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
    
    sorx=sort(X);
    sigx=[mna flip(mnd)];

    t1 = datestr(seconds(k),'HH-MM-SS');
    t2 = datestr(seconds(k+window),'HH-MM-SS');
    
    title = strcat(t1,"_to_",t2);
    frequencyLimits(1) = max(frequencyLimits(1),...
        cwtfreqbounds(numel(X),samplerate));
    [WT,F] = cwt(X,samplerate,'VoicesPerOctave',...
        voicesPerOctave,'FrequencyLimits',frequencyLimits);
    helperCWTTimeFreqPlot(WT,tquail,F,'surf',...
        title,'Time(s)','Hz')
    
    h = gcf;
    set(h, 'Visible', 'off');
    filename=strcat(scaloDir,title,'.png');
    
    % Save scalogram image
    exportgraphics(h,filename,'BackgroundColor','none','Resolution',300)
    
    filename=strcat(audioDir,title,'.wav');
    
    % Save audio segment
    audiowrite(filename,X,samplerate)
    close all
    
end

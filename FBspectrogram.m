function [s,t] = FBspectrogram(app)

s = cell(1,4); t= cell(1,4);
row= [1,3,5,7];
for i = 1:4
%[s{i},~,t{i}] = spectrogram(app.AudioFilePlay(app.subInterval(1):...
%    app.subInterval(2),i),app.wind,app.noverlap,app.F,app.Fs);

x1 = app.audioSamples(app.subInterval(1):app.subInterval(2),row(i));
x2 = app.audioSamples(app.subInterval(1):app.subInterval(2),row(i)+1);
    
[s1,~,t{i}] = spectrogram(x1,app.wind,app.noverlap,app.F,app.Fs);
[s2,~,t{i}] = spectrogram(x2,app.wind,app.noverlap,app.F,app.Fs);
s{i} = s1 +s2;
s{i}= db(abs(s{i}));


%Here we should add the 10s that we are in to "t"
%            t=t-t(1)+app.TS.Time(app.subInterval(1):app.subInterval(2));

T = t{i};

t{i} = t{i}-T(1);


%f = 1+max(max(s))*[1,1];
end
imagesc(app.UIAxes,t{1},app.F,s{1})
imagesc(app.UIAxes_2,t{2},app.F,s{2})
imagesc(app.UIAxes_3,t{3},app.F,s{3})
imagesc(app.UIAxes_4,t{4},app.F,s{4})
end
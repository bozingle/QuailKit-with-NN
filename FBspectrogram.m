function s = FBspectrogram(app)

s = cell(1,4);% t= cell(1,4);
row= [1,3,5,7];


for i = 1:4
    
x = (app.audioSamples(app.subInterval(1):app.subInterval(2),row(i)) + ...
    app.audioSamples(app.subInterval(1):app.subInterval(2),row(i)+1))/2;
window = app.Fs*app.window_size;
noverlap = round(app.noverlap_size*window);
s{i} = spectrogram(x,window,noverlap,app.F,app.Fs);

s{i}= abs(s{i});
s{i} = s{i}(50:end,:);

% T = t{i};
% t{i} = t{i}-T(1);

end
time = app.TS.Time(app.subInterval(1):app.subInterval(2));
imagesc(app.UIAxes,time,app.F,s{1})
imagesc(app.UIAxes_2,time,app.F,s{2})
imagesc(app.UIAxes_3,time,app.F,s{3})
imagesc(app.UIAxes_4,time,app.F,s{4})
app.UIAxes.YDir = 'normal'; app.UIAxes.XLim = [time(1),time(end)];
app.UIAxes_2.YDir = 'normal'; app.UIAxes_2.XLim = [time(1),time(end)];
app.UIAxes_3.YDir = 'normal'; app.UIAxes_3.XLim = [time(1),time(end)];
app.UIAxes_4.YDir = 'normal'; app.UIAxes_4.XLim = [time(1),time(end)];

end
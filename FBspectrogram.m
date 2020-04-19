function s = FBspectrogram(app)

s = cell(1,4);% t= cell(1,4);
%column= [1,3,5,7];


for i = 1:4
    
%x = (app.audioSamples(app.subInterval(1):app.subInterval(2),column(i)) + ...
%   app.audioSamples(app.subInterval(1):app.subInterval(2),column(i)+1))/2;
x= app.AudioFilePlay(app.subInterval(1):app.subInterval(2),i);
window = app.Fs*app.window_size;
noverlap = round(app.noverlap_size*window);
s{i} = spectrogram(x,window,noverlap,app.F,app.Fs);

s{i}= mat2gray(abs(s{i}));

end

curtime = app.curLoadInterval*app.loadIntervalRate + app.curSubInterval*app.loadSubIntervalRate;
time = curtime:1:(curtime+10);
timestr = app.convertToRealTime(time);

imagesc(app.UIAxes,time,app.F,s{1})
imagesc(app.UIAxes_2,time,app.F,s{2})
imagesc(app.UIAxes_3,time,app.F,s{3})
imagesc(app.UIAxes_4,time,app.F,s{4})

app.UIAxes.YDir = 'normal'; app.UIAxes.XLim = [time(1),time(end)];
app.UIAxes_2.YDir = 'normal'; app.UIAxes_2.XLim = [time(1),time(end)];
app.UIAxes_3.YDir = 'normal'; app.UIAxes_3.XLim = [time(1),time(end)];
app.UIAxes_4.YDir = 'normal'; app.UIAxes_4.XLim = [time(1),time(end)];
app.UIAxes.YLim = [app.F(1),app.F(end)]; app.UIAxes.XTickLabel = timestr;
app.UIAxes_2.YLim = [app.F(1),app.F(end)]; app.UIAxes_2.XTickLabel = timestr;
app.UIAxes_3.YLim = [app.F(1),app.F(end)]; app.UIAxes_3.XTickLabel = timestr;
app.UIAxes_4.YLim = [app.F(1),app.F(end)]; app.UIAxes_4.XTickLabel = timestr;

end
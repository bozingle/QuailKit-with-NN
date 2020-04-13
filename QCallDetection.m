%Algorithm written by Golnaz Moallem - Modified by Farshad Bolouri to
%adjust to the software
function Calls = QCallDetection(app)
Calls = [];
pos = cell(1,4);
curtime = app.curLoadInterval*app.loadIntervalRate + app.curSubInterval*app.loadSubIntervalRate;
time = curtime:1:(curtime+10);
%% Template Reading
template=double(imread('template_combined_real_bird.jpg'));
%temp_width=size(template,1);
temp_length=size(template,2);
%figure;imshow(template,[])
%title('Template')
%% Quail Call Detection
for i = 1:4
    Calls = [];
    spec_len=size(app.Spectrograms{i},2);
    spec_width=size(app.Spectrograms{i},1);
    
    spec_seg_size=ceil(spec_len/10);
    
    call_candidates=[];
    call_locations=[];
    no_seg=ceil(spec_len/spec_seg_size)*2-1;
    for s=1:no_seg
        spec_seg=app.Spectrograms{i}(100:end-100,(s-1)*...
            ceil(spec_seg_size/2)+1:min((s-1)*ceil(spec_seg_size/2)+1+spec_seg_size,spec_len));
        
        cc=xcorr2(spec_seg,template);
        cc_signal=mat2gray(max(cc)-mean(cc));
        TF = islocalmax(cc_signal,'MinProminence',0.2,'ProminenceWindow',temp_length/2);
        locs=find(TF);
        call=(((s-1)*ceil(spec_seg_size/2)+1)+locs)';
        call_candidates=[call_candidates;call];
        %         figure;imshow(spec_seg)
        %         x=1:length(cc_signal);
        %         figure;plot(x,cc_signal,x(TF),cc_signal(TF),'r*')
        %         waitforbuttonpress;
        
    end
    if ~isempty(call_candidates)
        if length(call_candidates)>1
            [L,n]=bwlabel(squareform(pdist(call_candidates))<temp_length/2,4);
            for k=1:n
                [rows,~]=find(L==k);
                rows=unique(rows);
                spec_seg=app.Spectrograms{i}(100:end-100,max(call_candidates(min(rows))-temp_length,1):min(call_candidates(min(rows)),spec_len));
                
                cc=xcorr2(spec_seg,template);
                cc_signal=mat2gray(max(cc)-mean(cc));
                
                
                TF = islocalmax(cc_signal,'MinProminence',0.3,'ProminenceWindow',temp_length/2);
                locs=find(TF);
                %                 figure;imshow(spec_seg)
                %                 x=1:length(cc_signal);
                %                 figure;plot(x,cc_signal,x(TF),cc_signal(TF),'r*')
                %                 waitforbuttonpress;
                
                call=(time(1)+(10/spec_len)*(call_candidates(min(rows))+locs-floor(temp_length/2)))';
                Calls=[Calls;call];
                %call_locations=[call_locations;max(call_candidates(min(rows))-ceil(spec_seg_size/2),1)+locs'];
            end
        else
            spec_seg=app.Spectrograms{i}(100:end-100,max(call_candidates(1)-temp_length,1):min(call_candidates(1),spec_len));
            
            cc=xcorr2(spec_seg,template);
            cc_signal=mat2gray(max(cc)-mean(cc));
            
            
            TF = islocalmax(cc_signal,'MinProminence',0.3,'ProminenceWindow',temp_length/2);
            locs=find(TF);
            %             figure;imshow(spec_seg)
            %             x=1:length(cc_signal);
            %             figure;plot(x,cc_signal,x(TF),cc_signal(TF),'r*')
            %                 waitforbuttonpress;
            
            call=(time(1)+(10/spec_len)*(call_candidates(1)+locs-floor(temp_length/2)))';
            Calls=[Calls;call];
            %call_locations=[call_locations;max(call_candidates(1)-ceil(spec_seg_size/2),1)+locs'];
        end
    end
    
    pos{i} = [Calls-0.75 1200*ones(length(Calls),1) ...
        0.5*ones(length(Calls),1) 1900*ones(length(Calls),1)];
    
end
%% Drawing Bounding Boxes
for row = 1:size(pos{1},1)
    rectangle(app.UIAxes,'Position',pos{1}(row,:),'EdgeColor','red')
end
for row = 1:size(pos{2},1)
    rectangle(app.UIAxes_2,'Position',pos{2}(row,:),'EdgeColor','red')
end
for row = 1:size(pos{3},1)
    rectangle(app.UIAxes_3,'Position',pos{3}(row,:),'EdgeColor','red')
end
for row = 1:size(pos{4},1)
    rectangle(app.UIAxes_4,'Position',pos{4}(row,:),'EdgeColor','red')
end

end


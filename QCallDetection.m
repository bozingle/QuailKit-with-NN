%Algorithm written by Golnaz Moallem - Modified by Farshad Bolouri to
%adjust to the software
function [CallA,CallB,CallC,CallD] = QCallDetection(app)
Calls = cell(1,4);
pos = cell(1,4);
curtime = app.curLoadInterval*app.loadIntervalRate + app.curSubInterval*app.loadSubIntervalRate;
time = curtime:1:(curtime+10);
%% Template Reading
template=mat2gray(double(imread('template_combined_real_bird_2.jpg')));
temp_width=size(template,1);
temp_length=size(template,2);
spec_duration = 10;
%figure;imshow(template,[])
%title('Template')
%% Quail Call Detection
for i = 1:4
    Ispec= app.Spectrograms{i};
    spec_len=size(Ispec,2);
    spec_width=size(Ispec,1);
    %     figure();imshow(Ispec)
    
    band=round((spec_width-temp_width)/3);
    spec_seg_size=ceil(spec_len/30);
    
    call_candidates=[];
    %call_locations=[];
    no_seg=ceil(spec_len/spec_seg_size)*2-1;
    for s=1:no_seg
        spec_seg=Ispec(band:end-band,(s-1)*ceil(spec_seg_size/2)+1:min((s-1)*ceil(spec_seg_size/2)+1+spec_seg_size,spec_len));
        
        cc=xcorr2(spec_seg,template);
        cc_signal=mat2gray(max(cc));
        cc_signal=cc_signal(round(temp_length/2)-1:end-round(temp_length/2));
        
        TF = islocalmax(cc_signal,'MinProminence',0.25,'ProminenceWindow',temp_length/2);
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
                spec_seg=Ispec(band:end-band,max(call_candidates(min(rows))-...
                    round(temp_length/2),1):min(call_candidates(min(rows))+round(temp_length/2),spec_len));
                
                cc=xcorr2(spec_seg,template);
                cc_signal=mat2gray(max(cc));
                cc_signal=cc_signal(round(temp_length/2)-1:end-round(temp_length/2));
                
                TF = islocalmax(cc_signal,'MinProminence',0.25,'ProminenceWindow',temp_length/2);
                location=find(TF);
                
                if call_candidates(min(rows)) <round(temp_length/2)
                    call=(time(1)+(spec_duration/spec_len)*location);
                    Calls{i}=[Calls{i};call'];
                    %call_locations=[call_locations;location'];
                else
                    call=(time(1)+(spec_duration/spec_len)*(call_candidates(min(rows))+location-round(temp_length/2)));
                    Calls{i}=[Calls{i};call'];
                    %call_locations=[call_locations;call_candidates(min(rows))+location'-round(temp_length/2)];
                end
                
                %                 figure;imshow(spec_seg)
                %                 x=1:length(cc_signal);
                %                 figure;plot(x,cc_signal,x(TF),cc_signal(TF),'r*')
                %                 waitforbuttonpress;
            end
        else
            spec_seg=Ispec(band:end-band,max(call_candidates(1)-round(temp_length/2),1):min(call_candidates(1)+round(temp_length/2),spec_len));
            
            cc=xcorr2(spec_seg,template);
            cc_signal=mat2gray(max(cc));
            cc_signal=cc_signal(round(temp_length/2)-1:end-round(temp_length/2));
            
            
            TF = islocalmax(cc_signal,'MinProminence',0.25,'ProminenceWindow',temp_length/2);
            location=find(TF);
            
            if call_candidates(1) <round(temp_length/2)
                call=(time(1)+(spec_duration/spec_len)*location)';
                Calls{i}=[Calls{i};call'];
                %call_locations=[call_locations;location'];
            else
                call=(time(1)+(spec_duration/spec_len)*(call_candidates(1)+location-round(temp_length/2)));
                Calls{i}=[Calls{i};call'];
                %call_locations=[call_locations;max(call_candidates(1)+location'-round(temp_length/2),1)];
            end
            
            %             figure;imshow(spec_seg)
            %             x=1:length(cc_signal);
            %             figure;plot(x,cc_signal,x(TF),cc_signal(TF),'r*')
            %             waitforbuttonpress;
        end
    end
    
    % For Drawing Bounding Boxes
    %pos{i} = [Calls{i} 1200*ones(length(Calls{i}),1) ...
    %    0.5*ones(length(Calls{i}),1) 1900*ones(length(Calls{i}),1)];
    
end
%% Place Call Times into corresponding variables
CallA = Calls{1};
CallA(find(CallA==0)) = [];
CallB = Calls{2};
CallB(find(CallB==0)) = [];
CallC = Calls{3};
CallC(find(CallC==0)) = [];
CallD = Calls{4};
CallD(find(CallD==0)) = [];
 %% Drawing Lines on Calls
 if app.OffButton.Value == 1 && strcmp(app.ModeSwitch.Value,"Online")
     for row = 1:size(Calls{1},1)
         line(app.UIAxes,Calls{1}(row,:)*ones(1,length(app.F)),app.F,'Color','red','LineWidth',1.5);
     end
     for row = 1:size(Calls{2},1)
         line(app.UIAxes_2,Calls{2}(row,:)*ones(1,length(app.F)),app.F,'Color','red','LineWidth',1.5);
     end
     for row = 1:size(Calls{3},1)
         line(app.UIAxes_3,Calls{3}(row,:)*ones(1,length(app.F)),app.F,'Color','red','LineWidth',1.5);
     end
     for row = 1:size(Calls{4},1)
         line(app.UIAxes_4,Calls{4}(row,:)*ones(1,length(app.F)),app.F,'Color','red','LineWidth',1.5);
     end
 end

end
 %% Drawing Bounding Boxes
% for row = 1:size(pos{1},1)
%     rectangle(app.UIAxes,'Position',pos{1}(row,:),'EdgeColor','red')
% end
% for row = 1:size(pos{2},1)
%     rectangle(app.UIAxes_2,'Position',pos{2}(row,:),'EdgeColor','red')
% end
% for row = 1:size(pos{3},1)
%     rectangle(app.UIAxes_3,'Position',pos{3}(row,:),'EdgeColor','red')
% end
% for row = 1:size(pos{4},1)
%     rectangle(app.UIAxes_4,'Position',pos{4}(row,:),'EdgeColor','red')
% end
% 
% end


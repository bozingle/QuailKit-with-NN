%% New with excel
function S = Localization(app, matchedMatrix)
    %Instantiations
    filename = fullfile(pwd,"S2 Sound Finder for Spreadsheets.xls");
    numCalls = size(matchedMatrix,2);
    
    matchedMatrix(matchedMatrix == 0) = NaN;
    lagMatrix = getLagMatrix(matchedMatrix);
    writematrix(lagMatrix',filename,"Sheet","sound","Range","C4:F"+num2str(4+numCalls));
    
    timeVals = mean(matchedMatrix',2,'omitnan');
    temps = avg10sTemp(app,app.metPaths, floor(timeVals(1)/10)*10,nan)*ones(numCalls,1);
    writematrix(temps,filename,"Sheet","sound","Range","B4:B"+num2str(4+numCalls));
    
    %Microphone locations
    micUTMpos = ll2utm(app.micpos(:,1),app.micpos(:,2));
    writematrix(micUTMpos,filename,'Sheet', 'mic', 'Range',"B3:C"+num2str(3+size(app.micpos,1)));
    
    % .. iterate or batch process?
    %Preallocate array and open Excel
    S = [];
    
    Excel = actxserver('Excel.Application');
    incnum = 1;
    for i = 1:size(lagMatrix,2)
        %Write current localization to sheet
        writematrix(i,filename,'Sheet','prep','Range','B1');
        
        %Open and close to make the calculations
        workbook = Excel.Workbooks.Open(filename);
        workbook.Save;
        workbook.Close;
        
        %Write solution into S
        soln = readmatrix(filename,'Sheet','find2D','Range','Q23:Q24')';
        if ~isempty(soln) && ~isnan(soln(1))
            S(incnum,:) = [i incnum soln];
            incnum = incnum + 1;
        end
        
    end
    Excel.Quit;
    if ~isempty(S)
        S(:,3:4) = utm2ll(S(:,3),S(:,4), ones(size(S,1),1)*14);
    end
end

function avgTemp = avg10sTemp(app,metPaths, tensInterval, prevTempVal)
    %Preallocate the array
    mictempavgs = zeros(1,4);
    
    % Iterate through metadata filepaths.
    for i = 1:length(metPaths)
        %Read data in
        metadata = readtable(metPaths(i));
        
        %Format time values
        times = str2double(split(string(metadata.TIME), ':'));
        
        if size(times,2) == 1
            times = times';
        end
        
        timeindices = intersect(find((metadata.DATE+metadata.TIME - app.Date) <= duration(24,0,0)- duration(app.Date.Hour,0,0)),...
            find((metadata.DATE+metadata.TIME - app.Date) >= 0));
        times = times(timeindices,:);
        
        temps = [];
        if ~isempty(times)
            times = 60^2*(times(:,1) - times(1,1)) + 60*(times(:,2)-times(1,2)) + times(:,3)-times(1,3);

            %Find the time indexes that concern us
            timedif = times - tensInterval;
            indices = intersect(find(timedif >= 0),find(timedif <= 10));

            %Checks if the temp values exist
            temps = metadata.TEMP_C_(timeindices);
            temps = temps(indices);
        else
            avgTemp = NaN
            return ;
        end
        
        if ~isempty(temps)
            %Average the temps
            mictempavg = mean(temps);
        elseif isnan(prevTempVal)
            timevals = times(abs(timedif) == min(abs(timedif)));
            timedif = times - timevals(end);
            indices = intersect(find(timedif >= 0),find(timedif <= 10));
            temps = metadata.TEMP_C_(timeindices);
            temps = temps(indices);
            mictempavg = mean(temps);
        else
            %Assume the previous temp value is the current temp value for
            %this 10 seconds
            mictempavg = prevTempVal;
        end
        
        %Append average to the avgs matrix
        mictempavgs(i) = mictempavg;
    end
    
    %Return full temp average
    avgTemp = mean(mictempavgs);
end

function tempMat = getTempMatrix(temps,timeVals)
    %Preallocate tempMat
    tempMat = zeros(size(timeVals,1),1);
    %Iterate through the temperatures
    for i = 1:length(temps)
        %Find timeVal indices for tempMat.
        tempTimeVals = timeVals - i*10;
        indices = intersect(find(tempTimeVals >= 0),find(tempTimeVals < 10))
        
        tempMat(indices) = temps(i);
    end
    tempMat = tempMat';
end

function lagMatrix = getLagMatrix(matchedMatrix)
   lagMatrix = [];
   i = 1;
   while i <= size(matchedMatrix,2)
       minVal = min(matchedMatrix(:,i));
       lagMatrix(:,i) = matchedMatrix(:,i) - minVal;
       i = i + 1;
   end
end

%% Old Function
% function S = Localization(app,matchedMatrix)
%     %matchedMatrix(find(matchedMatrix == 0)) = NaN;
%     lagMatrix = getLagMatrix(matchedMatrix);
%     
%     S = [];
%     
%     micPosGPS = app.micpos(:,1:2);
%     micPosUTM = ll2utm(micPosGPS(:,1),micPosGPS(:,2));
%     meanMicLoc = mean(micPosUTM,1);
%     
%     c = 331.3*sqrt(1 + mean(app.micpos(:,4))/273.15);
%     
%     e = zeros(67,1);
%     numLoc = 1;
%     for i = 1:size(matchedMatrix,2)
%         A = zeros(67,3);
%         A(1:size(micPosUTM,1),1) = micPosUTM(:,1) - meanMicLoc(1);
%         A(1:size(micPosUTM,1),2) = micPosUTM(:,2) - meanMicLoc(2);
%         
%         e(1:size(micPosUTM,1),1) = ~isnan(lagMatrix(:,i))';
% 
%         avgTime = sum(lagMatrix(:,i), 'omitnan')/64;
%         
%         A(1:size(micPosUTM,1),3) = -(lagMatrix(:,i)' - avgTime)*c;
%         A(find(e == 0), :) = 0;
% 
%         B = A*pinv(A'*A)';
%         aVec = (A(:,1).^2 + A(:,2).^2 - A(:,3).^2)/2;
%         BTe = B'*e;
%         BTa = B'*aVec;
% 
%         c2 = BTe(1)^2 + BTe(2)^2 - BTe(3)^2;
%         c1 = 2*(BTe(1)*BTa(1) + BTe(2)*BTa(2) - BTe(3)*BTa(3) - 1);
%         c0 = (BTa(1))^2 + (BTa(2))^2 - (BTa(3))^2;
% 
%         lambda1 = (-c1 + sqrt(c1^2 - 4*c2*c0))/(2*c2);
%         lambda2 = (-c1 - sqrt(c1^2 - 4*c2*c0))/(2*c2);
% 
%         N = aVec + e.*lambda1;
%         G = aVec + e.*lambda2;
%         
%         BTN = B'*N;
%         BTG = B'*G;
%         
%         solsMat = [BTN(1) + meanMicLoc(1),BTN(2) + meanMicLoc(2);...
%             BTG(1) + meanMicLoc(1),BTG(2) + meanMicLoc(2)];
%         
%         rms1 = (A*BTN-N).^2;
%         rms1(find(e == 0)) = [];
%         rms2 = (A*BTG - G).^2;
%         rms2(find(e == 0)) = [];
%         
%         rmsError = sqrt([mean(rms1) mean(rms2)]);
%         Sel = (rmsError(1)<=rmsError(2)) + (rmsError(1) > rmsError(2))*2;
%         f = solsMat(Sel,:);
%         if isreal(f)
%             S = [S;numLoc f];
%         end
%         numLoc = numLoc + 1;
%     end
%     S(:,2:3) = utm2ll(S(:,2),S(:,3), ones(size(S,1),1)*14);
% end
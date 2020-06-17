function S = Localization(app,matchedMatrix)
    %matchedMatrix(find(matchedMatrix == 0)) = NaN;
    lagMatrix = getLagMatrix(matchedMatrix);
    
    S = [];
    
    micPosGPS = app.micpos(:,1:2);
    micPosUTM = ll2utm(micPosGPS(:,1),micPosGPS(:,2));
    meanMicLoc = mean(micPosUTM,1);
    
    c = 331.3*sqrt(1 + mean(app.micpos(:,4))/273.15);
    
    
    
    e = zeros(67,1);
    numLoc = 1;
    for i = 1:size(matchedMatrix,2)
        A = zeros(67,3);
        A(1:size(micPosUTM,1),1) = micPosUTM(:,1) - meanMicLoc(1);
        A(1:size(micPosUTM,1),2) = micPosUTM(:,2) - meanMicLoc(2);
        
        e(1:size(micPosUTM,1),1) = ~isnan(lagMatrix(:,i))';

        avgTime = sum(lagMatrix(:,i), 'omitnan')/64;
        
        A(1:size(micPosUTM,1),3) = -(lagMatrix(:,i)' - avgTime)*c;
        A(find(e == 0), :) = 0;

        B = A*pinv(A'*A)';
        aVec = (A(:,1).^2 + A(:,2).^2 - A(:,3).^2)/2;
        BTe = B'*e;
        BTa = B'*aVec;

        c2 = BTe(1)^2 + BTe(2)^2 - BTe(3)^2;
        c1 = 2*(BTe(1)*BTa(1) + BTe(2)*BTa(2) - BTe(3)*BTa(3) - 1);
        c0 = (BTa(1))^2 + (BTa(2))^2 - (BTa(3))^2;

        lambda1 = (-c1 + sqrt(c1^2 - 4*c2*c0))/(2*c2);
        lambda2 = (-c1 - sqrt(c1^2 - 4*c2*c0))/(2*c2);

        N = aVec + e.*lambda1;
        G = aVec + e.*lambda2;
        
        BTN = B'*N;
        BTG = B'*G;
        
        solsMat = [BTN(1) + meanMicLoc(1),BTN(2) + meanMicLoc(2);...
            BTG(1) + meanMicLoc(1),BTG(2) + meanMicLoc(2)];
        
        rms1 = (A*BTN-N).^2;
        rms1(find(e == 0)) = [];
        rms2 = (A*BTG - G).^2;
        rms2(find(e == 0)) = [];
        
        rmsError = sqrt([mean(rms1) mean(rms2)]);
        Sel = (rmsError(1)<=rmsError(2)) + (rmsError(1) > rmsError(2))*2;
        f = solsMat(Sel,:);
        if isreal(f)
            S = [S;numLoc f];
        end
        numLoc = numLoc + 1;
    end
    S(:,2:3) = utm2ll(S(:,2),S(:,3), ones(size(S,1),1)*14);
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
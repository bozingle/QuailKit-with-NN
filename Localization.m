function S = Localization(app,matchedMatrix)
    matchedMatrix(find(matchedMatrix == 0)) = NaN;
    lagMatrix = getLagMatrix(matchedMatrix);
    
    S = [];
    
    micPosGPS = app.micpos(:,1:2);
    micPosUTM = ll2utm(micPosGPS(:,1),micPosGPS(:,2));
    meanMicLoc = mean(micPosUTM,1);
    
    c = 331.3*sqrt(1 + mean(app.micpos(:,4))/273.15);
    
    
    
    e = zeros(67,1);
    
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
        
        f = min([B(:,1)'*N + meanMicLoc(1),B(:,2)'*N + meanMicLoc(2);...
            B(:,1)'*G + meanMicLoc(1),B(:,2)'*G + meanMicLoc(2)],[],1);
        if isreal(f)
            S = [S; f];
        end
    end
    S = utm2ll(S(:,1),S(:,2), ones(size(S,1),1)*14);
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
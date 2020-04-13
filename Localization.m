function Localization(call,mLoc)

    meanMicLoc = mean(mLoc,1);
    
    c = 331.3*sqrt(1 + call(1)/273.15);
    
    e = zeros(67,1);
    e(1:size(mLoc,1),1) = ~isnan(call(2:end))';
    
    avgTime = sum(call(2:end), 'omitnan')/64;
    
    A = zeros(67,3);
    A(1:size(mLoc,1),1) = mLoc(:,1) - meanMicLoc(1);
    A(1:size(mLoc,1),2) = mLoc(:,2) - meanMicLoc(2);
    A(1:size(mLoc,1),3) = -(call(2:end)' - avgTime)*c;
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

    S = min([B(:,1)'*N + meanMicLoc(1),B(:,2)'*N + meanMicLoc(2);...
        B(:,1)'*G + meanMicLoc(1),B(:,2)'*G + meanMicLoc(2)],[],1);
end
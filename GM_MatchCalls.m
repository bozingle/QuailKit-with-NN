function matchedMatrixFinal = GM_FindMatchedCalls(mA,mB,mC,mD,maxTimeLag)
matchedMatrixA = GM_findMatch_for_one_mic_as_ref(mA,mB,mC,mD,maxTimeLag);

matchedMatrixB = GM_findMatch_for_one_mic_as_ref(mB,mA,mC,mD,maxTimeLag);
matchedMatrixB=[matchedMatrixB(2,:);matchedMatrixB(1,:);matchedMatrixB(3,:);matchedMatrixB(4,:)];

matchedMatrixC = GM_findMatch_for_one_mic_as_ref(mC,mA,mB,mD,maxTimeLag);
matchedMatrixC=[matchedMatrixC(2,:);matchedMatrixC(3,:);matchedMatrixC(1,:);matchedMatrixC(4,:)];

matchedMatrixD = GM_findMatch_for_one_mic_as_ref(mD,mA,mB,mC,maxTimeLag);
matchedMatrixD=[matchedMatrixD(2,:);matchedMatrixD(3,:);matchedMatrixD(4,:);matchedMatrixD(1,:)];

matchedMatrixOverall=unique([matchedMatrixA matchedMatrixB matchedMatrixC matchedMatrixD]','rows')';

matchedMatrixFinal=[];
[~,~,ic] = unique(matchedMatrixOverall(1,:));
for i=1:max(ic)
    locs=find(ic==i);
    if i==1
        matchedMatrixFinal=[matchedMatrixFinal matchedMatrixOverall(:,locs)];
    elseif(length(locs)>1)
        sum_col=sum(matchedMatrixOverall(:,locs));
        matchedMatrixFinal=[matchedMatrixFinal matchedMatrixOverall(:,locs(sum_col==max(sum_col)))];
    else
        matchedMatrixFinal=[matchedMatrixFinal matchedMatrixOverall(:,locs)];
    end
end

end
function matchedMatrixFinal = GM_FindMatchedCalls(mA,mB,mC,mD,maxTimeLag)
try
matchedMatrixA = GM_findMatch_for_one_mic_as_ref(mA,mB,mC,mD,maxTimeLag);

matchedMatrixB = GM_findMatch_for_one_mic_as_ref(mB,mA,mC,mD,maxTimeLag);
if ~isempty(matchedMatrixB)
matchedMatrixB=[matchedMatrixB(2,:);matchedMatrixB(1,:);matchedMatrixB(3,:);matchedMatrixB(4,:)];
end

matchedMatrixC = GM_findMatch_for_one_mic_as_ref(mC,mA,mB,mD,maxTimeLag);
if ~isempty(matchedMatrixC)
matchedMatrixC=[matchedMatrixC(2,:);matchedMatrixC(3,:);matchedMatrixC(1,:);matchedMatrixC(4,:)];
end

matchedMatrixD = GM_findMatch_for_one_mic_as_ref(mD,mA,mB,mC,maxTimeLag);
if ~isempty(matchedMatrixD)
matchedMatrixD=[matchedMatrixD(2,:);matchedMatrixD(3,:);matchedMatrixD(4,:);matchedMatrixD(1,:)];
end

matchedMatrixOverall=unique([matchedMatrixA matchedMatrixB matchedMatrixC matchedMatrixD]','rows')';

matchedMatrixFinal=[];
if ~isempty(matchedMatrixOverall)
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

catch e
    disp("error");
end

%% Elimination of repeated columns, Algorithm written by Farshad
matchedMatrixFinal(matchedMatrixFinal == 0) = NaN;
i = 1;
flag = false;
while i < size(matchedMatrixFinal,2) && flag == false
    column1 = matchedMatrixFinal(:,1);
    x = isnan(column1);
    for j = 2:size(matchedMatrixFinal,2) + 1
        if j == size(matchedMatrixFinal,2) + 1
            flag = true;
            break
        else
            column2 = matchedMatrixFinal(:,j);
            if column1(x==0) == column2(x==0)
                matchedMatrixFinal(:,1) = [];
                break
            end
        end
    end
    i = i+1;
end

end
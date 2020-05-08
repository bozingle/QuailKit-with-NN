% Algorithm developed by Farshad Bolouri
function [TP,FP,FN] = confusionMat(Annotated,Detected)
TP = zeros(1,4); % Detected and Annotated
FP = zeros(1,4); % Detected but not Annotated
FN = zeros(1,4); % Annotated but not Detected

for rec = 1:4
    flag = zeros(1,size(Annotated{rec},1));
    for i = 1:size(Detected{rec},1)
        for j = 1:size(Annotated{rec},1)
            if Detected{rec}(i) >= Annotated{rec}(j,1) && Detected{rec}(i) <= Annotated{rec}(j,2)
                TP(rec) = TP(rec) + 1;
                flag(j) = 1;
                break
            else
                if j == size(Annotated{rec},1)
                    FP(rec) = FP(rec) + 1;
                end
            end
        end
    end
    FN(rec) = length(find(~flag));
end

end


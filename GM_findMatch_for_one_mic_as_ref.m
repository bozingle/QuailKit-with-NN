function matchedMatrix = GM_findMatch_for_one_mic_as_ref(ref,mic1,mic2,mic3,maxTimeLag)
matchedMatrix = [];
i = 1;
while (i <= length(ref))
    if (sum(abs(mic1-ref(i))<maxTimeLag)>0 && sum(abs(mic2-ref(i))<maxTimeLag)>0)...
            || (sum(abs(mic1-ref(i))<maxTimeLag)>0 && sum(abs(mic3-ref(i))<maxTimeLag)>0)...
            || (sum(abs(mic2-ref(i))<maxTimeLag)>0 && sum(abs(mic3-ref(i))<maxTimeLag)>0)
        
        match1=min(mic1(abs(mic1-ref(i))<maxTimeLag));
        match2=min(mic2(abs(mic2-ref(i))<maxTimeLag));
        match3=min(mic3(abs(mic3-ref(i))<maxTimeLag)); 
        if isempty(match1)
            match1=0;
        end
        if isempty(match2)
            match2=0;
        end
        if isempty(match3)
            match3=0;
        end
        
        columnN = [ref(i); match1; match2; match3];
        matchedMatrix = [matchedMatrix columnN];
    end   
    i = i+1;
end
matchedMatrix( :, ~any(matchedMatrix,1) ) = [];
end

function meanTraces = getMeanTraces(traces,numberOfSets,setSize)
%GETMEANTRACES Get mean traces by sets

meanTraces = zeros(numberOfSets,size(traces,2));

for i = 1 : numberOfSets
    meanTraces(i,:)=mean(traces((i-1)*setSize+1:i*setSize,:),1);
end
end


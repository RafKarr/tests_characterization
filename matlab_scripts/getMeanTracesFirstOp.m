function meanTraces = getMeanTracesFirstOp(traces,numberOfSets,setSize)
%GETMEANTRACES Get mean traces by sets on first op

meanTraces = zeros(numberOfSets,size(traces,2));

for i = 1 : numberOfSets
    if mod(i-1,setSize) == 0
        index = (i-1)/31 * setSize^2; %If this is true, jump to the next mod mult
    end
    index = index + 1;
    meanTraces(i,:)=mean(traces(index:setSize:(setSize-1)*setSize + index,:),1);
end
end


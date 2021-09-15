function compressedTraces = compressSqrWithSync(traces,clockIndexes)

compressedTraceSize = length(clockIndexes) + 1;

compressedTraces = zeros(size(traces,1),compressedTraceSize);


for i = 1 : size(traces,1)
    previousIndex = 1;
    for j = 1 : compressedTraceSize
        if(j == compressedTraceSize)
            index = length(traces(i,:))+1;
        else
            index = clockIndexes(j);
        end
        sizeSlot = index - previousIndex;
        compressedTraces(i,j) = norm(traces(i,previousIndex:index-1))^2/sizeSlot;
        previousIndex = index;
    end
end

end


function compressedTraces = compressSqrWithSync(traces,clockIndexes)

compressedTraceSize = length(clockIndexes) + 1;

compressedTraces = zeros(size(traces,1),compressedTraceSize);


for i = 1 : size(traces,1)
    previousIndex = 1;
    for j = 1 : compressedTraceSize
        if(j == compressedTraceSize)
            index = length(traces(i,:));
        else
            index = clockIndexes(j);
        end
        compressedTraces(i,j) = norm(traces(i,previousIndex:index-1))^2;
        previousIndex = index;
    end
end

end


function compressedTraces = compressMaxWithoutSync(traces,compressedTraceSize,samplesPerCycle)
%COMPRESSMAXWITHOUTSYNC Compress traces by clock cycle taking the max
%value. It is not synchronized with the real clock cycle

compressedTraces = zeros(size(traces,1),compressedTraceSize);
for i = 1 : size(traces,1)
    for j = 1 : compressedTraceSize
        index = (j-1)*samplesPerCycle + 1;
        if (index + samplesPerCycle - 1 <= size(traces,2))
            compressedTraces(i,j) = max(traces(i,index:index+samplesPerCycle-1));
        else
            compressedTraces(i,j) = max(traces(i,index:size(traces,2)));
        end
    end
end
end


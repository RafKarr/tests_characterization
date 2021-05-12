function threshold = corrThreshold(traces,inputComparison)
%CORRTHRESHOLD Calculates the threshold for a correlation comparison if
%they have the same operand or not
corrEq = [];
corrDiff = [];

for i = 1 : size(traces,1) - 1
    for j = i + 1 : size(traces,1)
        corrMat = corrcoef(traces(i,:),traces(j,:));
        if (hammingWeight(hex2dec(inputComparison(i,:))) == hammingWeight(hex2dec(inputComparison(j,:))))
            corrEq = [corrEq corrMat(1,2)];
        else
            corrDiff = [corrDiff corrMat(1,2)];
        end
    end
end

threshold = (mean(corrEq) + mean(corrDiff))/2;
end


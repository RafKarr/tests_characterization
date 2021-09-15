function [confusionMatrix,type1Errors,type2Errors] = getConfusionMatrixDist(traces,comparedInputs, threshold)
    %GETCONFUSIONMATRIXDIST Get the confusion matrix of this with threshold
    %   Detailed explanation goes here

    totalComparisons = (size(traces,1)) * (size(traces,1)-1) / 2;
    confusionMatrix = zeros(2,2);
    type1Errors = zeros(totalComparisons,2);
    indType1Errors = 0;
    type2Errors = zeros(totalComparisons,2);
    indType2Errors = 0;

    for i = 1 : size(traces,1) - 1
        for j = i + 1 : size(traces,1)
            dist = norm(traces(i,:) - traces(j,:));
            if (dist<=threshold)
                if (hammingWeight(hex2dec(comparedInputs(i,:))) ~= hammingWeight(hex2dec(comparedInputs(j,:))))
                    confusionMatrix(2,1) = confusionMatrix(2,1) + 1;
                    indType2Errors = indType2Errors + 1;
                    type2Errors(indType2Errors,:) = [hammingWeight(hex2dec(comparedInputs(i,:))) hammingWeight(hex2dec(comparedInputs(j,:)))];
                else
                    confusionMatrix(1,1) = confusionMatrix(1,1) + 1;
                end
            else
                if (hammingWeight(hex2dec(comparedInputs(i,:))) ~= hammingWeight(hex2dec(comparedInputs(j,:))))
                    confusionMatrix(2,2) = confusionMatrix(2,2) + 1; 
                else
                   confusionMatrix(1,2) = confusionMatrix(1,2) + 1;
                   indType1Errors = indType1Errors + 1;
                   type1Errors(indType1Errors,:) = [hammingWeight(hex2dec(comparedInputs(i,:))) hammingWeight(hex2dec(comparedInputs(j,:)))];
                 end
            end
        end
    end

    type1Errors = type1Errors(1:indType1Errors,:);
    type2Errors = type2Errors(1:indType2Errors,:);

end

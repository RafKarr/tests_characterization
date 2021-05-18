function rate = getFalsePositiveRate(confusionMatrix)
%GETFALSEPOSITIVERATE False positive rate for a confusion matrix
rate = confusionMatrix(2,1) / (confusionMatrix(2,1) + confusionMatrix(2,2));
end

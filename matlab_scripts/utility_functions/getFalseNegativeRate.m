function rate = getFalseNegativeRate(confusionMatrix)
%GETFALSENEGATIVERATE False negative rate for a confusion matrix
rate = confusionMatrix(1,2) / (confusionMatrix(1,1) + confusionMatrix(1,2));
end


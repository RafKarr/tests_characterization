function acc = getAccuracy(confusionMatrix)
%GETACCURACY Acccuracy of a confusion matrix
    acc = (confusionMatrix(1,1)+confusionMatrix(2,2))/sum(confusionMatrix,'all');
end


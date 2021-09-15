function matrix = getConfusionMatrix(scores,labels,threshold,positiveLabel)
%Get confusion matrix given scores, labels and threshold

matrix = zeros(2,2);

for i = 1 : length(scores)
    if (positiveLabel == 1)
         if (scores(i) >= threshold)
            if(labels(i) == true)
                matrix(1,1) = matrix(1,1) + 1;
            else 
                matrix(2,1) = matrix(2,1) + 1;
            end
        else
            if(labels(i) == false)
                matrix(2,2) = matrix(2,2) + 1;
            else 
                matrix(1,1) = matrix(1,2) + 1;
            end
        end
    else
        if (scores(i) <= threshold)
            if(labels(i) == true)
                matrix(1,1) = matrix(1,1) + 1;
            else 
                matrix(2,1) = matrix(2,1) + 1;
            end
        else
            if(labels(i) == false)
                matrix(2,2) = matrix(2,2) + 1;
            else 
                matrix(1,1) = matrix(1,2) + 1;
            end
        end
    end
end

end


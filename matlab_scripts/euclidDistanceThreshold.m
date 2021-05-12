function threshold = euclidDistanceThreshold(traces,inputComparison)
%EUCLIDDISTANCETHRESHOLD Calculates the threshold for euclid distance

distEq = [];
distDiff = [];

for i = 1 : size(traces,1) - 1
    for j = i + 1 : size(traces,1)
        dist = norm(traces(i,:)-traces(j,:));
        if (hammingWeight(hex2dec(inputComparison(i,:))) == hammingWeight(hex2dec(inputComparison(j,:))))
            distEq = [distEq dist];
        else
            distDiff = [distDiff dist];
        end
    end
end

threshold = (mean(distEq) + mean(distDiff))/2;
end


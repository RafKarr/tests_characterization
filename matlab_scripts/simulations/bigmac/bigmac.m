function [computedTraces,computedTraces2, euclidDistances] = bigmac(traces,l)
%BIGMAC Executes the big mac attack

%Create the power traces
%Each operation is of size l^2. So 
lsquared = l^2;
% temp = zeros(l,size(traces,2));

computedTraces = zeros((size(traces,1))/...
    lsquared,size(traces,2)*l);
%Row size is (length) divided by l^2
%Column size is the size of each individual trace * l

for i = 1:size(computedTraces,1)
    temp = zeros(l,size(traces,2));
    for j = 1:l
       block = (i-1)*lsquared  + (j-1)*l; 
       temp(j,:) = mean(traces(block + 1: block + l,:),1); 
    end
    computedTraces(i,:) = reshape(temp',numel(temp),1)';
end

computedTraces2 = zeros((size(traces,1))/...
    lsquared,size(traces,2)*l);
%Row size is (length) divided by l^2
%Column size is the size of each individual trace * l

for i = 1:size(computedTraces2,1)
    temp = zeros(l,size(traces,2));
    for j = 1:l
       indices = 1 + (j-1) + (i-1)* lsquared : l : (l-1)*l+ j + (i-1)* lsquared; 
       temp(j,:) = mean(traces(indices,:),1); 
    end
    computedTraces2(i,:) = reshape(temp',numel(temp),1)';
end

%Now, calculate the euclid distances with the second operation and third
%                                                               operation
euclidDistances = zeros(4,size(computedTraces,1));

for i = 1:size(computedTraces,1)
        euclidDistances(1,i) = norm(computedTraces(2,:)-computedTraces(i,:));
end

for i = 1:size(computedTraces,1)
        euclidDistances(2,i) = norm(computedTraces(3,:)-computedTraces(i,:));
end

for i = 1:size(computedTraces2,1)
        euclidDistances(3,i) = norm(computedTraces2(2,:)-computedTraces2(i,:));
end

for i = 1:size(computedTraces2,1)
        euclidDistances(4,i) = norm(computedTraces2(3,:)-computedTraces2(i,:));
end

end


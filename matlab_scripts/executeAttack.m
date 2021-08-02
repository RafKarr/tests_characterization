function successMatrix = executeAttack(traces,pairs,numberOfWords,numberOfModMults)
%EXECUTEATTACK Execute the attack

%Allocate successMatrix
successMatrix = zeros(3,pairs*2,10);

% Get mean traces and other compressed traces
numberOfSets = numberOfWords*numberOfModMults;
meanTraces = getMeanTracesFirstOp(traces,numberOfSets,numberOfWords);
meanThenMaxTraces = compressMaxWithSync(meanTraces,clockIndexes);
maxThenMeanTraces = compressMaxWithSync(traces,clockIndexes);
maxThenMeanTraces = getMeanTracesFirstOp(maxThenMeanTraces,numberOfSets,numberOfWords);
sqrThenMeanTraces = compressSqrWithSync(traces,clockIndexes);
sqrThenMeanTraces = getMeanTracesFirstOp(sqrThenMeanTraces,numberOfSets,numberOfWords);
flagSame = 1; %Flag for comparing between known collisions or not
indexU1 = 1; %Start with same mults
meanThenMeanTraces = compressAvgWithSync(meanTraces,clockIndexes);
indexU2 = 2;

for i = 1 : pairsPerSet * 2
    %Prepare the sets
    U11 = zeros(numberOfWords * multsToCompare, size(meanTraces,2)); %Size of this? Vertical numberOfWords * 6 Horizontal, the vertical size of each trace
    U21 = zeros(size(U11));
    U12 = zeros(numberOfWords * multsToCompare, size(meanThenMaxTraces,2));
    U22 = zeros(size(U12));
    U13 = zeros(numberOfWords * multsToCompare, size(meanThenMeanTraces,2));
    U23 = zeros(size(U13));
    U14 = zeros(numberOfWords * multsToCompare, size(maxThenMeanTraces,2));
    U24 = zeros(size(U14));
    U15 = zeros(numberOfWords * multsToCompare, size(sqrThenMeanTraces,2));
    U25 = zeros(size(U15));
    for j = 1 : multsToCompare
        U11((j-1)*numberOfWords+1 : j * numberOfWords, :) = meanTraces((indexU1-1) * numberOfWords + 1 : (indexU1) * numberOfWords,:);
        U21((j-1)*numberOfWords+1 : j * numberOfWords, :) = meanTraces((indexU2-1) * numberOfWords + 1 : (indexU2) * numberOfWords,:);
        U12((j-1)*numberOfWords+1 : j * numberOfWords, :) = meanThenMaxTraces((indexU1-1) * numberOfWords + 1 : (indexU1) * numberOfWords,:);
        U22((j-1)*numberOfWords+1 : j * numberOfWords, :) = meanThenMaxTraces((indexU2-1) * numberOfWords + 1 : (indexU2) * numberOfWords,:);
        U13((j-1)*numberOfWords+1 : j * numberOfWords, :) = meanThenMeanTraces((indexU1-1) * numberOfWords + 1 : (indexU1) * numberOfWords,:);
        U23((j-1)*numberOfWords+1 : j * numberOfWords, :) = meanThenMeanTraces((indexU2-1) * numberOfWords + 1 : (indexU2) * numberOfWords,:);
        U14((j-1)*numberOfWords+1 : j * numberOfWords, :) = maxThenMeanTraces((indexU1-1) * numberOfWords + 1 : (indexU1) * numberOfWords,:);
        U24((j-1)*numberOfWords+1 : j * numberOfWords, :) = maxThenMeanTraces((indexU2-1) * numberOfWords + 1 : (indexU2) * numberOfWords,:);
        U15((j-1)*numberOfWords+1 : j * numberOfWords, :) = sqrThenMeanTraces((indexU1-1) * numberOfWords + 1 : (indexU1) * numberOfWords,:);
        U25((j-1)*numberOfWords+1 : j * numberOfWords, :) = sqrThenMeanTraces((indexU2-1) * numberOfWords + 1 : (indexU2) * numberOfWords,:);
        if (flagSame == 1)
            indexU1 = indexU1 + 2;
            indexU2 = indexU2 + 2;
        else
            indexU1 = indexU1 + 1;
            indexU2 = indexU2 + 1;
        end
    end
    
    %Store all sets in two cells
    cellU1 = {U11, U12, U13, U14, U15};
    cellU2 = {U21, U22, U23, U24, U25};
    
    %Loop through the cells
    for j = 1 : 5
        U1 = cell2mat(cellU1(j)); %Select sets
        U2 = cell2mat(cellU2(j));
        scoreVector = zeros(2,numberOfWords*6); %Score vector for just one ?
        for l = 1 : numberOfWords * multsToCompare
            tempU1 = U1(l,:);
            tempU2 = U2(l,:);
            corrMat = corrcoef(tempU1,tempU2);
            scoreVector(1,l) = corrMat(1,2); %Correlation
            scoreVector(2,l) = norm(U1(l,:) - U2(l,:)); %Euclidean distance
        end
        
        successMatrix(1,i,j) = sum(scoreVector(1,:) >= selectedPoints(j,1));
        successMatrix(2,i,j) = flagSame;
        successMatrix(3,i,j) = successMatrix(1,i,j) >= selectedPoints(j,2);
        successMatrix(1,i,j+5) = sum(scoreVector(2,:) <= selectedPoints(j+5,1));
        successMatrix(2,i,j+5) = flagSame;
        successMatrix(3,i,j+5) = successMatrix(1,i,j+5) >= selectedPoints(j+5,2);
    end
    if (i == pairsPerSet && flagSame == 1)
        flagSame = 0;
        indexU1 = 1;
        indexU2 = 3;
    end
end
end


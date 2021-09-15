function successMatrix = executeAttack(traces,pairs,numberOfWords,numberOfModMults,clockIndexes,multsToCompare,selectedPoints,onOperand)
%EXECUTEATTACK Execute the attack

%Allocate successMatrix
successMatrix = zeros(3,pairs*2,4);

% Get mean traces and other compressed traces
numberOfSets = numberOfWords*numberOfModMults;

if (onOperand == "first")
    meanTraces = getMeanTracesFirstOp(traces,numberOfSets,numberOfWords);
    sqrThenMeanTraces = compressSqrWithSync(traces,clockIndexes);
    sqrThenMeanTraces = getMeanTracesFirstOp(sqrThenMeanTraces,numberOfSets,numberOfWords);
else
    if (onOperand == "second")
        meanTraces = getMeanTraces(traces,numberOfSets,numberOfWords);
        sqrThenMeanTraces = compressSqrWithSync(traces,clockIndexes);
        sqrThenMeanTraces = getMeanTraces(sqrThenMeanTraces,numberOfSets,numberOfWords);
    else
        e = MException('executeAttack:wrongoperand','Wrong specification of operand');
        throw(e);
    end
end

flagSame = 1; %Flag for comparing between known collisions or not
indexU1 = 1; %Start with same mults
indexU2 = 2;

for i = 1 : pairs * 2
    %Prepare the sets
    U11 = zeros(numberOfWords * multsToCompare, size(meanTraces,2)); %Size of this? Vertical numberOfWords * 6 Horizontal, the vertical size of each trace
    U21 = zeros(size(U11));
    U12 = zeros(numberOfWords * multsToCompare, size(sqrThenMeanTraces,2));
    U22 = zeros(size(U12));
    for j = 1 : multsToCompare
        U11((j-1)*numberOfWords+1 : j * numberOfWords, :) = meanTraces((indexU1-1) * numberOfWords + 1 : (indexU1) * numberOfWords,:);
        U21((j-1)*numberOfWords+1 : j * numberOfWords, :) = meanTraces((indexU2-1) * numberOfWords + 1 : (indexU2) * numberOfWords,:);
        U12((j-1)*numberOfWords+1 : j * numberOfWords, :) = sqrThenMeanTraces((indexU1-1) * numberOfWords + 1 : (indexU1) * numberOfWords,:);
        U22((j-1)*numberOfWords+1 : j * numberOfWords, :) = sqrThenMeanTraces((indexU2-1) * numberOfWords + 1 : (indexU2) * numberOfWords,:);
        if (flagSame == 1)
            indexU1 = indexU1 + 2;
            indexU2 = indexU2 + 2;
        else
            indexU1 = indexU1 + 1;
            indexU2 = indexU2 + 1;
        end
    end
    
    %Store all sets in two cells
    cellU1 = {U11, U12};
    cellU2 = {U21, U22};
    
    %Loop through the cells
    for j = 1 : 2
        U1 = cell2mat(cellU1(j)); %Select sets
        U2 = cell2mat(cellU2(j));
        scoreVector = zeros(2,numberOfWords*multsToCompare);
        for k = 1 : numberOfWords * multsToCompare
            tempU1 = U1(k,:);
            tempU2 = U2(k,:);
            corrMat = corrcoef(tempU1,tempU2);
            scoreVector(1,k) = corrMat(1,2); %Correlation
            scoreVector(2,k) = norm(U1(k,:) - U2(k,:)); %Euclidean distance
        end
        
        successMatrix(1,i,j) = sum(scoreVector(1,:) >= selectedPoints((j-1)*4+1,1));
        successMatrix(2,i,j) = flagSame;
        successMatrix(3,i,j) = successMatrix(1,i,j) >= selectedPoints((j-1)*4+1,2);
        successMatrix(1,i,j+2) = sum(scoreVector(2,:) <= selectedPoints((j-1)*4+6,1));
        successMatrix(2,i,j+2) = flagSame;
        successMatrix(3,i,j+2) = successMatrix(1,i,j+2) >= selectedPoints((j-1)*4+6,2);
    end
    if (i == pairs && flagSame == 1)
        flagSame = 0;
        indexU1 = 1;
        indexU2 = 3;
    end
end
end


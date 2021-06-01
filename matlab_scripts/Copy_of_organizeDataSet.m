%Organize dataset for logistic regression (or other models)
%% Load section
load('./traces_v5/threshold.mat');
traces_Y_final = traces_Y;
inputs_a_final = inputs_a;
inputs_b_final = inputs_b;

%Then load the others
load('./traces_v5/input_sets_second_op_31.mat');
traces_Y_final = [traces_Y_final; traces_Y];
inputs_a_final = [inputs_a_final; inputs_a];
inputs_b_final = [inputs_b_final; inputs_b];

traces_Y = traces_Y_final;
inputs_a = inputs_a_final;
inputs_b = inputs_b_final;

clear inputs_a_final inputs_b_final traces_Y_final
%% Trace reduction part
%I've decided to reduce it with the squaring method
clockIndexes = getClockIndexes();
reducedTraces = compressSqrWithSync(traces_Y,clockIndexes);
reducedTraces = getMeanTraces(reducedTraces,1500,31);
clear clockIndexes traces_Y
%% Organization
totalComparisons = (size(reducedTraces,1)) * (size(reducedTraces,1)-1) / 2;
dataMatrix = zeros(totalComparisons,size(reducedTraces,2)*2);
labels = zeros(totalComparisons,1);
index = 0;
comparedInputs = inputs_b(1:31:size(inputs_b,1),:);
for i = 1 : size(reducedTraces,1) - 1
    for j = i + 1 : size(reducedTraces,1)
        index = index + 1;
        dataMatrix(index,:) = [reducedTraces(i,:) reducedTraces(j,:)];
        if (hammingWeight(hex2dec(comparedInputs(i,:))) == hammingWeight(hex2dec(comparedInputs(j,:))))
            labels(index) = 1; 
        else
           labels(index) = 0;
        end
    end
end
%% 
save('./log_reg/datav5.mat','dataMatrix','labels');
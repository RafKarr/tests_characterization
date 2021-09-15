function [th_distinguisher, th_bino, acc, fpr_bino, tpr_bino, fpr_dist, tpr_dist] ...
    = getThresholdDistinguisher(fprVector,tprVector,thresholdVector, ...
    psame, N)
%GETTHRESHOLDDISTINGUISHER Obtain the optimal threshold distinguisher
%   Also yields the threshold binomial, the accuracy, the false positive
%   rate and the true positive rate
th_bino = 0;
acc = 0;
fpr_bino = 0;
tpr_bino = 0;
fpr_dist = 0;
tpr_dist = 0;
for i = 1 : length(fprVector)
    [temp_th_bino, temp_acc_th_bino, temp_fpr_th_bino, temp_tpr_th_bino]...
        = getThresholdBino(N,psame,fprVector(i),tprVector(i));
    if (temp_acc_th_bino > acc)
        th_bino = temp_th_bino;
        acc = temp_acc_th_bino;
        fpr_bino = temp_fpr_th_bino;
        tpr_bino = temp_tpr_th_bino;
        fpr_dist = fprVector(i);
        tpr_dist = tprVector(i);
    end
end
th_distinguisher = thresholdVector((fprVector==fpr_dist)&(tprVector==tpr_dist));
end


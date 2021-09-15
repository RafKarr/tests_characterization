function [th_bino,acc_th_bino, fpr_th_bino, tpr_th_bino] = getThresholdBino(N, psame, fpr_distinguisher, tpr_distinguisher)
%GETTHRESHOLDBINO Obtains the threshold of the binomial analysis and metrics
th_bino = 0;
acc_th_bino = 0;
fpr_th_bino = 0;
tpr_th_bino = 0;
k = 0 : N;
prandom = psame * tpr_distinguisher + (1 - psame) * fpr_distinguisher;
if (tpr_distinguisher < prandom) % If this happens, it's senseless: return 0
    return;
end
pdftrue = binopdf(k,N,tpr_distinguisher);
pdfrandom = binopdf(k,N,prandom);
for i = 0 : N
    temp_fpr = sum(pdfrandom(i+1:end));
    temp_tpr = sum(pdftrue(i+1:end));
    temp_acc = temp_tpr/2 + (1-temp_fpr)/2;
    if (temp_acc > acc_th_bino)
        th_bino = i;
        acc_th_bino = temp_acc;
        fpr_th_bino = temp_fpr;
        tpr_th_bino = temp_acc;
    end
end
end


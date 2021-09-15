
%% This is to plot each of the results of the traces

baseName = "results-x.mat";

for i = 1 : 5
    load(strrep(baseName,"x",num2str(i)));
    figure 
    hold on
    grid on
    for j = 1:4
        plot(ed(j,:))
    end
    
    legend("Average First Operand, 1xM", "Average First Operand, MxM","Average Second Operand, 1xM","Average Second Operand, MxM")    
end
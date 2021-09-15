function indexes = getClockIndexesShort()
%GETCLOCKINDEXES Summary of this function goes here
%   Detailed explanation goes here
    load('./traces_clock/clock_1c.mat','traces_Y');
    [pk,indexes] = findpeaks(traces_Y);
    
    indexes = indexes(pk>=0.043);
end


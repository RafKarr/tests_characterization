function indexes = getClockIndexesShort()
%GETCLOCKINDEXES Summary of this function goes here
%   Detailed explanation goes here
    load('./traces_clock/clock1c.mat','traces_Y');
    [pk,indexes] = findpeaks(clock_trace);
    
    indexes = indexes(pk>=0.13);
end


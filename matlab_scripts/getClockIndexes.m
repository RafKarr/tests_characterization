function indexes = getClockIndexes()
%GETCLOCKINDEXES Summary of this function goes here
%   Detailed explanation goes here
    load('./traces_clock/clock.mat','clock_trace');
    [pk,indexes] = findpeaks(clock_trace);
    
    indexes = indexes(pk>=0.13);
end


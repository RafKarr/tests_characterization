function res1 = bcdc(t1,t2)
%BCDC Calculates the bounded collision detection criterion.
%   From the work of Diop, one can also have this measure
   res1 = 1/sqrt(2);
   diffTrace = t1 - t2;
   res1 = res1 * std(diffTrace);
   res1 = res1 / std(t1);
end


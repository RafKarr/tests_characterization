function r = hammingWeight(n)

shifts = [-1, -2, -4, -8, -16];
masks = [1431655765, 858993459, 252645135, 16711935, 65535];

r = n;
for i=1:5
   r = bitand(bitshift(r, shifts(i)), masks(i)) + ...
      bitand(r, masks(i));
end

%First, let's try with a vector of four 8 bit words without reduction

base = uint8.empty();
exponent = uint8.empty();

for i = 1:3
    base(i) = 0;
    exponent(i) = 0;
end

base(4) = 12;
exponent(4) = 12;

whos base
whos exponent
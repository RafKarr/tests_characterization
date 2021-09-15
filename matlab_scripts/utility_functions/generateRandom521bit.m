function output = generateRandom521bit()

output = char(zeros(31,6));
%Little endian 
for i = 1:31
    if i ~= 31
        temp = randi([0 131071]);
    else
        %Last word only has 11 bits
        temp = randi([0 2047]);
    end
    output(i,:) = dec2hex(temp,6);
end

end


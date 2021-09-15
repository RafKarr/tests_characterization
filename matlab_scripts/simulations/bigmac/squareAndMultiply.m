function result = squareAndMultiply(base,exponent)

base = vpi(base);
exponent = vpi(exponent);
exponent = vpi2bin(exponent);

%Modulus
modulus = hex2bin('A9E167983F39D55FF2A093415EA6798985C8355D9A915BFB1D01DA197026170FBDA522D035856D7A986614415CCFB7B7083B09C991B81969376DF9651E7BD9A93324A37F3BBBAF460186363432CB07035952FC858B3104B8CC18081448E64F1CFB5D60C4E05C1F53D37F53D86901F105F87A70D1BE83C65F38CF1C2CAA6AA7EB');
modulus = bin2vpi(modulus);

result = vpi(1);

for i = 1 : length(exponent)
    result = mod(longIntMult8(result,result),modulus);
    if exponent(i)=='1'
        result = mod(longIntMult8(result,base),modulus);
    end
end
end
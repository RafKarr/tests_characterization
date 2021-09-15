function str = hex2bin(a)
        str = strrep(a,' ','');
        str = dec2bin(hex2dec(str'),4);                    
        str = reshape (str', numel(str), 1)';
    end
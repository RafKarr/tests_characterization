function leakageModel8(a,b)

%Check the matrix where we are saving the traces

    arrayA = get8bitwords(a);
    arrayB = get8bitwords(b);
    
        l = 128; %1024 bit rsa algorithm in blocks of 8 bits
    
    if length(arrayA) ~= l
        arrayA = [arrayA zeros(1,l-length(arrayA))];
    end
    
    if length(arrayB) ~= l
        arrayB = [arrayB zeros(1,l-length(arrayB))];
    end
    
    fileName = './traces/trace-5.mat';
    
    try 
        load(fileName,'fulltrace');
    catch
        fulltrace = [];
    end
    
    %Size of trace
    %Let's say one multiplication takes one clock cycle (i.e. 148 
    % Mhz ) and we take the max sample rate from the oscilloscope 
    % (10 GS/s). Then we get approximately 68 samples.
    sizeTrace = 68;
    lastindex = size(fulltrace,1);
    fulltrace = [fulltrace;zeros(l^2,sizeTrace)];
    

    %Now we calculate the hamming weight of every multiplication
    for i = 1 : l
        for j = 1 : l
            mult = arrayA(i) * arrayB(j);
            hw = hammingWeight(mult);
            
            localtrace = zeros(1,sizeTrace);
            noise = wgn(sizeTrace,5,0);
%             noise = zeros(1,sizeTrace);
            for h = 1 : sizeTrace
                localtrace(h) = hw + noise(h);
            end
            fulltrace(lastindex + j + (i-1)*l,:) = localtrace;
        end
    end
    
    save(fileName,'fulltrace');
    
    function res = get8bitwords(a)
        if a == 0
            res = 0;
        else
            bits = floor(log2(a))+1;
            blocks = ceil(bits/8);
            res = zeros(1,blocks);
            for w = 1:blocks
                res(w) = mod(a,2^8);
                a = a/2^8;
            end
        end
    end


end
rng shuffle
clear
format long;
if ~isempty(instrfind)
     fclose(instrfind);
      delete(instrfind);
end

% Prepare Lecroy
init_LeCroy;

myComPort = serial('COM7','BaudRate',115200,'DataBits',8,'StopBits',1,'Timeout',200); %4800 %921600 460800 115200
fopen(myComPort);
fprintf('Loading Success!\n\nBegin test!\n----------------\n');
Test = 0;

setSize = 31;

multssets = 80;

no_Test = multssets * setSize^2;

inputs_a = char(zeros(no_Test,6));
inputs_b = char(zeros(no_Test,6));

%80 multiplications with 40 pairs of them with the same second operand
for i = 1 : multssets/2
    %Generate random b
%     b = generateRandom521bit();
    a = generateRandom521bit();
    %Multiply with two different a
    for j = 1:2
%         a = generateRandom521bit();
        b = generateRandom521bit();
        %Select subwords and send
        for k = 1:setSize
            subB = b(k,:);
            for l=1:setSize
                index = 2*setSize^2*(i-1)+setSize^2*(j-1)+31*(k-1)+l;
                subA = a(l,:);
                inputs_a(index,:) = subA;
                inputs_b(index,:) = subB;
                expMult = dec2hex(hex2dec(subA)*hex2dec(subB),12);
                % Send A
                for m = 1:3
                    sendbyte = subA((2*m-1):(2*m));
                    x=uint8(hex2dec(sendbyte));
                    fwrite(myComPort,x,'uint8');
                end
                %Send B
                for m = 1:3
                    sendbyte = subB((2*m-1):(2*m));
                    x=uint8(hex2dec(sendbyte));
                    fwrite(myComPort,x,'uint8');
                end
                acquire_LeCroy_scope_data
                if (exist('traces_Y','var')==0)
                    traces_Y = zeros(no_Test,size(Y,2));
                end
                traces_Y(index,:) = Y;
                result = dec2hex(fread(myComPort,6,'uint8'),2);
                result = reshape(result',1,numel(result));
                if (result == expMult)
                    disp('OK!');
                    Test= Test + 1;
                else
                    e = MException('Error');
                    throw(e);
                end
            end
        end
    end
end


WrongTest =no_Test-Test;
fprintf('Closing the Port ...\n...\n');
fclose(myComPort);
disp('Completed!!')
disp('------------')
fprintf('Summary:\n Total tests: %d\n Total correct cases: %d\n Total wrong cases: %d\n', no_Test,Test,WrongTest);

% save('./traces_v6/input_sets_second_op2.mat','inputs_a','inputs_b','traces_Y','-v7.3');
save('./traces_v7/input_sets_first_op1.mat','inputs_a','inputs_b','traces_Y','-v7.3');

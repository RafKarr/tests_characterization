dbstop if error
rng shuffle
% cleanupObj = onCleanup(@cleanMeUp);

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
Test =0;
no_Test = 5001;
inputs_a = char(zeros(no_Test,6));
inputs_b = char(zeros(no_Test,6));

%First random multiplication 
a = randi([0 131071]);
b = randi([0 131071]);
expMult = dec2hex(a * b,12);
a = dec2hex(a,6);
b = dec2hex(b,6);
inputs_a(1,:) = a;
inputs_b(1,:) = b;
% Send A
for k = 1:3
    sendbyte = a((2*k-1):(2*k));
    x=uint8(hex2dec(sendbyte));
    fwrite(myComPort,x,'uint8');
end
%Send B
for k = 1:3
    sendbyte = b((2*k-1):(2*k));
    x=uint8(hex2dec(sendbyte));
    fwrite(myComPort,x,'uint8');
end
acquire_LeCroy_scope_data
traces_Y = zeros(no_Test,length(Y));
traces_Y(1,:) = Y;
result = dec2hex(fread(myComPort,6,'uint8'),2);
result = reshape(result',1,numel(result));
if (result == expMult)
    disp('OK first mult... continuing');
    Test= Test + 1;
end
%1000 multiplications with the same operands
for n =2: 1001
    inputs_a(n,:) = a;
    inputs_b(n,:) = b;
    % Send A
    for k = 1:3
        sendbyte = a((2*k-1):(2*k));
        x=uint8(hex2dec(sendbyte));
        fwrite(myComPort,x,'uint8');
    end
    %Send B
    for k = 1:3
        sendbyte = b((2*k-1):(2*k));
        x=uint8(hex2dec(sendbyte));
        fwrite(myComPort,x,'uint8');
    end
    acquire_LeCroy_scope_data
    traces_Y(n,:) = Y;
    result = dec2hex(fread(myComPort,6,'uint8'),2);
    result = reshape(result',1,numel(result));
    if (result == expMult)
        disp('OK!');
        Test= Test + 1;
    end
end
disp('Done same operands');
%1000 multiplications with the same operands but inversed
for n =1002: 2001
    inputs_a(n,:) = b;
    inputs_b(n,:) = a;
    % Send A
    for k = 1:3
        sendbyte = b((2*k-1):(2*k));
        x=uint8(hex2dec(sendbyte));
        fwrite(myComPort,x,'uint8');
    end
    %Send B
    for k = 1:3
        sendbyte = a((2*k-1):(2*k));
        x=uint8(hex2dec(sendbyte));
        fwrite(myComPort,x,'uint8');
    end
    acquire_LeCroy_scope_data
    traces_Y(n,:) = Y;
    result = dec2hex(fread(myComPort,6,'uint8'),2);
    result = reshape(result',1,numel(result));
    if (result == expMult)
        disp('OK!');
        Test= Test + 1;
    end
end
disp('Done same inverted operands');
%1000 multiplications with the second operand changed
for n =2002: 3001
%     a = randi([0 131071]);
    temp_b = randi([0 131071]);
    expMult = dec2hex(hex2dec(a) * temp_b,12);
%     a = dec2hex(a,6);
    temp_b = dec2hex(temp_b,6);
    inputs_a(n,:) = a;
    inputs_b(n,:) = temp_b;
    % Send A
    for k = 1:3
        sendbyte = a((2*k-1):(2*k));
        x=uint8(hex2dec(sendbyte));
        fwrite(myComPort,x,'uint8');
    end
    %Send B
    for k = 1:3
        sendbyte = temp_b((2*k-1):(2*k));
        x=uint8(hex2dec(sendbyte));
        fwrite(myComPort,x,'uint8');
    end
    acquire_LeCroy_scope_data
    traces_Y(n,:) = Y;
    result = dec2hex(fread(myComPort,6,'uint8'),2);
    result = reshape(result',1,numel(result));
    if (result == expMult)
        disp('OK!');
        Test= Test + 1;
    end
end
disp('Done second operand changed');
%1000 multiplications with the first operand changed
for n =3002: 4001
%     a = randi([0 131071]);
    temp_a = randi([0 131071]);
    expMult = dec2hex(hex2dec(b) * temp_a,12);
%     a = dec2hex(a,6);
    temp_a = dec2hex(temp_a,6);
    inputs_a(n,:) = temp_a;
    inputs_b(n,:) = b;
    % Send A
    for k = 1:3
        sendbyte = temp_a((2*k-1):(2*k));
        x=uint8(hex2dec(sendbyte));
        fwrite(myComPort,x,'uint8');
    end
    %Send B
    for k = 1:3
        sendbyte = b((2*k-1):(2*k));
        x=uint8(hex2dec(sendbyte));
        fwrite(myComPort,x,'uint8');
    end
    acquire_LeCroy_scope_data
    traces_Y(n,:) = Y;
    result = dec2hex(fread(myComPort,6,'uint8'),2);
    result = reshape(result',1,numel(result));
    if (result == expMult)
        disp('OK!');
        Test= Test + 1;
    end
end
disp('Done first operand changed');
%1000 multiplications with both operands changed
for n =4002: 5001
%     a = randi([0 131071]);
    temp_a = randi([0 131071]);
    temp_b = randi([0 131071]);
    expMult = dec2hex(temp_b * temp_a,12);
%     a = dec2hex(a,6);
    temp_a = dec2hex(temp_a,6);
    temp_b = dec2hex(temp_b,6);
    inputs_a(n,:) = temp_a;
    inputs_b(n,:) = temp_b;
    % Send A
    for k = 1:3
        sendbyte = temp_a((2*k-1):(2*k));
        x=uint8(hex2dec(sendbyte));
        fwrite(myComPort,x,'uint8');
    end
    %Send B
    for k = 1:3
        sendbyte = temp_b((2*k-1):(2*k));
        x=uint8(hex2dec(sendbyte));
        fwrite(myComPort,x,'uint8');
    end
    acquire_LeCroy_scope_data
    traces_Y(n,:) = Y;
    result = dec2hex(fread(myComPort,6,'uint8'),2);
    result = reshape(result',1,numel(result));
    if (result == expMult)
        disp('OK!');
        Test= Test + 1;
    end
end
disp('Done both operands changed');

WrongTest =no_Test-Test;
fprintf('Closing the Port ...\n...\n');
fclose(myComPort);
disp('Completed!!')
disp('------------')
fprintf('Summary:\n Total tests: %d\n Total correct cases: %d\n Total wrong cases: %d\n', no_Test,Test,WrongTest);

save('./traces/input_2.mat', 'inputs_a', 'inputs_b','traces_Y');
% save('./traces/input.mat', 'inputs_a', 'inputs_b');
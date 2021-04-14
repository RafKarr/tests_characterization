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
no_Test = 300;
inputs_a = char(zeros(no_Test,6));
inputs_b = char(zeros(no_Test,6));
traces_Y = zeros(300,20003);
b = randi([0 131071]);
b = dec2hex(b,6);
%100 multiplications with the same second operand
for n =1: 100
    a = randi([0 131071]);
    expMult = dec2hex((hex2dec(b)*a),12);
    a = dec2hex(a,6);
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
disp('Done same second operand');

%10 sets of 20 multiplications with the same second operand each set
for l =1: 10
    b = randi([0 131071]);
    b = dec2hex(b,6);
    for n = 1 : 20
        a = randi([0 131071]);
        expMult = dec2hex((hex2dec(b)*a),12);
        a = dec2hex(a,6);
        inputs_a(100+(l-1)*20+n,:) = a;
        inputs_b(100+(l-1)*20+n,:) = b;
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
        traces_Y(100+(l-1)*20+n,:) = Y;
        result = dec2hex(fread(myComPort,6,'uint8'),2);
        result = reshape(result',1,numel(result));
        if (result == expMult)
            disp('OK!');
            Test= Test + 1;
        end
    end
end

WrongTest =no_Test-Test;
fprintf('Closing the Port ...\n...\n');
fclose(myComPort);
disp('Completed!!')
disp('------------')
fprintf('Summary:\n Total tests: %d\n Total correct cases: %d\n Total wrong cases: %d\n', no_Test,Test,WrongTest);

save('./traces/input_sets_second_op.mat', 'inputs_a', 'inputs_b','traces_Y');

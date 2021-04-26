
rng shuffle
% cleanupObj = onCleanup(@cleanMeUp);
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
Test =0;

setSize = 50;
sets1 = 10;
sets2 = 100;

no_Test = (sets1 + sets2)*setSize;

load('./traces_v4/input_sets_second_op.mat','inputs_a','inputs_b');
% inputs_a = char(zeros(no_Test,6));
% inputs_b = char(zeros(no_Test,6));
% b = randi([0 131071]);
% b = dec2hex(b,6);
b = inputs_b(1,:);


%500 multiplications with the same second operand
for n =1: sets1 * setSize
%     a = randi([0 131071]);
    a = hex2dec(inputs_a(n,:));
    expMult = dec2hex((hex2dec(b)*a),12);
     a = dec2hex(a,6);
%     inputs_a(n,:) = a;
%     inputs_b(n,:) = b;
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
    if (exist('traces_Y','var')==0)
        traces_Y = zeros(no_Test,size(Y,2));
        traces_filt = zeros(no_Test,size(FILT_Y,2));
    end
    traces_Y(n,:) = Y;
    traces_filt(n,:) = FILT_Y;
    result = dec2hex(fread(myComPort,6,'uint8'),2);
    result = reshape(result',1,numel(result));
    if (result == expMult)
        disp('OK!');
        Test= Test + 1;
    else
        disp('NOT OK!');
    end
end
disp('Done same second operand');

%100 sets of 50 multiplications with the same second operand each set
for l =1: sets2
%     b = randi([0 131071]);
%     b = dec2hex(b,6);
    b = inputs_b(sets1*setSize+(l-1)*setSize+1,:);
    for n = 1 : setSize
%         a = randi([0 131071]);
        a = hex2dec(inputs_a(sets1*setSize+(l-1)*setSize+n,:));
        expMult = dec2hex((hex2dec(b)*a),12);
         a= dec2hex(a,6);
%         inputs_a(sets1*setSize+(l-1)*setSize+n,:) = a;
%         inputs_b(sets1*setSize+(l-1)*setSize+n,:) = b;
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
        traces_Y(sets1*setSize+(l-1)*setSize+n,:) = Y;
        traces_filt(sets1*setSize+(l-1)*setSize+n,:) = FILT_Y;
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

% meanTrig = mean(traces_trig,1);
% traces_Y = traces_Y(:,meanTrig >=1.5);

% save('./traces_v4/input_sets_second_op.mat', 'inputs_a', 'inputs_b','traces_Y','traces_filt');
save('./traces_v5/input_sets_second_op.mat','inputs_a','inputs_b','traces_Y','traces_filt');

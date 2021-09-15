
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
no_Test = 1;
b = randi([0 131071]);
b = dec2hex(b,6);
a = randi([0 131071]);
expMult = dec2hex((hex2dec(b)*a),12);
a = dec2hex(a,6);

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
traces_Y = zeros(no_Test,size(Y,2));
traces_Y(1,:) = Y;
result = dec2hex(fread(myComPort,6,'uint8'),2);
result = reshape(result',1,numel(result));
if (result == expMult)
    disp('OK!');
    Test= Test + 1;
else
    disp('NOT OK!');
end


WrongTest =no_Test-Test;
fprintf('Closing the Port ...\n...\n');
fclose(myComPort);
disp('Completed!!')
disp('------------')
fprintf('Summary:\n Total tests: %d\n Total correct cases: %d\n Total wrong cases: %d\n', no_Test,Test,WrongTest);

save('./traces_clock/clock_1c','traces_Y','-v7.3');

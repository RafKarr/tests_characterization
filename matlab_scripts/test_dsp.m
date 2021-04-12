rng shuffle

format long;
if ~isempty(instrfind)
     fclose(instrfind);
      delete(instrfind);
end

% Prepare Lecroy
% init_LeCroy;

myComPort = serial('COM6','BaudRate',115200,'DataBits',8,'StopBits',1,'Timeout',200); %4800 %921600 460800 115200
fopen(myComPort);
fprintf('Loading Success!\n\nBegin test!\n----------------\n');
Test =0;
no_Test = 1000;
inputs_a = char(zeros(no_Test,6));
inputs_b = char(zeros(no_Test,6));
for n =1: no_Test
a = randi([0 131071]);
b = randi([0 131071]);
expMult = dec2hex(a * b,12);
a = dec2hex(a,6);
b = dec2hex(b,6);
inputs_a(n,:) = a;
inputs_b(n,:) = a;
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
result = dec2hex(fread(myComPort,6,'uint8'));
result = reshape(result',1,numel(result));
if (result == expMult)
    disp('OK!');
    Test= Test + 1;
end
end
WrongTest =no_Test-Test;
fprintf('Closing the Port ...\n...\n');
fclose(myComPort);
disp('Completed!!')
disp('------------')
fprintf('Summary:\n Total tests: %d\n Total correct cases: %d\n Total wrong cases: %d\n', no_Test,Test,WrongTest);

%acquire_LeCroy_scope_data
save('input.mat', 'inputs_a', 'inputs_b'); %And the traces, of course

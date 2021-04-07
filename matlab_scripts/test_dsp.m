myComPort = serial('COM7','BaudRate',115200,'DataBits',8,'StopBits',1,'ByteOrder','bigEndian','Timeout',200); %4800 %921600 460800 115200
fopen(myComPort);
fprintf('Loading Success!\n\nBegin test!\n----------------\n');
% Test =0;
% no_Test = 1;
% for n =1: no_Test
% a = dec2hex(randi([0 131071]),6)
% b = dec2hex(randi([0 131071]),6)
a = '01182C'
b = '0046F9'
%expMult = a * b;
% Send A
for k = 1:3
    sendbyte = a((2*k-1):(2*k))
    x=uint8(hex2dec(sendbyte));
    fwrite(myComPort,x,'uint8');
end
%Send B
for k = 1:3
    sendbyte = b((2*k-1):(2*k))
    x=uint8(hex2dec(sendbyte));
    fwrite(myComPort,x,'uint8');
end
Result = dec2hex(fread(myComPort,6,'uint8'))
% if (expCipher == cipher)
%     disp('OK!');
%     Test= Test + 1;
% end
% end
% WrongTest =no_Test-Test;
fprintf('Closing the Port ...\n...\n');
fclose(myComPort);
disp('Completed!!')
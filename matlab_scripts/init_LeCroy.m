% Create a TCPIP object.
%interfaceObj = instrfind('Type', 'tcpip', 'RemoteHost', '127.0.0.1', 'RemotePort', 1861, 'Tag', '');
visaObj = visa('agilent','USB0::0x05FF::0x1023::2814N61911::0::INSTR');

% Create the TCPIP object if it does not exist
% otherwise use the object that was found.
% if isempty(interfaceObj)
%     interfaceObj = tcpip('172.31.146.86', 1861);
% else
%     fclose(interfaceObj);
%     interfaceObj = interfaceObj(1);
% end

% Create a device object. 
deviceObj = icdevice('lecroy_basic_driver.mdd', visaObj);

% Connect device object to hardware.
connect(deviceObj);
groupObj = get(deviceObj, 'Waveform');
groupObj = groupObj(1);

% groupObj2 = get(deviceObj, 'Waveform');
% groupObj2 = groupObj2(1);

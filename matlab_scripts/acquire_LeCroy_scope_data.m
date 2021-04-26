% ACQUIRE_LECROY_SCOPE_DATA M-Code for communicating with an instrument. 
%  
%   This is the machine generated representation of an instrument control 
%   session using a device object. The instrument control session comprises  
%   all the steps you are likely to take when communicating with your  
%   instrument. These steps are:
%       
%       1. Create a device object   
%       2. Connect to the instrument 
%       3. Configure properties 
%       4. Invoke functions 
%       5. Disconnect from the instrument 
%  
%   To run the instrument control session, type the name of the M-file,
%   acquire_LeCroy_scope_data, at the MATLAB command prompt.
% 
%   The M-file, ACQUIRE_LECROY_SCOPE_DATA must be on your MATLAB PATH. For additional information
%   on setting your MATLAB PATH, type 'help addpath' at the MATLAB command
%   prompt.
%
%   Example:
%       acquire_LeCroy_scope_data;
%
%   See also ICDEVICE.

% Copyright 2009 - 2010 The MathWorks, Inc.
%   Creation time: 08-Jan-2009 14:37:45 


% Create a TCPIP object.
%interfaceObj = instrfind('Type', 'tcpip', 'RemoteHost', '127.0.0.1', 'RemotePort', 1861, 'Tag', '');
%%%%visaObj = visa('agilent','USB0::0x05FF::0x1023::2814N61911::0::INSTR');

% Create the TCPIP object if it does not exist
% otherwise use the object that was found.
% if isempty(interfaceObj)
%     interfaceObj = tcpip('172.31.146.86', 1861);
% else
%     fclose(interfaceObj);
%     interfaceObj = interfaceObj(1);
% end

% Create a device object. 
%%%%deviceObj = icdevice('lecroy_basic_driver.mdd', visaObj);

% Connect device object to hardware.
%%%%connect(deviceObj);

% % Execute device object function(s).
% groupObj = get(deviceObj, 'Waveform');
% groupObj = groupObj(1);
[Y, T, XUNIT, YUNIT, HEADER] = invoke(groupObj, 'readwaveform', 'channel2');
[TRIG, T2, XUNIT2, YUNIT2, HEADER2] = invoke(groupObj2, 'readwaveform', 'channel3');
[FILT_Y, T3, XUNIT3, YUNIT3, HEADER3] = invoke(groupObj2, 'readwaveform', 'traceB');
%%%%groupObj2 = get(deviceObj, 'Waveform');
%%%%groupObj2 = groupObj2(1);
%[Y2, T2, XUNIT2, YUNIT2, HEADER2] = invoke(groupObj2, 'readwaveform', 'channel2');

%%%%groupObj3 = get(deviceObj, 'Waveform');
%%%%groupObj3 = groupObj3(1);
% [Y3, T3, XUNIT3, YUNIT3, HEADER3] = invoke(groupObj3, 'readwaveform', 'channel3');


%[Y2, T2, XUNIT2, YUNIT2, HEADER2] = invoke(groupObj, 'readwaveform', 'channel2');

% Disconnect device object from hardware.
%%%%disconnect(deviceObj);

% Delete objects.
%%%%delete([deviceObj visaObj]);

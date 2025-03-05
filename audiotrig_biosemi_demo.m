

clear;clc;close all

%%
fs = 44100;
dur = 0.05;
t = (1:dur*fs)*(1/fs);
tone = sin(2*pi*1000*t');
    xx = tone;% This is just for trial
    xx_rate = fs;


%%
try
numDevices = PsychPortAudio('GetOpenDeviceCount');
if numDevices==0
error('sound already intialized')
end
catch ME
    InitializePsychSound(1) % initalizing psychtoolbox audio drivers
    devs= PsychPortAudio('GetDevices');
    disp('Initialized PsychSound done')
end

%% 

portName = 'COM5';
baudRate = 115200;
[port, errmsg] = IOPort('OpenSerialPort', portName, 'BaudRate=115200');

if ~isempty(errmsg)
    error(['error opening port' errmsg])
end
    pahandle = PsychPortAudio('Open', 14,1,4,xx_rate,2);
    PsychPortAudio('FillBuffer', pahandle, [xx';xx'])

%%
jit = [];
for i= 1:500
clc
      [nwritten, when, errmsg, prewritetime, postwritetime, lastchecktime]= IOPort('Write', port, uint8(1),3); % port high

    synctime = when+0.017;
        % WaitSecs(0.002);
    IOPort('Write', port, uint8(0)); % port low

    starttime = PsychPortAudio('Start', pahandle, 1, synctime, 1);


    disp(['trigger sent at ', num2str(synctime)])
    disp(['audio played at ', num2str(starttime)])
    disp(['offset =  ', num2str((starttime-synctime)*1e3), 'ms'])
    offset = (starttime-synctime)*1e3;
    if offset>0.0005
      [nwritten, when, errmsg, prewritetime, postwritetime, lastchecktime]= IOPort('Write', port, uint8(255),3); % port high
      [nwritten, when, errmsg, prewritetime, postwritetime, lastchecktime]= IOPort('Write', port, uint8(0),3); % port high
    disp('errortrig sent')
    end

        jit(i,1) = (starttime-synctime)*1e3;

    while PsychPortAudio('GetStatus', pahandle).Active
        WaitSecs(0.01);  % Check every 10ms
    end    
    PsychPortAudio('Stop', pahandle);
     WaitSecs(0.017)

    disp(num2str(i))
end
%%
IOPort('Close', port)

PsychPortAudio('Close', pahandle)

%%
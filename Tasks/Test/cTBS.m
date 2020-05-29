commandwindow;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Prompt Info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prompt = {'Enter ID:','Session Number:', 'Intensity of Stimulation:', 'Duration of Stimulation:'};
run_info = inputdlg(prompt, 'Info', 1, {' ', '1', '0', '40'});
SubID =run_info{1};
SessionNo = run_info{2};
intensity = str2num(run_info{3});
Seconds = str2num(run_info{4});

%Every seconds 5 trains are delivered. Each train of pulses is composed of
%3 pulses, so every seconds 15 pulses are delivered
Duration = Seconds * 5;

DateT = date;
HideCursor()

device=0;
pulse_shape=1;
pulse_time=[0 20 40];

display=1;
PM100=PM100_Class;

% create COM port object
obj=PM100.create_COM_object(display,4);

% reset stimulator interface
PM100.reset(obj);

% get ID
ID=PM100.get_ID(obj,device,display);

% get status
STATUS=PM100.get_status(obj,device,display);

% get coil temperature
[CT,coil_temp]=PM100.get_coil_temperature(obj,device,display);


% setup stimulation protocol
PM100.setup_protocol(obj,device,pulse_shape,intensity,pulse_time,1)


pause(3)

for i=1:Duration
    
    % activate stimulator
    PM100.activate(obj,device)
    
    % start stimulation (run protocol)
    PM100.start_stimulation(obj,device)
    
    WaitSecs(0.2);
    
end
%deactivate stimulator
PM100.deactivate(obj,device)


s=instrfind;
fclose(s)
delete(s)

ShowCursor();
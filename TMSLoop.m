device=0;
pulse_shape=1;
pulse_time=[0 50 100 150];
intensity= [80 80 80 80];
display=1;
PM100=PM100_Class;

% create COM port object
obj=PM100.create_COM_object(display);

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

for i=1:3
    
    % activate stimulator
    PM100.activate(obj,device)
    
    % start stimulation (run protocol)
    PM100.start_stimulation(obj,device)
    
    WaitSecs(2);
    
end
%deactivate stimulator
PM100.deactivate(obj,device)


s=instrfind;
fclose(s)
delete(s)


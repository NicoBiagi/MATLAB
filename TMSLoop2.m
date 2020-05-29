device=0;
pulse_shape=1;
pulse_time=[0 100 200 300];
intensity= [70 80 90 100];
pulse_time2=[0 50 100 150];
intensity2= [80 80 80 80];
display=1;
PM100=PM100_Class;

try
% create COM port object
obj1=PM100.create_COM_object(display,6);
obj2=PM100.create_COM_object(display,7);

% reset stimulator interface
PM100.reset(obj1);
PM100.reset(obj2);

% get ID
ID1=PM100.get_ID(obj1,device,display);
ID2=PM100.get_ID(obj2,device,display);

% get status
STATUS1=PM100.get_status(obj1,device,display);
STATUS2=PM100.get_status(obj2,device,display);

% get coil temperature
[CT1,coil_temp1]=PM100.get_coil_temperature(obj1,device,display);
[CT2,coil_temp2]=PM100.get_coil_temperature(obj2,device,display);


% setup stimulation protocol
PM100.setup_protocol(obj1,device,pulse_shape,intensity,pulse_time,1)
PM100.setup_protocol(obj2,device,pulse_shape,intensity2,pulse_time2,1)


pause(3)

for i=1:3
    
    % activate stimulator
    PM100.activate(obj1,device)
    PM100.activate(obj2,device)
    
    % start stimulation (run protocol)
    PM100.start_stimulation(obj1,device)
    PM100.start_stimulation(obj2,device)
    
    WaitSecs(2);
    
end
%deactivate stimulator
PM100.deactivate(obj1,device)
PM100.deactivate(obj2,device)


s=instrfind;
fclose(s)
delete(s)

catch
s=instrfind;
fclose(s)
delete(s)
    
end
%%%%First copy the .asc file in excel
clear;
clc;

cd 'C:\Users\zj903545\OneDrive - University of Reading\PhD\Undergraduate Project\2nd Project\Script\Pilot'

% Load the .xlsx file
filename = 'Pilot.xlsx';
[num text raw] = xlsread(filename);

str_text = string(text);
str= str_text(:,1);
str2 = str_text(:,2);

start_index = find(str == 'START');
start = cell2mat(raw(start_index,2));


%% Get all the messages

MSG0 = find(str == 'MSG');
MSG=[];
x = 1;
for i = 1:length(MSG0)
    % remove the MSG that are before the start of the experiment (i.e., the
    % calibration)
    if MSG0(i) > start_index
        MSG(x) = MSG0(i);
        x= x+1;
    end
end

MSG= MSG';
% the time-stamp for the message is in the row below the MSG
MSG_time0 = MSG+1;

x = 1;
MSG_time = [];
x = 1;
for i = 1:length(MSG_time0)
    a = cell2mat(raw(MSG_time0(i),1));
    if isa(a,'double') ==1
        MSG_time(x) = MSG_time0(i);
        x=x+1;
    else
        tt =1;
        while isa(cell2mat(raw(MSG_time0(i)+tt,1)),'double')~=1
            tt=tt+1;
        end
        MSG_time(x) = MSG_time0(i)+tt;
        x=x+1;
    end
    
end

MSG_time =MSG_time';

MSG_MON = find(contains(str2, 'MULLERON')==1);
MSG_MOFF = find(contains (str2, 'MULLEROFF')==1);

%% Get all the saccades
SAC0 = find(contains(str, 'SACC')==1);
x = 1;
for i = 1:length(SAC0)
    if SAC0(i) > start_index
        SAC(x)=SAC0(i);
        x=x+1;
    end
end
%% Get all the fixation
FIX0 = find(contains(str, 'FIX')==1);
x = 1;
for i = 1:length(FIX0)
    if FIX0(i) > start_index
        FIX(x)=FIX0(i);
        x=x+1;
    end
end
%% Get all the blinks
BLINK0 = find(contains(str, 'BLINK')==1);
x = 1;
for i = 1:length(BLINK0)
    if BLINK0(i) > start_index
        BLINK(x)=BLINK0(i);
        x=x+1;
    end
end

%%

if length(MSG_MON) == length(MSG_MOFF)
    for i =1:length(MSG_MON)
        SSAC_raw{:,i} = find(contains(str(MSG_MON(i):MSG_MOFF(i)),'SSAC')==1)+MSG_MON(i);
        ESAC_raw{:,i} = find(contains(str(MSG_MON(i):MSG_MOFF(i)),'ESAC')==1)+MSG_MON(i);
        
    end
else
end
%%
x=1;
y=1;
for i = 1:length(SSAC_raw)
    rep=0;
    for x = 1:length(SSAC_raw{1,i})
        for y = 1:length(ESAC_raw{1,i})
            if SSAC_raw{1,i}(x) < ESAC_raw{1,i}(y)
                rep = rep+1;
                temp_SSAC(rep) = SSAC_raw{1,i}(x);
                temp_ESAC(rep) = ESAC_raw{1,i}(y);
            end
        end
    end
    if exist('temp_SSAC') == 0
        temp_SSAC = nan;
        temp_ESAC = nan;
    end
    SSAC{1,i} = unique(temp_SSAC);
    ESAC{1,i} = unique(temp_ESAC);
    clearvars temp_SSAC temp_ESAC
end

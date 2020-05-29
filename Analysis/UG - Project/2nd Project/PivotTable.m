clear;
clc;
format long g

cd 'C:\Users\zj903545\OneDrive - University of Reading\PhD\Undergraduate Project\2nd Project\Script\Pilot\Eye-tracker data\Excel\Final';
a =pwd;
files_excel0 = dir(strcat(a, '/*.xlsx'));
x=1;
for i = 1:length(files_excel0)
    if contains(files_excel0(i).name, 'Pivot')==0 && contains(files_excel0(i).name, 'SPSS')==0
        files_excel(x)=files_excel0(i);
        x = x+1;
    end
end
%%
clearvars -except files_excel;
clc
for i = 1:length(files_excel)
    if contains(files_excel(i).name, 'MT1')
        task = 'MT1';
    elseif contains(files_excel(i).name, 'RS1')
        task = 'RS1';
    elseif contains(files_excel(i).name, 'RS2')
        task = 'RS2';
    elseif contains(files_excel(i).name, 'RS3')
        task = 'RS3';
    elseif contains(files_excel(i).name, 'VS1')
        task = 'VS1';
    elseif contains(files_excel(i).name, 'VS2')
        task = 'VS2';
    end
    
    % load the excel file
    [num text raw] = xlsread(files_excel(i).name);
    
    % get the PPS IDs
    id = text(:,1);
    ID=[];
    for k = 2:length(id)
        ID{k} = id{k}(end);
    end
    ID(1)=[];
    ID= string(ID)';
    ID = str2double(ID);
    num= [num ID];
    
    % remove dummy trials
    ones= find(num(:,16)==1);
    num(ones,:)=[];
    
    %remove the adjusted trials
    adjusted = find(num(:,1) == 1);
    if isempty(adjusted)== 0
        before_adj = length(num);
        num(adjusted,:)= [];
    else
    end
    after_adj = length(num);
    
    % remove the trials in whihc a blinking occurred
    blinking = find(num(:,5) == 1);
    if isempty(blinking) == 0
        before_b = length(num);
        num(blinking, :) = [];
    else
    end
    after_b = length(num);
    
    % get the horizontal length of the saccade.
    % If X_length > 0, saccade is rightwards, otherwise is leftwards
    X_length = num(:,8) - num(:,13);
    
    % get the vertical length of the saccade.
    % If Y_length > 0 saccade is downwards, otherwise is upwards
    Y_length = num(:,9) - num(:,14);
    
    % get the direction of the saccade
    for l = 1:length(num)
        if X_length(l) >0 & X_length(l)>abs(Y_length(l));
            Direction{l} = 'RIGHT';
        elseif X_length(l) <0 & abs(X_length(l))>abs(Y_length(l));
            Direction{l} = 'LEFT';
        elseif Y_length(l)> 0 Y_length(l)>abs(X_length(l));
            Direction{l} = 'DOWN';
        elseif Y_length(l)< 0 abs(Y_length(l))>abs(X_length(l));
            Direction{l} = 'UP';
        end
    end
    
    Direction = Direction';
    
    %get the number of trials before removing the saccades going in the WRONG
    %direction
    before_direction = length(num);
    
    % remove all saccades that are upwards
    up1 = startsWith(Direction, 'UP');
    up = find(up1==1);
    
    % remove all the saccades that are downwards
    down1 = startsWith(Direction, 'DOWN');
    down = find(down1==1);
    
    wrong_direction = [up; down];
    wrong_direction = sort(wrong_direction);
    num(wrong_direction,:)=[];
    
    Direction(wrong_direction)=[];
    Direction = string(Direction);
    
    for h= 1:length(Direction)
        if Direction(h) == 'LEFT';
            DIRECTION{h} = 0;
        elseif Direction(h) == 'RIGHT';
            DIRECTION{h} = 1;
        end
    end
    
    
    DIRECTION = DIRECTION';
    DIRECTION = string(DIRECTION);
    DIRECTION = str2double(DIRECTION);
    num = [num DIRECTION];
    
    %get the number of trials after removing the saccades going in the WRONG
    %direction
    after_direction = length(num);
    
    % get the number of participants
    PP= unique(ID);
    PP= string(PP);
    PP = str2double(PP);
    
    % get the trial ID
    TrialID = unique(num(:,16));
    TrialID = string(TrialID);
    TrialID = str2double(TrialID);
    cols = [2 3 4 7 8 9 11 12 13 14 16 18 19];
    
    % get the directions of saccades
    direc = unique(DIRECTION);
    
    for k = 1:length(PP)
        pp =PP(k);
        for j =1:length(TrialID)
            first_task = TrialID(j);
            for t= 1:length(direc)
                dd= direc(t);
                b{j,k,t} = find(num(:,16) == first_task & num(:,18)== pp & num(:,19)==dd);
                data(j,1:length(cols),t,k) = nanmean(num(b{j,k,t},cols),1);
            end
        end
    end
    
    data_reshaped = reshape(data(:,:,:,:), size(data,1), size(data,2),[length(PP)*length(direc)]);
    dataset = permute(data_reshaped,[1 3 2]);Rnew = R(~cellfun(@isempty, R))
    dataset = reshape(dataset,[],size(data_reshaped,2),1);
    dataset2 = [dataset(:,12:end) dataset(:,11) dataset(:,1:end-3)];
    nan= find(isnan(dataset2(:,1)));
    dataset2(nan,:)=[];
    dataset2(:,3) = dataset2(:,3)-1;
    
    
    
    
    
    filename = [task '-Pivot1.xlsx'];
    xlswrite(filename, dataset2);
    clearvars -except files_excel
    
end

%%
%load the MATLAB output with the trial type
clear
clc
cd 'C:\Users\zj903545\OneDrive - University of Reading\PhD\Undergraduate Project\2nd Project\Script\Pilot\MATLAB data\Excel-TrialList';
a = pwd;
files_matlab0 = dir(strcat(a, '/*.csv'));
x=1;
for i = 1:length(files_matlab0)
    if contains(files_matlab0(i).name, 'BT')==0
        files_matlab(x)=files_matlab0(i);
        x = x+1;
    end
end

cd 'C:\Users\zj903545\OneDrive - University of Reading\PhD\Undergraduate Project\2nd Project\Script\Pilot\Eye-tracker data\Excel\Final';
a =pwd;
files_excel0 = dir(strcat(a, '/*.xlsx'));
y=1;
for i = 1:length(files_excel0)
    if contains(files_excel0(i).name, 'Pivot1')==1
        files_excel(y)=files_excel0(i);
        y = y+1;
    end
end
%%
for i =1:length(files_excel)
    for k = 1:length(files_matlab)
        if contains(files_excel(i).name, 'VS1')==1
            if contains(files_matlab(k).name, 'VS1')==1
                task ='VS1';
                data_matlab = csvread([files_matlab(k).folder '\' files_matlab(k).name]);
            end
        elseif contains(files_excel(i).name, 'VS2')==1
            if contains(files_matlab(k).name, 'VS2')==1
                task ='VS2';
                data_matlab = csvread([files_matlab(k).folder '\' files_matlab(k).name]);
            end
        elseif contains(files_excel(i).name, 'RS1')==1
            if contains(files_matlab(k).name, 'RS1')==1
                task ='RS1';
                data_matlab = csvread([files_matlab(k).folder '\' files_matlab(k).name]);
            end
        elseif contains(files_excel(i).name, 'RS2')==1
            if contains(files_matlab(k).name, 'RS2')==1
                task ='RS2';
                data_matlab = csvread([files_matlab(k).folder '\' files_matlab(k).name]);
            end
        elseif contains(files_excel(i).name, 'RS3')==1
            if contains(files_matlab(k).name, 'RS3')==1
                task ='RS3';
                data_matlab = csvread([files_matlab(k).folder '\' files_matlab(k).name]);
            end
        elseif contains(files_excel(i).name, 'MT1')==1
            if contains(files_matlab(k).name, 'MT1')==1
                task ='MT1';
                data_matlab = csvread([files_matlab(k).folder '\' files_matlab(k).name]);
            end
        end
    end
    
    data_pivot= xlsread([files_excel(i).folder '\' files_excel(i).name]);
    PPs = unique(data_pivot(:,1));
    Trials = unique (data_matlab(:,3));
    % [ParticipantID TrialID]
    row_matlab= [data_matlab(:,1) data_matlab(:,3)];
    % [ParticipantID TrialID ]
    row_pivot =[data_pivot(:,1) data_pivot(:,3)];
    ids(1:length(data_pivot))=0;
    all_direction1(1:length(data_pivot))=0;
    all_direction2(1:length(data_pivot))=0;
    all_direction3(1:length(data_pivot))=0;
    all_direction4(1:length(data_pivot))=0;
    if size(data_matlab,2)~=6
        for t = 1:length(PPs)
            pp=PPs(t);
            for j = 1:length(Trials)
                trial = Trials(j);
                idx_matlab = find(row_matlab(:,1) == pp & row_matlab(:,2)==trial);
                idx_pivot = find(row_pivot(:,1) == pp & row_pivot(:,2)==trial);
                
                ids(idx_pivot) = data_matlab(idx_matlab,1);
                all_direction1(idx_pivot) = data_matlab(idx_matlab,3);
                all_direction2(idx_pivot) = data_matlab(idx_matlab,4);
                all_direction3(idx_pivot) = data_matlab(idx_matlab,5);
            end
            
        end
        
        ids = ids';
        all_direction1 = all_direction1';
        all_direction2 = all_direction2';
        all_direction3 = all_direction3';
        final = [ids all_direction1 all_direction2 all_direction3];
        data_pivot = [data_pivot all_direction2 all_direction3];
        
    else
        for t = 1:length(PPs)
            for j = 1:length(Trials)
                
                idx_matlab = find(row_matlab(:,1) == t & row_matlab(:,2)==j);
                idx_pivot = find(row_pivot(:,1) == t & row_pivot(:,2)==j);
                
                ids(idx_pivot) = data_matlab(idx_matlab,1)';
                all_direction1(idx_pivot) = data_matlab(idx_matlab,3);
                all_direction2(idx_pivot) = data_matlab(idx_matlab,4);
                all_direction3(idx_pivot) = data_matlab(idx_matlab,5);
                all_direction4(idx_pivot) = data_matlab(idx_matlab,6);
            end
        end
        
        
        ids = ids';
        all_direction1 = all_direction1';
        all_direction2 = all_direction2';
        all_direction3 = all_direction3';
        all_direction4 = all_direction4';
        final = [ids all_direction1 all_direction2 all_direction3 all_direction4];
        data_pivot = [data_pivot all_direction2 all_direction3 all_direction4];
    end
    
    filename = [task '-Pivot2.xlsx'];
    xlswrite(filename, data_pivot);
    clearvars -except files_excel files_matlab
    
end
%%
clear
clc
format long g
cd 'C:\Users\zj903545\OneDrive - University of Reading\PhD\Undergraduate Project\2nd Project\Script\Pilot\Eye-tracker data\Excel\Final';
a =pwd;
files_excel0 = dir(strcat(a, '/*.xlsx'));
y=1;
for i = 1:length(files_excel0)
    if contains(files_excel0(i).name, 'Pivot2')==1
        files_excel(y)=files_excel0(i);
        y = y+1;
    end
end
%%
for i = 1:length(files_excel)
    if contains(files_excel(i).name, 'MT1')
        task = 'MT1';
    elseif contains(files_excel(i).name, 'RS1')
        task = 'RS1';
    elseif contains(files_excel(i).name, 'RS2')
        task = 'RS2';
    elseif contains(files_excel(i).name, 'RS3')
        task = 'RS3';
    elseif contains(files_excel(i).name, 'VS1')
        task = 'VS1';
    elseif contains(files_excel(i).name, 'VS2')
        task = 'VS2';
    end
    
    % load the excel file
    [num text raw] = xlsread(files_excel(1).name);
    
    % unique PP ID
    PP= unique(num(:,1));
    
    % unique saccade direction
    Direction = unique(num(:,2));
    
    if size(num,2)~=16
        % task1 is the wing direction
        task1 = unique(num(:,14));
        % task2 is the direction/shaft length
        task2 = unique(num(:,15));
        %task2 = [-1];
    else
        % task1 is the wing direction
        task1 = unique(num(:,14));
        % task2 is the wing direction
        task2 = unique(num(:,15));
        % task3 is the wing direction
        task3 = unique(num(:,16));
    end
    
    %cols = [4 5 6 7 8 9 10 11 12 13];
    cols = [4];
    
    if size(num,2)~=16
        for k = 1:length(PP)
            pp =PP(k);
            for t= 1:length(Direction)
                dd= Direction(t);
                for z=1:length(task2)
                    second_task = task2(z);
                    for j =1:length(task1)
                        first_task = task1(j);
                        
                        
                        
                        b{k,t,z,j} = find(num(:,1)== pp & num(:,14) == first_task & num(:,15) == second_task & num(:,2)==dd);
                        data(k,1:length(cols),t,z,j) = nanmean(num(b{k,t,z,j},cols),1);
                    end
                end
            end
        end
    end
    
    
    
    %         filename = [task '-Pivot3.xlsx'];
    %         xlswrite(filename, data_pivot);
    %         clearvars -except files_excel
end
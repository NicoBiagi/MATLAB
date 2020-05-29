clear
clc

cd 'C:\Users\zj903545\OneDrive - University of Reading\PhD\Undergraduate Project\2nd Project\Script\Pilot\Eye-tracker data\Excel\Final\Old\Manual\Pivot1';

a= pwd;

files_excel0 = dir(strcat(a, '/*.xlsx'));
x=1;
for i = 1:length(files_excel0)
    if contains(files_excel0(i).name, 'Pivot')==1
        files_excel(x)=files_excel0(i);
        x = x+1;
    end
end
%%
cd 'C:\Users\zj903545\OneDrive - University of Reading\PhD\Undergraduate Project\2nd Project\Script\Pilot\Eye-tracker data\Excel\Final\Old\Manual\Matlab';
b = pwd;
files_matlab0 = dir(strcat(b, '/*.xlsx'));
y=1;
z=1;
for i = 1:length(files_matlab0)
    if contains(files_matlab0(i).name, 'MATLAB')==1
        files_matlab1(y)=files_matlab0(i);
        y = y+1;
    end
end
for i = 1:length(files_matlab1)
    if contains(files_matlab1(i).name, 'BT')==0
        files_matlab(z) = files_matlab1(i);
        z = z+1;
    end
end

%%

for i = 1:length(files_excel)
    for k = 1:length(files_matlab)
        if contains(files_excel(i).name, 'MT1')==1
            if contains(files_matlab(k).name, 'MT1') ==1
                filename = ['MT1-Prova.xlsx'];
            end
        elseif  contains(files_excel(i).name, 'RS1')==1
            if contains(files_matlab(k).name, 'RS1') ==1
                filename = ['RS1-Prova.xlsx'];
            end
        elseif  contains(files_excel(i).name, 'RS2')==1
            if contains(files_matlab(k).name, 'RS2') ==1
                filename = ['RS2-Prova.xlsx'];
            end
        elseif  contains(files_excel(i).name, 'RS3')==1
            if contains(files_matlab(k).name, 'RS3') ==1
                filename = ['RS3-Prova.xlsx'];
            end
        elseif  contains(files_excel(i).name, 'VS1')==1
            if contains(files_matlab(k).name, 'VS1') ==1
                filename = ['VS1-Prova.xlsx'];
            end
        elseif  contains(files_excel(i).name, 'VS2')==1
            if contains(files_matlab(k).name, 'VS2') ==1
                filename = ['VS2-Prova.xlsx'];
            end
        end
    end
    
    
    data_pivot= xlsread([files_excel(i).folder '\' files_excel(i).name]);
    data_matlab = xlsread([files_matlab(k).folder '\' files_matlab(k).name]);
    PPs = unique(data_pivot(:,1));
    Trials = unique (data_matlab(:,3));
    long= [data_matlab(:,3) data_matlab(:,1)];;
    short =[data_pivot(:,3) data_pivot(:,2) data_pivot(:,1)];
    all_direction1 = 0;
    all_direction2 = 0;
    all_direction3 =0;
    all_direction4 =0;
    if size(data_matlab,2)~=6
        for t = 1:length(PPs)
            for j = 1:length(Trials)
                
                idx_long = find(long(:,1) == j & long(:,2)==t);
                idx_short = find(short(:,2) == j & short(:,3)==t);
                
                all_direction1(end+1:end+length(idx_short),1) = repmat(data_matlab(idx_long,3), length(idx_short),1);
                all_direction2(end+1:end+length(idx_short),1) = repmat(data_matlab(idx_long,4), length(idx_short),1);
                all_direction3(end+1:end+length(idx_short),1) = repmat(data_matlab(idx_long,5), length(idx_short),1);
            end
            
        end
        all_direction1 = all_direction1(2:end);
        all_direction2 = all_direction2(2:end);
        all_direction3 = all_direction3(2:end);
        final = [all_direction1 all_direction2 all_direction3];
        data_pivot = [data_pivot all_direction2 all_direction3];
        
    else
        for t = 1:length(PPs)
            for j = 1:length(Trials)
                
                idx_long = find(long(:,1) == j & long(:,2)==t);
                idx_short = find(short(:,2) == j & short(:,3)==t);
                
                all_direction1(end+1:end+length(idx_short),1) = repmat(data_matlab(idx_long,3), length(idx_short),1);
                all_direction2(end+1:end+length(idx_short),1) = repmat(data_matlab(idx_long,4), length(idx_short),1);
                all_direction3(end+1:end+length(idx_short),1) = repmat(data_matlab(idx_long,5), length(idx_short),1);
                all_direction4(end+1:end+length(idx_short),1) = repmat(data_matlab(idx_long,6), length(idx_short),1);
            end
        end
        
        all_direction1 = all_direction1(2:end);
        all_direction2 = all_direction2(2:end);
        all_direction3 = all_direction3(2:end);
        all_direction4 = all_direction4(2:end);
        final = [all_direction1 all_direction2 all_direction3 all_direction4];
        data_pivot = [data_pivot all_direction2 all_direction3 all_direction4];
    end
    xlswrite(filename, data_pivot);
    clearvars -except files_excel files_matlab
    
end
%%
clear
b =pwd;
files_final0= dir(strcat(b, '/*.xlsx'));
y= 1;
for i = 1:length(files_final0)
    if contains(files_final0(i).name, 'MATLAB')==0
        files_final(y)=files_final0(i);
        y = y+1;
    end
end


     
clear
clc
format long g
cd 'C:\Users\zj903545\OneDrive - University of Reading\PhD\Undergraduate Project\2nd Project\Script\Pilot\Eye-tracker data\Excel\Final';
a =pwd;

files_excel0 = dir(strcat(a, '/*.xlsx'));
x=1;
for i = 1:length(files_excel0)
    if contains(files_excel0(i).name, 'Pivot2')==1
        files_excel(x)=files_excel0(i);
        x = x+1;
    end
end
%%

for h = 1:length(files_excel)
    % load the excel file
    [num text raw] = xlsread(files_excel(h).name);
    % get the number of pp
    ID = unique(num(:,1));
    if contains(files_excel(h).name, 'MT1')
        % get the name for save the file later on
        task = 'MT1';
        % values for the external wings
        a = [-1 0 1];
        % name for the variables
        a_name ={'inwards' 'flat' 'outwards'};
        % for MT1 the second column is the shaft direction
        b = [-1 0];
        % name fo the variables
        b_name = {'shaft_left' 'shaft_right'};
        % for MT1 the third column is the saccades direction
        c= [0 1];
        % name for the variables
        c_name = {'leftwards' 'rightwards'};
        d= 1;
        % name for the variables
        d_name = {'a'};
        
    elseif contains(files_excel(h).name, 'RS1')
        task = 'RS1';
        a = [-1 0 1];
        % name for the variables
        a_name ={'inwards' 'flat' 'outwards'};
        b = [1 2 4];
        % name for the variables
        b_name = {'shaft1' 'shaft2' 'shaft3'};
        c= [0 1];
        % name for the variables
        c_name = {'leftwards' 'rightwards'};
        d= 1;
        % name for the variables
        d_name = {'a'};
        
    elseif contains(files_excel(h).name, 'RS2')
        task = 'RS2';
        a = [-1 0 1];
        % name for the variables
        a_name ={'inwards' 'flat' 'outwards'};
        b = [1 2 4];
        % name for the variables
        b_name = {'shaft1' 'shaft2' 'shaft3'};
        c= [0 1];
        % name for the variables
        c_name = {'leftwards' 'rightwards'};
        d= 1;
        % name for the variables
        d_name = {'a'};
        
    elseif contains(files_excel(h).name, 'RS3')
        task = 'RS3';
        a = [-1 0 1];
        % name for the variables
        a_name ={'inwards' 'flat' 'outwards'};
        b = [-1 0];
        % name for the variables
        b_name = {'left' 'right'};
        c= [0 1];
        % name for the variables
        c_name = {'leftwards' 'rightwards'};
        d= 1;
        % name for the variables
        d_name = {'a'};
        
    elseif contains(files_excel(h).name, 'VS1')
        task = 'VS1';
        a = [-1 0 1];
        % name for the variables
        a_name ={'inwards' 'flat' 'outwards'};
        b = [1 2];
        % name for the variables
        b_name = {'shaft1' 'shaft2'};
        c= [0 1];
        % name for the variables
        c_name = {'audio_left' 'audio_right'};
        d= [0 1];
        % name for the variables
        d_name = {'leftwards' 'rightwards'};
        
    elseif contains(files_excel(h).name, 'VS2')
        task = 'VS2';
        a = [-1 0 1];
        % name for the variables
        a_name ={'inwards' 'flat' 'outwards'};
        b = [1 2];
        % name for the variables
        b_name = {'shaft1' 'shaft2'};
        c = [0 1];
        % name for the variables
        c_name = {'blue' 'red'};
        d= [0 1];
        % name for the variables
        d_name = {'leftwards' 'rightwards'};
        
    end
    % names for the variables THEY NEED TO BE IN THIS ORDER IN THE FINAL
    % EXCEL SHEET
    m_names = {'amplitudes' 'angles' 'avg_velocity' 'duration' 'length_x' 'length_y' 'start_x' 'end_x' 'start_y' 'end_y' 'peak_velocity' 'start_time' 'count'};
    filename = ['SPSS-ready-' task '.xlsx'];
    
    % Looping through all the participants
    for ppt = 1:length(ID)
        y = 1;
        if length(d)~= 1
            %for all the varibles
            for measure = 6:size(num,2)
                x = 1;
                for i=1:3
                    for j=1:2
                        for k =1:length(c)
                            for t = 1:length(d)                                                               
                                idx= find(num(:,1) == ppt & num(:,2) == a(i) & num(:,3) == b(j) & num(:,4)==c(k) & num(:,5)==d(t));
                                header{y} = [m_names{measure-5} '_' a_name{i} '_' b_name{j}  '_' c_name{k} '_' d_name{t} ];                                
                                all_data(ppt,x, measure) = nanmean(num(idx,measure));
                                x=x+1;
                                y = y+1;
                                
                            end
                        end
                    end
                end
            end
        else
            for measure = 5:size(num,2)
                x = 1;
                for i=1:3
                    for j=1:2
                        for k =1:length(c)
                            for t = 1:length(d)  
                                idx= find(num(:,1) == ppt & num(:,2) == a(i) & num(:,3) == b(j) & num(:,4)==c(k));
                                header{y} = [m_names{measure-4} '_' a_name{i} '_' b_name{j}  '_' c_name{k}];                                
                                all_data(ppt,x, measure) = nanmean(num(idx,measure));
                                x=x+1;
                                y = y+1;
                                
                            end
                        end
                    end
                end
            end
        end
    end
    
    if length(d)~= 1
        all_data_new = reshape(all_data, [length(ID),24*size(num,2)]);
        all_data_new = all_data_new(:,121:end);
    else
        all_data_new = reshape(all_data, [length(ID),12*size(num,2)]);
        all_data_new = all_data_new(:,49:end);
    end
    
    spss_filename = [task];
    final_data = [header; num2cell(all_data_new)];
    xlswrite(filename,final_data);
    %export2spss(header,all_data_new,spss_filename);
    clearvars -except files_excel
end
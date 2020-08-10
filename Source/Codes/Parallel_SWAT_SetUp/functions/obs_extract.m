function [weight,behave_thredshold, variabl_all ] = obs_extract( file_name )
%  SUFI2_in='D:\Work_2020\Papers\SWAT\SWAT_Calibration\Muti_lumped_calibaration\muti_sptail.Sufi2.SwatCup\SUFI2.IN\';
% SUFI2_out='D:\Work_2020\Papers\SWAT\SWAT_Calibration\Muti_lumped_calibaration\muti_sptail.Sufi2.SwatCup\SUFI2.IN\';

%% observed_rch.txt
 fid=fopen(file_name,'r');
% fid=fopen([SUFI2_in, 'observed.txt'],'r');
L=1;
while ~feof(fid)
    str=fgetl(fid);
    % if ~isempty(str)
    data{L,1}=str;
    L=L+1;
    % end
end
fclose(fid);
split_variabl=': of the simulation, second column is variable name and date (format arbitrary), third column is variable value.';
index = find(strcmp(strtrim(data),split_variabl ));

temp=regexp(data{1}, '\s+', 'split');
num_variable=str2double(temp{1});

variable_length=zeros(length(index),1);
for kk=1:length(index);
    rows=data{index(kk)-1,1};
    temp=regexp(rows, '\s+', 'split');
    variable_length(kk)=str2double(temp{1});
end

%% extract all the observations

    % behave threshold
    behave=data{3};
    behave_temp01=regexp(behave, '\s+', 'split');
    behave_thredshold=str2double(behave_temp01{1});
    
variabl_all=cell(1, num_variable);
weight_all=zeros(1,num_variable);
for mm=1:num_variable
    
    temp =data((index(mm)+1):(index(mm)+variable_length(mm)),1);
    
    % weight
    weigh_temp=data{index(mm)-7};
    weigh_temp01=regexp(weigh_temp, '\s+', 'split');
    weight_all(mm)=str2double(weigh_temp01{1});

    % data
    temp02=zeros(length(temp),2);
    for jj=1:length(temp)
     temp01=regexp(temp{jj}, '\s+', 'split');
     temp02(jj,:)=[str2double(temp01{1}),str2double(temp01{3})];
    end
    variabl_all{mm}=temp02;
end
weight=weight_all;

end



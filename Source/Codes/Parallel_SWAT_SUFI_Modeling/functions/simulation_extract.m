function [ variabl_all ] = simulation_extract( filename)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

fid=fopen(filename,'r');
% fid=fopen([SUFI2_in, 'observed_sub.txt'],'r');
L=1;
split=[];
while ~feof(fid)
    str=fgetl(fid);
    data{L,1}=str;
    
      if length(strtrim(str))<5 % number of simulation <10000
        split=[split;L];
      end   
    L=L+1;
    % end
end
fclose(fid);

%% extract all the observations
variabl_all=cell(length(split),1);
if length(split)<2
    variable_length=length(data);
else
    variable_length=split(2)-split(1)-1;
end


for mm=1:length(split)
    if length(split)<2
        temp=data(2:end);
    else
        temp =data((split(mm)+1):(split(mm)+variable_length),1);
    end
    temp02=zeros(length(temp),2);

    for jj=1:length(temp)
     temp01=regexp(temp{jj}, '\s+', 'split');
     temp02(jj,:)=[str2double(temp01{1}),str2double(temp01{2})];
    end
    variabl_all{mm}=temp02;
end


end


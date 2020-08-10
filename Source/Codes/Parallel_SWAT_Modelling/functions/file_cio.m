function [ ] = file_cio(folder,Num_year,simu_begin, end_julian,IPRINT, NSKIP)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

%define paramter
% folder='D:\Work_2020\Papers\SWAT\SWAT_Calibration\Multi_Station_Clibration\Sptatial_clibration\SWAT_Single_station.Sufi2.SwatCup\';
% Num_year='5';
% simu_begin='2005';
% end_julian='365';

fid=fopen(strcat(folder,'file - Copy.cio'),'r');
L=1;
while ~feof(fid)
    str=fgetl(fid);
    % if ~isempty(str)
    data{L,1}=str;
    L=L+1;
    % end
end
fclose(fid);

fp = fopen(strcat(folder, 'file.cio'),'w+');

for i=1:length(data)
    
    % number of year for simulaiton
    if i==8
        temp01=regexp(data{i}, '\s+', 'split');
        temp01{2}=num2str(Num_year);
        temp02=['           ', strjoin(temp01)];
        data{i,1}=[temp02,' '];
    end
    
    % begin simulation year
    if i==9
        temp01=regexp(data{i}, '\s+', 'split');
        temp01{2}=num2str(simu_begin);
        temp02=['           ', strjoin(temp01)];
        data{i,1}=[temp02,' '];
    end
    
    % End julian day
    if i==11
        temp01=regexp(data{i}, '\s+', 'split');
        temp01{2}=num2str(end_julian);
        temp02=['           ', strjoin(temp01)];
        data{i,1}=[temp02,' '];
    end
    
    % IRPRIN
    if i==59
        temp01=regexp(data{i}, '\s+', 'split');
        temp01{2}=num2str(IPRINT);
        temp02=['              ', strjoin(temp01)];
        data{i,1}=[temp02,' '];
    end
    
       % NSKIP
    if i==60
        temp01=regexp(data{i}, '\s+', 'split');
        temp01{2}=num2str(NSKIP);
        temp02=['              ', strjoin(temp01)];
        data{i,1}=[temp02,' '];
    end
    
    fprintf(fp,'%s\n', data{i,1});
end


%
end


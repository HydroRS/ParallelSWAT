function Num = NumSim_extract( par_inf_file )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
  fid=fopen(par_inf_file,'r');
    % fid=fopen([SUFI2_in, 'observed.txt'],'r');
    L=1;
    while ~feof(fid)
        str=fgetl(fid);
        data{L,1}=str;
        L=L+1;
    end
    if isempty(data{3})
        start_para=4;
    else  start_para=3;
    end
    fclose(fid);
    temp=regexp(data{2}, '\s+', 'split');
    Num=str2num(temp{1});
    
end


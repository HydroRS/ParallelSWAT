function [simu_begin,simu_end] = Sim_begin_end_extract( SUFI2_extract_rch_def )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
  fid=fopen(SUFI2_extract_rch_def,'r');
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
    temp_begin=regexp(data{end-2}, '\s+', 'split');
    temp_end=regexp(data{end-1}, '\s+', 'split');
    simu_begin=str2num(temp_begin{1});
     simu_end=str2num(temp_end{1});
    
end


function [ ] = Paramter_Set_Redistribute( sufi2_in_origin,workers,swat_excute_folder_par )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
% only modify trk is OK


fid=fopen([sufi2_in_origin, 'par_val.txt'],'r');
L=1;
while ~feof(fid)
    str=fgetl(fid);
    data{L,1}=str;
    L=L+1;
end

interval=length(data)/workers;
interval_start=1;
interval_end=interval;
for kk=1:workers
    data_temp=data(interval_start:interval_end);
    
%     fp = fopen([swat_excute_folder_par{kk},'\SUFI2.IN\','par_val.txt'],'w+');
%     fprintf(fp,'%s\n',data_temp{:,1});
    
    dlmwrite([swat_excute_folder_par{kk},'\SUFI2.IN\','trk.txt'],interval_start,'%d');    
    
    interval_start=1+interval_end;
    interval_end=interval_start+interval-1;
end
 
  %     multiple_formt1={'%d';'%9.6f ';'\n'};
%     fprintf(fp,[multiple_formt1{[1 ones(1,Num_parm)*2, 3]}],par_val_data');
 




  
end


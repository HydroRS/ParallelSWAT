function [ output_args ] = write_goal(par_inf_txt, goal_text, par_val_data, no_pars, no_Sims, type_of_goal_fn, subbasin,subbasin_total, first_iteration,StremOrET)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
% par_inf='D:\Work_2020\Papers\SWAT\SWAT_Calibration\Muti_lumped_calibaration\muti_sptail.Sufi2.SwatCup\SUFI2.IN\par_inf.txt';
% par_val='D:\Work_2020\Papers\SWAT\SWAT_Calibration\Muti_lumped_calibaration\muti_sptail.Sufi2.SwatCup\SUFI2.IN\par_val.txt';
% line01='10';
% line02='5';
% line03='KGE'

if StremOrET>0
subbasin=subbasin-1; % only used for streamflow 
end

 fid=fopen(par_inf_txt,'r');
% fid=fopen([SUFI2_in, 'observed.txt'],'r');
L=1;
while ~feof(fid)
    str=fgetl(fid);
    % if ~isempty(str)
    data{L,1}=str;
    L=L+1;
    % end
end

if isempty(data{3})
    start_para=4;
else  start_para=3;
end

range=start_para:length(data);

if subbasin>0 && first_iteration==0
    
    
    
    sub_parm_length=length(range)/subbasin_total;
    range=range(1:sub_parm_length);
    par_val_data=[par_val_data(:,1),par_val_data(:,(sub_parm_length*subbasin-(sub_parm_length-1)+1)...
        :(sub_parm_length*subbasin+1)),par_val_data(:,end) ];
end
 
temp02=cell(1,length(range));
for jj=1:length(range)
    if subbasin==0
    temp01=regexp(data{jj+start_para-1}, '\s+', 'split');
    elseif subbasin>0 && first_iteration==0
      temp01=regexp(data{jj+start_para*subbasin-1}, '\s+', 'split');  
    else
        temp01=regexp(data{jj+start_para-1}, '\s+', 'split');  
    end
    temp02{jj}=temp01{1};
end
 temp02{jj+1}='goal_value';
 
 if subbasin>0
     if first_iteration==0
     no_pars=no_pars/subbasin_total;
     end
 end


fp = fopen(goal_text,'w+');
fprintf(fp,'%s\n', ['no_pars= ',num2str(no_pars)]);
fprintf(fp,'%s\n', ['no_Sims= ',num2str(no_Sims)]);
fprintf(fp,'%s\n', ['type_of_goal_fn= ',type_of_goal_fn]);

temp03=['Sim_No. ',temp02];

multiple_formt0={'%s\t';'\n'};
fprintf(fp,[multiple_formt0{[ones(1,length(range)+2) 2]}], temp03{1,:});


multiple_formt1={'%d';'%9.4f ';'\n'};
fprintf(fp,[multiple_formt1{[1 ones(1,length(range)+1)*2 3]}],par_val_data');


end





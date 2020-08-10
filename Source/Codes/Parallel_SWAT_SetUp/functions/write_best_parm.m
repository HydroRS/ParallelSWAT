function [ ] = write_best_parm( par_inf_txt, best_para_txt, best_par, type_of_goal_fn, simu_num, best_Sims_num,best_goal,subbasin,subbasin_total,first_iteration,StremOrET )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
% par_inf='D:\Work_2020\Papers\SWAT\SWAT_Calibration\Muti_lumped_calibaration\muti_sptail.Sufi2.SwatCup\SUFI2.IN\par_inf.txt';

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
para_value=zeros(length(range),2);
temp02=cell(length(range),1);
for jj=1:length(range)
    temp01=regexp(data{jj+start_para-1}, '\s+', 'split');
    temp02{jj}=temp01{1};
    para_value(jj,:)=str2double(temp01(2:end));
end
 
 best_para01=[best_par',para_value];
 
 best_para02=[temp02, num2cell(best_para01)];
  best_para03=[temp02, num2cell(best_par')];
  
  if subbasin>0 && first_iteration==0
      sub_parm_length=length(best_para02)/subbasin_total;
      best_para02=best_para02((sub_parm_length*subbasin-(sub_parm_length-1)):(sub_parm_length*subbasin),:);
      best_para03=best_para03((sub_parm_length*subbasin-(sub_parm_length-1)):(sub_parm_length*subbasin),:); 
      best_par=best_par((sub_parm_length*subbasin-(sub_parm_length-1)):(sub_parm_length*subbasin));
  end
 
 fp = fopen(best_para_txt,'w+');
 fprintf(fp,'%s\n', ['Goal_type=',type_of_goal_fn, '  No_sims=', num2str(simu_num),...
     '  Best_sim_no= ', num2str(best_Sims_num), '  Best_goal = ', num2str(best_goal) ]);
 fprintf(fp,'\n');
 fprintf(fp,'%s\n','Parameter_Name  Fitted_Value     Min_value      Max_value' );
 
 for i=1:length(best_para02(:,1))
     fprintf(fp,'%s   %9.4f %9.4f %9.4f\n',best_para02{i,1},best_para02{i,2:end});
 end
 
  fprintf(fp,'\n');
  fprintf(fp,'%s\n',num2str(best_par));
   fprintf(fp,'\n');
   
 for i=1:length(best_para03(:,1))
     fprintf(fp,'%s   %9.4f\n',best_para03{i,1},best_para03{i,2});
 end
 
  
  
end


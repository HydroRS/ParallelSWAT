function [] = SUFI2_goal_fn( SUFI2_in, SUFI2_out,obj_choice, devide_variabl, simu_begin,simu_end, Elu_Distance, subbasin,subbasin_total, StremOrET, first_iteration)
% SUFI2_goal_fn.exe % beh_pars.txt  % best_par.txt
% best_sim.txt % best_sim_nr.txt % goal.txt % no_beh_sims.txt
if subbasin>=1
    devide_variabl=1;
end
% devide_variabl
% devide bettween the streamflow and ET observations
% for instance, 2 means that the first two varible is streamflow,
% the other is ET

%------observe
[weight, behave_thredshold, observ ] = obs_extract( [SUFI2_in, 'observed.txt']);
simulation_length=length(observ{1});

%--------var_file_name

var_file_name=textread([SUFI2_in, 'var_file_name.txt'], '%s');
subbasin_all=xlsread([SUFI2_in,'ZL_Paramter\subbasin_number.xlsx']);

if subbasin>0
    if StremOrET==0 % ET
   stream_station=var_file_name(subbasin_all(subbasin,2));
   ET_station=var_file_name(subbasin_all(subbasin,1)+3); % three streanflow station
    var_file_name=[stream_station;ET_station];
    elseif StremOrET>0 %streamflow
         stream_station=var_file_name(subbasin_all(subbasin,1));
      ET_station= var_file_name(subbasin_all(subbasin,1)); % three streanflow station
    var_file_name=[stream_station;ET_station];
    end
end

fid=fopen([SUFI2_in,'par_inf.txt'],'r');
L=1;
while ~feof(fid)
    str=fgetl(fid);
    data{L,1}=str;
    L=L+1;
end
simu_num_temp=regexp(data{2}, '\s+', 'split');
simu_num=str2double(simu_num_temp{1});

goal_single=zeros(simu_num, length(var_file_name));
% signle variable objection 
simulated_all=[];
for ii=1:length(var_file_name)
    temp= simulation_extract( [SUFI2_out,var_file_name{ii}]);
    simulated_all=[simulated_all,temp];
    
    if subbasin==0
        obs_temp=observ{ii};
    elseif subbasin>0
        if StremOrET==0 % ET
            if ii==1
                obs_temp=observ{subbasin_all(subbasin,2)};
            else
                obs_temp=observ{subbasin_all(subbasin,1)+3};
            end
        elseif  StremOrET>0 % streamflow
            obs_temp=observ{subbasin_all(subbasin,1)};
        end
    end
   
    for jj=1:simu_num
        % 1 NSE; 2 KGE; 3 R2; 4 RMSE
%         if subbasin==0
            if ii<=devide_variabl % daily for streamflow
                obs=obs_temp(:,end);
                simu= temp{jj}(:,end);
                  [value,type_goal]=objective_estimate(obj_choice, obs(:,end), simu(:,end));
                goal_single(jj,ii)=value;
            else
                obs=Daily2monthly_new(obs_temp(:,end), simu_begin,simu_end);
                simu=Daily2monthly_new(temp{jj}(:,end), simu_begin,simu_end);
                %      end
                [value,type_goal]=objective_estimate(obj_choice, obs(:,end), simu(:,end));
                goal_single(jj,ii)=value;
            end
%             
%         elseif subbasin>0
% %         else
%             % monthly for ET
%             obs=Daily2monthly_new(obs_temp(:,end), simu_begin,simu_end);
%             simu=Daily2monthly_new(temp{jj}(:,end), simu_begin,simu_end);
%             %      end
%             [value,type_goal]=objective_estimate(obj_choice, obs(:,end), simu(:,end));
%             goal_single(jj,ii)=value;
%         end
    end
    
end
% Muti_objective
if Elu_Distance==0
    
    if subbasin==0     
        weight_normal=weight./sum(weight);
    elseif subbasin>0
        if StremOrET==0
        weight_normal=[0,1];
        elseif StremOrET>0
            weight_normal=[1,0];
        end
    end
    Weight_used=repmat(weight_normal,simu_num, 1);
    
    goal_all=sum(goal_single.*Weight_used,2);
elseif Elu_Distance==1 %  Elu_Distance Objetive combination
    goal_single_new=1-goal_single;
    Stream_obj=sum(repmat(1/devide_variabl,simu_num,devide_variabl)...
               .*goal_single_new(:,1:devide_variabl),2);
    ET_obj=sum(repmat(1/(length(var_file_name)-devide_variabl),simu_num,....
            length(var_file_name)-devide_variabl).*goal_single_new(:,...
              devide_variabl+1:length(var_file_name)),2);
    objetives_2=[Stream_obj,ET_obj ];
 
    Elu_Distance_A=xlsread([SUFI2_in,'ZL_Paramter\Eu_distance_A.xlsx']);
    Distance_A=repmat(Elu_Distance_A,simu_num, 1);
    goal_all=sqrt(sum((objetives_2+Distance_A).^2,2));
end


par_val_data=load([SUFI2_in,'par_val.txt']);
par_val_data=[par_val_data,goal_all];

 [value,type_goal]=objective_estimate(obj_choice, 1, 1);
[row, col]=size(par_val_data);

if subbasin>0
% make dir
mkdir([SUFI2_out,'subbasin',num2str(subbasin)]);
mkdir([SUFI2_out,'subbasin',num2str(subbasin),'\SUFI2.OUT']);
% write goal.txt
write_goal([SUFI2_in,'par_inf.txt'], [SUFI2_out,'subbasin',num2str(subbasin),...
           '\SUFI2.OUT\goal.txt'], par_val_data, col-2, simu_num, type_goal,subbasin,subbasin_total,first_iteration,StremOrET);

elseif subbasin==0
% write goal.txt
subbasin_total=0;
write_goal([SUFI2_in,'par_inf.txt'], [SUFI2_out,'goal.txt'], par_val_data,...
          col-2, simu_num, type_goal,subbasin,subbasin_total,first_iteration, StremOrET);
end

% write best simu
if Elu_Distance==0
    best_simu_id=find(goal_all==max(goal_all));
elseif Elu_Distance==1
    best_simu_id=find(goal_all==min(goal_all));
end
    
fp = fopen([SUFI2_out,'best_sim.txt'],'w+');
for kk=1:length(var_file_name)
    fprintf(fp,'%s\n',var_file_name{kk}(1:end-4));
    fprintf(fp,'%s\n','observed  simulated');
     fprintf(fp,'%9.4f  %9.4f\n',[observ{kk}(:,end),simulated_all{best_simu_id,kk}(:,end)]');
     fprintf(fp,'\n');
      fprintf(fp,'\n');
end

% write no_beh_sims.txt, beh_pars.txt

no_beh_sims=find(goal_all>=behave_thredshold);
if subbasin==0
fp02 = fopen([SUFI2_out,'no_beh_sims.txt'],'w+');
elseif subbasin>0
fp02 = fopen([SUFI2_out,'subbasin',num2str(subbasin),'\SUFI2.OUT\best_sim.txt'],'w+');
end
fprintf(fp02,'%s\n',['no_behav_sims= ', num2str(length(no_beh_sims))]);
fclose(fp02);

% write beh_FLOW_OUT_1.txt
if no_beh_sims>0
    for pp=1:length(var_file_name)
        if subbasin==0
            fp03 = fopen([SUFI2_out,['beh_', var_file_name{pp}]],'w+');
        elseif subbasin>0
            fp03 = fopen([SUFI2_out,'subbasin',num2str(subbasin),'\SUFI2.OUT\',['beh_', var_file_name{pp}]],'w+');
        end
		
        for jj=1:length(no_beh_sims)
             fprintf(fp03,'%s\n',['     ',num2str(jj)]);
             fprintf(fp03,'%9.4f\n',simulated_all{no_beh_sims(jj),pp}(:,end)');
        end
       fclose(fp03);
    end
    
end


if subbasin==0
fp01 = fopen([SUFI2_out,'beh_pars.txt'],'w+');
elseif subbasin>0
fp01 = fopen([SUFI2_out,'subbasin',num2str(subbasin),'\SUFI2.OUT\beh_pars.txt'],'w+');
end
beh_pars=[(1:length(no_beh_sims))',par_val_data(no_beh_sims,2:(end-1))];
multiple_formt1={'%d  ';'%6.4f  ';'\n'};
fprintf(fp01,[multiple_formt1{[1 ones(1,col-2)*2 3]}],beh_pars');
fclose(fp01);

% write best_par.txt 
best_par=par_val_data(best_simu_id,2:end);
best_par(end)=[];
best_goal=goal_all(best_simu_id);
if subbasin==0
write_best_parm( [SUFI2_in,'par_inf.txt'],[SUFI2_out,'best_par.txt'], best_par,... 
             type_goal, simu_num, best_simu_id,best_goal,subbasin,subbasin_total,first_iteration, StremOrET)
elseif subbasin>0
write_best_parm( [SUFI2_in,'par_inf.txt'],[SUFI2_out,'subbasin',num2str(subbasin),...
         '\SUFI2.OUT\best_par.txt'], best_par, type_goal, simu_num, best_simu_id,best_goal,subbasin,subbasin_total,first_iteration,StremOrET )
end


% write best_sim_nr.txt
if subbasin==0
fp03 = fopen([SUFI2_out,'best_sim_nr.txt'],'w+');
elseif subbasin>0
fp03 = fopen([SUFI2_out,'subbasin',num2str(subbasin),'\SUFI2.OUT\best_sim_nr.txt'],'w+');
end
fprintf(fp03,'%d\n',best_simu_id);
fclose(fp03);
 fclose all
 
 if subbasin==0
 % write goal_single
 xlswrite([SUFI2_out,'goal_single_objevtive.xlsx'],goal_single);
% matlabpool close
end

end


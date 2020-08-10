function [] = SUFI2_goal_fn( SUFI2_in, SUFI2_out,obj_choice, devide_variabl, simu_begin,simu_end, Elu_Distance, subbasin,subbasin_total, StremOrET, first_iteration)
% SUFI2_goal_fn.exe % beh_pars.txt  % best_par.txt
% best_sim.txt % best_sim_nr.txt % goal.txt % no_beh_sims.txt


%------observe
[weight, behave_thredshold, observ ] = obs_extract( [SUFI2_in, 'observed.txt']);
simulation_length=length(observ{1});

%--------var_file_name
var_file_name=textread([SUFI2_in, 'var_file_name.txt'], '%s');
subbasin_all=xlsread([SUFI2_in,'\subbasin_number.xlsx']);

%Num_streamflow_gauge
Num_streamflow_gauge=devide_variabl;

if subbasin>0
    
    % if the spatially optimizaiton is enabled, we force the devide_variabl
    % equal to 1, and meanwhile, we don't support the Elu_Distance weight
    % adjustment of the objective functions. So, Elu_Distance=0;
    devide_variabl=1;
    Elu_Distance=0;
    
    if StremOrET==0 % ET
        
        % if the ET-related paramters are to be optimized, we here get the streamflow
        % simulation at the gauge in the downstream area of the subbains. The
        % downstream streamflow gauge of each subbains is defined in the file
        % 'subbasin_number.xlsx' in the SUFI_IN folder. The second variable is
        % the ET simulation for each subbasin.
        
        stream_station=var_file_name(subbasin_all(subbasin,2));
        ET_station=var_file_name(subbasin_all(subbasin,1)+3); % three streanflow station
        var_file_name=[stream_station;ET_station];
        
        % var_file_name=['FLOW_OUT_1.txt'; 'ET_1.txt']
        % which means the subbain 1 contribute streanflow to the gauge flow_out_1.
        
    elseif StremOrET>0 %streamflow
        
        % two same gauges such as ['FLOW_OUT_2.txt'; 'FLOW_OUT_2.txt'] were evaluated  
        stream_station=var_file_name(subbasin_all(subbasin,1));
        ET_station= var_file_name(subbasin_all(subbasin,1));
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
parfor ii=1:length(var_file_name)
    
    % extract simulaiton for the objective ii (such as Flow_out_01.txt) of 
    % each SWAT-run. The data saved in a cell file, each row represents the 
    % swat-run, the coloumn is the different obectives
    temp= simulation_extract( [SUFI2_out,var_file_name{ii}]);
    simulated_all=[simulated_all,temp];
    
    % observe_temp is the observation for var_file_name{ii}
    if subbasin==0
        obs_temp=observ{ii};
    elseif subbasin>0
        if StremOrET==0 % ET
            % ii=1 means the first varible is streamflow (e.g. FLOW_OUT_1)
            if ii==1
                obs_temp=observ{subbasin_all(subbasin,2)};
            
            % ii=2 means the second varible is ET (e.g. ET_1)
            % since there three streamflow gauges, the ET for subbain 01
            % should the 4th one of all the observed variables
            % Num_streamflow_gauge=3
            else
                obs_temp=observ{subbasin_all(subbasin,1)+Num_streamflow_gauge};
            end
        elseif  StremOrET>0 % streamflow
            obs_temp=observ{subbasin_all(subbasin,1)};
        end
    end
   
    for jj=1:simu_num
      
          % The objectives before the devide_variable is evaluated for the
          % daily results(Streamflow), while after it is for the monthly
          % results (ET)
            if ii<=devide_variabl % daily for streamflow
                obs=obs_temp(:,end);
                simu= temp{jj}(:,end);
                  % obj_choice: 1 NSE; 2 KGE; 3 R2; 4 RMSE
                  [value,type_goal]=objective_estimate(obj_choice, obs(:,end), simu(:,end));
                goal_single(jj,ii)=value;
            else
                 % obj_choice: 1 NSE; 2 KGE; 3 R2; 4 RMSE
                obs=Daily2monthly_new(obs_temp(:,end), simu_begin,simu_end);
                simu=Daily2monthly_new(temp{jj}(:,end), simu_begin,simu_end);
                %      end
                [value,type_goal]=objective_estimate(obj_choice, obs(:,end), simu(:,end));
                goal_single(jj,ii)=value;
            end

    end
    
end

% Muti_objective
if Elu_Distance==0
    
    if subbasin==0  
        % The weight are extracted from the SWAT-cup configuration files
        % the weights were averaged to their summation
        weight_normal=weight./sum(weight);
    elseif subbasin>0
        
        % if only ET related paramters to be calibrated,we force the weight
        % of streamflow to zero
        if StremOrET==0
        weight_normal=[0,1];
        
        % if only streamflow related paramters to be calibrated,we force the weight
        % of the second objectives to zero 
        % ['FLOW_OUT_2.txt'; 'FLOW_OUT_2.txt'], the second is the evaluated at the 
        % the monthly scale, it was not used. 
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
 
    Elu_Distance_A=xlsread([SUFI2_in,'\Eu_distance_A.xlsx']);
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
 save ([SUFI2_out,'goal_single_objevtive.mat'], 'goal_single');
% matlabpool close
end

end


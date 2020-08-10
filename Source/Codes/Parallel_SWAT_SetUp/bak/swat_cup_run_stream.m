%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       This program is used to run swat-cup automatically                %
%       The difference is that:                                          %
%       (1) we can defined our objetives                                  %
%       (2) we can also give parallel computing                           %
%       Author: Ling Zhang, zhanglingky@lzb.ac.cn£¬2020/3/8               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ===============================================================
%                     1. swat-cup definition                              %                
%  ========================================================================
clc;clear
current_folder=['D:\Work_2020\Papers\SWAT\Calibration_strategy\ET&Streamflow',...
               '\Step_Spatially\SUFI2'];
cd(current_folder);
addpath('.\functions')
swat_excute_folder=['D:\Work_2020\Papers\SWAT\Calibration_strategy\ET&Streamflow'...
                    '\Step_Spatially\muti_sptail.Sufi2.SwatCup\'];

sufi2_in=[swat_excute_folder,'SUFI2.IN\'];
sufi2_out=[swat_excute_folder, 'SUFI2.OUT\'];

iteration_last_name='Iter05-single\';
observ_fold='D:\Work_2020\Papers\SWAT\SWAT_ZL\Observations\';


% update paramter range or not
updated_pram_range=1;
% Update subbasin best range
update_sub_range=0;

samp_subbasin=0;
% sample for each subbasin or not

% update best paramter or not
update_best_parmter=0;
% Update subbasin best pramter 
update_sub_best_param=0;
% update the paramters from the first iteration?
first_iteration=0;

% subbasin=23;
subbasin=2;

% save iteration or not
save_iteration=1;
iteration_name='Iter06-single';

% validation or not
validation_or_not=0;

% if ovservation or the weight changed, it should be updated.
observe_upate=0;

% number of simulations
Num_simulation='300';

% Which paramter set to clibrate
clibration='O';

% daily or monthly simulation
% 0, mothly;1, daily; 2,yearly
IPRINT=1; 
NSKIP=2;

% var_file_name
var_file_name=textread([sufi2_in,'ZL_Paramter\','rch_observe.txt'], '%s');
devide_variabl=length(var_file_name);%

% ET_file_name
ET_file_name=textread([sufi2_in,'ZL_Paramter\','sub_et_observed.txt'], '%s');

%  weight
% weight=xlsread([sufi2_in,'ZL_Paramter\','observ_weight.xlsx'],'sheet1');
weight=[1;0;0];

%  weight ET
% weigh_ET=xlsread([sufi2_in,'ZL_Paramter\','observ_weight.xlsx'],'sheet2');
weigh_ET=[0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0];
% objection
obj_choice=2; % 1 NSE; 2 KGE; 3 R2; 4 RMSE

% Parallel computing or Not
ParallelorNot=1;

% Evaluaiton period (not include warm-up period)
simu_begin=2007;
simu_end=2009;

%% ===============================================================
%                     1. swat-cup set up                                  %
%  ========================================================================
cd(current_folder);
[simu_begin, simu_end]=swat_cup_setup( swat_excute_folder,iteration_last_name, ...
    observ_fold,updated_pram_range, update_best_parmter,...
   validation_or_not, observe_upate, Num_simulation, clibration,...
   IPRINT, NSKIP, var_file_name,ET_file_name, weight, weigh_ET,...
    update_sub_best_param,update_sub_range,subbasin,first_iteration);
%% ===============================================================
%             2.  SUI2 sampling for each subbasin  or not            %
%==========================================================================

if samp_subbasin==0
% step 03: Latin hypercube sampling 
cd(swat_excute_folder); 
system('SUFI2_Pre.bat')
elseif samp_subbasin==1
    system('taskkill /F /IM smpd.exe');
    fclose all;
    cd(current_folder);
   subbasin_sample( sufi2_in,subbasin, swat_excute_folder)
end
 
%% ===============================================================
%             2. Run SUI2 step by step: Run and save results              %
%==========================================================================
delete(strcat(sufi2_out,'*.txt'));
cd(swat_excute_folder); 
% step 03: Latin hypercube sampling 
% system('SUFI2_Pre.bat')
tic
if ParallelorNot==0
    % step 04:Run SWAT model
  t1=clock;
    for iii=1:str2num(Num_simulation)
        curent_run_num=textread([sufi2_in,'trk.txt'],'%d');
        
        % step 4.1 model.in
        system('SUFI2_make_input.exe')
        
        % step 4.2 update paramter
        % system('start /w Swat_Edit.exe');
         system('Swat_Edit_Hidden.bat');
        
        
        % step 4.3 run swat
        system('swat.exe');
        
        % step 4.4 extract result
        system('SUFI2_extract_rch.exe');
        system('SUFI2_extract_sub.exe');
        % system('SUFI2_extract_hru.exe');
        % system('SUFI2_extract_res.exe');
        
        % update run_num
        run_num=iii+1;
        dlmwrite([sufi2_in,'trk.txt'],run_num,'%d');
    end
   t2=clock;  

else
    % -------------------------------------%
    %         Parallel Computing           %
    % -------------------------------------%
    cd(current_folder);
    t1=clock; 
    matlabpool close force local
    % open a pool of MATLAB workers
    % The maximum works depend on the computer
    % work_number=2;
    work_number=6;
    matlabpool local 6
    Parallel_Computing(swat_excute_folder,sufi2_in,work_number,...
        var_file_name,ET_file_name,current_folder,Num_simulation);
   t2=clock;
end
run_time_swat=etime(t2,t1);
%% ===============================================================
%             3. Run SUI2 step by step: Post process                      %
%==========================================================================
% Eludistance or wight for objectives 
Eludistance=0;

% subbasin goal
subbasin_goal=0;

% sub ET=0; sub stream=1
StremOrET=0;

% goal for the first iteration?
goal_first_iteration=0;

% *********************************************
% step 05:Run SUFI2_goal_fn
cd(current_folder);
 t3=clock;
 
if subbasin_goal==0
    subbasin=0;
    jj=0;
    subbasin_total=0;
SUFI2_goal_fn( sufi2_in, sufi2_out,obj_choice, devide_variabl,...
               simu_begin, simu_end, Eludistance,jj,subbasin,StremOrET,goal_first_iteration)
           
% step 06:Run SUFI2_Post-new
cd(swat_excute_folder); 
system('SUFI2_Post-new.bat')

elseif subbasin_goal==1
    % matlabpool 8;
    
    % Qilian && Zhama
    subbasin=2;
    
    subbasin_total=subbasin;
    parfor jj=1:subbasin
%         if StremOrET==0 % ET
            jj_sub=jj;
%         elseif StremOrET>0  % streamflow sub2+3
%             jj_sub=jj+1;
%         end
        
        SUFI2_goal_fn( sufi2_in, sufi2_out,obj_choice, devide_variabl,...
            simu_begin, simu_end,Eludistance, jj_sub, subbasin_total,StremOrET, goal_first_iteration);
        
        % step 06:Run SUFI2_Post-new
        mkdir([sufi2_out,'subbasin',num2str(jj_sub),'\SUFI2.IN']);
        copyfile([swat_excute_folder,'SUFI2.IN'],[sufi2_out,'subbasin',num2str(jj_sub),'\SUFI2.IN'])
        
        copyfile([swat_excute_folder,'SUFI2_new_pars.exe'],[sufi2_out,'subbasin',num2str(jj_sub)])
        % copyfile([swat_excute_folder,'SUFI2_95ppu.exe'],[sufi2_out,'subbasin',num2str(subbasin)] )
        cd([sufi2_out,'subbasin',num2str(jj_sub)]);
        system('SUFI2_new_pars.exe')
        % system('SUFI2_95ppu.exe')
        
    end
    matlabpool close
end
    
 t4=clock;
run_time_post=etime(t4,t3);

cd(current_folder);

%% ===============================================================
%                4. save SUfI2 results                                    %
%==========================================================================
if save_iteration==1
cd([swat_excute_folder, 'Iterations\']);
mkdir(iteration_name);
copyfile(strcat(sufi2_out,'*.*'),strcat(swat_excute_folder, 'Iterations\',...
                                        iteration_name, '\Sufi2.Out'));
                                    
copyfile(strcat(sufi2_in,'*.*'), strcat(swat_excute_folder, 'Iterations\',...
                                    iteration_name,'\Sufi2.In'));
end




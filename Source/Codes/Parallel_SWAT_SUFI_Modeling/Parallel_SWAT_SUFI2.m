%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       This program is used for the parallel computing of SWAT          %
%       (1) The program is compatiable with the SWAT-CUP software        %
%       (2) The program is freely avaiable
%       (3) The LHS sampling and SUFI2 algorithm can run in parallel for 
%           each subwatershed (each subbasin for ET, each subwatershed
%           gauged by parallel stations)
%       (4) Users can define their own objectives, not limted by SWAT¡ªCUP
%       Author: Ling Zhang, zhanglingky@lzb.ac.cn£¬2020/3/8               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ===============================================================
%                     1. swat-cup definition                              %                
%  ========================================================================
clc;clear

% Location of the main funciton Parallel_SWAT_modelling.m
current_folder=['D:\Work_2020\MyCodes\Parallel_spatially_stepwise_calibration-SWAT'...
               '\Source\Codes\Parallel_SWAT_SUFI_Modeling\'];
cd(current_folder);
addpath('.\functions')

% Location of the SWAT files
swat_excute_folder=['D:\Work_2020\MyCodes\Parallel_spatially_stepwise_calibration-SWAT'...
                    '\test_data\muti_sptail.Sufi2.SwatCup\'];

sufi2_in=[swat_excute_folder,'SUFI2.IN\'];
sufi2_out=[swat_excute_folder, 'SUFI2.OUT\'];


% Parallel computing or Not
% If it is set to 0, the progarm will run SWAT as in SWAT_CUP
% If it is set to 1, the program will run SWAT in parallel
% and it will significantly improve the computational efficiency
ParallelorNot=1;

% save iteration or not
save_iteration=1;
iteration_name='Iter01';

% Single objective function
% It can be defined to any other forms in objective_estimate.m
% It was used to esimate the value of each objetive single objective
% For instance, there are 3 gauges and 23 subabsins, then we have 26 
% single objectives
obj_choice=2; % 1 NSE; 2 KGE; 3 R2; 4 RMSE

 
 % Wethear this is the first iteration
% if the answer is ture, it is unity, which means that the paramter ranges
% are the same for all the subbasin, which is the conventional case.
% if the answer is false, it is zero, which means the paramer ranges are
% differet for each subwatershed, wich is the case after the first
% iteration of the spatially optimization.
Spatial_Optimization_first_iteration=1;


% ******************************************************
% The following paramters do not need definitation 
% They were read from the SWAT_CUP files. 
% ******************************************************


% Note: the number should be the integral times of the number of worker 
% For instance, your computer has 5 precessor cores, the number of
% simulaitons can be 5*40=200, or 5*60=300, and so on.
% The number of simulatins is defined in the file Par_inf.txt
par_inf_file=[sufi2_in,'par_inf.txt'];
Num_simulation= NumSim_extract(par_inf_file );


% var_file_rch
% file names of all the reaches where the gauges exists
var_file_name=textread([sufi2_in,'var_file_rch.txt'], '%s');
devide_variabl=length(var_file_name); % number of streamflow gauges

% var_file_sub.txt
% file names of all the subbains
ET_file_name=textread([sufi2_in,'var_file_sub.txt'], '%s');


% Evaluaiton period (not include warm-up period)
SUFI2_extract_rch_def=[swat_excute_folder,'SUFI2_extract_rch.def'];
[simu_begin,simu_end]=Sim_begin_end_extract( SUFI2_extract_rch_def );
%% ===============================================================
%             2.  SUI2 sampling for each subbasin or not            %
%==========================================================================

if Spatial_Optimization_first_iteration==1
%  Latin hypercube sampling 
cd(swat_excute_folder); 
system('SUFI2_Pre.bat')
elseif Spatial_Optimization_first_iteration==0
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

tic
if ParallelorNot==0
  t1=clock;
    for iii=1:Num_simulation
        
        No_sim=['============ Sim No.',num2str(iii),'============'];
        disp(No_sim);
        
        curent_run_num=textread([sufi2_in,'trk.txt'],'%d');
        
        % step 2.1 model.in
        system('SUFI2_make_input.exe')
        
        % step 2.2 update paramter
        % system('start /w Swat_Edit.exe');
         system('Swat_Edit_Hidden.bat');
        
        
        % step 2.3 run swat
        system('swat.exe');
        
        % step 2.4 extract result
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
    % The maximum works or precessor cores depend on your computer
    
    work_number=2;
    command=['matlabpool local ',num2str(work_number)];
    disp(command);
    eval(command);
    
    % Note: The parallel framework needs an intiation for the first-time run
    % and it will demands sevearl minitues. After initiation, the parallel
    % framework will run directly for the following iteations.
    Parallel_Computing(swat_excute_folder,sufi2_in,work_number,...
        var_file_name,ET_file_name,current_folder,Num_simulation);
   t2=clock;
end
run_time_swat=etime(t2,t1);

%% ===============================================================
%             3. Run SUI2 step by step: Post process                      %
%==========================================================================


% ******************************************************
% The following paramters should be defined by the users 
% ******************************************************

% Subbasin goal, if =0, the SUFI2 algorithm will run as in SWAT-CUP with 
% the difference that it enables user to define customized objective functions
% if=1, it means the SFUI2 will run in parallel for each subwatershed
subbasin_goal=1;


% Number of subwatersheds for model calibration
% It equals to the number of subbains if each subbasin is calibrated on
% the variable such as ET. It equals to the number of upstreamf streamflow
% gauges (parallel not nested, i.e., the streamflow simulaitons will not
% affect each other).
subbasin=2;


% Transformation constants assigned to the the objective functions of
% different variables:
% Ref: Madsen, H., 2000. Automatic calibration of a conceptual 
% rainfall¨Crunoff model using multiple objectives. 
% Journal of Hydrology, 235(3): 276
% If it set as zero, the weight will be the same for each objetive. For
% instance, if there are 26 objectives, the weight will be 1/26.
% If it set as one, the weight will be adjusted for the different variables
Madsen_weight=0;


% ET or Streamflow realted paramters to be optimized 
% If ET related paramters is to be calibrated it equals to 0
% elseif Streamflow related paramters to be optimizd, it equals to 1
ET_or_Streamflow=1;

% If parallel streamflow gauges to be calibrated,Parallel_streamflow=1
% In our case, Zhama (Flow_out_1), Qilian (Flow_out_3) were calibrated in
% parallel. If not, such as the outlet (Yingluoxia) to be calibrated,
%Parallel_streamflow=0
Parallel_streamflow=1;

% ******************************************************
%               Run SUFI2 algorithm
% ******************************************************

% step 05:Run SUFI2_goal_fn
cd(current_folder);
t3=clock;

if subbasin_goal==0
    subbasin=0;
    jj=0;
    subbasin_total=0;
    SUFI2_goal_fn( sufi2_in, sufi2_out,obj_choice, devide_variabl,...
        simu_begin, simu_end, Madsen_weight,jj,subbasin,...
        ET_or_Streamflow,Spatial_Optimization_first_iteration)
    
    % step 06:Run SUFI2_Post-new
    cd(swat_excute_folder);
    system('SUFI2_Post-new.bat')
    
elseif subbasin_goal==1
    % matlabpool 8;
    subbasin_total=subbasin;
    parfor jj=1:subbasin
        
         if ET_or_Streamflow==0 % ET
            jj_sub=jj;
         else
             if Parallel_streamflow==1  % streamflow sub2+3
              jj_sub=jj+1;
             else
                 jj_sub=jj;
             end
         end
        
        SUFI2_goal_fn( sufi2_in, sufi2_out,obj_choice, devide_variabl,...
            simu_begin, simu_end,Madsen_weight, jj_sub, subbasin_total,...
            ET_or_Streamflow, Spatial_Optimization_first_iteration);
        
        % step 06:Run SUFI2_Post-new
        mkdir([sufi2_out,'subbasin',num2str(jj_sub),'\SUFI2.IN']);
        copyfile([swat_excute_folder,'SUFI2.IN'],[sufi2_out,'subbasin',...
            num2str(jj_sub),'\SUFI2.IN'])
        
        copyfile([swat_excute_folder,'SUFI2_new_pars.exe'],...
            [sufi2_out,'subbasin',num2str(jj_sub)])
        
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
                                
 dlmwrite([swat_excute_folder, 'Iterations\',iteration_name, '\SUFI2.OUT',...
                         'Run_time_SWAT.txt'],run_time_swat,'%f'); 
  dlmwrite([swat_excute_folder, 'Iterations\',iteration_name, '\SUFI2.OUT',...
                         'Run_time_Post.txt'],run_time_post,'%f');                    
end




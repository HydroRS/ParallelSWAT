%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       This program is used for the setup of parallel computing of SWAT %
%       (1) The SWAT-CUP required files can be prepared automatically    %
%       (2) It can update the parmater range or the best parmater set
%       Author: Ling Zhang, zhanglingky@lzb.ac.cn£¬2020/3/8               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ===============================================================
%                     1. swat-cup definition                              %                
%  ========================================================================
clc;clear

%% Folder definition
% Location of the main funciton Parallel_SWAT_modelling.m
current_folder=['D:\Work_2020\MyCodes\Parallel_spatially_stepwise_calibration-SWAT'...
               '\Source\Codes\Parallel_SWAT_SetUp\'];
cd(current_folder);
addpath('.\functions')

% Location of the SWAT files
swat_excute_folder=['D:\Work_2020\MyCodes\Parallel_spatially_stepwise_calibration-SWAT'...
                    '\test_data\muti_sptail.Sufi2.SwatCup\'];

sufi2_in=[swat_excute_folder,'SUFI2.IN\'];
sufi2_out=[swat_excute_folder, 'SUFI2.OUT\'];

% The folder which saved the results for the last iteration
iteration_last_name='Iter01\';

observ_fold='D:\Work_2020\MyCodes\Parallel_spatially_stepwise_calibration-SWAT\test_data\obs\';

%% Parmater update or nor?
% If updated_pram_range=1, the paramter range will be updated from the 
% last iteration, else the range will not change
updated_pram_range=0;

% If the updated_pram_range=1, the users needs define wethear the subbasin
% paramter ranges to be updated. If update_sub_range=0, the progrom will 
% update paramter range as in SWAT-CUP
update_sub_range=0;


% The following two paramters are used to define if the best paramters to
% be updated, this is used for model validation after the calibration
% update best paramter or not
update_best_parmter=0;

% If update_best_parmter=1, the users should further define whethear the
% subbasin best parameters to be updated
% Update subbasin best pramter 
update_sub_best_param=0;


%% Observe update or not?

%If model validation to be conducted, validation_or_not=1
% IF validation_or_not=1, observe_upate should equal to 1
% since the calibration is different from the validation period
validation_or_not=0;

% if ovservation or the weight changed, observe_upate should be unity.
% For instance, if the validation period is to be evaluated, it should be
% updated. Or if the weight of the objectives to be updated,
% observe_upate=1
observe_upate=1;

% Weight for streamflow for each streamflow gauge
% FLOW_OUT_1:Yingluoxia; FLOW_OUT_2:Zhama; FLOW_OUT_3:Qilian
weight=[1;1;1];

% Weight for ET over each of subbasin (totally 23 subbasins)
weigh_ET=[0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0];


%% Other settings
% daily or monthly simulation
% 0, mothly;1, daily; 2,yearly
IPRINT=1;

%Number of years to be skipped for analysis
NSKIP=2;

% Th different paramter set to be optimized
% The paramter set was defined in swat_cup_setup.m
clibration='O';
    
% number of simulations for each iteration
Num_simulation=10;

% var_file_rch
% file names of all the reaches where the gauges exists
var_file_name=textread([sufi2_in,'var_file_rch.txt'], '%s');
devide_variabl=length(var_file_name); % number of streamflow gauges

% var_file_sub.txt
% file names of all the subbains
ET_file_name=textread([sufi2_in,'var_file_sub.txt'], '%s');

 % Wethear this is the first iteration
% if the answer is ture, it is unity, which means that the paramter ranges
% are the same for all the subbasin, which is the conventional case.
% if the answer is false, it is zero, which means the paramer ranges are
% differet for each subwatershed, wich is the case after the first
% iteration of the spatially optimization.
Spatial_Optimization_first_iteration=1;

% number of subbasins
subbasin=23;

%% ===============================================================
%                     1. swat-cup set up                                  %
%  ========================================================================
cd(current_folder);
swat_cup_setup( swat_excute_folder,iteration_last_name, ...
    observ_fold,updated_pram_range, update_best_parmter,...
   validation_or_not, observe_upate, Num_simulation, clibration,...
   IPRINT, NSKIP, var_file_name,ET_file_name, weight, weigh_ET,...
    update_sub_best_param,update_sub_range,subbasin,...
    Spatial_Optimization_first_iteration);
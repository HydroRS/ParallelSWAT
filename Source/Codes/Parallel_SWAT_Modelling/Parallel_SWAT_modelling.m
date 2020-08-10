%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       This program is used for the parallel computing of SWAT          %
%       (1) The program is compatiable with the SWAT-CUP software        %
%       (2) The program is freely avaiable
%       Author: Ling Zhang, zhanglingky@lzb.ac.cn£¬2020/3/8               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ===============================================================
%                     1. Parallel_computing configuration                  %                
%  ========================================================================
clc;clear

% Location of the main funciton Parallel_SWAT_modelling.m
current_folder=['D:\Work_2020\MyCodes\Parallel_spatially_stepwise_calibration-SWAT'...
               '\Source\Codes\Parallel_SWAT_Modelling\'];
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


%****************************************************************
%****************************************************************
% The following paramters don't need definition
% They were read from the SWAT_CUP files.


% Note: the number should be the integral times of the number of worker 
% For instance, your computer has 5 precessor cores, the number of
% simulaitons can be 5*40=200, or 5*60=300, and so on.
% The number of simulatins is defined in the file Par_inf.txt
par_inf_file=[sufi2_in,'par_inf.txt'];
Num_simulation= NumSim_extract(par_inf_file );


% var_file_rch
% file names of all the reaches where the gauges exists
var_file_name=textread([sufi2_in,'var_file_rch.txt'], '%s');

% var_file_sub.txt
% file names of all the subbains
ET_file_name=textread([sufi2_in,'var_file_sub.txt'], '%s');


%% ===============================================================
%             2. Run SUI2 step by step: Run and save results              %
%==========================================================================

% Latin hypercube sampling 
cd(swat_excute_folder); 
system('SUFI2_Pre.bat')
delete(strcat(sufi2_out,'*.txt'));
 
% system('SUFI2_Pre.bat')
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
%             3. Run SUI2 Post process                      %
%==========================================================================

% step 06:Run SUFI2_Post-new
cd(swat_excute_folder); 
system('SUFI2_Post.bat')

%% ===============================================================
%     4. save the modeling results for the current iteration  %
%==========================================================================
if save_iteration==1
cd([swat_excute_folder, 'Iterations\']);
mkdir(iteration_name);
copyfile(strcat(sufi2_out,'*.*'),strcat(swat_excute_folder, 'Iterations\',...
                                        iteration_name, '\SUFI2.OUT'));
                                    
copyfile(strcat(sufi2_in,'*.*'), strcat(swat_excute_folder, 'Iterations\',...
                                    iteration_name,'\SUFI2.IN'));
 dlmwrite([swat_excute_folder, 'Iterations\',iteration_name, '\SUFI2.OUT',...
                         'Run_time.txt'],run_time_swat,'%f');                              
end




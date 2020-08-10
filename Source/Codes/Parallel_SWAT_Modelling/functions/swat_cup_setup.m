function [ begin_year,end_year ] = swat_cup_setup( swat_excute_folder,iteration_last_name, observ_fold,updated_pram_range, update_best_parmter,...
                                          validation_or_not, observe_upate, Num_simulation, clibration,IPRINT, NSKIP, var_file_name,ET_file_name,...
                                          weight, weigh_ET,update_sub_best_param,update_sub_range,subbasin,first_iteration)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%%------------------- SWAT-CUP excute-----------------------
subbasin_all_para=0;
subbasin_all_para_range=0;
% addpath('.\functions')
%swat_excute_folder='D:\Work_2020\Papers\SWAT\SWAT_Calibration\Muti_lumped_calibaration\muti_sptail.Sufi2.SwatCup\';
sufi2_in=[swat_excute_folder,'SUFI2.IN\'];
sufi2_out=[swat_excute_folder, 'SUFI2.OUT\'];
swat_iteration_folder=[swat_excute_folder, 'Iterations\'];
iteration_last=[swat_iteration_folder,iteration_last_name];
% observ_fold='D:\Work_2020\Papers\SWAT\SWAT_ZL\Observations\';

%-------------------------------------------------------------------------------
if clibration=='T';
    Num_parm='2';
    clibate_parmeter={'TLAPS'; 'PLAPS'}; %  %forcing
end

if clibration=='S';
 Num_parm='5';
clibate_parmeter={'SFTMP';'SMTMP';'SMFMX';'SMFMN';'TIMP'}; %snow
end

% if clibration=='O';
%     Num_parm='13';
% clibate_parmeter={'Surflag';'ESCO';'EPCO';'Sol_AWC';'Sol_k';'cn2';'ch_n2';'ch_k2';'Alpha_bf'...
%                    ;'gw_delay';'gwqmn';'Revpamn';'gw_revap'}; % others
% end

if clibration=='O';
%     Num_parm='13';
% clibate_parmeter={'Surflag';'ESCO';'EPCO';'Sol_AWC';'cn2';'ch_n2';'ch_k2';'Alpha_bf'...
%                    ;'gw_delay';'gwqmn';'gw_revap';'TLAPS';'canmx'}; % others

   Num_parm='9';
clibate_parmeter={'Surflag';'Sol_AWC';'cn2';'ch_n2';'ch_k2';'Alpha_bf'...
                   ;'gw_delay';'gwqmn';'gw_revap'}; % others   
%     Num_parm='18';
% clibate_parmeter={'Surflag';'Sol_AWC';'cn2';'ch_n2';'ch_k2';'Alpha_bf'...
%                    ;'gw_delay';'gwqmn';'gw_revap';'Surflag1';'Sol_AWC1';'cn21';'ch_n21';'ch_k21';'Alpha_bf1'...
%                    ;'gw_delay1';'gwqmn1';'gw_revap1'}; % others

end

if clibration=='E';
%     Num_parm='5';
% clibate_parmeter={'ESCO';'EPCO';'cn2';'TLAPS';'canmx'}; % others
  Num_parm='4';
clibate_parmeter={'ESCO';'EPCO';'TLAPS';'canmx'}; % others
end

if clibration=='A';
    Num_parm='13';
clibate_parmeter={'Surflag';'ESCO';'EPCO';'Sol_AWC';'cn2';'ch_n2';'ch_k2';'Alpha_bf'...
                   ;'gw_delay';'gwqmn';'gw_revap';'TLAPS';'canmx'}; % others
end
% -------------------------------------------------------------------------------
%% Define Paramters
if validation_or_not==1
    % not include warm-up period
    % 2010-2012
    begin_year=2010; 
    end_year=2013;
else
    % not include warm-up period
    % 2007-2009
    begin_year=2007; 
    end_year=2009;
end


% file cio
if validation_or_not==1
    Num_year=6;
    % include warm-up period
    % 2008-2012
    simu_begin=2008; 
    end_julian=365;    
else
    Num_year=5;
    % include warm-up period
    % 2005-2009
    simu_begin=2005; 
    end_julian=365;
end



goal_type_defalt=9;

subbains=23;

% rch define
Num_rch='3';
Num_rch_sub='1 12 19';

Num_rch_1='23';
Num_rch_sub_1='1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23';



%% ---------------------------------
 % file_cio
    file_cio(swat_excute_folder, Num_year,simu_begin, end_julian,IPRINT, NSKIP )
    
if observe_upate==1
    % rch_observed
    
    rch_observed(sufi2_in, observ_fold, begin_year,end_year, var_file_name,IPRINT);
    
    % ET_observed
     sub_ET_observed(sufi2_in, observ_fold, begin_year,end_year, ET_file_name, IPRINT)
     
    % observed_objective function-streamflow
    observed_objective( sufi2_in, observ_fold,begin_year,end_year,var_file_name,...
                               weight, IPRINT, goal_type_defalt )
 
                           
     % observed_objective function-ET
    observed_objective_ET( sufi2_in, observ_fold,begin_year,end_year,ET_file_name,...
                               weigh_ET, IPRINT )
    
    % rch_define
    rch_def(swat_excute_folder, Num_rch, Num_rch_sub, begin_year, end_year,IPRINT )
    
     % sub_ET_define
    extract_sub_def(swat_excute_folder, Num_rch_1, Num_rch_sub_1, begin_year, end_year,IPRINT )
    
end

%% --------------------SWAT-CUP Set-up------------------------------

% par_inf.txt
line01='   : Number of Parameters (the program only reads the first 4 parameters or any number indicated here)';
line02='  : number of simulations';



% Surflag='v__SURLAG.hru________19-23    0.05  6';
% Sol_AWC='r__SOL_AWC().sol________19-23    -0.15   0.15';
% cn2='r__CN2.mgt________19-23   -0.25   0.25';
% ch_n2='v__CH_N2.rte________19-23    0   0.15';
% ch_k2='v__CH_K2.rte________19-23    5   100';
% Alpha_bf='v__ALPHA_BF.gw________19-23    0   1';
% gw_delay='v__GW_DELAY.gw________19-23    0  500';
% gwqmn='v__GWQMN.gw________19-23    0   5000';
% gw_revap='v__GW_REVAP.gw________19-23    0.02   0.2';
% 
% Surflag='v__SURLAG.hru________1,4-8,14-18    0.05  6';
% Sol_AWC='r__SOL_AWC().sol________1,4-8,14-18    -0.15   0.15';
% cn2='r__CN2.mgt________1,4-8,14-18   -0.25   0.25';
% ch_n2='v__CH_N2.rte________1,4-8,14-18    0   0.15';
% ch_k2='v__CH_K2.rte________1,4-8,14-18    5   100';
% Alpha_bf='v__ALPHA_BF.gw________1,4-8,14-18    0   1';
% gw_delay='v__GW_DELAY.gw________1,4-8,14-18    0  500';
% gwqmn='v__GWQMN.gw________1,4-8,14-18    0   5000';
% gw_revap='v__GW_REVAP.gw________1,4-8,14-18    0.02   0.2';


% % Surflag1='v__SURLAG.hru________2-3,9-13    0.05  6';
% % Sol_AWC1='r__SOL_AWC().sol________2-3,9-13    -0.15   0.15';
% % cn21='r__CN2.mgt________2-3,9-13  -0.25   0.25';
% % ch_n21='v__CH_N2.rte________2-3,9-13    0   0.15';
% % ch_k21='v__CH_K2.rte________2-3,9-13    5   100';
% % Alpha_bf1='v__ALPHA_BF.gw________2-3,9-13    0   1';
% % gw_delay1='v__GW_DELAY.gw________2-3,9-13    0  500';
% % gwqmn1='v__GWQMN.gw________2-3,9-13    0   5000';
% % gw_revap1='v__GW_REVAP.gw________2-3,9-13    0.02   0.2';

Surflag='v__SURLAG.hru    0.05  6';
Sol_AWC='r__SOL_AWC().sol    -0.15   0.15';
cn2='r__CN2.mgt   -0.25   0.25';
ch_n2='v__CH_N2.rte    0   0.15';
ch_k2='v__CH_K2.rte    5   100';
Alpha_bf='v__ALPHA_BF.gw    0   1';
gw_delay='v__GW_DELAY.gw    0  500';
gwqmn='v__GWQMN.gw    0   5000';
gw_revap='v__GW_REVAP.gw    0.02   0.2';
% Sol_k='r__SOL_K().sol    -0.15   0.15';
%Revpamn='v__REVAPMN.gw    0.01   500';
ESCO='v__ESCO.hru    0.1   1';
EPCO='v__EPCO.hru    0.1   1';

TLAPS='v__TLAPS.sub    -10   0';
PLAPS='v__PLAPS.sub    0   120';
canmx='v__CANMX.hru  0  50';

SFTMP='v__SFTMP.bsn    -5   5';
SMTMP='v__SMTMP.bsn    -5   5';
SMFMX='v__SMFMX.bsn    0   10';
SMFMN='v__SMFMN.bsn    0   10';
TIMP='v__TIMP.bsn    0   1';


if update_best_parmter==0
fp = fopen(strcat(sufi2_in, 'par_inf.txt'),'w+');
fprintf(fp,'%s\n', [Num_parm,line01]);
fprintf(fp,'%s\n', [Num_simulation,line02]);
fprintf(fp,'\n');
for ii=1:length(clibate_parmeter)
    if ii==length(clibate_parmeter)
    fprintf(fp,'%s',eval(clibate_parmeter{ii}));
    else
    fprintf(fp,'%s\n',eval(clibate_parmeter{ii}));
    end
end
fclose(fp);
end

% sw_edit_def
line03='1        : starting simulation number';
line04='   : ending simulation number';

fp = fopen(strcat(swat_excute_folder, 'SUFI2_swEdit.def'),'w+');
fprintf(fp,'%s\n', line03);
fprintf(fp,'%s', [Num_simulation,line04]);
fclose(fp);
%fprintf(fp,'\n');

% var_file_name.txt
fp = fopen(strcat(sufi2_in, 'var_file_name.txt'),'w+');
fprintf(fp,'%s\n', [var_file_name{1}(1:(end-4)),'.txt']);
fprintf(fp,'%s\n', [var_file_name{2}(1:(end-4)),'.txt']);
fprintf(fp,'%s', [var_file_name{3}(1:(end-4)),'.txt']);
fprintf(fp,'\n');
fp = fopen(strcat(sufi2_in, 'var_file_name.txt'),'a+');
for mm=1:subbains
fprintf(fp,'%s\n', [ET_file_name{mm},'.txt']);
end
fclose(fp);

%var_file_rch.txt
fp = fopen(strcat(sufi2_in, 'var_file_rch.txt'),'w+');
fprintf(fp,'%s\n', [var_file_name{1}(1:(end-4)),'.txt']);
fprintf(fp,'%s\n', [var_file_name{2}(1:(end-4)),'.txt']);
fprintf(fp,'%s', [var_file_name{3}(1:(end-4)),'.txt']);
fclose(fp);

%var_file_sub.txt
fp = fopen(strcat(sufi2_in, 'var_file_sub.txt'),'w+');
for mm=1:subbains
fprintf(fp,'%s\n', [ET_file_name{mm},'.txt']);
end
fclose(fp);

%% update best parmater

if update_best_parmter==1
    if update_sub_best_param==0
        kk=0;
        subbasin_all_para=0;
        [updated_paramter] =Read_Update_paramter([iteration_last,'SUFI2.OUT\'], kk,subbasin_all_para );
        fp = fopen(strcat(sufi2_in, 'par_inf.txt'),'w+');
        fprintf(fp,'%s\n', [Num_parm,line01]);
        fprintf(fp,'%s\n', [Num_simulation,line02]);
        fprintf(fp,'\n');
        for ii=1:length(updated_paramter)
            if ii==length(updated_paramter)
                fprintf(fp,'%s',updated_paramter{ii,1});
            else
                fprintf(fp,'%s\n',updated_paramter{ii,1});
            end
        end
        
    elseif update_sub_best_param==1
        for kk=1:subbasin
              
            [updated_paramter] =Read_Update_paramter([iteration_last,'SUFI2.OUT\subbasin',num2str(kk),'\SUFI2.OUT\'], kk,subbasin_all_para,first_iteration );
            if subbasin_all_para>0
                Num_parm_new=str2num(Num_parm);
                current_updated_paramter=updated_paramter((Num_parm_new*kk-(Num_parm_new-1)):Num_parm_new*kk); % 11 paramters for each subbasin
            else
                    current_updated_paramter=updated_paramter;  
            end
            
            if kk==1
                format='w+';
            else
                format='a+';
            end
            
            fp = fopen(strcat(sufi2_in, 'par_inf.txt'),format);
            
            if kk==1
                %  four param for each sub
                
                Num_parm_temp=num2str(str2num(Num_parm)*subbasin);
                
                fprintf(fp,'%s\n', [Num_parm_temp,line01]);
                fprintf(fp,'%s\n', [Num_simulation,line02]);
                fprintf(fp,'\n');
            end
            
            for ii=1:length(current_updated_paramter)
                if kk<subbasin
                    fprintf(fp,'%s\n',current_updated_paramter{ii,1});
                else
                    if ii==length(current_updated_paramter)
                        fprintf(fp,'%s',current_updated_paramter{ii,1});
                    else
                        fprintf(fp,'%s\n',current_updated_paramter{ii,1});
                    end
                end
            end
        end
    end
end


% update_parmter
if updated_pram_range==1
    if update_sub_range==0
        kk=0;
        subbasin=0;
   updata_para_range( sufi2_in,sufi2_in,iteration_last,Num_parm,Num_simulation, kk, subbasin, subbasin_all_para_range,first_iteration)
    elseif update_sub_range==1
        for kk=1:subbasin
   % updata_para_range( sufi2_in,[sufi2_out,'subbasin',num2str(kk),'\SUFI2.OUT\'],Num_parm,Num_simulation,kk,subbasin)
   updata_para_range( [iteration_last,'Sufi2.Out\subbasin',num2str(kk),'\SUFI2.IN\'],sufi2_in,...
            [iteration_last,'Sufi2.Out\subbasin',num2str(kk),'\SUFI2.OUT\'],Num_parm,Num_simulation,kk,subbasin,subbasin_all_para_range, first_iteration )
        end
    end
end


 

end


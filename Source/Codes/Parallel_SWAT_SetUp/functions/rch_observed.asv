function [ output_args ] = rch_observed(sufi2_in, observ_fold, begin_year,end_year, var_file_name, INPRINT)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here


if INPRINT==0;
    sheet='sheet2';
elseif INPRINT==1;
     sheet='sheet1';
else
    sheet='sheet3';
end
    

rch01='   : this is the name of the variable and the subbasin number to be included in the objective function';
rch02='   : number of data points for this variable as it follows below. First column is a sequential number from beginning';
rch03= ' : of the simulation, second column is variable name and date (format arbitrary), third column is variable value.';

% define paramter

% begin_year=2007;
% end_year=2009;
% variable_name01='FLOW_OUT_1';
% variable_name02='FLOW_OUT_12';
% variable_name03='FLOW_OUT_19';
% Num_observ='1096';

for kk=1:length(var_file_name)
    %data=xlsread('Qilian_1990-2014_daily_data.xls');
    data=xlsread(strcat(observ_fold,var_file_name{kk}(1:end-3),'xls'),sheet);
    
    total_days=0;
    daily_day=[];
    Each_Year_Flag_all=[];
    for year=begin_year:end_year
        
       if INPRINT==1 % daily data
        Num_year_days=yeardays(year);
       elseif INPRINT==0 % mothly data
           Num_year_days=12;
       end
        
        total_days=total_days+Num_year_days;
        
        temp_days=(1:Num_year_days)';
        
        temp_flag01=repmat({'FLOW_OUT_'},Num_year_days,1);
        temp_flag02=repmat({num2str(year)},Num_year_days,1);
        
        Each_Year_Flag=strcat(temp_flag01,num2str(temp_days),'_',temp_flag02);
        Each_Year_Flag=strrep(Each_Year_Flag,' ','');
        
        Each_Year_Flag_all=[Each_Year_Flag_all;Each_Year_Flag];
        
        id=find(data(:,1)==year);
        daily_day=[daily_day;data(id,end)];
    end
    
    FLOW_out_data=cell(total_days,3);
    
    FLOW_out_data(:,1)=num2cell((1:total_days)');
    FLOW_out_data(:,2)=Each_Year_Flag_all;
    FLOW_out_data(:,3)=num2cell(daily_day);
    
    if kk==1
        format='w+';
    else
        format='a+';
    end
    
    fp = fopen(strcat(sufi2_in, 'observed_rch.txt'),format);
    if kk==1
        fprintf(fp,'%s\n', '3     : number of observed variables');
    end
    fprintf(fp,'\n');
    temp01=var_file_name{kk};
    fprintf(fp,'%s\n', [temp01(1:end-4),rch01]);
    Num_observ=num2str(length(daily_day'));
    fprintf(fp,'%s\n', [Num_observ,rch02]);
    fprintf(fp,'%s\n', rch03);
    for ii =1:total_days
        fprintf(fp,'%d %s %4.2f\n', FLOW_out_data{ii,:});
    end
    fclose(fp);
end




end


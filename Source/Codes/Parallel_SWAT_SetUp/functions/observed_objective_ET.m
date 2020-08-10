function [ output_args ] =observed_objective_ET(sufi2_in, observ_fold,begin_year,end_year,var_file_name,...
                               weight, INPRINT)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here



if INPRINT==0;
    sheet='sheet2';
elseif INPRINT==1;
     sheet='sheet1';
else
    sheet='sheet3';
end
    

rch01='   : this is the name of the variable and the subbasin number to be included in the objective function';
rch02='     : weight of the variable in the objective function';
rch03= '-1    : Dynamic flow separation. Not considered if -1. If 1, then values should be added in the forth column below after observations';
rch04= '-1    : constant flow separation, threshold value. (not considered if -1)';
rch05= '1     : if separation of signal is considered, this is weight of the smaller values in the objective function';
rch06= '1     : if separation of signal is considered, this is weight of the larger values in the objective function';
rch07= '10    : percentage of measurement error';
rch08= '   : number of data points for this variable as it follows below. First column is a sequential number from beginning';
rch09= '      : of the simulation, second column is variable name and date (format arbitrary), third column is variable value.';

%%
      

data_temp=xlsread(strcat(observ_fold,'subbasin_ET_2000-2013_new.xlsx'),sheet);
for kk=1:length(var_file_name)
  
    data=[data_temp(:,1),data_temp(:,kk+2)];
    
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
        
        temp_flag01=repmat({'ET_'},Num_year_days,1);
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
    


 format='a+';
fp = fopen(strcat(sufi2_in, 'observed.txt'),format);

% if kk==1
%     % 26=23sub ET+ 3 streamlow
%     fprintf(fp,'%s\n', '26     : number of observed variables');
%     fprintf(fp,'%s\n', [num2str(goal_type_defalt), '     : Objective function type, 1=mult,2=sum,3=r2,4=chi2,5=NS,6=br2,7=ssqr,8=PBIAS,9=KGE,10=RSR,11=MNS']);
%     fprintf(fp,'%s\n', '0.5   : min value of objective function threshold for the behavioral solutions');
%     fprintf(fp,'%s\n', '1     : if objective function is 11=MNS (modified NS),indicate the power, p.');
% end


fprintf(fp,'\n');
  temp01=var_file_name{kk};
    fprintf(fp,'%s\n', [temp01(1:end),rch01]);
fprintf(fp,'%s\n', [num2str(weight(kk)),rch02]);
fprintf(fp,'%s\n', rch03);
fprintf(fp,'%s\n', rch04);
fprintf(fp,'%s\n', rch05);
fprintf(fp,'%s\n', rch06);
fprintf(fp,'%s\n', rch07);
Num_observ=num2str(length(daily_day'));
fprintf(fp,'%s\n', [Num_observ,rch08]);
fprintf(fp,'%s\n', rch09);

for ii =1:total_days
fprintf(fp,'%d %s %4.2f\n', FLOW_out_data{ii,:});
end
fclose(fp);

end





end


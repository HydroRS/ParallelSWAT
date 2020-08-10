function [ monthly_data_sum ] = Daily2monthly_new( input_args, Model_start_year,Model_end_year)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%% User difined Parmaters

monthly_data_sum=[];
crrent_day=1;
for year = Model_start_year:Model_end_year 
    for month = 1:12   
        month_day = eomday(year, month);
        data_temp=sum(input_args(crrent_day:(crrent_day+month_day-1)));
        monthly_data_sum=[monthly_data_sum;data_temp];
        crrent_day=crrent_day+month_day;
    end
      
end




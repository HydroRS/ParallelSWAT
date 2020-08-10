function [  ] = extract_sub_def(folder, Num_rch, Num_rch_sub,  Begin_year, end_year, IPRINT )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here


% define parameter
% 
% Num_rch='3';
% Num_rch_sub='1 12 19';
% Begin_year=2007; 
% end_year=2009;


line01='output.sub     : swat output file name';
line02='1              : number of variables to get';
line03='23              : total number of subbasins in the project';
line04='              :total number of subbasins in the project';
line05='          : subbasin numbers for the first variable';
% line04_1='              : number of reaches (subbasins) to get for the second variable';
% line05_1='          : reach (subbasin) numbers for the second variable';
line06='           : beginning year of simulation not including the warm up period';
line07='          : end year of simulation';
line08='              : time step (1=daily, 2=monthly, 3=yearly)';
line0301='8              : variable column number(s) in the swat output file (as many as the above number)';

if IPRINT==0
    IPRINT_new=2;
elseif IPRINT==1
    IPRINT_new=1;
else IPRINT_new=3;
end
    
fp = fopen(strcat(folder, 'SUFI2_extract_sub.def'),'w+');
fprintf(fp,'%s\n', line01);
fprintf(fp,'\n');
fprintf(fp,'%s\n', line02);
fprintf(fp,'%s\n', line0301);
fprintf(fp,'\n');
fprintf(fp,'%s\n', line03);
fprintf(fp,'\n');
fprintf(fp,'%s\n', [Num_rch,line04]);
fprintf(fp,'%s\n', [Num_rch_sub,line05]);
% fprintf(fp,'\n');
% fprintf(fp,'%s\n', [Num_rch_1,line04_1]);
% fprintf(fp,'%s\n', [Num_rch_sub_1,line05_1]);
fprintf(fp,'\n');
fprintf(fp,'%s\n', [num2str(Begin_year),line06]);
fprintf(fp,'%s\n', [num2str(end_year),line07]);
fprintf(fp,'%s\n', [num2str(IPRINT_new),line08]);
%fprintf(fp,'\n');

end


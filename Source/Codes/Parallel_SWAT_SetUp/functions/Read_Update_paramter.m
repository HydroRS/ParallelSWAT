function [updated_paramter] =Read_Update_paramter(folder,subbasin, subbasin_all_para,first_iteration )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% Update paramter 

%  folder='D:\Work_2020\Papers\SWAT\SWAT_Calibration\Muti_spatial_calibration\muti_sptail.Sufi2.SwatCup\Iterations\Yingluo_Iter02\Sufi2.Out\';

% best paramter 
fid=fopen(strcat(folder,'best_par.txt'),'r');
L=1;
while ~feof(fid)
       str=fgetl(fid);
   % if ~isempty(str) 
       data{L,1}=str;
       L=L+1;
   % end
end

[m,n]=find(cellfun(@(x) isempty(x),data)==1);

updated_paramter=data((m(end)+1):end, 1);

if subbasin>0
    for jj=1:length(updated_paramter)
        temp01=regexp(updated_paramter{jj}, '\s+', 'split');
        if subbasin_all_para==0 && first_iteration==1
        temp02=[temp01{1},'________',num2str(subbasin),'     ', temp01{2}];
        elseif subbasin_all_para>0 
         temp02=[temp01{1},'     ', temp01{2}]; 
        else
         temp02=[temp01{1},'     ', temp01{2}]; 
        end
        updated_paramter{jj}=temp02;
    end
end

for mm=1:length(updated_paramter)
    updated_paramter{mm,1}=[updated_paramter{mm,1},...
        updated_paramter{mm,1}(end-10:end)];
end





end


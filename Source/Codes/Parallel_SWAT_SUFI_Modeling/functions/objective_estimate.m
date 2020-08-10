function [ output,str_type ] = objective_estimate( ObjType, Obs_vec, simu_vec)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
 if ObjType ==1 % NSE
     NSE=1-sum((Obs_vec-simu_vec).^2)/sum(Obs_vec-mean(Obs_vec).^2);
     output=NSE;
     str_type='NSE';
 elseif ObjType ==2 % KGE
     r_val=(corr(simu_vec,Obs_vec)-1)^2;
     std_val=(std(simu_vec)/std(Obs_vec)-1)^2;
     u_val=(mean(simu_vec)/mean(Obs_vec)-1)^2;
     KGE=1-sqrt(r_val+std_val+u_val);
     output=KGE;
     str_type='KGE';
 elseif ObjType ==3 % R2
    CC=corr(simu_vec,Obs_vec)^2;
    output=CC;
    
 elseif ObjType==4 % RMSE
   RMSE=sqrt((sum((simu_vec-Obs_vec).^2))/length(Obs_vec));  
   output=RMSE;
    str_type='RMSE';
 end
 
end


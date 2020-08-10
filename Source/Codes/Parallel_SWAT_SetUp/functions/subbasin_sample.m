function [ output_args ] = subbasin_sample( sufi2_in,subbasin,swat_excute_folder )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
 line01='   : Number of Parameters (the program only reads the first 4 parameters or any number indicated here)';
    cd(sufi2_in);
      fclose all;
    if exist([sufi2_in,'par_inf_bak.txt']) ==2
        delete([sufi2_in,'par_inf_bak.txt'])
    end
    eval(['!rename', 32 'par_inf.txt', 32 'par_inf_bak.txt']);
    
    fid=fopen([sufi2_in,'par_inf_bak.txt'],'r');
    % fid=fopen([SUFI2_in, 'observed.txt'],'r');
    L=1;
    while ~feof(fid)
        str=fgetl(fid);
        data{L,1}=str;
        L=L+1;
    end
    if isempty(data{3})
        start_para=4;
    else  start_para=3;
    end
    fclose(fid);
   par_value_all=[];
    for ii=1:subbasin
        temp_data=data(start_para:end,:);
        sub_parm_length=length(temp_data)/subbasin;
        sub_parm=temp_data((sub_parm_length*ii-(sub_parm_length-1)):sub_parm_length*ii);
        
        fp = fopen(strcat(sufi2_in, 'par_inf.txt'),'w+');
        fprintf(fp,'%s\n', [num2str(sub_parm_length),line01]);
        fprintf(fp,'%s\n', data{2});
        for kk=1:length(sub_parm)
            if kk==length(sub_parm)
                fprintf(fp,'%s',sub_parm{kk});
            else
                fprintf(fp,'%s\n',sub_parm{kk});
            end
        end
        fclose(fp);
        cd(swat_excute_folder); 
        system('SUFI2_Pre.bat');
        
        par_value_temp=load([sufi2_in, 'par_val.txt']);
        
        if ii==1
            par_value_all=[par_value_all,par_value_temp];
        else
            par_value_all=[par_value_all,par_value_temp(:,2:end)];
        end
        
    end  
    fp = fopen(strcat(sufi2_in, 'par_val.txt'),'w+');
      multiple_formt1={'%d';'%9.4f ';'\n'};
      [m n]=size(par_value_all);
    fprintf(fp,[multiple_formt1{[1 ones(1,(n-1))*2 3]}],par_value_all');
    
     cd(sufi2_in);
    if exist([sufi2_in,'par_inf.txt']) ==2
          fclose all;
        delete([sufi2_in,'par_inf.txt'])
    end
    eval(['!rename', 32 'par_inf_bak.txt', 32 'par_inf.txt']);

end


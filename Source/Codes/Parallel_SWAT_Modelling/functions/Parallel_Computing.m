function [ ] = Parallel_Computing(swat_excute_folder,sufi2_in,work_number,var_file_name,ET_file_name,current_folder,Num_simulation )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
swat_excute_folder_par=Composite();
temp_id=strfind(swat_excute_folder,'\');
temp_folder=swat_excute_folder(1:temp_id(end-1));
for kk=1:work_number
    if ~exist([temp_folder,'\Parallel',num2str(kk),'\'],'dir')
    mkdir(temp_folder,['Parallel', num2str(kk)])
    copyfile([swat_excute_folder,'*.*'], [temp_folder,'Parallel',num2str(kk)]);
    else
        copyfile([swat_excute_folder,'SUFI2.IN\','*.*'], [temp_folder,...
                                      'Parallel',num2str(kk),'\SUFI2.IN']);
        copyfile([swat_excute_folder,'*.def'], [temp_folder,...
                                      'Parallel',num2str(kk),'\']);
       copyfile([swat_excute_folder,'file.cio'], [temp_folder,...
                                      'Parallel',num2str(kk),'\']);      
    end
    swat_excute_folder_par{kk}=[temp_folder,'Parallel',num2str(kk)];
end

% Parmter set re-distribution among the workers
cd(current_folder);
Paramter_Set_Redistribute( sufi2_in,work_number,swat_excute_folder_par )

% deletle existing output files
spmd
delete(strcat([swat_excute_folder_par, '\SUFI2.OUT\'],'*.txt'));
end

% Num_simulation/work_number=integer

for iii=1:(Num_simulation/work_number)
  % Parallel processes 
  spmd
    curent_run_num=textread([swat_excute_folder_par,'\SUFI2.IN\','trk.txt'],'%d');
    cd(swat_excute_folder_par);
    % step 4.1 model.in
     system('SUFI2_make_input.exe');
      % step 4.2 update paramter
      system('Swat_Edit_Hidden.bat');
     % step 4.3 run swat
     system('swat.exe');
      % step 4.4 extract result
     system('SUFI2_extract_rch.exe');
     system('SUFI2_extract_sub.exe');
     % system('SUFI2_extract_hru.exe');
     % system('SUFI2_extract_res.exe');
      % update run_num
     run_num=curent_run_num+1;
     dlmwrite([swat_excute_folder_par,'\SUFI2.IN\','trk.txt'],run_num,'%d');    
  end
end

% Combing the results of all parallels
delete(strcat([swat_excute_folder, 'SUFI2.OUT\'],'*.txt'));
Comb_Parallel(swat_excute_folder, swat_excute_folder_par,...
              var_file_name, ET_file_name )

% matlabpool close

end


function [ output_args ] = Comb_Parallel(swat_excute_folder_origin, swat_excute_folder_par, rch_file_name, Susb_file_name )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_all_rch=[];
for kk=1:length(swat_excute_folder_par) 
    for mm=1:length(rch_file_name) % each output
        fid=fopen([swat_excute_folder_par{kk},'\SUFI2.OUT\',[rch_file_name{mm}(1:(end-4)),'.txt']],'r');
        L=1;
        while ~feof(fid)
            str=fgetl(fid);
            data{L,mm}=str;
            L=L+1;
        end
    end
    data_all_rch=[data_all_rch;data];
end
% write out rch output 
for mm=1:length(rch_file_name) % each output
    if mm==1 
        format='w+';
    else format='a+';
    end
    fp = fopen([swat_excute_folder_origin,'SUFI2.OUT\',[rch_file_name{mm}(1:(end-4)),'.txt']],format);
    fprintf(fp,'%s\n', data_all_rch{:,mm});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_all_sub=[];
for kk=1:length(swat_excute_folder_par) 
    for mm=1:length(Susb_file_name) % each output
        fid=fopen([swat_excute_folder_par{kk},'\SUFI2.OUT\',Susb_file_name{mm}(1:(end-4)),'.txt'],'r');
        L=1;
        while ~feof(fid)
            str=fgetl(fid);
            data_sub{L,mm}=str;
            L=L+1;
        end
    end
    data_all_sub=[data_all_sub;data_sub];
end

% write out sub output 
for mm=1:length(Susb_file_name) % each subb output
    if mm==1 
        format='w+';
    else format='a+';
    end
    fp = fopen([swat_excute_folder_origin,'SUFI2.OUT\',Susb_file_name{mm}(1:(end-4)),'.txt'],format);
    fprintf(fp,'%s\n', data_all_sub{:,mm});
end



end


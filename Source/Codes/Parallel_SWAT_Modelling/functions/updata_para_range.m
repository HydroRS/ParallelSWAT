function [ output_args ] = updata_para_range( sufi2_in,sufi2_in_origin,iteration_last,Num_parm,Num_simulation,subbasin_id,subnumber,subbasin_all_para,first_iteration)
%UNTITLED2 Summary of this function goes here

%   Detailed explanation goes here
line01='   : Number of Parameters (the program only reads the first 4 parameters or any number indicated here)';
line02='  : number of simulations';

if subnumber==0
fid=fopen([sufi2_in,'par_inf.txt'],'r');
elseif subnumber>0
 fid=fopen([sufi2_in,'par_inf.txt'],'r');   
end

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


range=start_para:length(data);
para_value=zeros(length(range),2);
temp02=cell(length(range),1);
for jj=1:length(range)
    temp01=regexp(data{jj+start_para-1}, '\s+', 'split');
    temp02{jj}=temp01{1};
    para_value(jj,:)=str2double(temp01(2:end));
end

if subnumber>0 && first_iteration==0
    
    sub_parm_length=length(range)/subnumber;
    range=range(1:sub_parm_length);
    para_value=para_value((sub_parm_length*subbasin_id-(sub_parm_length-1))...
        :(sub_parm_length*subbasin_id),:);
    temp02=temp02((sub_parm_length*subbasin_id-(sub_parm_length-1))...
        :(sub_parm_length*subbasin_id),:);
    
end

  best_para02=[temp02, num2cell(para_value)];

      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % new paramter arnge
 if subnumber==0
     fid=fopen(strcat(iteration_last,'Sufi2.Out\new_pars.txt'),'r');
 elseif subnumber>0
     fid=fopen(strcat(iteration_last,'new_pars.txt'),'r');
 end
 
L=1;
while ~feof(fid)
       str=fgetl(fid);
   % if ~isempty(str) 
       data1{L,1}=str;
       L=L+1;
   % end
end

k=0;
for jj=1:length(data1)

  if data1{jj,1}(1:3)=='---'; 
      k=k+1;
      break;
  end
  k=k+1;
end
updated_paramter_range=data1((k+1):end, 1);

para_value_new=zeros(length(range),2);
for jj=1:length(range)
    temp04=regexp(updated_paramter_range{jj}, '\s+', 'split');
    para_value_new(jj,:)=str2double(temp04(3:end));
end

index01=para_value(:,1)<para_value_new(:,1);
lower=para_value(:,1);
lower(index01,1)=para_value_new(index01,1);

index02=para_value(:,2)>para_value_new(:,2);
upper=para_value(:,2);
upper(index02,1)=para_value_new(index02,2);

if subnumber==0
    new_range=[temp02, num2cell(lower), num2cell(upper)];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fp = fopen(strcat(sufi2_in, 'par_inf.txt'),'w+');
    fprintf(fp,'%s\n', [Num_parm,line01]);
    fprintf(fp,'%s\n', [Num_simulation,line02]);
    fprintf(fp,'\n');
    
    for i=1:length(best_para02(:,1))
        if i<length(best_para02(:,1))
            fprintf(fp,'%s   %9.4f %9.4f\n',new_range{i,:});
        else
            fprintf(fp,'%s   %9.4f %9.4f',new_range{i,:});
        end
    end
    
elseif subnumber>0
    
    if subbasin_all_para==0
        if first_iteration==1
            for mm=1:length(temp02)
                temp02{mm,1}=[temp02{mm,1},'________',num2str(subbasin_id)];
            end
        end
    end
    new_range=[temp02, num2cell(lower), num2cell(upper)];
   if subbasin_all_para>0
        new_range=new_range((str2num(Num_parm)*subbasin_id-(str2num(Num_parm)-1)):str2num(Num_parm)*subbasin_id,:);
    end

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if subbasin_id==1
        format='w+';
    else
        format='a+';
    end
    fp = fopen(strcat(sufi2_in_origin, 'par_inf.txt'),format);
    
    if subbasin_id==1
        Num_parm=num2str(str2num(Num_parm)*subnumber);
        fprintf(fp,'%s\n', [Num_parm,line01]);
        fprintf(fp,'%s\n', [Num_simulation,line02]);
        fprintf(fp,'\n');
    end
    
    if subbasin_all_para==0
        length_temp=length(best_para02(:,1));
    elseif subbasin_all_para>0
        length_temp=length(best_para02(:,1))/subnumber;
    end
    for i=1:length_temp
        if subbasin_id<subnumber
            fprintf(fp,'%s   %9.4f %9.4f\n',new_range{i,:});
        else
            if i<length(best_para02(:,1))
                fprintf(fp,'%s   %9.4f %9.4f\n',new_range{i,:});
            else
                fprintf(fp,'%s   %9.4f %9.4f',new_range{i,:});
            end
        end
        
    end
end

fclose all;

end


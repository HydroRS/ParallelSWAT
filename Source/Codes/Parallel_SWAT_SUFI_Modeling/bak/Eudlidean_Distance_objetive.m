% Ref Madsen H. Automatic calibration of a conceptual rainfall¨Crunoff model
% using multiple objectives. Journal of Hydrology, 2000, 235(3 ):276-288.

folder=['D:\Work_2020\Papers\SWAT\SWAT_Calibration\Muti_lumped_calibaration'...
    '\muti_sptail.Sufi2.SwatCup\Iterations\test-ET&Stream\Iter01\Sufi2.Out\'];

objetives=xlsread([folder,'goal_single_objevtive.xlsx']);
% max_objetive=max(objetives,[],1);
% Eu_distance_A=min(max_objetive)-max_objetive;

% update 01
% objetives_new=sqrt((1-objetives).^2);
%  min_objetive=min(objetives_new,[],1);
%  Eu_distance_A=max(min_objetive)-min_objetive;

% update 02
 objetives_new=1-objetives;
 Stream_obj=sum(repmat(1/3,300,3).*objetives_new(:,1:3),2);
  ET_obj=sum(repmat(1/23,300,23).*objetives_new(:,4:26),2);
  objetives_2=[Stream_obj,ET_obj ];
  min_objetive=min(objetives_2,[],1);
  Eu_distance_A=max(min_objetive)-min_objetive;


xlswrite(['D:\Work_2020\Papers\SWAT\SWAT_Calibration\Muti_lumped_calibaration'...
          '\muti_sptail.Sufi2.SwatCup\SUFI2.IN\ZL_Paramter\Eu_distance_A.xlsx'],...
          Eu_distance_A)
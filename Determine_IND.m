function [IND]=Determine_IND(Calibration,binwidth)
%This is an optional function that is used to only target pixels that have
%a certain amount of signal (Above Background). This was not used in the
%main text and we are not going to use it in the example here. 

IND=[];

for ii=size(Calibration(1).Z_Plane,1):-1:1
    for iii=size(Calibration(1).Z_Plane,2):-1:1
        
        Total=[];
        for i=length(Calibration):-1:1
            Total=[Total, (Calibration(i).Z_Plane{ii,iii})];
        end
        
        if mean(Total)>.25*binwidth
          IND(end+1,1:2)=[ii,iii];
        end
        
    end
end

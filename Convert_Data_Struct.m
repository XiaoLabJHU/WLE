%This will be a function to convert the new simulation data to the correct
%structure for analysis with the WLE method. 
function [RegIm]=Convert_Data_Struct(ResSimu)

RegIm={};

for i=1:length(ResSimu)
    for ii=1:size(ResSimu(i).ImSimu,3)
    RegIm{i,ii}=ResSimu(i).ImSimu(:,:,ii);  
    end
end
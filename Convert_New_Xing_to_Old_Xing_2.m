%This will be a function to convert the new simulation data to the correct
%structure. 
function [RegIm]=Convert_New_Xing_to_Old_Xing_2(ResSimu)

RegIm={};

%{
for i=1:length(ResSimu)
    for ii=1:size(ResSimu(i).ImSimu,3)
    RegIm{i,ii}=[];  
    end
end
%}
for i=1:length(ResSimu)
    for ii=1:size(ResSimu(i).ImSimu,3)
    RegIm{i,ii}=ResSimu(i).ImSimu(:,:,ii);  
    end
end
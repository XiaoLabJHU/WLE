

function [Background,Alpha]=Determine_Second_Term(Bead_Struct)
%Bead Struct is the calabration beads
%Number_of_Boot is related to the number of virtual cells you want to make adding noise to smooth the pdf.
%Number of boot will increase the number beads that many times.

%out
%Is a matrix of histograms containing the pdf of having a particular
%value this is used to calculate the likelihood

%bins is a matrix of the bins for the Lik_Matrix pdfs, they are the edges!

%Calibration is the organized data used to make the pdfs

RegIm=Bead_Struct;
%First we are going to go through and determine the background by using the
%pixels of each bead furthest from the center.
Background=[];
for ii=1:size(RegIm,2)
    for i=1:size(RegIm,1)
        if length(RegIm{i,ii})>1
        Background(end+1)=RegIm{i,ii}(1,1);
        Background(end+1)= RegIm{i,ii}(end,end);
        Background(end+1)= RegIm{i,ii}(1,end);
        Background(end+1)= RegIm{i,ii}(end,1);
        end
    end
end

Alpha=[];
for ii=1:size(RegIm,2)
    for i=1:size(RegIm,1)
        if length(RegIm{i,ii})>1
            %{
            One=RegIm{i,ii}(1:3,1:end);
                    Two=RegIm{i,ii}(1:end,1:3);
                    Three=RegIm{i,ii}(1:end,end-3:end);
                    Four=RegIm{i,ii}(end-3:end,1:end);
                    Outer= unique([One(:)',Two(:)',Three(:)',Four(:)']);
    %}
        Bead_Pix=RegIm{i,ii}-mean(Background);
        Alpha(end+1)=sum(sum(Bead_Pix));
        end
    end
end





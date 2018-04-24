

%CHB 2018

function [Bead_Pix_Mod]=Creat_New_Pixels(Bead_Pix, X, Y)

midrow=floor(size(Bead_Pix,1)/2)+1;
midcol=floor(size(Bead_Pix,2)/2)+1;

Bead_Pix_Mod=[];
%X=11;
%Y=11;
Bead_Pix=imtranslate(Bead_Pix,[midcol-X,midrow-Y]);

for aa=-6:6
    for bb=-6:6
        %counts=length(Calibration{aa+5,bb+5});
        if size(Bead_Pix,1)>=aa+midrow && size(Bead_Pix,2)>=bb+midcol && aa+midrow>0 && bb+midcol>0
            Bead_Pix_Mod(aa+7,bb+7)=Bead_Pix(aa+midrow,bb+midcol);
        else
            disp('Pix was outside of cropped region, you may want to try cropping again')
            Bead_Pix_Mod(aa+7,bb+7)=0;
        end
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
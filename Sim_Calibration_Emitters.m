

function [Calibration]=Sim_Calibration_Emitters(Bead_Struct, Number_of_Emitters, Background2, Alpha2)
%This is a function that will simulate the calibration emitters that will
%be used to generate the probability density matrix later on. 

%Bead_Struct: Is the cropped bead images at each z-plane (Each row is a new
%z-plane)

%Number_of_Emitters: the number of simulated emitters at each z-plane 

%Background2 and Alpha2: are the arrays determined in step 1;








RegIm=Bead_Struct;

%We start by defining some structures/variables
Calibration={};
Calibration(size(RegIm,1)).Z_Plane={};
for i=1:13
    for ii=1:13
        for iii=1:size(RegIm,1)
            Calibration(iii).Z_Plane{i,ii}=[];
        end
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Step 2A:
%First we are going to go through and determine the background by using the
%pixels of each bead furthest from the center. Note: the cropped emitters
%should be centered. 
Background=[];
for ii=1:size(RegIm,2)
    for i=1:size(RegIm,1)
        if length(RegIm{i,ii})>1
            Background(end+1)= RegIm{i,ii}(1,1);
            Background(end+1)= RegIm{i,ii}(end,end);
            Background(end+1)= RegIm{i,ii}(1,end);
            Background(end+1)= RegIm{i,ii}(end,1);
        end
    end
end


%Here we are determining the PSF(i,j|Z) term as disscussed in the SI. This
%is simply taking the mean background subtracted normalized bead image for
%each z-plane. 

for i=1:size(RegIm,1)
    RegIm3=[];
    for ii=1:size(RegIm,2)
        if length(RegIm{i,ii})>1
            Bead_Pix=RegIm{i,ii}-mean(Background);
            Alpha=sum(sum(Bead_Pix));
            Bead_Pix=Bead_Pix/Alpha;
            RegIm3(:,:,ii)=[Bead_Pix];
        end
    end
    
    RegIm3_mean=mean(RegIm3,3);
    for ii=1:size(RegIm,2)
        if length(RegIm{i,ii})>1
            RegIm{i,ii}=RegIm3_mean;
        end
    end
    
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Step 2B: Here we simulate emitters with Photon noise as a Poisson and a
%scaled background term. 


    for ii=1:Number_of_Emitters
        
        disp([num2str(ii/Number_of_Emitters)])
        
        parfor i=1:size(RegIm,1)
            
            %Make sure that there is a mean bead image at that z-plane. 
            if length(RegIm{i,1})>1
                
                %Grab an Alpha value at random, make sure that it is
                %positive. This will be used to scale the PSF term and will
                %also influence the amount of noise from the Poisson Photon
                %noise. 
                
                back4=-100;
                while back4<0
                    Aint=randi(length(Alpha2))
                    back4=Alpha2(Aint);
                end
                
                %This is a function that will add poisson noise using the PSF and Alpha for the z-plane. 
                Bead_Pix=Noisey(RegIm{i,1}*back4);

                %Here we randomly assign a background signal to each pixel
                back3=[];
                for cat=1:size(Bead_Pix,1)
                    for cat2=1:size(Bead_Pix,2)
                        back3(cat, cat2)=Background2(randi(length(Background2)));
                    end
                end
                
                %Calculate the mean of the background signal for that
                %simulated emitter. 
                back3_mean=mean(mean(back3));
                
                %Create the simulated emitter by combining the background
                %term and the signal from the PSF term. 
                for cat=1:size(Bead_Pix,1)
                    for cat2=1:size(Bead_Pix,2)
                        Bead_Pix(cat,cat2)=Bead_Pix(cat,cat2)/back4+(back3(cat,cat2)-back3_mean)/back4;
                    end
                end
                
                %Here we only fit to a 2D gaussian to determine the
                %centroid of the calibration emitter. We then only use this
                %centroid to center the simulated calibration emitter. 
                [Para resnorm jacobian] = gauss2d_chris(Bead_Pix, 0);
                X=Para(2);
                Y=Para(3);
                
                %This is the function that centers the calibration emitter
                %and crops it out. (Creates a 11x11 image, with the emitter
                %centered) Uses a linear to translate the image.
                [Bead_Pix_Mod]=Creat_New_Pixels(Bead_Pix, X, Y);
                
                %here we just reorganize the data.
                Calibration(i).Z_Plane=Cal(Bead_Pix_Mod, Calibration(i).Z_Plane);
            end
        end
        
    end

end





function [Calibration]=Cal(Bead_Pix_Mod, Calibration)

%This is a simple function that will create the calibration matrix
for aa=-6:6
    for bb=-6:6
        counts=length(Calibration{aa+7,bb+7});
        if Bead_Pix_Mod(aa+7,bb+7)~=0
            Calibration{aa+7,bb+7}(counts+1)=Bead_Pix_Mod(aa+7,bb+7);
        end
    end
end

end



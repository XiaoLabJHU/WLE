
function [z]=Determine_z_liki_Final(PDM, bins, Image3, indexs, imp)
%This is a function that will maximize the likelihood and obtain the best
%z-plane based off of the calculated probability distributions.

%Here we determine the center of the emitter so that we can align the
%pixels in the same manner, we aligned the pixels of our experimental
%calibration emitters. 

[Para resnorm jacobian] = gauss2d_chris(Image3, 0);
X=Para(2);
Y=Para(3);

%We start with a really low lik value so that we can maximize it during the
%phase space search. 
Likelyhood=-9999999999999999999999999999999999999999999999999;

%Start with the determined zposition as not being defined.
z=nan;

%Shift and crop the emitter as in the previous steps. 
[Image_Mod]=Creat_New_Pixels(Image3, X, Y);

%Go through each z-plane and determine the one that maximizes the
%likelihood. 
for z_check=1:1:size(PDM,3)
    Likelyhood_t=0;
    for kcat=1:length(indexs)
        i=indexs(kcat,1);
        ii=indexs(kcat,2);
        edges = bins{i,ii,z_check};
        area=median(abs(diff(edges)));
        
        %Just in case the center of the emitter is more toward the edge of
        %the cropped image, the cropped emitters pixels will equal zero
        %where there is no signal. 
        if Image_Mod(i,ii)~=0
            
            %Find out what bin the actual signal is in.
            N = histcounts(Image_Mod(i,ii),edges);
            %divide by area of bin to make pdf
            smoother=(PDM{i,ii,z_check}/area);
            %multiply importance (weight) by the log of probability density
            %to have that signal. 
            Likelyhood_t=Likelyhood_t+imp(kcat)*log((smoother(N>0)));
            
        else
            
            Likelyhood_t=Likelyhood_t+imp(kcat)*log(.0000001);
            
        end
    end
    
    if Likelyhood_t>Likelyhood
        Likelyhood=Likelyhood_t;
        z=z_check;
    end
    
    
end


if isnan(z)
    for z_check=1:1:size(PDM,3)
    Likelyhood_t=0;
    for kcat=1:length(indexs)
        i=indexs(kcat,1);
        ii=indexs(kcat,2);
        edges = bins{i,ii,z_check};
         area=median(abs(diff(edges)));
        if Image_Mod(i,ii)~=0
            
            N = histcounts(Image_Mod(i,ii),edges);
            
            smoother=(PDM{i,ii,z_check}/area+.000001);
            
            Likelyhood_t=Likelyhood_t+imp(kcat)*log((smoother(N>0)));
            
        else
            
            Likelyhood_t=Likelyhood_t+imp(kcat)*log(.000001);
            
        end
    end
    
    if Likelyhood_t>Likelyhood
        Likelyhood=Likelyhood_t;
        z=z_check;
    end
    
    
    end
end




%toc


end




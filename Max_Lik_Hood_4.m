function [Lik_Matrix, bins2]=Max_Lik_Hood_4(Calibration, binwidth)
%In this function we simply determine the probaiblity distributions to have
%a particular signal given the pixel and z-plane of the emitter. 

%here we define some structures that will hold the data.
bins2={};
Lik_Matrix={};

Clik={};
Clik(size(Calibration,1)).Z_Plane={};
for i=1:13
    for ii=1:13
        for iii=1:length(Calibration)
            Clik(iii).Z_Plane{i,ii}=[];
        end
    end
end

Clikbin={};
Clikbin(size(Calibration,1)).Z_Plane={};
for i=1:13
    for ii=1:13
        for iii=1:length(Calibration)
            Clikbin(iii).Z_Plane{i,ii}=[];
        end
    end
end



%Here we perform this calculation in // and simply go through the
%experimental calibration emitters and generate histograms with a certain
%number of bins (determined to be 15% of the total data considered for that
%histogram) 

parfor i=1:length(Calibration)
    tic
    for ii=size(Calibration(1).Z_Plane,1):-1:1
        
        for iii=size(Calibration(1).Z_Plane,2):-1:1
            
            Total=(Calibration(i).Z_Plane{ii,iii});
            
            kd1=min(Total);
            kd2=max(Total);
            numofbins=20;%We start the search with 20 bins
            maxoftt=1;
            
            while maxoftt>=.15 %Here is where we define the maximum amount of data that will be in one bin, one can easily change this value.
                bins=[-Inf,kd1-(kd2-kd1)/numofbins:(kd2-kd1)/numofbins:kd2+(kd2-kd1)/numofbins,Inf];
                tt=histogram((Calibration(i).Z_Plane{ii,iii}),bins,'Normalization','probability');
                maxoftt=max(tt.Values);
                numofbins=numofbins+1;
            end
            
            tt=histogram((Calibration(i).Z_Plane{ii,iii}),bins,'Normalization','probability');
            Clikbin(i).Z_Plane{ii,iii}=bins;
            Clik(i).Z_Plane{ii,iii}=tt.Values;%/sum(tt.Values);
        end
    end
    toc
end

%Here we organize the data in a more intuative format so you can look at
%the ind cells later if you wish, by just clicking on the PDM.

bins2={};
Lik_Matrix={};


for i=1:13
    for ii=1:13
        for iii=1:length(Calibration)
            Lik_Matrix{i,ii,iii}=Clik(iii).Z_Plane{i,ii};
            bins2{i,ii,iii}=Clikbin(iii).Z_Plane{i,ii};
        end
    end
end





end


%This is an example script to run an example of the WLE methodology on
%sythetic data. The exact data we will be analyzing here is the
%experimental PSF 2 we analyzed in the main text.
%Please contact Christopher H. Bohrer if you have any questions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%Step 1: Here we load in the data and calculate the scalling factors and
%the background distribution of the experimental emitters. This quick
%calculation is done in the function Determine_Second_Term

clear
Filename_Beads='Simu_SNR5_Cali2_realPSF';
Filename_Exp='Simu_SNR2_Cali2_realPSF';

%Load in the experimental emitters
load(Filename_Exp)
%Convert data into the proper structure for analysis
[RegIm]=Convert_Data_Struct(ResSimu);
%Calculate the background and scaling factors for all experimental
%emitters and store them in the arrays Background and Alpha
[Background, Alpha]=Determine_Second_Term(RegIm);

%Specifically for the example here, we will plot the distribution
%of background signal and Alpha terms as individual histograms
figure
subplot(2,1,1)
histogram(Alpha)
xlabel('Scaling Factors')
ylabel('Counts')
subplot(2,1,2)
histogram(Background)
xlabel('Background')
ylabel('Counts')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%Step 2: Here we will load in the Bead images and use those images to
%generate our calibration emitters. The inner workings for the individual
%functions are all commented. The logic for the following step is more
%clearly explained in the main text. Depending upon how many cores your
%computer has this could take varying amounts of time. Also, we do not
%simulate the same number of calibration emitters as in the main text. 

%If you do not want to wait for this step to run, simply load Step_2.mat

%load in the images of the beads, for this example here this is the images
%with the highest SNR.
load([Filename_Beads])

%Convert to the correct format for the WLE algorithm
[RegIm]=Convert_Data_Struct(ResSimu);

%This is the function that will generate the calibration emitters at the
%various z-planes. If you would like to see the inner workings of this
%function, all the important aspects of the function are commented and 
%described in the user guide. 
[Calibration]=Sim_Calibration_Emitters(RegIm,500,Background, Alpha);


%To look at how the mean intensity in the center pixel varies for at each
%z-plane, of the simulation of the experimental calibration emitters run
%the following:

I_Values_at_each_Z_Plane_7_7=[];
Z_Plane=[];
for i=1:100
    I_Values_at_each_Z_Plane_7_7(end+1)=mean(Calibration(i).Z_Plane{7,7}(:));
Z_Plane(end+1)=i;
end

plot(Z_Plane*10-500, I_Values_at_each_Z_Plane_7_7)
ylabel('Mean Normalized Intensity')
xlabel('Z-Plane')







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

%Step 3: 

%If you do not want to wait for the following code to run simply load
%Step_3.mat

%Here we determine the probability density distributions to observe a
%particular signal for each pixel, using the experimental calibration
%emitters that we generated in the previous step. 

%Here we define a minimum binwidth for the probability density distribution
%Note: This is just for this for this user example.
binwidth=std((Background(1:length(Alpha))-mean(Background))./Alpha);

%Here we will determine which pixels to use to determine the Z
%position, as we do not want noise to dominate our calculation.
%The following process is optional, and allows WLE to only utilize pixels
%with a certain amount of signal above background right off the bat.

%If you do not want to speed up the later phase space search and perform
%the calculation as in the main text of the work you can uncomment the
%following line of code.
%binwidth=-100000;
[indexs]=Determine_IND(Calibration,binwidth);

%The following function is where we actually determine the probability
%distributions to have a particular signal. For this example here we adjust
%the bin size until there is at most 15% of the data in one bin. One can
%change this by altering the following function and should keep in mind the
%number of simulated emitters generated. 
[PDM, bins2]=Max_Lik_Hood_4(Calibration,binwidth);



%Here we will generate the probability dist vs z-plane for inspeciton. It
%should look like the figure in the main text.
Check_Lik_Matrix 

%clear('Calibration') %If you want to clear up some space on your computer
%depending upon how many experimental calibration emitters you generated. 













%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%


%Step 4: Here we are going to perform the phase space search and optimize
%the weighted likelihood. This will be done by manipulating the weighted
%imporatance (imp) of each pixel, until we have minimized the score
%function. This is just a simple algorithm to determine the weights that
%are best for the optical setup. 

%If you do not want to wait for this to run you can simply load
%Final_Analyzed_SNR2_Cali2_rea.mat

%Step 4A:

imp=ones(1,length(indexs));%These are the weights of the individual pixels, relative to the centroid. 
score_final=999999999999999999999999999999999999999;%start with a large score so we can minimize this the first go

%Here we start with all the weights equal to 1, which is the same as MLE 

scores=[];%This will store the calculated scoring function at each iteration
Error=[];%This will calculate the error for each iteration. 


%We are also going to load in the B-spline fit for the condition
load(['Fit_',Filename_Exp])
%Load in the experimental emitters
load(Filename_Exp)
%Convert data into the proper structure for analysis
[RegIm]=Convert_Data_Struct(ResSimu);

sdfwerfg=randi(length(imp));%The first random element of the weight matrix we are going to change, after the first iteration. 
imp_temp=imp;%Just storing the origonal.


%This is for the number of iterations for the phase space search, 1000
%should be enough and you will be able to see if the phase space search
%converged. 
for lskdjf=1:1000

    %Just define some arrays
    frames=[];
    zcalc=[];
    zcalc_traditional=[];
    ztrue=[];
    counts=0;
    
    for ii=[1:2]
        counts=counts+1;
        vvsid=length(zcalc);
        
        parfor i=[1:size(RegIm,1)]
            
          %Here we subtract out the mean background and then divide by its
          %integrated signal from the emitter. 
          
                Image1=RegIm{i,ii};
                Image1=RegIm{i,ii}-mean(Background);
                Image1=Image1./sum(sum(Image1));
                
                
                %Step 4B:
                
                %This is the actual function that maximizes the WLE, please
                %look into the function for more details. 
                [z]=Determine_z_liki_Final(PDM, bins2, Image1, indexs, imp)
                
                %Here we just store the results
                frames(vvsid+i)=ii+(i-1)*2;
                
                zcalc(vvsid+i)=z;
                
                ztrue(vvsid+i)=i;
                
                %To give the B-spline methodology even footing, because our
                %methodology cannot go below/above 500nm above the focal
                %plane. If the B-spline goes above (due to error in the
                %calculation) we restrict it to be within the same range as
                %WLE
                Temp_Calc_Z=FitS(i).Z(ii);
                if round((Temp_Calc_Z/(1000/size(RegIm,1))+1))>1 && round((Temp_Calc_Z/(1000/size(RegIm,1))+1))<100
                    zcalc_traditional(vvsid+i)=(Temp_Calc_Z/10+1);
                else
                    zcalc_traditional(vvsid+i)=1;
                end
                
                if round((Temp_Calc_Z/(1000/size(RegIm,1))+1))>=100
                    zcalc_traditional(vvsid+i)=100;
                end
        end
   
    end
    
    %Step 4C:
    %Here I will calculate the score by taking localizaitons that are
    %within 5 frames of each other and minimizing the distance between them
    
    df=[];
    d_dis=[];
    for oinwefr=1:length(frames)-1
        for oinwer=oinwefr:length(frames)
            df(end+1)=abs(frames(oinwefr)-frames(oinwer));
            d_dis(end+1)=abs(zcalc(oinwefr)-zcalc(oinwer));
        end
    end
    
    %Find the distances between localizations that are less than 5 frames
    %separated. And then take the sum of the abs distances.
    
    nsdfoin=find(df<5);
    score=sum(d_dis(nsdfoin));
    
    %We then store the Score and the Error for that iteration.
    scores(end+1)=score;
    Error(end+1)=mean(abs(zcalc(1:length(ztrue))-ztrue)*10);
    
    %If the score is the lowest score we have ever seen write out the
    %results.
    if score<score_final
        disp(['score=',num2str(score)])
        disp(['score_final=',num2str(score_final)])
        disp(['WLE Error=', num2str(mean(abs(zcalc(1:length(ztrue))-ztrue)*10)),'   B-Spline Error=',num2str(mean(abs(zcalc_traditional(1:length(ztrue))-ztrue)*10))])
        score_final=score;
        save(['Final_Analyzed_',Filename_Exp(6:end-4)])
    else
        imp=imp_temp;
    end
    imp_temp=imp;
    imp(sdfwerfg)=rand; 
end

%Here we are going to plot the score and how the error varied with the
%score for each iteration. you should see it plateau
%%

disp(['WLE Error=', num2str(mean(abs(zcalc(1:length(ztrue))-ztrue)*10)),'   B-Spline Error=',num2str(mean(abs(zcalc_traditional(1:length(ztrue))-ztrue)*10))])
subplot(2,1,1)
plot(log10(1:length(scores)),scores)
xlabel('Log_{10}(Iteration)','FontSize',20)
ylabel('Score','FontSize',20)
axis tight
subplot(2,1,2)
plot(log10(1:length(scores)),Error)
xlabel('Log_{10}(Iteration)','FontSize',20)
axis tight
ylabel('WLE Error','FontSize',20)
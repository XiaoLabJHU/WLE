%This is a function that will add a certain amount of Poisson noise to each of the pixels

function Bead_Pix_Noise=Noisey(Bead_Pix)

Bead_Pix_Noise=zeros(size(Bead_Pix,1),size(Bead_Pix,2));

for i=1:size(Bead_Pix,1)
    for ii=1:size(Bead_Pix,2)
        if Bead_Pix(i,ii)>0
            Bead_Pix_Noise(i,ii)=poissrnd(Bead_Pix(i,ii));
        end
    end
end

end
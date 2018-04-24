clf
counter=1;
offset=0;
colormap jet
ll={};
counter2=0;
for sodin=1+offset:size(PDM,1)-offset
    for nsi=1+offset:size(PDM,2)-offset
        li_t=[];
        binst=[];
        zposee=[];
        
        for i=1:size(PDM,3)
            inds=PDM{sodin,nsi,i}>0;
            li_t=[li_t, PDM{sodin,nsi,i}(inds)];
            binst=[binst, bins2{sodin,nsi,i}(inds)];
            zposee=[zposee,(bins2{sodin,nsi,i}(inds)*0)+i];
            %{
    plot(bins2{6,6,i}(1:end-1),PDM{6,6,i})
    drawnow
    pause
    hold on
            %}
            
        end
        if sum(indexs((indexs(:,1)==sodin),2)==nsi)>0
        subplot(size(PDM,1)-offset*2,size(PDM,2)-offset*2,counter)
        
        %imagesc(li_t)
        scatter(zposee,binst,20,li_t,'filled')
        counter2=counter2+1;
        %title(num2str(imp(counter2)))
        %colorbar
        axis tight
        end
        counter=counter+1;
        %axis off
    end
end

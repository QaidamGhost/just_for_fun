function areas_of_rising_lakes(start_water_level,incre,total_incre,path_of_dem)
%% Input DEM and define the range of rising water level and its increment to generate a batch of images showing the areas of lakes at different levels.
% "TopoToolbox" and its dependencies are needed.

%start_water_level=2825;
%incre=5;
%total_incre=250;
%path_of_dem='E:/MoveData/dem/WestPartOfTheNortherQaidam5.tif';

DEM = GRIDobj(path_of_dem);
    while incre<total_incre
        water_level=start_water_level+incre;
        imageschs(DEM,[],'colorbar',false,'colormap','landcolor')
    
        DEM2=DEM;
        [m,n]=size(DEM2.Z);
        C=zeros(m,n);
        for i=1:m
            for j=1:n
                if DEM2.Z(i,j)> water_level
                    C(m-i+1,j)=1;
                elseif DEM2.Z(i,j)<= water_level
                    C(m-i+1,j)=0;
                end
            end
        end
        DEM2.Z=C;
        
        hold on
        colormap([0.3010,0.7450,0.9330;0,1,0]);
        clims=[0 1];
        a=imagesc(DEM2.georef.SpatialRef.XWorldLimits,DEM2.georef.SpatialRef.YWorldLimits,DEM2.Z,clims);
        axis xy
        set(a,'alphadata',~DEM2.Z);
        titlename=num2str(water_level);
        tmp=size(titlename);
        titlename(tmp(2)+1)=' ';
        titlename(tmp(2)+2)='m';
        title(titlename);
        saveas(a,titlename,'png');
        hold off
    end
end
function MapLocalizationPoints(parent, varargin)
    %figName - Name of the figure
    
    %You can plot any number of items and specify the marker and size of
    %the marker with the following varargin:
    %Name - Of the collection of points to be plotted.
    %Below, these are similar to MATLAB's plot() arguments.
    %LineSpec 
    %MarkerSize
    %MarkerFaceColor
    
    if mod(length(varargin),5) == 0
        gx = geoaxes('parent',parent);
        hold on;
        Names = [];
        for i = 0:5:length(varargin)-1
            
            Names = [Names string(cell2mat(varargin(i+1)))];
            Points = cell2mat(varargin(i+2));
            LineSpec = cell2mat(varargin(i+3));
            Size = cell2mat(varargin(i+4));
            FaceColor = cell2mat(varargin(i+5));
            if ~isempty(Points)
                geoplot(gx,Points(:,1),Points(:,2),LineSpec,'MarkerSize',Size,'MarkerFaceColor',FaceColor);
            end
        end
        hold off;
        geobasemap(gx, 'satellite');
        legend(gx,Names);
    else
        disp("Not enough arguments");
    end
end
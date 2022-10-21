function [figObj] = plotMeanCapacity(obj,lineStyle,lineWidth,legendStr,varargin)

    snr = obj.simulation.snr;
    C = obj.simulation.C;
    
    if isscalar(C)
        error("Нет данных для графика, вызовите simulate")
    end
    
    set(0, 'DefaultAxesFontName', 'Times New Roman');
    set(0, 'DefaultTextFontName', 'Times New Roman');
    
    if (nargin == 5)
        figObj = varargin{1};
    else
        figObj = figure;
    end 
    
    meanC = mean(C,1);
    plot(snr,meanC,lineStyle,'LineWidth',lineWidth);
    hold on;
    grid on;
    xlim([snr(1) snr(end)]);
    xlabel('Отношение сигнал/шум, дБ');
    ylabel('C, бит/с/Гц');
    
    legObj = findobj(figObj, 'Type', 'Legend');
    if isempty(legObj)
        legend(legendStr);
    else
        strLeg = legObj.String;
        numLegends = size(strLeg,2);
        strLeg{numLegends} = legendStr;
        legObj.String = strLeg;
    end
end


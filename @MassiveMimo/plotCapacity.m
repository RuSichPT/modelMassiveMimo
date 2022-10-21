function [figObj] = plotCapacity(obj,type,lineStyle,lineWidth,legendStr,varargin)

    snr = obj.simulation.snr;
    C = obj.simulation.C;
    
    if isscalar(C)
        error("Нет данных для графика, вызовите simulate")
    end
    
    set(0, 'DefaultAxesFontName', 'Times New Roman');
    set(0, 'DefaultTextFontName', 'Times New Roman');
    
    if (nargin == 6)
        figObj = varargin{1};
    else
        figObj = figure;
    end 
    
    if type == "mean"            
        C = mean(C,1);
    elseif type == "all" 
        C = sum(C,1);
    else
        error('Нет такого типа. Выберите mean или all')
    end

    plot(snr,C,lineStyle,'LineWidth',lineWidth);
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


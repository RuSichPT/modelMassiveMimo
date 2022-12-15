classdef Painter
    %% Constructor, get
    methods
        function obj = Painter()
            set(0, 'DefaultAxesFontName', 'Times New Roman');
            set(0, 'DefaultTextFontName', 'Times New Roman');
        end
    end
    %%
    methods
        function figObj = plotBer(obj,snr,ber,lineStyle,lineWidth,legendStr,figObj) 
            % lineStyle - цвет графика, 'k','r','g','b','c' '-', '--', ':', '-.'
            % lineWidth - ширина линии 
            semilogy(snr,ber,lineStyle,'LineWidth',lineWidth);
            hold on;
            grid on;
            xlim([snr(1) snr(end)]);
            ylim([10^-6 10^0]);            
            obj.addLegend(legendStr,figObj);
        end
        function figObj = plotCapacity(obj,snr,capacity,lineStyle,lineWidth,legendStr,figObj)
            % lineStyle - цвет графика, 'k','r','g','b','c' '-', '--', ':', '-.'
            % lineWidth - ширина линии
            plot(snr,capacity,lineStyle,'LineWidth',lineWidth);
            hold on;
            grid on;
            xlim([snr(1) snr(end)]);
            xlabel('Отношение сигнал/шум, дБ');
            ylabel('Пропускная способность, бит/с/Гц');
            obj.addLegend(legendStr,figObj);
        end
    end
    %%
    methods (Access = private)
        function addLegend(~,legendStr,figObj)
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
    end
end



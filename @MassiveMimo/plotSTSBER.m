function [figObj] = plotSTSBER(obj, lineStyle, lineWidth, flagSNR, partLegendStr, varargin)
    % lineStyle - цвет графика, lineWidth - ширина линии
    % 'k','r','g','b','c'
    % varargin{1}; figObj строим график на этой figObj 
    % varargin{2}; цвет
    % flagSNR = SNR Eb/N0 
    
    % lineStyle = {'r';'b';'g';'c';'m';'y';'k';'w'};
    % lineStyle = {'k';'--k';'-.k';':k';};
    
    bps = obj.main.bps;
    snr = obj.simulation.snr;
    ber = obj.simulation.ber;
    numSTS = obj.main.numSTS;
    
    set(0, 'DefaultAxesFontName', 'Times New Roman');
    set(0, 'DefaultTextFontName', 'Times New Roman'); 

    if (nargin == 6)
        figObj = varargin{1};
    else
        figObj = figure;
    end   
    
    legendStr = cell(1, numSTS);
    for sts = 1:numSTS 
        if (nargin == 7)
            if (flagSNR == "SNR")
                semilogy(snr, ber(sts,:), lineStyle{sts}, 'LineWidth', lineWidth, 'Color', varargin{1});
            elseif (flagSNR == "Eb/N0") 
                semilogy(snr - (10*log10(bps)), ber(sts,:),lineStyle{sts},'LineWidth', lineWidth, 'Color', varargin{1});
            end
        else
            if (flagSNR == "SNR")
                semilogy(snr, ber(sts,:), lineStyle{sts}, 'LineWidth', lineWidth);
            elseif (flagSNR == "Eb/N0")
                semilogy(snr - (10*log10(bps)), ber(sts,:), lineStyle{sts}, 'LineWidth', lineWidth);
            end
        end       
        hold on;
        legendStr{sts} = [partLegendStr num2str(sts) ' stream'];
    end
    
    grid on;
    xlim([0 snr(end)]);
    ylim([10^-6 10^0]);
    if (flagSNR == "SNR")
        xlabel('Отношение сигнал/шум, дБ');
    elseif (flagSNR == "Eb/N0")
        xlabel('E_b / N_0 , дБ');
    end
    ylabel('Вероятность битовой ошибки');
    title("Massive MIMO streams")
    
    if (nargin == 6)
        legObj = findobj(figObj, 'Type', 'Legend');
        strLeg = legObj.String;
        numLegends = size(strLeg,2);
        for sts = 1:numSTS 
            strLeg{numLegends - numSTS + sts} = legendStr{sts};
        end
        legObj.String = strLeg;
    else        
        legend(legendStr);
    end
end


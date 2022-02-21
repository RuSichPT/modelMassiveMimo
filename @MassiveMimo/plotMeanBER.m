function [figObj] = plotMeanBER(obj, lineStyle, lineWidth, flagSNR, legendStr, varargin)

    % lineStyle - ���� �������, lineWidth - ������ �����
    % 'k','r','g','b','c'
    % '-', '--', ':', '-.'
    % flagFigure = 1 ��������� ����� ������, flag = 0 �� ���������
    % flagSNR =  SNR Eb/N0
    
    bps = obj.main.bps;
    snr = obj.simulation.snr;
    ber = obj.simulation.ber;
    
    if isscalar(ber)
        error("��� ������ ��� �������, �������� simulate")
    end
    
    set(0, 'DefaultAxesFontName', 'Times New Roman');
    set(0, 'DefaultTextFontName', 'Times New Roman');
%     set(0, 'CurrentFigure', figureHandle)

    meanBer = mean(ber,1);
        
    if (nargin == 6)
        figObj = varargin{1};
    else
        figObj = figure;
    end    
    
    if (nargin == 7)
        if (flagSNR == "SNR")
            semilogy(snr, meanBer, lineStyle, 'LineWidth', lineWidth, 'Color', varargin{2});
        elseif (flagSNR == "Eb/N0") 
            semilogy(snr - (10*log10(bps)), meanBer,lineStyle,'LineWidth', lineWidth, 'Color', varargin{2});
        end
    else
        if (flagSNR == "SNR")
            semilogy(snr, meanBer, lineStyle, 'LineWidth', lineWidth);
        elseif (flagSNR == "Eb/N0")
            semilogy(snr - (10*log10(bps)), meanBer, lineStyle, 'LineWidth', lineWidth);
        end
    end
    hold on;
    grid on;
    xlim([snr(1) snr(end)]);
    ylim([10^-6 10^0]);
    if (flagSNR == "SNR")
        xlabel('��������� ������/���, ��');
    elseif (flagSNR == "Eb/N0")
        xlabel('E_b / N_0 , ��');
    end
    ylabel('����������� ������� ������');
    title("Massive MIMO");
    

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


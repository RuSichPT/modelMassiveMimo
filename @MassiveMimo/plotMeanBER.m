function plotMeanBER(obj, lineStyle, lineWidth, flagFigure, flagSNR, varargin)

    % lineStyle - ���� �������, lineWidth - ������ �����
    % 'k','r','g','b','c'
    % flagFigure = 1 ��������� ����� ������, flag = 0 �� ���������
    % flagSNR =  SNR Eb/N0
    
    bps = obj.main.bps;
    snr = obj.simulation.snr;
    ber = obj.simulation.ber;
    
    set(0, 'DefaultAxesFontName', 'Times New Roman');
    set(0, 'DefaultTextFontName', 'Times New Roman'); 

    meanBer = mean(ber,1);

    if (flagFigure == "createFigure")
        figure()
    elseif (flagFigure == "notCreateFigure")     
        if (nargin==7)
            if (flagSNR == "SNR")
                semilogy(snr, meanBer, lineStyle, 'LineWidth', lineWidth, 'Color', varargin{1});
            elseif (flagSNR == "Eb/N0") 
                semilogy(snr - (10*log10(bps)), meanBer,lineStyle,'LineWidth', lineWidth, 'Color', varargin{1});
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
        xlim([0 snr(end)]);
        ylim([10^-6 10^0]);
        if (flagSNR == "SNR")
            xlabel('��������� ������/���, ��');
        elseif (flagSNR == "Eb/N0")
            xlabel('E_b / N_0 , ��');
        end
        ylabel('����������� ������� ������');
        % ylabel('BER');
    end
end


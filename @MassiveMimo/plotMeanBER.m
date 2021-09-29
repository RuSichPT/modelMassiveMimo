function plotMeanBER(obj, lineStyle, lineWidth, flagFigure, flagSNR, varargin)

    % lineStyle - ���� �������, lineWidth - ������ �����
    % 'k','r','g','b','c'
    % flagFigure = 1 ��������� ����� ������, flag = 0 �� ���������
    % flagSNR =  SNR Eb/N0
    
    set(0,'DefaultAxesFontName','Times New Roman');
    set(0,'DefaultTextFontName','Times New Roman'); 

    meanBer = mean(obj.ber,1);

    if (flagFigure == "createFigure")
        figure()
    elseif (flagFigure == "notCreateFigure")     
        if (nargin==7)
            if (flagSNR == "SNR")
                semilogy(obj.snr,meanBer,lineStyle,'LineWidth',lineWidth,'Color',varargin{1});
            elseif (flagSNR == "Eb/N0") 
                semilogy(obj.snr-(10*log10(obj.bps)),meanBer,lineStyle,'LineWidth',lineWidth,'Color',varargin{1});
            end
        else
            if (flagSNR == "SNR")
                semilogy(obj.snr,meanBer,lineStyle,'LineWidth',lineWidth);
            elseif (flagSNR == "Eb/N0")
                semilogy(obj.snr-(10*log10(obj.bps)),meanBer,lineStyle,'LineWidth',lineWidth);
            end
        end
        hold on;
        grid on;
        xlim([0 obj.snr(end)]);
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


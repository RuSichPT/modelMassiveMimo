function plot_ber(ber,snr,bps,str,N,flag,varargin)
% str - ���� �������, N - ������ �����
% 'k','r','g','b','c'
% flag = 1 ��������� ����� ������,flag = 0 �� ���������
set(0,'DefaultAxesFontName','Times New Roman');
set(0,'DefaultTextFontName','Times New Roman'); 
if flag == 1
    figure()
end
if (nargin==7)
    if(bps == 0)
        semilogy(snr,ber,str,'LineWidth',N,'Color',varargin{1});
    else
        semilogy(snr-(10*log10(bps)),ber,str,'LineWidth',N,'Color',varargin{1});
    end
else
    if(bps == 0)
        semilogy(snr,ber,str,'LineWidth',N);
    else
        semilogy(snr-(10*log10(bps)),ber,str,'LineWidth',N);
    end
end
hold on;
grid on;
xlim([0 snr(end)]);
ylim([10^-6 10^0]);
if(bps == 0)
    xlabel('��������� ������/���, ��');
else
    xlabel('E_b / N_0 , ��');
end
ylabel('����������� ������� ������');
% ylabel('BER');
end


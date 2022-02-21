function plotImpulseFrequencyResponses(numb_TX, numb_RX, H, sampleRate)
    % numb_TX - ����� ������� �� Tx, ������� ������
    % numb_RX - ����� ������� �� Rx, ������� ������ 
    % N_h - ���-�� ����������� �������� (����������� ���������� �������)
    % ����� ���������� ��������������

    if ~isobject(H)
        error('������� H �� ������ ���� ��������');
    end
    
    if ~iscell(H)
        error('������� H ������ ���� cell �� �������������');
    end    
    H = cat(2,H{:});
    N_h = size(H,3);
    
    % ��� ��������
    N_FFT = 512;
    m = -N_FFT/2+1:N_FFT/2;
    freq = m * sampleRate/N_FFT;
    dt = 1/sampleRate;
    tau = (0:1:N_h-1)*dt;

    % ���������� �������������� 
    h_time = [];
    for i = 1:N_h
        h_time = cat(2,h_time,H(numb_TX,numb_RX,i));
    end
    abs_h = abs(h_time);
    figure();
    stem(tau, abs_h);
    % ylim([0 2])
    grid on;
    title("Impulse Response " + num2str(numb_TX)+"x"+num2str(numb_RX));
    ylabel('Magnitude');
    xlabel('Delay (s)');

    % ���
    h_freq = fft(h_time', N_FFT);
    figure();
    plot(freq, mag2db(fftshift(abs(h_freq))));
    ylim([-40 20]);
    grid on;
    title("Frequency Response " + num2str(numb_TX)+"x"+num2str(numb_RX));
    ylabel('dBw');
    xlabel('Frequency (Hz)');
end


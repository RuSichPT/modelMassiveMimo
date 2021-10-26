function plotImpulseFrequencyResponses(numb_TX, numb_RX, H, sampleRate)
    % numb_TX - номер антенны на Tx, которую строим
    % numb_RX - номер антенны на Rx, которую строим 
    % N_h - кол-во задержанных сигналов (размерность канального тензора)
    % длина импульсной характеристики

    % Оси графиков
    N_FFT = 512;
    m = -N_FFT/2+1:N_FFT/2;
    freq = m * sampleRate/N_FFT;
    dt = 1/sampleRate;
    tau = (0:1:length(H)-1)*dt;

    % Импульсная характеристика
    h = [];
    N_h = length(H);
    for i = 1:N_h
        h = [h H{i}(numb_TX,numb_RX)];
    end
    abs_h = abs(h);
    figure();
    stem(tau, abs_h);
    % ylim([0 2])
    grid on;
    title("Impulse Response " + num2str(numb_TX)+"x"+num2str(numb_RX));
    ylabel('Magnitude');
    xlabel('Delay (s)');

    % АЧХ
    h_freq = fft(h', N_FFT);
    figure();
    plot(freq, mag2db(fftshift(abs(h_freq))));
    ylim([-40 20]);
    grid on;
    title("Frequency Response " + num2str(numb_TX)+"x"+num2str(numb_RX));
    ylabel('dBw');
    xlabel('Frequency (Hz)');
end


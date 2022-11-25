function figObj = plotESD(masIQ, sampleRate_Hz)

   % Определяем размерность IQ_mas:
   dims = size(masIQ);
   if (length(dims) == 1)
      dims = [dims 1];
   end
  
   % Определяем, сколько точек рисовать
   if (2^nextpow2(dims(1)) == dims(1))
      Nfft = dims(1);
   else
      Nfft = 2^(nextpow2(dims(1))-1);
   end
    
    figObj = figure;
    dataFFT = fftshift(fft(masIQ, Nfft));
    ESD = 20*log10(abs(dataFFT)); 
%     ESD_norm = ESD - max(ESD);
    freq = (-Nfft/2 : 1 : Nfft/2-1)'/Nfft*sampleRate_Hz/1000;   
    plot(freq, ESD);
    
    title('Спектральная плотность энергии');
    grid on;
    xlabel('\deltaf, кГц');
    ylabel('{|S(\omega)|}^2_{норм}, дБ');
end
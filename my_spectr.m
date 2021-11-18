function figure_id = my_spectr(IQ_mas, SAMPLE_RATE_Hz)

   % ќпредел€ем размерность IQ_mas:
   dims = size(IQ_mas);
   if (length(dims) == 1)
      dims = [dims 1];
   end
  
   % ќпредел€ем, сколько точек рисовать
   if (2^nextpow2(dims(1)) == dims(1))
      n_fft = dims(1);
   else
      n_fft = 2^(nextpow2(dims(1))-1);
   end

   % –асчЄт:
   w = window(@blackmanharris, n_fft);
   
   mas_spectr = [];
   for n = 1 : 1 : dims(2)
%      y_mas = pwelch(IQ_mas(1:n_fft, n), n_fft);
%      y_mas = 10*log10(fftshift(abs(y_mas)));
      
      y_mas = fft(IQ_mas(1:n_fft, n) .* w, n_fft);
      y_mas = 20*log10(fftshift(abs(y_mas)));

      mas_spectr = [mas_spectr y_mas];
   end % for n
   
   % ƒл€ нормировки спектра:
   max_val = max(mas_spectr(:));
   
   % –исование:
   x_mas = (-n_fft/2 : 1 : n_fft/2-1)'/n_fft*SAMPLE_RATE_Hz/1000;
   figure_id = figure();
   hold all;
   for n = 1 : 1 : dims(2)
      plot(x_mas, mas_spectr(:,n) - max_val);
   end % for n
   hold off;
   title('—пектр');
   grid on;
   xlabel('\deltaf, к√ц');
   ylabel('P_н_о_р_м, дЅ');  
end



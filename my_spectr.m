function figure_id = my_spectr(IQ_mas, SAMPLE_RATE_Hz)

   % ���������� ����������� IQ_mas:
   dims = size(IQ_mas);
   if (length(dims) == 1)
      dims = [dims 1];
   end
  
   % ����������, ������� ����� ��������
   if (2^nextpow2(dims(1)) == dims(1))
      n_fft = dims(1);
   else
      n_fft = 2^(nextpow2(dims(1))-1);
   end

   % ������:
   w = window(@blackmanharris, n_fft);
   
   mas_spectr = [];
   for n = 1 : 1 : dims(2)
%      y_mas = pwelch(IQ_mas(1:n_fft, n), n_fft);
%      y_mas = 10*log10(fftshift(abs(y_mas)));
      
      y_mas = fft(IQ_mas(1:n_fft, n) .* w, n_fft);
      y_mas = 20*log10(fftshift(abs(y_mas)));

      mas_spectr = [mas_spectr y_mas];
   end % for n
   
   % ��� ���������� �������:
   max_val = max(mas_spectr(:));
   
   % ���������:
   x_mas = (-n_fft/2 : 1 : n_fft/2-1)'/n_fft*SAMPLE_RATE_Hz/1000;
   figure_id = figure();
   hold all;
   for n = 1 : 1 : dims(2)
      plot(x_mas, mas_spectr(:,n) - max_val);
   end % for n
   hold off;
   title('������');
   grid on;
   xlabel('\deltaf, ���');
   ylabel('P_�_�_�_�, ��');  
end



function [outputData] = equalizerZFnumSC(Y, H_estim)
    % ������ Y = X*H+ksi; 

    % ���������� ��� ������ ����������
    % Y - �������� ������� [msc,symb_ofdm,numTx]
    % H_estim - ������ ������� ���� [msc,numTx,numRx]
    % msc - ���-�� ����������,symb_ofdm - ���-�� �������� ofdm

%     Instead of multiplying by the inverse, use matrix right division (/) or matrix left division (\). That is:
%     Replace inv(A)*b with A\b - faster 
%     Replace b*inv(A) with b/A - faster 
    
    outputData = zeros(size(Y,1), size(Y,2), size(Y,3));
    for i = 1:size(Y,1)    
        h_estim = squeeze(H_estim(i,:,:));
        inv_H_ZF = h_estim*h_estim';
        outputData(i,:,:) =  squeeze(Y(i,:,:))*h_estim' / inv_H_ZF;
    end
    % �������� ������ � �������� IQ
end


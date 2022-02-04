function outputData = equalizerZFnumSC(obj, inputData, H_estim)
    % ������ inputData = outputData*H+ksi; 

    % ���������� ��� ������ ����������
    % data - �������� ������� [msc,symb_ofdm,numTx]
    % H_estim - ������ ������� ���� [msc,numSTS,numRx]
    % msc - ���-�� ����������,symb_ofdm - ���-�� �������� ofdm

%     Instead of multiplying by the inverse, use matrix right division (/) or matrix left division (\). That is:
%     Replace inv(A)*b with A\b - faster 
%     Replace b*inv(A) with b/A - faster 

    [numSubCarr,numSTS,numRx] = size(H_estim);
    numSymbOFDM = obj.ofdm.numSymbOFDM;
    outputData = zeros(numSubCarr, numSymbOFDM, numSTS);
    for i = 1:size(inputData,1)    
        h_estim = reshape((H_estim(i,:,:)),numSTS,numRx);
        inv_H_ZF = h_estim*h_estim';
        outputData(i,:,:) = squeeze(inputData(i,:,:))*h_estim' / inv_H_ZF;
    end
    % �������� ������ � �������� IQ
end


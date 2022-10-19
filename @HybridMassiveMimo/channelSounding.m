function [H_estim, H_estimUsers] = channelSounding(obj, snr)
    % ��������������� ����������  
    numTx = obj.main.numTx;
    numUsers = obj.main.numUsers;
    lenFFT = obj.ofdm.lengthFFT;
    cycPrefLen = obj.ofdm.cyclicPrefixLength;
    nullCarrInd = obj.ofdm.nullCarrierIndices;    
    downChann = obj.downChannel; 
    %% ��������� ���������
    [preamble, ltfSC] = obj.generatePreamble(numTx);
    %% ��������� OFDM  
    preambleOFDM = ofdmmod(preamble, lenFFT, cycPrefLen, nullCarrInd);
    %% ����������� ������
    channelPreamble = downChann.pass(preambleOFDM);
    H_estimUsers = cell(numUsers, 1);
    for uIdx = 1:numUsers
        %% ����������� ���
        noisePreamble = awgn(channelPreamble{uIdx,:}, snr, 'measured');
        %% ����������� OFDM
        outPreamble = ofdmdemod(noisePreamble, lenFFT, cycPrefLen, cycPrefLen, nullCarrInd);
        %% ������ ������  
        H_estimUsers{uIdx} = obj.channelEstimate(outPreamble, ltfSC, numTx);
    end
    H_estim = cat(3,H_estimUsers{:});
end


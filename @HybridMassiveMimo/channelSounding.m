function [H_estim, H_estimUsers] = channelSounding(obj, snr)
    % ��������������� ����������  
    numTx = obj.main.numTx;
    numUsers = obj.main.numUsers;
    lenFFT = obj.ofdm.lengthFFT;
    cycPrefLen = obj.ofdm.cyclicPrefixLength;
    nullCarrInd = obj.ofdm.nullCarrierIndices;    
    downChann = obj.channel.downChannel;  
    %% ��������� ���������
    [preamble, ltfSC] = obj.generatePreamble(numTx);
    %% ��������� OFDM  
    preambleOFDM = ofdmmod(preamble, lenFFT, cycPrefLen, nullCarrInd);
    
    H_estimUsers = cell(numUsers, 1);
    for uIdx = 1:numUsers
        %% ����������� ������
        channelPreamble = obj.passChannel(preambleOFDM, downChann{uIdx});
        %% ����������� ���
        noisePreamble = awgn(channelPreamble, snr, 'measured');
        %% ����������� OFDM
        outPreamble = ofdmdemod(noisePreamble, lenFFT, cycPrefLen, cycPrefLen, nullCarrInd);
        %% ������ ������  
        H_estimUsers{uIdx} = obj.channelEstimate(outPreamble, ltfSC, numTx);
    end
    H_estim = cat(3,H_estimUsers{:});
end


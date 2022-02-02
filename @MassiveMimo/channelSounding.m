function H_estim = channelSounding(obj, snr)
    % ��������������� ����������  
    numTx = obj.main.numTx;
    numPhasedElemRx = obj.main.numPhasedElemRx;
    numSTSVec = obj.main.numSTSVec;
    numRxVec = numSTSVec*numPhasedElemRx;
    numUsers = obj.main.numUsers;
    lenFFT = obj.ofdm.lengthFFT;
    cycPrefLen = obj.ofdm.cyclicPrefixLength;
    nullCarrInd = obj.ofdm.nullCarrierIndices;    
    downChann = obj.channel.downChannel;  
    %% ��������� ���������
    [preamble, ltfSC] = obj.generatePreamble(numTx);
    %% ��������� OFDM  
    preambleOFDM = ofdmmod(preamble, lenFFT, cycPrefLen, nullCarrInd);  
    %% ����������� ������
    channelPreamble = obj.passChannel(preambleOFDM, downChann);
    %% ����������� ���
    noisePreamble = awgn(channelPreamble, snr, 'measured');
    
%     %1 �������
%     %% ����������� OFDM
%     outPreamble = ofdmdemod(noisePreamble, lenFFT, cycPrefLen, cycPrefLen, nullCarrInd);
%     %% ������ ������  
%     H_estim = obj.channelEstimate(outPreamble, ltfSC, numTx);

    %2 �������
    H_estim = cell(numUsers, 1);
    for uIdx = 1:numUsers
        %% �������� �� ������
        rxU = numRxVec(uIdx);
        rxIdx = sum(numRxVec(1:(uIdx-1)))+(1:rxU);
        adder = cell(numSTSVec(uIdx), 1);
        for i = 1:numSTSVec(uIdx)
            adder{i} = ones(numPhasedElemRx,1);
        end
        adder = blkdiag(adder{:});
        sumPreamble = noisePreamble(:,rxIdx)*adder;
        %% ����������� OFDM
        outPreamble = ofdmdemod(sumPreamble, lenFFT, cycPrefLen, cycPrefLen, nullCarrInd);
        %% ������ ������  
        H_estim{uIdx} = obj.channelEstimate(outPreamble, ltfSC, numTx);
    end
    H_estim = cat(3,H_estim{:});
end


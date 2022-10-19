function H_estim = channelSounding(obj, snr)
    % ��������������� ����������  
    numTx = obj.main.numTx;
    numPhasedElemRx = obj.main.numPhasedElemRx;
    numSTSVec = obj.main.numSTSVec;
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
    H_estim = cell(numUsers, 1);
    for uIdx = 1:numUsers
        %% ����������� ���
        noisePreamble = awgn(channelPreamble{uIdx,:}, snr, 'measured');
%         if (obj.main.precoderType ~= "DIAG")
%             %% �������� �� ������
%             adder = cell(numSTSVec(uIdx), 1);
%             for i = 1:numSTSVec(uIdx)
%                 adder{i} = ones(numPhasedElemRx,1);
%             end
%             adder = blkdiag(adder{:});
%             sumPreamble = noisePreamble*adder;
%         else
%             sumPreamble = noisePreamble;
%         end
        %% ����������� OFDM
        outPreamble = ofdmdemod(noisePreamble, lenFFT, cycPrefLen, cycPrefLen, nullCarrInd);
        %% ������ ������  
        H_estim{uIdx} = obj.channelEstimate(outPreamble, ltfSC, numTx);
    end
    H_estim = cat(3,H_estim{:});
end


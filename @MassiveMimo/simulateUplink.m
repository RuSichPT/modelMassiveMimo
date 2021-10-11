function H_estim = simulateUplink(obj, snr)
    % ��������������� ���������� 
    numRx = obj.main.numRx;
    numSubCarr = obj.ofdm.numSubCarriers;
    lenFFT = obj.ofdm.lengthFFT;
    cycPrefLen = obj.ofdm.cyclicPrefixLength;
    nullCarrInd = obj.ofdm.nullCarrierIndices;
    upChann = obj.channel.upChannel;  
    %% ��������� ������ 
    x = randi([0 1], numSubCarr, 1);
    %% ��������� 
    ltfSC = pskmod(x,2);

    P = helperGetP(numRx);    
    Pred = P;
    
    Nltf = numRx;
    ltfTx = zeros(numSubCarr, Nltf, numRx);
    for i = 1:Nltf   
        ltf = ltfSC*Pred(:, i).';                
        ltfTx(:,i,:) = ltf;
    end
    %% ��������� OFDM
    preambula = ofdmmod(ltfTx, lenFFT, cycPrefLen, nullCarrInd);
    %% ����������� ������
    channelPreambula = obj.passChannel(preambula, upChann);
    %% ����������� ���
    noisePreambula = awgn(channelPreambula, snr, 'measured');
    %% ����������� OFDM
    outPreambula = ofdmdemod(noisePreambula, lenFFT, cycPrefLen, cycPrefLen, nullCarrInd);
    %% ������ ������  
    H_estim = obj.channelEstimate(outPreambula, ltfSC, numRx);
    H_estim = conj(permute(H_estim, [1,3,2]));
end


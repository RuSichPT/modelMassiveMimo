function [numErrors, numBits] = simulateOneSNRmutCorr(obj, snr, corrMatrix)
    %% ��������������� ����������
    numTx = obj.main.numTx;
    numSTS = obj.main.numSTS;
    modulation = obj.main.modulation;
    bps = obj.main.bps;
    lenFFT = obj.ofdm.lengthFFT;
    cycPrefLen = obj.ofdm.cyclicPrefixLength;
    nullCarrInd = obj.ofdm.nullCarrierIndices;
    numSymbOFDM = obj.ofdm.numSymbOFDM;
    numSubCarr = obj.ofdm.numSubCarriers;
    downChann = obj.channel.downChannel;
    %% ������������ ������
    % ��������� ���������
    [preambulaOFDMZond,zondLtfSC] = obj.generatePreambleOFDM(numTx);
    % ��������� �����������
    preambulaOFDMZond = preambulaOFDMZond * corrMatrix;
    % ����������� ������
    channelPreambulaZond = obj.passChannel(preambulaOFDMZond, downChann);
    % �����������  ���
    noisePreambulaZond = awgn(channelPreambulaZond, snr, 'measured');
    % ����������� OFDM
    outPreambulaZond = ofdmdemod(noisePreambulaZond, lenFFT, cycPrefLen, cycPrefLen, ...
                                    nullCarrInd);
    % ������ ������  
    H_estim_zond = obj.channelEstimate(outPreambulaZond, zondLtfSC, numTx);
    %% ��������� ������
    numBits = bps * numSymbOFDM * numSubCarr;
    inpData = randi([0 1], numBits, numSTS);
    %% ��������� 
    tmpModData = qammod(inpData, modulation, 'InputType', 'bit');
    inpModData = reshape(tmpModData, numSubCarr, numSymbOFDM, numSTS);
    %% ��������������
    [precodData, precodWeights, ~] = obj.applyPrecod(inpModData, H_estim_zond);           
    %% ��������� �������  
    [inpPreambula, ltfSC] = obj.generatePreambleOFDM(numSTS, precodWeights);
    %% ��������� OFDM
    tmpdataOFDM = ofdmmod(precodData, lenFFT, cycPrefLen, nullCarrInd);                            
    dataOFDM = [inpPreambula ; tmpdataOFDM];
    %% ��������� �����������
    dataOFDM = dataOFDM * corrMatrix; 
    %% ����������� ������
    channelData = obj.passChannel(dataOFDM, downChann);
    %% ����������� ���
    noiseData = awgn(channelData, snr, 'measured');
    %% ����������� OFDM
    modDataOut = ofdmdemod(noiseData, lenFFT, cycPrefLen, cycPrefLen, nullCarrInd);           
    %% ������ ������
    outPreambula = modDataOut(:,1:numSTS,:);
    modDataOut = modDataOut(:,(1 + numSTS):end,:);
    H_estim = obj.channelEstimate(outPreambula, ltfSC, numSTS);
    %% ����������
    tmpEqualizeData = obj.equalizerZFnumSC(modDataOut, H_estim);
    equalizeData = reshape(tmpEqualizeData, numSubCarr * numSymbOFDM, numSTS);
    %% �����������
    outData = qamdemod(equalizeData, modulation, 'OutputType', 'bit');
    %% �������� ������  
    numErrors = obj.calculateErrors(inpData, outData);   
end


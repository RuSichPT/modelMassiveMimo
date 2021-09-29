function [numErrors, numBits] = simulateOneSNR(obj, snr)
    %% ������������ ������
    [preambulaOFDMZond,zondLtfSC] = obj.generatePreamble(obj.numTx);
    % ����������� ������
    channelPreambulaZond = obj.passChannel(preambulaOFDMZond);
    % �����������  ���
    noisePreambulaZond = awgn(channelPreambulaZond, snr, 'measured');
    % ����������� OFDM
    outPreambulaZond = ofdmdemod(noisePreambulaZond, obj.lengthFFT, obj.cyclicPrefixLength, obj.cyclicPrefixLength, ...
                                    obj.nullCarrierIndices);
    % ������ ������  
    H_estim_zond = obj.channelEstimate(outPreambulaZond, zondLtfSC, obj.numTx); 
    %% ��������� ������
    numBits = obj.bps * obj.numSymbOFDM * obj.numSubCarriers;
    inpData = randi([0 1], numBits, obj.numSTS);
    %% ��������� 
    tmpModData = qammod(inpData, obj.modulation, 'InputType', 'bit');
    inpModData = reshape(tmpModData, obj.numSubCarriers, obj.numSymbOFDM, obj.numSTS);
    %% ��������������
    [precodData, precodWeights] = obj.applyPrecod(inpModData, H_estim_zond);           
    %% ��������� �������  
    [inpPreambula, ltfSC] = obj.generatePreamble(obj.numSTS, precodWeights);
    %% ��������� OFDM
    tmpdataOFDM = ofdmmod(precodData, obj.lengthFFT, obj.cyclicPrefixLength, obj.nullCarrierIndices);                            
    dataOFDM = [inpPreambula ; tmpdataOFDM];
    %% ����������� ������
    channelData = obj.passChannel(dataOFDM);
    %% ����������� ���
    noiseData = awgn(channelData, snr, 'measured');
    %% ����������� OFDM
    modDataOut = ofdmdemod(noiseData, obj.lengthFFT, obj.cyclicPrefixLength, obj.cyclicPrefixLength, obj.nullCarrierIndices);           
    %% ������ ������
    outPreambula = modDataOut(:,1:obj.numSTS,:);
    modDataOut = modDataOut(:,(1 + obj.numSTS):end,:);
    H_estim = obj.channelEstimate(outPreambula, ltfSC, obj.numSTS);
    %% ����������
    tmpEqualizeData = obj.equalizerZFnumSC(modDataOut, H_estim);
    equalizeData = reshape(tmpEqualizeData, obj.numSubCarriers * obj.numSymbOFDM, obj.numSTS);
    %% �����������
    outData = qamdemod(equalizeData, obj.modulation, 'OutputType', 'bit');
    %% �������� ������  
    numErrors = obj.calculateErrors(inpData, outData);   
end


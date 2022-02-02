function [numErrors, numBits] = simulateOneSNR(obj, snr)
    % ��������������� ����������
    numSTS = obj.main.numSTS;
    numPhasedElemRx = obj.main.numPhasedElemRx;
    numSTSVec = obj.main.numSTSVec;
    numRxVec = numSTSVec*numPhasedElemRx;
    modulation = obj.main.modulation;
    numUsers = obj.main.numUsers;
    bps = obj.main.bps;
    lenFFT = obj.ofdm.lengthFFT;
    cycPrefLen = obj.ofdm.cyclicPrefixLength;
    nullCarrInd = obj.ofdm.nullCarrierIndices;
    numSymbOFDM = obj.ofdm.numSymbOFDM;
    numSubCarr = obj.ofdm.numSubCarriers;
    downChann = obj.channel.downChannel;
    %% ������������ ������
    H_estim_zond = obj.channelSounding(snr);
    %% ��������� ������
    numBits = bps * numSymbOFDM * numSubCarr;
    inpData = randi([0 1], numBits, numSTS);
    %% ��������� 
    tmpModData = qammod(inpData, modulation, 'InputType', 'bit');
    inpModData = reshape(tmpModData, numSubCarr, numSymbOFDM, numSTS);
    %% ��������� �������
    [preambula, ltfSC] = obj.generatePreamble(numSTS);
    inpModData = cat(2, preambula, inpModData);
    %% ��������������
    [precodData, ~, ~] = obj.applyPrecod(inpModData, H_estim_zond);
    %% ��������� OFDM  
    dataOFDM = ofdmmod(precodData, lenFFT, cycPrefLen, nullCarrInd);  
    obj.dataOFDM = dataOFDM;
    %% ����������� ������
    channelData = obj.passChannel(dataOFDM, downChann);
    %% ����������� ���
    noiseData = awgn(channelData, snr, 'measured');
%     %% �������� �� ������
%     sumData = cell(numUsers, 1);
%     for uIdx = 1:numUsers
%         rxU = numRxVec(uIdx);
%         rxIdx = sum(numRxVec(1:(uIdx-1)))+(1:rxU);
%         adder = cell(numSTSVec(uIdx), 1);
%         for i = 1:numSTSVec(uIdx)
%             adder{i} = ones(numPhasedElemRx,1);
%         end
%         adder = blkdiag(adder{:});
%         sumData{uIdx} = noiseData(:,rxIdx)*adder;
%     end
%     sumData = cat(2,sumData{:});
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
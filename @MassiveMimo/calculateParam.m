function calculateParam(obj)

    % ��������� ������� 
    obj.main.numSTS = sum(obj.main.numSTSVec);
    obj.main.numPhasedElemTx = obj.main.numTx / obj.main.numSTS;
    obj.main.numPhasedElemRx = obj.main.numRx / obj.main.numSTS; 
    obj.main.bps = log2(obj.main.modulation);
    
    % ��������� OFDM
    tmpNCI = obj.ofdm.lengthFFT - obj.ofdm.numSubCarriers;
    lengthFFT = obj.ofdm.lengthFFT;
    obj.ofdm.nullCarrierIndices = [1:(tmpNCI / 2) (1 + lengthFFT - tmpNCI / 2):lengthFFT]';
    
    % ��������� ������               
    obj.channel.downChannel = obj.createChannel();
    if ~isobject(obj.channel.downChannel)
        obj.channel.upChannel = obj.channel.downChannel';
    end

end


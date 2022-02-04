function calculateParam(obj)

    % Параметры системы
    obj.main.numSTS = sum(obj.main.numSTSVec);
    obj.main.numPhasedElemTx = obj.main.numTx / obj.main.numSTS;
    obj.main.numPhasedElemRx = obj.main.numRx / obj.main.numSTS; 
    obj.main.bps = log2(obj.main.modulation);
    obj.main.numRxUsers = obj.main.numSTSVec*obj.main.numPhasedElemRx;
    
    % Параметры OFDM
    tmpNCI = obj.ofdm.lengthFFT - obj.ofdm.numSubCarriers;
    lengthFFT = obj.ofdm.lengthFFT;
    obj.ofdm.nullCarrierIndices = [1:(tmpNCI / 2) (1 + lengthFFT - tmpNCI / 2):lengthFFT]';
    
    % Параметры канала
    obj.channel.downChannel = obj.createChannel();

%     if ~isobject(obj.channel.downChannel)
%         obj.channel.upChannel = obj.channel.downChannel';
%     end

    if (obj.channel.type == "STATIC")
        obj.channel.upChannel = obj.channel.downChannel';
    end
end


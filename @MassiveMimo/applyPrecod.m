function [outputData, precodWeights, combWeights] = applyPrecod(obj, inputData, estimateChannel)
    
    % inputData - входные данные размерностью [numSC,numOFDM,numSTS]
    % numSC - кол-во поднессущих
    % numOFDM - кол-во символов OFDM от каждой антенны
    % numSTS - кол-во потоков данных;
    
    % estimateChannel - оценка канала размерностью [numSC,numTx,numSTS]
    % numTx - кол-во излучающих антен
    
    % outputData - выходные данные размерностью [numSC,numOFDM,numTx]
    % precodWeights - веса прекодирования
    % combWeights - веса комбинирования
    
    switch obj.main.precoderType
        case {"MF"}
            [outputData, precodWeights] = applyPrecodMF(inputData, estimateChannel);
            combWeights = 0;
        case {"ZF"}
            [outputData, precodWeights] = applyPrecodZF(inputData, estimateChannel);
            combWeights = 0;
        case {"RZF"}
            [outputData, precodWeights] = applyPrecodRZF(inputData, estimateChannel,0,2);
            combWeights = 0;
        case {"EBM"}
            [outputData, precodWeights, combWeights] = applyPrecodEBM(inputData, estimateChannel);
    end    
    
end


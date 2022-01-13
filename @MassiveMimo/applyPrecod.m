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
        case {'MF'}
            [outputData, precodWeights] = applyPrecodMF(inputData, estimateChannel);
            combWeights = 0;
        case {'ZF'}
            [outputData, precodWeights] = applyPrecodZF(inputData, estimateChannel);
            combWeights = 0;
        case {'RZF'}
            [outputData, precodWeights] = applyPrecodRZF(inputData, estimateChannel, 0, 0.01);
            combWeights = 0;
        case {'EBM'}
            [outputData, precodWeights, combWeights] = applyPrecodEBM(inputData, estimateChannel);
        case {'NOT'}
            [outputData, precodWeights, combWeights] = applyPrecodNot(inputData, estimateChannel);
        case {'BD'}
            [outputData, precodWeights, combWeights] = applyPrecodBD(inputData, estimateChannel, obj.main.numSTSVec);
        case {'TPE'}
            [outputData, precodWeights] = applyPrecodTPE(inputData, estimateChannel, 3);
            combWeights = 0;
        case {'NSA'}
            % K = 1:3; K = 3 max в таком случае выч сложность == ZF => K = 2 
            [outputData, precodWeights] = applyPrecodNSA(inputData, estimateChannel, 2); 
            combWeights = 0;
        case {'NI'}
            % K = 1:2; K = 2 max в таком случае выч сложность == ZF => K = 1 (тк использует 1 итерацию NSA)
            [outputData, precodWeights] = applyPrecodNI(inputData, estimateChannel, 1);  
            combWeights = 0;
        case {'NI-NSA'}
            [outputData, precodWeights] = applyPrecodNI_NSA(inputData, estimateChannel, 2);  
            combWeights = 0;
    end    
    
end


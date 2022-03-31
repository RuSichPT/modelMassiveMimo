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
    combWeights = cell(1,obj.main.numUsers);
    switch obj.main.precoderType
        case {'MF'}
            [outputData, precodWeights] = applyPrecodMF(inputData, estimateChannel);
            for uIdx = 1:obj.main.numUsers
                combWeights{uIdx} = 1;
            end
        case {'ZF'}
            [outputData, precodWeights] = applyPrecodZF(inputData, estimateChannel);
            for uIdx = 1:obj.main.numUsers
                combWeights{uIdx} = 1;
            end
        case {'RZF'}
            [outputData, precodWeights] = applyPrecodRZF(inputData, estimateChannel, 0, 0.01);
            for uIdx = 1:obj.main.numUsers
                combWeights{uIdx} = 1;
            end
        case {'EBM'}
            [outputData, precodWeights, combWeights] = applyPrecodEBM(inputData, estimateChannel);
        case {'DIAG'}
            if (obj.main.numUsers > 1)
                [outputData, precodWeights, combWeights] = applyPrecodDiagMU(inputData, estimateChannel, obj.main.numSTSVec);
            else
                [outputData, precodWeights, combWeights] = applyPrecodDiagSU(inputData, estimateChannel);
            end
        case {'TPE'}
            [outputData, precodWeights] = applyPrecodTPE(inputData, estimateChannel, 3);
            for uIdx = 1:obj.main.numUsers
                combWeights{uIdx} = 1;
            end
        case {'NSA'}
            % K = 1:3; K = 3 max в таком случае выч сложность == ZF => K = 2 
            [outputData, precodWeights] = applyPrecodNSA(inputData, estimateChannel, 2); 
            for uIdx = 1:obj.main.numUsers
                combWeights{uIdx} = 1;
            end
        case {'NI'}
            % K = 1:2; K = 2 max в таком случае выч сложность == ZF => K = 1 (тк использует 1 итерацию NSA)
            [outputData, precodWeights] = applyPrecodNI(inputData, estimateChannel, 1);  
            for uIdx = 1:obj.main.numUsers
                combWeights{uIdx} = 1;
            end
        case {'NI-NSA'}
            [outputData, precodWeights] = applyPrecodNI_NSA(inputData, estimateChannel, 2);  
            for uIdx = 1:obj.main.numUsers
                combWeights{uIdx} = 1;
            end
        otherwise
            error('Нет такого типа прекодера!');
    end    
    
end


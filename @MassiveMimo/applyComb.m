function [outputData] = applyComb(obj, inputData, combWeights)
    
    % inputData - входные данные размерностью [numSC,numOFDM,numSTS]
    % numSC - кол-во поднессущих
    % numOFDM - кол-во символов OFDM от каждой антенны
    % numSTS - кол-во потоков данных;    
    % combWeights - веса комбинирования [numRx,numSTS,numSC]
    % numRx - кол-во принимающих антен    
    % outputData - выходные данные размерностью [numSC,numOFDM,numTx]
    
    numSC = size(inputData,1);
    numOFDM = size(inputData,2);
    numSTS = size(combWeights,2);
    
    outputData = zeros(numSC,numOFDM,numSTS);
      
    switch obj.main.combainerType
        case {'NONE'}
            outputData = inputData;
        case {'DIAG'}
            for iSC = 1:numSC
                outputData(iSC,:,:) = squeeze(inputData(iSC,:,:))*squeeze(combWeights(:,:,iSC));
            end
        otherwise
            error('Нет такого типа прекодера!');
    end    
    
end


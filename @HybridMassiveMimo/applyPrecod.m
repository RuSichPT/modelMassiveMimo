function [digitalData, Frf] = applyPrecod(obj, inputData, estimateChannel)

    % inputData - входные данные размерностью [numSC,numOFDM,numSTS]
    % numSC - кол-во поднессущих
    % numOFDM - кол-во символов OFDM от каждой антенны
    % numSTS - кол-во потоков данных;
    
    % estimateChannel - оценка канала размерностью [numSC,numTx,numSTS]
    % numTx - кол-во излучающих антен
    
    % digitalData - выходные цифровые данные размерностью [numSC,numOFDM,numSTS]
    % Frf - веса прекодирования RF
    
    % Переопределение переменных
    numSTSVec = obj.main.numSTSVec;
    numUsers = obj.main.numUsers;
    
    switch obj.main.precoderType
        case {'JSDM'}
            [digitalData, ~,Frf] = applyPrecodJSDM(inputData, estimateChannel, numSTSVec, numUsers);
        case {'ZF'}
            [digitalData, ~,Frf] = applyPrecodZF(inputData, estimateChannel);
    end     

end


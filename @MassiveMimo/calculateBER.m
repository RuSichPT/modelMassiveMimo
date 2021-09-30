function [berconf,lengthConfInterval] = calculateBER(obj, numErrors, numBits)

    % obj.main.numSTS - кол-во потоков данных
    % numErrors - кол-во ошибок;
    % numBits - кол-во бит
    
    % berconf - BER
    % lengthConfInterval - длина доверительного интервала
    % obj.simulation.confidenceLevel - % уровень достоверности
       
    numSTS = obj.main.numSTS;
    confLvl = obj.simulation.confidenceLevel;
    
    confidenceInterval = zeros(2, numSTS);
    lengthConfInterval = zeros(1, numSTS);
    berconf = zeros(1, numSTS);
    
    for i = 1:numSTS
        [berconf(i), confidenceInterval(:,i)] = berconfint(numErrors(i), numBits, confLvl);
        lengthConfInterval(i) = confidenceInterval(2,i) - confidenceInterval(1,i);
    end

end


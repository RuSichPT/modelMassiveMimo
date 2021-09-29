function [berconf,lengthConfInterval] = calculateBER(obj, numErrors, numBits)

    % obj.numSTS - кол-во потоков данных
    % numErrors - кол-во ошибок;
    % numBits - кол-во бит
    
    % berconf - BER
    % lengthConfInterval - длина доверительного интервала
    confidenceInterval = zeros(2, obj.numSTS);
    lengthConfInterval = zeros(1, obj.numSTS);
    berconf = zeros(1, obj.numSTS);
    
    for i = 1:obj.numSTS
        [berconf(i), confidenceInterval(:,i)] = berconfint(numErrors(i), numBits, obj.confidenceLevel);
        lengthConfInterval(i) = confidenceInterval(2,i) - confidenceInterval(1,i);
    end

end


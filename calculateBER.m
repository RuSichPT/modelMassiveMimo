function [berconf,lengthConfInterval] = calculateBER(numSTS, numErrors, numBits, confidenceLevel)

    % numSTS - кол-во потоков данных
    % numErrors - кол-во ошибок;
    % numBits - кол-во бит
    
    % berconf - BER
    % lengthConfInterval - длина доверительного интервала
    confidenceInterval = zeros(2, numSTS);
    lengthConfInterval = zeros(1, numSTS);
    berconf = zeros(1, numSTS);
    
    for i = 1:numSTS
        [berconf(i), confidenceInterval(:,i)] = berconfint(numErrors(i), numBits, confidenceLevel);
        lengthConfInterval(i) = confidenceInterval(2,i) - confidenceInterval(1,i);
    end

end


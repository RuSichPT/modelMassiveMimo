function numErrors = calculateErrors(obj, inpData, outData)

    % inpData, outData - входные и выходные данные размерностью [numBits, numSTS]
    % numBits - кол-во бит
    % numSTS - кол-во потоков данных;
    
    % numErrors - кол-во ошибок в numBits

    numSTS = obj.main.numSTS;
    
    numErrors = zeros(1, numSTS);            
    for i = 1:numSTS
        numErrors(i) = sum(abs(outData(:,i) - inpData(:,i)));
    end
end


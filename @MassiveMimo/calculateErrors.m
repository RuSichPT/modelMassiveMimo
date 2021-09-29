function numErrors = calculateErrors(obj, inpData, outData)

    % inpData, outData - входные и выходные данные размерностью [numBits, numSTS]
    % numBits - кол-во бит
    % numSTS - кол-во потоков данных;
    
    % numErrors - кол-во ошибок в numBits

    numErrors = zeros(1, obj.numSTS);            
    for i = 1:obj.numSTS
        numErrors(i) = sum(abs(outData(:,i) - inpData(:,i)));
    end
end


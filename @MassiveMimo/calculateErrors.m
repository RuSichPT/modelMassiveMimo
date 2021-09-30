function numErrors = calculateErrors(obj, inpData, outData)

    % inpData, outData - ������� � �������� ������ ������������ [numBits, numSTS]
    % numBits - ���-�� ���
    % numSTS - ���-�� ������� ������;
    
    % numErrors - ���-�� ������ � numBits

    numSTS = obj.main.numSTS;
    
    numErrors = zeros(1, numSTS);            
    for i = 1:numSTS
        numErrors(i) = sum(abs(outData(:,i) - inpData(:,i)));
    end
end


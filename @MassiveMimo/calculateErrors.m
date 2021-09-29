function numErrors = calculateErrors(obj, inpData, outData)

    % inpData, outData - ������� � �������� ������ ������������ [numBits, numSTS]
    % numBits - ���-�� ���
    % numSTS - ���-�� ������� ������;
    
    % numErrors - ���-�� ������ � numBits

    numErrors = zeros(1, obj.numSTS);            
    for i = 1:obj.numSTS
        numErrors(i) = sum(abs(outData(:,i) - inpData(:,i)));
    end
end


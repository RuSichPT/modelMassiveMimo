function [numErrors] = calculateErrors(inpData, outData)

    % inpData, outData - ������� � �������� ������ ������������ [numBits, numSTS]
    % numBits - ���-�� ���
    % numSTS - ���-�� ������� ������;
    
    % numErrors - ���-�� ������ � numBits

    numSTS = size(inpData, 2);
    numErrors = zeros(1, numSTS);            
    for i = 1:numSTS
        numErrors(i) = sum(abs(outData(:,i) - inpData(:,i)));
    end
end


function [berconf,lengthConfInterval] = calculateBER(obj, numErrors, numBits)

    % obj.main.numSTS - ���-�� ������� ������
    % numErrors - ���-�� ������;
    % numBits - ���-�� ���
    
    % berconf - BER
    % lengthConfInterval - ����� �������������� ���������
    % obj.simulation.confidenceLevel - % ������� �������������
       
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


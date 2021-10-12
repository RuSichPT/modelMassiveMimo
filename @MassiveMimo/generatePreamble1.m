function [preamble, ltfSC] = generatePreamble1(obj, numSTS)
    % ��������������� ����������
    numSubCarr = obj.ofdm.numSubCarriers;
    %% ��������� ������ 
    x = randi([0 1], numSubCarr, 4);
    %% ��������� 
    ltfSC = pskmod(x, 2);
    
    Nltf = 1;
    preamble = zeros(numSubCarr, Nltf, numSTS);
    for i = 1:Nltf              
        preamble(:,i,:) = ltfSC;
    end
end
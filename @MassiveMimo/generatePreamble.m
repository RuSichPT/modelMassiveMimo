function [preamble, ltfSC] = generatePreamble(obj, numSTS)
    % ��������������� ����������
    numSubCarr = obj.ofdm.numSubCarriers;
    %% ��������� ������ 
    x = randi([0 1], numSubCarr, 1);
    %% ��������� 
    ltfSC = pskmod(x, 2);

    P = helperGetP(numSTS);    
    Pred = P;
    
    Nltf = numSTS;
    preamble = zeros(numSubCarr, Nltf, numSTS);
    for i = 1:Nltf   
        ltf = ltfSC*Pred(:, i).';                
        preamble(:,i,:) = ltf;
    end
end



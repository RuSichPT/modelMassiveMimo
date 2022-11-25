function [preamble, ltfSC] = generatePreamble(obj, numSTS)
    % ��������������� ����������
    numSubCarr = obj.ofdm.numSubCarriers;
    %% ��������� ������ 
    x = randi([0 1], numSubCarr, 1);
    %% ��������� 
    ltfSC = pskmod(x, 2);

    if ~sum(numSTS == [1 2 4 8 16 32 64 128 256 512 1024])
        error('numSts �� �� ��������� 1 2 4 8 16 32 64 128 256 512 1024')
    end
    P = helperGetP(numSTS);    
    Pred = P;
    
    Nltf = numSTS;
    preamble = zeros(numSubCarr, Nltf, numSTS);
    for i = 1:Nltf   
        ltf = ltfSC*Pred(:, i).';                
        preamble(:,i,:) = ltf;
    end
end
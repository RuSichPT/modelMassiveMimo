function [preamble, ltfSC] = generatePreamble(obj, numSTS)
    % Переопределение переменных
    numSubCarr = obj.ofdm.numSubCarriers;
    %% Формируем данные 
    x = randi([0 1], numSubCarr, 1);
    %% Модулятор 
    ltfSC = pskmod(x, 2);

    if ~sum(numSTS == [1 2 4 8 16 32 64 128 256 512 1024])
        error('numSts дб из диапазона 1 2 4 8 16 32 64 128 256 512 1024')
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
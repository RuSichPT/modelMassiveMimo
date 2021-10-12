function [preamble, ltfSC] = generatePreamble(obj, numSTS)
    % Переопределение переменных
    numSubCarr = obj.ofdm.numSubCarriers;
    %% Формируем данные 
    x = randi([0 1], numSubCarr, 1);
    %% Модулятор 
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



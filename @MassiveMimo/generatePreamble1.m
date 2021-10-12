function [preamble, ltfSC] = generatePreamble1(obj, numSTS)
    % Переопределение переменных
    numSubCarr = obj.ofdm.numSubCarriers;
    %% Формируем данные 
    x = randi([0 1], numSubCarr, 4);
    %% Модулятор 
    ltfSC = pskmod(x, 2);
    
    Nltf = 1;
    preamble = zeros(numSubCarr, Nltf, numSTS);
    for i = 1:Nltf              
        preamble(:,i,:) = ltfSC;
    end
end
function [da,dp] = loadSteeringVector(NumbElem)

    % Парциальные ДН отдельных элементов с учётом расположения на антенне
    for ii = 1:NumbElem
        textA = ['dn' num2str(NumbElem) '\a' num2str(ii) '.tab'];
        da(:,ii) = dlmread(textA, '\t', 1, 1);
    end

    for ii = 1:NumbElem
        textP = ['dn' num2str(NumbElem) '\p' num2str(ii) '.tab'];
        dp(:,ii) = dlmread(textP, '\t', 1, 1);
    end

end


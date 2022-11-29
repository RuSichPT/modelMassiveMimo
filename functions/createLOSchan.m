function [Husers,H] = createLOSchan(numUsers,txpos,txang)

    if numUsers ~= length(txang)
        error("Кол-во пользователей не совпдает с кол-вом углов");
    end
    
    Husers = cell(numUsers,1);
    Ar = cell(numUsers,1); G = cell(numUsers,1); At = cell(numUsers,1);
    numScatters = cell(numUsers,1);
   
    % H = At*G*Ar.'
    for uIdx = 1:numUsers
        numScatters{uIdx} = size(txang{uIdx},2);
        % At   
        At{uIdx} = steervec(txpos,txang{uIdx});
        % Ar
        Ar{uIdx} = ones(1,numScatters{uIdx});
        % G
        g = 1/sqrt(2)*complex(randn(1,numScatters{uIdx}),randn(1,numScatters{uIdx}));
        G{uIdx} = diag(g);
        
        Husers{uIdx} = At{uIdx}*G{uIdx}*Ar{uIdx}.';
    end
    H = cat(2,Husers{:});
end


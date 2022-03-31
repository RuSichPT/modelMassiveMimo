function [Husers,H,txang,rxang] = createScatteringChan(numUsers,txpos,rxpos)

    Husers = cell(numUsers,1);
    Ar = cell(numUsers,1); G = cell(numUsers,1); At = cell(numUsers,1);
    txang = cell(numUsers,1);
    rxang = cell(numUsers,1);
    numScatters = cell(numUsers,1);
   
    % H = At*G*Ar.'
    for uIdx = 1:numUsers
        numScatters{uIdx} = randi(30);
        % At        
        if isscalar(txpos)
            At{uIdx} = ones(1,numScatters{uIdx});
        else
            txang{uIdx} = [360*rand(1,numScatters{uIdx})-180;180*rand(1,numScatters{uIdx})-90];
            At{uIdx} = steervec(txpos,txang{uIdx});
        end
        % Ar
        if isscalar(rxpos)
            Ar{uIdx} = ones(1,numScatters{uIdx});
        else
            rxang{uIdx} = [360*rand(1,numScatters{uIdx})-180;180*rand(1,numScatters{uIdx})-90];
            Ar{uIdx} = steervec(rxpos,rxang{uIdx});  
        end
        % G
        g = 1/sqrt(2)*complex(randn(1,numScatters{uIdx}),randn(1,numScatters{uIdx}));
        G{uIdx} = diag(g);
        
        Husers{uIdx} = At{uIdx}*G{uIdx}*Ar{uIdx}.';
    end
    H = cat(2,Husers{:});
end


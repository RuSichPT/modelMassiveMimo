function [H,Husers] = CreateChannelByDN_static(numRxUsers, numUsers, numBeamDelays, txang, da, dp)
%% Описание
% numRxUsers - кол-во приемных антенн на кждом пользователе(размернность канального тензора)
% numUsers - кол-во пользователей
% numBeamDelays - кол-во задержанных сигналов (размерность канального тензора)
% txang - углы прихода на абонента
% da - действительная часть(амплитуда) stereeng vector
% dp - мнимая часть(фаза) stereeng vector

% numBeams - кол-во лучей приходящих одновременно на абонента с разных углов 
% txang - углы прихода N_scatters на передающую антенну
% rxang углы прихода N_scatters на приемную антенну (если изотропная на приеме то не нужныы)
% pathGains - усиление пути
% phi - азимут
% At  - фазирующиая матрица на передаче 
% Aк  - фазирующиая матрица на приеме 
% G - diag(Path_gains)

%% создание канала
numTx = size(da,2);
numRx = sum(numRxUsers);

H = zeros(numTx,numRx,numBeamDelays);
numBeams = cell(numUsers,1);
pathGains = cell(numUsers,1);

rng(6536);
for i_BeamsDelays = 1:numBeamDelays
    Ar = cell(numUsers,1); G = cell(numUsers,1); At = cell(numUsers,1);
    H_users = [];
    for uIdx = 1:numUsers
        numBeams{uIdx} = length(txang{uIdx}); 
        pathGains{uIdx} = 1/sqrt(2)*complex(randn(1,numBeams{uIdx}), randn(1,numBeams{uIdx}));
        % получение фазирующией матрицы At    
        for i_beam = 1:numBeams{uIdx}
            if txang{uIdx}(i_beam)<=180
                phi = 181 + txang{uIdx}(i_beam);
            elseif txang{uIdx}(i_beam) > 180 
                phi = txang{uIdx}(i_beam) - 180;
            end
            At{uIdx}(:,i_beam) = (da(phi,:).*exp(-1i*dp(phi,:))).'; % с парциальными ДН
        end
        % получение фазирующией матрицы Ar 
        Ar{uIdx} = ones(numBeams{uIdx},numRxUsers(uIdx));
        % получение канальной матрицы H_user
        G{uIdx} = diag(pathGains{uIdx});
        H_user = At{uIdx}*G{uIdx}*Ar{uIdx};
        H_users = cat(2,H_users,H_user);
    end
    H(:,:,i_BeamsDelays) = H_users;
end

Husers = cell(numUsers,1);
for uIdx = 1:numUsers
    rxU = numRxUsers(uIdx);
    rxIdx = sum(numRxUsers(1:(uIdx-1)))+(1:rxU);
    Husers{uIdx} = H(:,rxIdx,:);
end
rng('shuffle')
end

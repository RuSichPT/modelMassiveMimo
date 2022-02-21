function [H, Husers] = createChannelByDnStatic(channel, numRxUsers, numUsers)
%% Описание
% numRxUsers - кол-во приемных антенн на кждом пользователе(размернность канального тензора)
% numUsers - кол-во пользователей
% numDelayBeams - кол-во задержанных сигналов (размерность канального тензора)
% txang - углы прихода на абонента
% da - действительная часть(амплитуда) stereeng vector
% dp - мнимая часть(фаза) stereeng vector
% power - мощность задержанных лучей


% numBeams - кол-во лучей приходящих одновременно на абонента с разных углов 
% txang - углы прихода N_scatters на передающую антенну
% rxang углы прихода N_scatters на приемную антенну (если изотропная на приеме то не нужныы)
% pathGains - усиление пути
% phi - азимут
% At  - фазирующиая матрица на передаче 
% Aк  - фазирующиая матрица на приеме 
% G - diag(Path_gains)

%% создание канала
da = channel.da;
dp = channel.dp;
pdB = channel.pdB;
txang = channel.txAng;
numDelayBeams = length(pdB);

numTx = size(da,2);
numRx = sum(numRxUsers);

H = zeros(numTx,numRx,numDelayBeams);
numScatters = cell(numUsers,1);
pathGains = cell(numUsers,1);
power = (10.^(pdB/10));

rng(6536);
for iDelay = 1:numDelayBeams
    Ar = cell(numUsers,1); G = cell(numUsers,1); At = cell(numUsers,1);
    H_users = [];
    for uIdx = 1:numUsers
        numScatters{uIdx} = length(txang{uIdx}); 
        pathGains{uIdx} = 1/sqrt(2)*complex(randn(1,numScatters{uIdx}), randn(1,numScatters{uIdx}));  
        % получение фазирующией матрицы At    
        for iScatter = 1:numScatters{uIdx}
            if txang{uIdx}(iScatter)<=180
                phi = 181 + txang{uIdx}(iScatter);
            elseif txang{uIdx}(iScatter) > 180 
                phi = txang{uIdx}(iScatter) - 180;
            end
            At{uIdx}(:,iScatter) = (da(phi,:).*exp(-1i*dp(phi,:))).'; % с парциальными ДН
        end
        % получение фазирующией матрицы Ar 
        Ar{uIdx} = ones(numScatters{uIdx},numRxUsers(uIdx));
        % получение канальной матрицы H_user
        G{uIdx} = diag(pathGains{uIdx});
        H_user = At{uIdx}*G{uIdx}*Ar{uIdx};
        H_users = cat(2,H_users,H_user);
    end
    H(:,:,iDelay) = H_users*power(iDelay);
end

Husers = cell(numUsers,1);
for uIdx = 1:numUsers
    rxU = numRxUsers(uIdx);
    rxIdx = sum(numRxUsers(1:(uIdx-1)))+(1:rxU);
    Husers{uIdx} = H(:,rxIdx,:);
end
rng('shuffle')
end

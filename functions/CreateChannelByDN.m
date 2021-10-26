function [H] = CreateChannelByDN(N_users, N_BeamsDelays, da, dp)
%% Описание
% N_users - кол-во пользователей, (размернность канального тензора)
% N_BeamsDelays - кол-во задержанных сигналов (размерность канального тензора)
% txang - углы прихода на абонента
% da - действительная часть(амплитуда) stereeng vector
% dp - мнимая часть(фаза) stereeng vector

% N_beams - кол-во лучей приходящих одновременно на абонента с разных углов 
% txang - углы прихода N_scatters на передающую антенну
% rxang углы прихода N_scatters на приемную антенну (если изотропная на приеме то не нужныы)
% Path_gains - усиление пути
% phi - азимут
% At  - фазирующиая матрица на передаче 
% Aк  - фазирующиая матрица на приеме 
% G - diag(Path_gains)
%% создание канала
H = [];
for i_BeamsDelays = 1:N_BeamsDelays
    Ar = [];G = []; At = [];
    H_users = [];
    for i_user = 1:N_users
        N_beams{i_user} = randi(10);
        txang{i_user} = round(360*rand(1,N_beams{i_user})-180); 
        %rxang{ii} = round(360*rand(1,N_scatters)-180); 
        Path_gains{i_user} = 1/sqrt(2)*complex(randn(1,N_beams{i_user}), randn(1,N_beams{i_user}));
        % получение фазирующией матрицы At    
        for i_beam = 1:N_beams{i_user}
            if txang{i_user}(i_beam)<=180
                phi = 181 + txang{i_user}(i_beam);
            elseif txang{i_user}(i_beam) > 180 
                phi = txang{i_user}(i_beam) - 180;
            end
            At{i_user}(:,i_beam) = (da(phi,:).*exp(-1i*dp(phi,:))).'; % с парциальными ДН
        end
        % получение фазирующией матрицы Ar 
        Ar{i_user} = ones(N_beams{i_user},1);    
        G{i_user} = diag(Path_gains{i_user});
        H_user = At{i_user}*G{i_user}*Ar{i_user};
        H_users = [H_users H_user];
    end
    H{i_BeamsDelays} = H_users;
end

end


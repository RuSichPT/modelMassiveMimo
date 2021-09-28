function [H] = CreateChannelByDN(N_users, N_BeamsDelays, da, dp)
%% ��������
% N_users - ���-�� �������������, (������������ ���������� �������)
% N_BeamsDelays - ���-�� ����������� �������� (����������� ���������� �������)
% txang - ���� ������� �� ��������
% da - �������������� �����(���������) stereeng vector
% dp - ������ �����(����) stereeng vector

% N_beams - ���-�� ����� ���������� ������������ �� �������� � ������ ����� 
% txang - ���� ������� N_scatters �� ���������� �������
% rxang ���� ������� N_scatters �� �������� ������� (���� ���������� �� ������ �� �� ������)
% Path_gains - �������� ����
% phi - ������
% At  - ����������� ������� �� �������� 
% A�  - ����������� ������� �� ������ 
% G - diag(Path_gains)
%% �������� ������
H = [];
for i_BeamsDelays = 1:N_BeamsDelays
    Ar = [];G = []; At = [];
    H_users = [];
    for i_user = 1:N_users
        N_beams{i_user} = randi(10);
        txang{i_user} = round(360*rand(1,N_beams{i_user})-180); 
        %rxang{ii} = round(360*rand(1,N_scatters)-180); 
        Path_gains{i_user} = 1/sqrt(2)*complex(randn(1,N_beams{i_user}), randn(1,N_beams{i_user}));
        % ��������� ����������� ������� At    
        for i_beam = 1:N_beams{i_user}
            if txang{i_user}(i_beam)<=180
                phi = 181 + txang{i_user}(i_beam);
            elseif txang{i_user}(i_beam) > 180 
                phi = txang{i_user}(i_beam) - 180;
            end
            At{i_user}(:,i_beam) = (da(phi,:).*exp(-1i*dp(phi,:))).'; % � ������������ ��
        end
        % ��������� ����������� ������� Ar 
        Ar{i_user} = ones(N_beams{i_user},1);    
        G{i_user} = diag(Path_gains{i_user});
        H_user = At{i_user}*G{i_user}*Ar{i_user};
        H_users = [H_users H_user];
    end
    H{i_BeamsDelays} = H_users;
end

end


function [H, Husers] = createChannelByDn(channel, numRxUsers, numUsers)
%% ��������
% numRxUsers - ���-�� �������� ������ �� ����� ������������(������������ ���������� �������)
% numUsers - ���-�� �������������
% numDelayBeams - ���-�� ����������� �������� (����������� ���������� �������)
% txang - ���� ������� �� ��������
% da - �������������� �����(���������) stereeng vector
% dp - ������ �����(����) stereeng vector
% power - �������� ����������� �����


% numBeams - ���-�� ����� ���������� ������������ �� �������� � ������ ����� 
% txang - ���� ������� N_scatters �� ���������� �������
% rxang ���� ������� N_scatters �� �������� ������� (���� ���������� �� ������ �� �� ������)
% pathGains - �������� ����
% phi - ������
% At  - ����������� ������� �� �������� 
% A�  - ����������� ������� �� ������ 
% G - diag(Path_gains)

%% �������� ������
da = channel.da;
dp = channel.dp;
pdB = channel.pdB;
numDelayBeams = length(pdB);

numTx = size(da,2);
numRx = sum(numRxUsers);

H = zeros(numTx,numRx,numDelayBeams);
numScatters = cell(numUsers,1);
txang = cell(numUsers,1);
pathGains = cell(numUsers,1);
power = (10.^(pdB/10));

rng(6536);
for iDelay = 1:numDelayBeams
    Ar = cell(numUsers,1); G = cell(numUsers,1); At = cell(numUsers,1);
    H_users = [];
    for uIdx = 1:numUsers
        numScatters{uIdx} = randi(10);
        txang{uIdx} = round(360 * rand(1, numScatters{uIdx}) - 180);
        pathGains{uIdx} = 1/sqrt(2)*complex(randn(1,numScatters{uIdx}), randn(1,numScatters{uIdx}));  
        % ��������� ����������� ������� At    
        for iScatter = 1:numScatters{uIdx}
            if txang{uIdx}(iScatter)<=180
                phi = 181 + txang{uIdx}(iScatter);
            elseif txang{uIdx}(iScatter) > 180 
                phi = txang{uIdx}(iScatter) - 180;
            end
            At{uIdx}(:,iScatter) = (da(phi,:).*exp(-1i*dp(phi,:))).'; % � ������������ ��
        end
        % ��������� ����������� ������� Ar 
        Ar{uIdx} = ones(numRxUsers(uIdx),numScatters{uIdx});
        % ��������� ��������� ������� H_user
        G{uIdx} = diag(pathGains{uIdx});
        H_user = At{uIdx}*G{uIdx}*Ar{uIdx}.';
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
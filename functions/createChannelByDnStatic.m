function [H, Husers] = createChannelByDnStatic(channel, numRxUsers, numUsers)
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
txang = channel.txAng;
numDelayBeams = length(pdB);

numTx = size(da,2);
numRx = sum(numRxUsers);

H = zeros(numTx,numRx,numDelayBeams);
numBeams = cell(numUsers,1);
pathGains = cell(numUsers,1);
power = (10.^(pdB/10));

rng(6536);
for iDelay = 1:numDelayBeams
    Ar = cell(numUsers,1); G = cell(numUsers,1); At = cell(numUsers,1);
    H_users = [];
    for uIdx = 1:numUsers
        numBeams{uIdx} = length(txang{uIdx}); 
        pathGains{uIdx} = 1/sqrt(2)*complex(randn(1,numBeams{uIdx}), randn(1,numBeams{uIdx}));  
        % ��������� ����������� ������� At    
        for i_beam = 1:numBeams{uIdx}
            if txang{uIdx}(i_beam)<=180
                phi = 181 + txang{uIdx}(i_beam);
            elseif txang{uIdx}(i_beam) > 180 
                phi = txang{uIdx}(i_beam) - 180;
            end
            At{uIdx}(:,i_beam) = (da(phi,:).*exp(-1i*dp(phi,:))).'; % � ������������ ��
        end
        % ��������� ����������� ������� Ar 
        Ar{uIdx} = ones(numBeams{uIdx},numRxUsers(uIdx));
        % ��������� ��������� ������� H_user
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

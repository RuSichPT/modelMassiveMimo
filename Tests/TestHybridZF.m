clc; clear;
%% Параметры
N_T = 32;   % num Tx antennas
K = 2;      % num Users
L = 2;      % num paths
N_RF = K;
Psi = 1:K*L;
%% Инициализация At
prm.numUsers = 1;                 % Number of users
prm.numSTSVec = 4;%[3 1 2 2];        % Number of independent data streams per user 
prm.numSTS = sum(prm.numSTSVec);  % Must be a power of 2
prm.numTx = prm.numSTS*8;         % Number of BS transmit antennas (power of 2)
prm.numRx = prm.numSTSVec*2;      % Number of receive antennas, per user (any >= numSTSVec)
prm.nRays = K*L;             % Number of rays for Frf, Fbb partitioning
prm.fc = 28e9;               % 28 GHz system
prm.cLight = physconst('LightSpeed');
prm.lambda = prm.cLight/prm.fc;
prm.numCarriers = 234; 

numSTS = prm.numSTS;
numTx = prm.numTx;
numRx = prm.numRx;

[isTxURA,expFactorTx,isRxURA,expFactorRx] = helperArrayInfo(prm,true);

txarray = phased.PartitionedArray(...
    'Array',phased.URA([expFactorTx numSTS],0.5*prm.lambda),...
    'SubarraySelection',ones(numSTS,numTx),'SubarraySteering','Custom');

prm.posTxElem = getElementPosition(txarray)/prm.lambda;

% Single-user OMP
%   Spread rays in [az;el]=[-180:180;-90:90] 3D space, equal spacing
%   txang = [-180:360/prm.nRays:180; -90:180/prm.nRays:90];  
txang = [rand(1,prm.nRays)*360-180;rand(1,prm.nRays)*180-90]; % random
At = steervec(prm.posTxElem,txang);
%% Создание канала
Zk = zeros(K*L, K);
for k = 1:K
    for i = 1:K*L 
        Zk(i,k) = (randn(1)+1i*randn(1))/sqrt(2);
    end
end

H = conj(At)*Zk;
H = H';
%% Целевая функция
func = @(F_RF)(myFunc(F_RF, H));
%% В ручную перебираем аргумент
C_K_L = nchoosek(K*L, K); % число сочетаний
indx(1,:) = [1 2];    
indx(2,:) = [1 3]; 
indx(3,:) = [1 4]; 
indx(4,:) = [2 3]; 
indx(5,:) = [2 4]; 
indx(6,:) = [3 4];

view = [];
for i = 1:C_K_L
    F_RF_temp = At(:,indx(i,:));
    f0(i) = func(F_RF_temp);
    view = [view F_RF_temp];
end
clear F_RF_temp;
[~,minIdx] = min(f0);
F_RF0 = At(:,indx(minIdx,:));
%% F_BB: ZF Criterion, F_RF: Sequential Beamforming
[F_RF1, F_BB1] = getCoeff_RF_BB(At, H, N_RF);
%% Подстановка под одному столбцу
for i = 1:Psi(end)
    F_RF_temp = At(:,i);
    f2(i) = func(F_RF_temp);
end
clear F_RF_temp
temp = f2;
tempAt = At;
for i = 1:N_RF
    [~,k] = min(temp);
    F_RF2(:,i) = tempAt(:,k);
    temp(k) = [];
    tempAt(:,k) = [];
end
%% Проверяем результат
disp('Min func:');
disp(['Orig:' num2str(func(F_RF0))]);
disp(['ZF:' num2str(func(F_RF1))]);
disp(['One column:' num2str(func(F_RF2))]);
%%
function [F_RF,F_BB] = getCoeff_RF_BB(At,H,N_RF)

    F_RF = [];

    for m = 1:N_RF   
        [~,k] = minNormFrob(At, F_RF, H);

        F_RF(:,m) = At(:,k);
        At(:,k) = [];
    end

    F_BB = F_RF'*H'/((H*F_RF)*F_RF'*H');
end

function [minf,idx] = minNormFrob(At,F_RF,H)
    
    f = zeros(1, size(At,2));
    for i = 1:size(At,2)
        F1_RF = horzcat(F_RF,At(:,i));
        f(i) = myFunc(F1_RF,H);
    end
    
    [minf,idx] = min(f);
end

function [f] = myFunc(F_RF,H)
    f = norm(F_RF*F_RF'*H'/((H*F_RF)*F_RF'*H'),'fro');
end

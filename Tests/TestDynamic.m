rng(25);% Если  убрать доп условия(см ниже), то при этом rng S0 ~= []
clear;clc;
addpath("../functions")

numTx = 8;
numRx = 4;
numRF = 2;
numSub = numTx/numRF;
H = zeros(numTx, numRx);
for i = 1:numTx
    for j = 1:numRx           
        H(i,j) = (randn(1)+1i*randn(1))/sqrt(2);
    end
end
H = H';
%%
K = numTx*(numTx-1)/2;
%%
S_r = @(r) (r-1)*numSub+1:r*numSub;
S = cell(1,numRF+1);
S{1} = 1:numTx; %% 99 проц опечатка, в статье было numRF
for k = 2:length(S)
    r = k-1;
    S{k} = S_r(r);
end
%%
R_r = @(r) H(:,S_r(r))'*H(:,S_r(r));
R = H'*H;
absR = abs(R);
Ru = triu(absR,1);
vecRu = Ru(:);
sortVecRu = sort(vecRu,'descend');
sortVecRu(K+1:end) = [];
%%
all_ik_jk = [];
Smem = cell(K,length(S));
nsel = 0;
for k = 1:K
    [ik,jk] = find(Ru == sortVecRu(k));
    ik_jk = [ik jk];
    all_ik_jk = cat(1,all_ik_jk,ik_jk);
    S0 = S{1};
    S0_all{k} = S{1};
    for ii = 1:length(S)
        Smem{k,ii} = S{1,ii};
    end
    if ismember(ik,S0) && ismember(jk,S0)
        if nsel < numRF % nsel 0,1,2... 
            nsel = nsel + 1;
            S{nsel+1} = ik_jk;% так как S1 = S{2} 
            S0 = setdiff(S0,ik_jk); 
        else
            f = @(r) (func(union(S{r+1},ik_jk),nsel,r,numRF,absR) - func(S{r+1},nsel,r,numRF,absR));
            valuesF = zeros(1,numRF);
            for r = 1:numRF
               valuesF(r) = f(r);
            end
            [maxVal, indVal] = max(valuesF);
            S{indVal+1} = union(S{indVal+1},ik_jk);
            S0 = setdiff(S0,ik_jk);  
        end
        S{1} = S0;
    else
        [M,L] = get_m_l(nsel,ik_jk,S);

        if L == -1 || M == -1
            continue;
        end
        S_M = S{M+1};
        S_L = S{L+1};
        if ismember(ik,S_M) && ismember(jk,S_L)
            MU_current = func(S_M,nsel,M,numRF,absR) + func(S_L,nsel,L,numRF,absR);

            Stemp_M_j = union(S_M,jk);
            Stemp_L_j = setdiff(S_L,jk);
            MU_new_j = func(Stemp_M_j,nsel,M,numRF,absR) + func(Stemp_L_j,nsel,L,numRF,absR);

            Stemp_M_i = setdiff(S_M,ik);
            Stemp_L_i = union(S_L,ik);
            MU_new_i = func(Stemp_M_i,nsel,M,numRF,absR) + func(Stemp_L_i,nsel,L,numRF,absR);

            if M == 0
                str = ['M = ' num2str(M) ' k = ' num2str(k)];                
                disp(str);
            end
            if L == 0
                str = ['L = ' num2str(L) ' k = ' num2str(k)];
                disp(str);
            end
            % В случае добавления доп условия всегда в конце S0 == []
            if MU_new_j > MU_new_i && MU_new_j > MU_current && M ~= 0 && L ~= 0 % Доп условие L ~= 0
                S{M+1} = Stemp_M_j;
                S{L+1} = Stemp_L_j;
            elseif MU_new_i > MU_new_j && MU_new_i > MU_current && L ~= 0 && M ~= 0 % Доп условие M ~= 0
                S{M+1} = Stemp_M_i;
                S{L+1} = Stemp_L_i;
            end
            
            if ~isempty(intersect(Stemp_M_j,Stemp_L_j)) || ~isempty(intersect(Stemp_M_i,Stemp_L_i)) 
                error('Найдено пересечение')
            end

            if MU_new_i < 0 || MU_current < 0 || MU_new_j < 0
                error('Метрика не может быть < 0')
            end
        end
    end
end

Snew = dynamicSubarrayPartitioning(R,numRF,numTx);

function value = func(S,nsel,r,numRF,absR)
    powerS = length(S);
    if powerS == 0 || (nsel == numRF && r == 0)
        value = 0;
    else
        value = 1/powerS*sumR(absR,S);
    end
end

function value = sumR(R,S)
    value = sum(sum(R(S,S)));
end

% M L = 0,1,2 с нуля
function [M,L] = get_m_l(nsel,ik_jk,S)
    M = -1;
    L = -1;  
    res_ik = zeros(1,nsel+1); % так как nsel начинается с нуля 
    res_jk = zeros(1,nsel+1); % так как nsel начинается с нуля 
    
    for c0 = 1:length(res_ik)
        res_ik(c0) = ismember(ik_jk(1),S{c0});
        res_jk(c0) = ismember(ik_jk(2),S{c0});
    end
    if sum(res_ik) > 1 || sum(res_jk) > 1
        error('i j не могут принадлежать больше чем 1 подмножеству')       
    end
    if sum(res_ik) ~= 0 && sum(res_jk) ~= 0
        [~,M] = max(res_ik);
        [~,L] = max(res_jk);
        L = L - 1;
        M = M - 1;
        if L == M 
            M = -1;
            L = -1; 
        end
    end
end

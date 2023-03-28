function [S] = dynamicSubarrayPartitioning(R,Nrf,Ntx)

% R - выборочная ковариационная матрица векторов канала в частотной области 
% Nrf - количество RF цепочек (RF chains)
% Ntx - количество передающих антенн

% Задаем
Nsub = Ntx/Nrf;
K = Ntx*(Ntx-1)/2;
nsel = 0;
S_r = @(r) (r-1)*Nsub+1:r*Nsub;

% Расчитываем
absR = abs(R);
% Ru = triu(absR,1);
Ru = tril(absR,-1);
vecRu = Ru(:);
sortVecRu = sort(vecRu,'descend');
sortVecRu(K+1:end) = [];

S0 = 1:Ntx; % в литературе Nrf, это опечатка дб Ntx
S = cell(1,Nrf);
for k = 1:length(S)
    S{k} = S_r(k);
end

for k = 1:K
    [ik,jk] = find(Ru == sortVecRu(k));
    
    if ismember(ik,S0) && ismember(jk,S0)
        if nsel < Nrf % nsel 0,1,2... 
            nsel = nsel + 1;
            S{nsel} = [ik jk];
            S0 = setdiff(S0,[ik jk]); 
        else
            F_r = @(r) (metrika(union(S{r},[ik jk]),nsel,r,Nrf,absR) - metrika(S{r},nsel,r,Nrf,absR));
            F = zeros(1,Nrf);
            for r = 1:Nrf
               F(r) = F_r(r);
            end
            [~, arg] = max(F);

            S{arg} = union(S{arg},[ik jk]);
            S0 = setdiff(S0,[ik jk]);  
        end
    else
        [M,L] = getML(nsel,[ik jk],S);
        if L == -1 || M == -1
            continue;
        end
        if M == 0 || L == 0 % не может быть = 0, в литературе опечатка
            error('M,L не может быть = 0') 
        end
        
        if ismember(ik,S{M}) && ismember(jk,S{L})
            MU_current = metrika(S{M},nsel,M,Nrf,absR) + metrika(S{L},nsel,L,Nrf,absR);

            Stemp_M_j = union(S{M},jk);
            Stemp_L_j = setdiff(S{L},jk);
            MU_new_j = metrika(Stemp_M_j,nsel,M,Nrf,absR) + metrika(Stemp_L_j,nsel,L,Nrf,absR);

            Stemp_M_i = setdiff(S{M},ik);
            Stemp_L_i = union(S{L},ik);
            MU_new_i = metrika(Stemp_M_i,nsel,M,Nrf,absR) + metrika(Stemp_L_i,nsel,L,Nrf,absR);
            
            if MU_new_j > MU_new_i && MU_new_j > MU_current
                S{M} = Stemp_M_j;
                S{L} = Stemp_L_j;
            elseif MU_new_i > MU_new_j && MU_new_i > MU_current
                S{M} = Stemp_M_i;
                S{L} = Stemp_L_i;
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

end

function value = metrika(S,nsel,r,Nrf,absR)
    powerS = length(S);
    if powerS == 0 || (nsel == Nrf && r == 0)
        value = 0;
    else
        value = 1/powerS*sumR(absR,S);
    end
end

function value = sumR(R,S)
    value = sum(sum(R(S,S)));
end

function [M,L] = getML(nsel,ik_jk,S)
    M = -1; L = -1;  
    res_ik = zeros(1,nsel);% 0 не учитываем, в литературе опечатка
    res_jk = zeros(1,nsel);% 0 не учитываем, в литературе опечатка
    
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

        if L == M 
            M = -1;
            L = -1; 
        end
    end
end


function [cond] = funcCond(Va,Vd)

M_H = (Va*Vd)';
M = (Va*Vd);

cond = zeros (size(M_H,1), size(M,2));
for i = 1:size(M_H,1)
    for j = 1:size(M,2)
        if (i ~= j)
            cond(i,j) = M_H(i,:)*M(:,j);
        end
    end
end
    
end


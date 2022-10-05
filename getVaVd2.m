function [minVa,minVd] = getVaVd2(Vopt,initVd,Va0,Vd0,tay)

options = optimoptions('fmincon','Algorithm','interior-point','Display','iter');

funcVa = @(Va) norm(Vopt-Va*initVd,'fro');

g = @(Va) (funcCond(Va, initVd) - tay);
gfun = @(x) deal(g(x(1)),[]);

[minVa, fval1Va, exitflagVa, outputVa] = fmincon(funcVa,Va0,[],[],[],[],[],[],gfun,options);

funcVd = @(Vd) norm(Vopt-minVa*Vd,'fro');

g = @(Vd) (funcCond(minVa,Vd) - tay);
gfun = @(x) deal(g(x(1)),[]);

[minVd, fvalVd, exitflagVd, outputVd] = fmincon(funcVd,Vd0,[],[],[],[],[],[],gfun,options);

end


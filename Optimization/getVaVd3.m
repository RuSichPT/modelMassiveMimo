function [minVa,minVd] = getVaVd3(Vopt,initVd,Va0,Vd0,tay)

options = optimoptions('fmincon','Algorithm','interior-point','Display','iter');

g = @(Va, Vd) (funcCond(Va, Vd) - tay);
gfun = @(x) deal(g(x(1),x(2)),[]);

funcVa = @(Va) norm(Vopt-Va*initVd,'fro');
[minVa, fval1Va, exitflagVa, outputVa] = fmincon(funcVa,Va0,[],[],[],[],[],[],gfun,options);

funcVd = @(Vd) norm(Vopt-minVa*Vd,'fro');
[minVd, fvalVd, exitflagVd, outputVd] = fmincon(funcVd,Vd0,[],[],[],[],[],[],gfun,options);

end


function [minVa,minVd] = getVaVd1(Vopt,initVd,Va0,Vd0,tay)

options1 = optimoptions('fminunc','Algorithm','quasi-newton','Display','iter');
options2 = optimoptions('fmincon','Algorithm','interior-point','Display','iter');


funcVa = @(Va) norm(Vopt-Va*initVd,'fro');
[minVa, fvalVa, exitflagVa, outputVa] = fminunc(funcVa, Va0, options1);

funcVd = @(Vd) norm(Vopt-minVa*Vd,'fro');

g = @(Vd) (funcCond(minVa,Vd) - tay);
gfun = @(x) deal(g(x(1)),[]);

[minVd, fvalVd, exitflagVd, outputVd] = fmincon(funcVd,Vd0,[],[],[],[],[],[],gfun,options2);

end

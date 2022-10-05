clc;clear;

% % f = @(x, y) (x-5).^2+(y+2).^2+3;
% % xInt = [-15 15];
% % fsurf(f,xInt);
% % x0 = [5.1;3];
% % 
% % func = @(x) f(x(1),x(2));
% % options1 = optimoptions('fminunc','Algorithm','quasi-newton','Display','iter');
% % options2 = optimoptions('fmincon','Algorithm','interior-point','Display','iter');
% % A = eye(2,2);
% % b = [3 3];
% % [minf, fval, exitflag, output] = fminunc(func,x0,options1);
% % [minf, fval, exitflag, output] = fmincon(func,x0,A,b,[],[],[],[],[],options2);

% f = @(x,y) x.*exp(-x.^2-y.^2)+(x.^2+y.^2)/20;
% g = @(x,y) x.*y/2+(x+2).^2+(y-2).^2/2-2;
% fimplicit(g)
% axis([-6 0 -1 7])
% hold on
% fcontour(f)
% plot(-.9727,.4685,'ro');
% legend('constraint','f contours','minimum');
% hold off
% 
numTx = 16;
numRx = 4;
numSTS = numRx;
H = zeros(numTx,numRx);
for i = 1:numTx
    for j = 1:numRx           
        H(i,j) = (randn(1)+1i*randn(1))/sqrt(2);
    end
end
[U,S,Vopt] = svd(H');

F = (H'*H) \ H';

tay = 0.02;

initVd = zeros(numSTS,numSTS);
Vd0 = eye(numSTS,numSTS);
Va0 = eye(numTx,numSTS);

Vopt = Vopt(:,1:numSTS);
% Vopt = F';

[minVa1, minVd1] = getVaVd1(Vopt,initVd,Va0,Vd0,tay);
[minVa2, minVd2] = getVaVd2(Vopt,initVd,Va0,Vd0,tay);
[minVa3, minVd3] = getVaVd3(Vopt,initVd,Va0,Vd0,tay);

Vopt-minVa1*minVd1
Vopt-minVa2*minVd2
Vopt-minVa3*minVd3
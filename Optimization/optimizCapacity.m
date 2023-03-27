clear;clc;close all;
%% Задаем параметры
L0 = 100; 
K = 30;
snr = 20; %db
d = 0.25:0.01:0.55;
N = 200:400;
%% C_d
C_d = @(d) -C_coupling_d(d,L0,snr,K);

C_d_v = zeros(1,length(d));
for i = 1:length(d)
    C_d_v(i) = -C_d(d(i));
end
[~, imax] = max(C_d_v);
disp("dmax:" + d(imax));

figure('Name','C(d)');
plot(d,C_d_v);
xlabel("d")
ylabel("C")
grid on;
%% C_N
C_N = @(N) -C_coupling_N(N,L0,snr,K);

C_N_v = zeros(1,length(N));
for i = 1:length(N)
    C_N_v(i) = -C_N(N(i));
end
[~, imax] = max(C_N_v);
disp("Nmax:" + N(imax));

figure('Name','C(N)');
plot(N,C_N_v);
grid on;
xlabel("N")
ylabel("C")
%% Optimization C_d_N
options = optimoptions('fmincon','Algorithm','interior-point','Display','off');
ub = 4*L0+1;
lb = 2*L0+1;
Nmax = fmincon(C_N,1,[],[],[],[],lb,ub,[],options);
dmax = L0/(Nmax-1);
disp("opt dmax:" + dmax)
disp("opt Nmax:" + Nmax)
%%
function v = F(x,y)
    f1 = sqrt(x*(1 + sqrt(y))^2 + 1);
    f2 = sqrt(x*(1 - sqrt(y))^2 + 1);
    v = (f1 - f2)^2;
end

function v = arglog(x, N)    
    r = sqrt(1 - 4*x*x);
    numerator = (1 + r)^(N + 1) - (1 - r)^(N + 1);
    denominator = 2^(N + 1)*r;
    v = numerator/denominator;
    if v < 0
        error("arg log must be > 0")
    end
end

function v = R(d)
    n = 0;
    mu = pi/3;    
    arg1 = sqrt(n*n - 4*pi*pi*d*d + 4*pi*1i*n*sin(mu)*d);
    arg = imag(arg1);
    v = besselj(0,arg)/besselj(0,n);
end

function v = C_coupling(d,N,snr,K)
    b = N/K;
    f = F(snr/N,b);

    A = 13.4;
    a = exp(-A*d);

    C_N = b*log2(1 + snr/N - 1/4*f) + log2(1 + snr*b/N - 1/4*f) - N/(4*snr)*log2(exp(1))*f;

    v = C_N + 2/K*log2(arglog(a,N)) + 1/K*log2(arglog(R(d),N));
end

function v = C_coupling_d(d,L0,snr,K)
    N = L0/d + 1;
    v = C_coupling(d,N,snr,K);
end

function v = C_coupling_N(N,L0,snr,K)
    d = L0/(N-1);
    v = C_coupling(d,N,snr,K);
end

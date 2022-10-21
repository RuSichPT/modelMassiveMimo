clc; clear; close all;
c = 3e8;        % propagation speed
fc = 60e9;      % carrier frequency
lambda = c/fc;  % wavelength

txarray = phased.UCA('NumElements',8,'Radius',lambda/2);
txmipos = getElementPosition(txarray)/lambda;

viewArray(txarray);

rxarray = phased.UCA('NumElements',8,'Radius',lambda/2);
rxmopos = getElementPosition(rxarray)/lambda;

% rxarray = phased.IsotropicAntennaElement;
% rxmopos = [0 0 0]';

txcenter = [0;0;0];
rxcenter = [1500;500;0];

[~,txang] = rangeangle(rxcenter,txcenter);
[~,rxang] = rangeangle(txcenter,rxcenter);

txsipos = [0;0;0];
rxsopos = [0;0;0];

g = 1;  % gain for the path
mimochan = scatteringchanmtx(txmipos,rxmopos,txang,rxang,g);
N = 4; % кол-во лучей одновременно пришедших
rng(10)
mimochan = scatteringchanmtx(txmipos,rxmopos,N);
rng(10)
txang = [360*rand(1,N)-180;180*rand(1,N)-90];
rxang = [360*rand(1,N)-180;180*rand(1,N)-90];
g = 1/sqrt(2)*complex(randn(1,N),randn(1,N));
Ar = steervec(rxmopos,rxang);
At = steervec(txmipos,txang);

G = diag(g);
Htemp = Ar*G*At.';

H1 = At*G*Ar.';

H = Htemp.';  % Nt x Nr
txarraystv = phased.SteeringVector('SensorArray',txarray,...
    'PropagationSpeed',c);

rxarraystv = phased.SteeringVector('SensorArray',rxarray,...
    'PropagationSpeed',c);

wt = conj(txarraystv(fc,txang)).';
wt1 = conj(At).';

wr = conj(rxarraystv(fc,rxang));
wr1 = conj(Ar);

mimochan
H
wt*mimochan*wr
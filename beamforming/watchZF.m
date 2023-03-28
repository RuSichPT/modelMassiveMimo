clear; clc; %close all;
rng(24)
fc = 60e9;      % carrier frequency
c = physconst('LightSpeed');
lambda = c/fc;  % wavelength
numTx = 16; 
numScatters = 100;
azimuth = -180:180;
elevation = 0;
%% Канал
arrayTx = phased.ULA(numTx, 'ElementSpacing',0.5*lambda,'Element',phased.IsotropicAntennaElement("BackBaffled", true));
% figure;
% arrayTx.plotResponse(fc,c);
posArray = arrayTx.getElementPosition()/lambda; % Позиции элементов решетки
% At
anglesTx = 180*rand(1,numScatters)-90;
At = steervec(posArray,anglesTx);                   
% Ar
Ar = 1;
% G
G = 1/sqrt(2)*complex(randn(1,numScatters),randn(1,numScatters))';
H = At*G*Ar.';
%% ZF
wZf = (H'*H) \ H';
wMf = H';

arrayTx.Taper = wZf;
arrayTx.pattern(fc,azimuth,elevation,'Type','efield','PropagationSpeed',c);

arrayTx1 = phased.ULA(numTx, 'ElementSpacing',0.5*lambda,'Element',...
    phased.IsotropicAntennaElement('BackBaffled',true),'Taper',wZf);
% figure;
% arrayTx1.plotResponse(fc,c);
%%
figure();
arrayTx.pattern(fc,azimuth,elevation,'Type','efield','Weights',wZf.','PropagationSpeed',c);
figure();
arrayTx1.pattern(fc,azimuth,elevation,'Type','efield','PropagationSpeed',c);
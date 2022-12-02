clear;clc;close all;
cLight = physconst('LightSpeed');
fc = 4e9;                   % 4 GHz system
lambda = cLight/fc;
numUsers = 4;
anglesTx = {[-60;0]; [-30;0]; [30;0]; [60;0];};  %[azimuth;elevation]

Az = -90:90;
AzPlot = -180:180; 
Elev = 0;
izotropic = phased.IsotropicAntennaElement;
pattern(izotropic,fc,AzPlot,Elev,'CoordinateSystem','rectangular','Type','power','Normalize',false)
xlim([AzPlot(1) AzPlot(end)])
title('Izotropic');
%% SINC
f = @(x)2.557*abs(sinc(2*pi/180*x));
x = Az(1):Az(end);
magSinc(:,1) = f(x);
magSinc_dB = 20*log10(magSinc(:));
% figure();
% fplot(f,[AzPlot(1) AzPlot(end)]);
% grid on

P = sum(magSinc.*magSinc)/size(magSinc,1);

magnitude_dB = zeros(181,361);
offset = 181;
for i = 1:length(magSinc_dB)
    k = Az(i)+offset;
    magnitude_dB(:,k) = magSinc_dB(i);
end
customSinc = phased.CustomAntennaElement('MagnitudePattern',magnitude_dB);
figure();
pattern(customSinc,fc,AzPlot,Elev,'CoordinateSystem','rectangular','Type','power','Normalize',false)
title('Custom sinc 1 elem');
%% Прямоугольная 1.5
magnitude_dB = zeros(181,361);
temp = 20*log10(1.5);
for i = 1:length(magSinc_dB)
    k = Az(i)+offset;
    magnitude_dB(:,k) = temp;
end
customRect = phased.CustomAntennaElement('MagnitudePattern',magnitude_dB);
figure();
pattern(customRect,fc,AzPlot,Elev,'CoordinateSystem','rectangular','Type','power','Normalize',false)
title('Custom 1.5rectangle 1 elem');
%% Решетка
steeringAngle = [10; 0];  %[azimuth; elevation]
arraySize = [numUsers, numUsers];
elementSpacing = [0.5 0.5]*lambda;

% Izo
arrayTxIzo = phased.URA('Size',arraySize,'ElementSpacing',elementSpacing,'Element',izotropic);
posArrayTxIzo = getElementPosition(arrayTxIzo)/lambda;
WtIzo = steervec(posArrayTxIzo,steeringAngle);
figure();
pattern(arrayTxIzo,fc,AzPlot,Elev,'CoordinateSystem','rectangular','Type','power','Normalize',false);
title('Izotropic');

% Sinc
arrayTxSinc = phased.URA('Size',arraySize,'ElementSpacing',elementSpacing,'Element',customSinc);
posArrayTxSinc = getElementPosition(arrayTxSinc)/lambda;
WtSinc = steervec(posArrayTxSinc,steeringAngle);
figure();
pattern(arrayTxSinc,fc,AzPlot,Elev,'CoordinateSystem','rectangular','Type','power','Normalize',false);
title('Custom sinc');

% Rect
arrayTxRect = phased.URA('Size',arraySize,'ElementSpacing',elementSpacing,'Element',customRect);
posArrayTxRect = getElementPosition(arrayTxRect)/lambda;
WtRect = steervec(posArrayTxRect,steeringAngle);
figure();
pattern(arrayTxRect,fc,AzPlot,Elev,'CoordinateSystem','rectangular','Type','power','Normalize',false);
title('Custom 1.5rectangle');

rng(67);
[Husers1,H1] = createLOSchan(numUsers,posArrayTxIzo,anglesTx);
rng(67);
[Husers2,H2] = createLOSchan(numUsers,posArrayTxSinc,anglesTx);
rng(67);
[Husers3,H3] = createLOSchan(numUsers,posArrayTxRect,anglesTx);

%%
function [Husers,H] = createLOSchan(numUsers,txpos,txang)

    if numUsers ~= length(txang)
        error("Кол-во пользователей не совпдает с кол-вом углов");
    end
    
    Husers = cell(numUsers,1);
    Ar = cell(numUsers,1); G = cell(numUsers,1); At = cell(numUsers,1);
    numScatters = cell(numUsers,1);
   
    % H = At*G*Ar.'
    for uIdx = 1:numUsers
        numScatters{uIdx} = size(txang{uIdx},2);
        % At   
        At{uIdx} = steervec(txpos,txang{uIdx});
        % Ar
        Ar{uIdx} = ones(1,numScatters{uIdx});
        % G
        g = 1/sqrt(2)*complex(randn(1,numScatters{uIdx}),randn(1,numScatters{uIdx}));
        G{uIdx} = diag(g);
        
        Husers{uIdx} = At{uIdx}*G{uIdx}*Ar{uIdx}.';
    end
    H = cat(2,Husers{:});
end
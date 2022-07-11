clear;clc;close all;
cd ..\..;
load('DataBase/RLNC2022/RAYL_SPECIAL numSim 5 8x4x4x1111.mat');

hybridFull(1) = modelHybridFull;
mMimo(1) = modelMM1;
hybridSub(1) = modelHybridSub;
%%%%%%
load('DataBase/RLNC2022/RAYL_SPECIAL numSim 5 16x4x4x1111.mat');

hybridFull(2) = modelHybridFull;
mMimo(2) = modelMM1;
hybridSub(2) = modelHybridSub;
%%%%%%
load('DataBase/RLNC2022/RAYL_SPECIAL numSim 5 32x4x4x1111.mat');

hybridFull(3) = modelHybridFull;
mMimo(3) = modelMM1;
hybridSub(3) = modelHybridSub;
%%%%%%
load('DataBase/RLNC2022/RAYL_SPECIAL numSim 5 64x4x4x1111.mat');

hybridFull(4) = modelHybridFull;
mMimo(4) = modelMM1;
hybridSub(4) = modelHybridSub;
%%%%%%
load('DataBase/RLNC2022/RAYL_SPECIAL numSim 5 128x4x4x1111.mat');

hybridFull(5) = modelHybridFull;
mMimo(5) = modelMM1;
hybridSub(5) = modelHybridSub;
%%%%%%
load('DataBase/RLNC2022/RAYL_SPECIAL numSim 5 256x4x4x1111.mat');

hybridFull(6) = modelHybridFull;
mMimo(6) = modelMM1;
hybridSub(6) = modelHybridSub;
%%%%%%
load('DataBase/RLNC2022/RAYL_SPECIAL numSim 1 512x4x4x1111.mat');

hybridSub(7) = modelHybridSub;
%%%%%%

str0 = '';
fig1 = figure();
lineStyle = ["k" "--k" "-.k" ":k" "+--k" "o:k" "*--k"];
for i = 1:size(hybridFull,2)
    str1 = [str0 'Гибридное' ' ' num2str(hybridFull(i).main.numTx) 'x'  num2str(hybridFull(i).main.numRx)...
        'x'  num2str(hybridFull(i).main.numSTS)];
    hybridFull(i).plotMeanBER(lineStyle(i), 1.5, 'SNR', str1, fig1);
end
ylim([10^-4 10^0]);
fig2 = figure();
for i = 1:size(mMimo,2)
    str2 = [str0 'Цифровое' ' ' num2str(mMimo(i).main.numTx) 'x'  num2str(mMimo(i).main.numRx) 'x'  num2str(mMimo(i).main.numSTS)];
    mMimo(i).plotMeanBER(lineStyle(i), 1.5, 'SNR', str2, fig2);
end
ylim([10^-4 10^0]);
fig3 = figure();
for i = 1:size(hybridSub,2)
    str3 = [str0 num2str(hybridSub(i).main.precoderType) ' ' num2str(hybridSub(i).main.numTx) 'x'  num2str(hybridSub(i).main.numRx)...
        'x'  num2str(hybridSub(i).main.numSTS) ' type ' hybridSub(i).main.hybridType];
    hybridSub(i).plotMeanBER(lineStyle(i), 1.5, 'SNR', str3, fig3);
end
%%%%%%
level = 1e-2;
for i = 1:size(hybridFull,2)
    meanBer = mean(hybridFull(i).simulation.ber,1);
    snr = find(meanBer < level);
    if isempty(snr)
        SNRF(i) = inf;
    else
        SNRF(i) = snr(1);
    end
    
    meanBer = mean(mMimo(i).simulation.ber,1);
    snr = find(meanBer < level);
    if isempty(snr)
        SNRM(i) = inf;
    else
        SNRM(i) = snr(1);
    end
end
for i = 1:size(hybridSub,2)
    meanBer = mean(hybridSub(i).simulation.ber,1);
    snr = find(meanBer < level);
    if isempty(snr)
        SNRS(i) = inf;
    else
        SNRS(i) = snr(1);
    end
end

% костыль
SNRF(7) = SNRF(6);
SNRM(7) = SNRM(6);
%

lineWidth = 1.5;
n = 3:9;
Nt = 2.^n;
figure();
plot(Nt,SNRF,'+-k','LineWidth', lineWidth);
hold on;
grid on;
plot(Nt,SNRM,'*--k','LineWidth', lineWidth);
plot(Nt,SNRS,'>--k','LineWidth', lineWidth);
legend('Полностью связанная','Цифровая','Частично связанная')
ylim([0 hybridFull(1).simulation.snr(end)]);
ylabel('Отношение сигнал/шум, дБ');
xlabel('Количество антенн на передающей стороне, шт');



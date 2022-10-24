clear;clc;close all;
cd ..\..;
load('DataBase/Теория и техника радиосвязи 2022/RaylSpecialChannelflat numSim 5 8x4x4x1111.mat');

hybridFull(1) = modelHybridFull;
mMimo(1) = modelMM1;
hybridSub(1) = modelHybridSub;
%%%%%%
load('DataBase/RLNC2022/RAYL_SPECIALflat numSim 5 16x4x4x1111.mat');
close all; clear; clc;
phi=-90:1:89; J=sqrt(-1); 
phi1=phi*pi/180;
%% параметры системы
N=8; %количество элементов в решётке
f=3e9; % рабочая частота
c=3e8; % скорость света
l=c/f; % длина волны
d=l/2; % расстояние между элементами решётки
%% ДН элемента различной конфигурации
for jj=1:30
    DN1(jj)=0;
    DN1(151+jj)=0;
end
for jj=31:151
    DN1(jj)=1.22474;
end
% load G_uniform G_uniform;
% load G_sector G_sector;
% load G_sinc G_sinc;
load G_Fure G_Fure;
%%
max1=0;max2=0;max3=0;
for c0=1:120
xs(c0)=-60+c0; % угол фазирования в градусах
xph=xs(c0)*pi/180;
% фазирующие коэффициенты
for i=1:N
       Wg(i)=exp(-J*2*pi*(i-1)*d/l*sin(xph)); %геометрические       
end
% расчёт ДН
for jj=1:180
    DNN1(jj)=0;DNN2(jj)=0;DNN3(jj)=0;
    for kl=1:N
      DNN1(jj)=DNN1(jj)+Wg(kl)*exp(J*2*pi*(kl-1)*d/l*sin(phi1(jj)));
      DNN2(jj)=DNN2(jj)+DN1(jj)*Wg(kl)*exp(J*2*pi*(kl-1)*d/l*sin(phi1(jj)));
      DNN3(jj)=DNN3(jj)+G_Fure(jj)*Wg(kl)*exp(J*2*pi*(kl-1)*d/l*sin(phi1(jj)));
    end
%       DdB1(jj)=20*log10(abs(DNN1(jj)));
%       DdB2(jj)=20*log10(abs(DNN2(jj)));
%       DdB3(jj)=20*log10(abs(DNN3(jj)));
end
dnn1(c0) = DNN1(c0);
mm1(c0)=max(abs(DNN1));
mm2(c0)=max(abs(DNN2));
mm3(c0)=max(abs(DNN3));
max1=max1+mm1(c0);
max2=max2+mm2(c0);
max3=max3+mm3(c0);
end
max1=max1/120;
max2=max2/120;
max3=max3/120;
% figure(3);
%  plot(phi,DdB1,'k','LineWidth',2);grid on; hold on;
%  plot(phi,DdB2,'r','LineWidth',2);plot(phi,DdB3,'g','LineWidth',2);
%  xlim([-90 90]);
%  ylim([-60 -10]);
figure(4);
 plot(xs,mm1,'k','LineWidth',2);grid on; hold on;
 plot(xs,mm2,'r','LineWidth',2);plot(xs,mm3,'g','LineWidth',2);
 xlim([-60 60]);
 
figure(5);
plot(xs,dnn1,'k','LineWidth',2);
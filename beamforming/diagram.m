clear;
close all

phi_uniform = 1: 180;
G_uniform = ones(1, length(phi_uniform));
G_uniform = G_uniform / length(phi_uniform);
A1=max(G_uniform)*length(phi_uniform);
phi_sector = 31: 150;
G_sector = zeros(1, length(phi_uniform));
G_sector(phi_sector) = G_uniform(phi_sector) / (length(phi_sector) / length(phi_uniform));

w = 2;
fun = @(x) abs(sin(w * deg2rad(x - 90)) ./ (w * deg2rad(x - 90)));

G_sinc = fun(phi_uniform) / integral(fun, 0, 180);
A3=integral(fun, 0, 180);
phi = -90:1:90;
phi1=phi*pi/180;
fun1 = @(x) 0.88494+0.566407*cos(2*x)-0.283204*cos(4*x)+.141602*cos(8*x)-0.113281*cos(10*x);
G_Fure=fun1(phi1);
figure (1)
plot(phi_uniform - 90, 20 * log10(G_uniform))
hold on
plot(phi_uniform - 90, 20 * log10(G_sector))
plot(phi_uniform - 90, 20 * log10(G_sinc))
plot(phi, 20 * log10(G_Fure))
xlim([-90, 90])
%ylim([-80, 0])
xlabel("град.")
ylabel("G, дБ")
legend(["Изотропный излучатель", "Изотропный излучатель в диапазоне [-60; 60] град.", strcat("Аппроксимация при w = ", num2str(w))])
grid on
% figure (2)
% plot(phi_uniform - 90, G_uniform)
% hold on
% plot(phi_uniform - 90, G_sector)
% plot(phi_uniform - 90, G_sinc)
% xlim([-90, 90])
% %ylim([-80, 0])
% xlabel("град.")
% ylabel("G")
% legend(["Изотропный излучатель", "Изотропный излучатель в диапазоне [-60; 60] град.", strcat("Аппроксимация при w = ", num2str(w))])
% grid on
save G_uniform G_uniform;
save G_sector G_sector;
save G_sinc G_sinc;
save G_Fure G_Fure;
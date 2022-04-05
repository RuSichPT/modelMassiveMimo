clc;clear;close all;
Nt = 64;
NtRF = 4;

Nr = 16;
NrRF = 4;
rng(4096);
c = 3e8;
fc = 28e9;
lambda = c/fc;
txarray = phased.PartitionedArray(...
    'Array',phased.URA([sqrt(Nt) sqrt(Nt)],lambda/2),...
    'SubarraySelection',ones(NtRF,Nt),'SubarraySteering','Custom');
rxarray = phased.PartitionedArray(...
    'Array',phased.URA([sqrt(Nr) sqrt(Nr)],lambda/2),...
    'SubarraySelection',ones(NrRF,Nr),'SubarraySteering','Custom');
Ncl = 6;
Nray = 8;
Nscatter = Nray*Ncl;
angspread = 5;
% compute randomly placed scatterer clusters
txclang = [rand(1,Ncl)*120-60;rand(1,Ncl)*60-30];
rxclang = [rand(1,Ncl)*120-60;rand(1,Ncl)*60-30];
txang = zeros(2,Nscatter);
rxang = zeros(2,Nscatter);
% compute the rays within each cluster
for m = 1:Ncl
    txang(:,(m-1)*Nray+(1:Nray)) = randn(2,Nray)*sqrt(angspread)+txclang(:,m);
    rxang(:,(m-1)*Nray+(1:Nray)) = randn(2,Nray)*sqrt(angspread)+rxclang(:,m);
end

g = (randn(1,Nscatter)+1i*randn(1,Nscatter))/sqrt(Nscatter);

txpos = getElementPosition(txarray)/lambda;
rxpos = getElementPosition(rxarray)/lambda;
H = scatteringchanmtx(txpos,rxpos,txang,rxang,g);

F = diagbfweights(H);
F = F(1:NtRF,:);
figure();
pattern(txarray,fc,-90:90,-90:90,'Type','efield',...
    'ElementWeights',F','PropagationSpeed',c);

At = steervec(txpos,txang);
Ar = steervec(rxpos,rxang);

Ns = NtRF;
[Fbb,Frf] = omphybweights(H,Ns,NtRF,At);

figure();
pattern(txarray,fc,-90:90,-90:90,'Type','efield',...
    'ElementWeights',Frf'*Fbb','PropagationSpeed',c);
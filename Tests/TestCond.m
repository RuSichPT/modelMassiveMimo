clc;clear;%close all;
load('dn/G_is.mat','G_is');            
steerMat = G_is;
numUsers = 4;
anglesTxLoc{1} = 85;
anglesTxLoc{2} = 86;
anglesTxLoc{3} = 87;
anglesTxLoc{4} = 88;
for uIdx = 1:numUsers
    % At
    index = anglesTxLoc{uIdx}(1) + 91;
    At{uIdx} = steerMat(:,index);             
    % Ar
    Ar{uIdx} = 1;
    % G
    g = 1;
    G{uIdx} = diag(g);
    H{uIdx} = At{uIdx}*G{uIdx}*Ar{uIdx}.';
end
H = cat(2,H{:})
condnumber = cond(H)
lambda1 = eig(H*H')
lambda2 = eig(H'*H)
sigma = svd(H)
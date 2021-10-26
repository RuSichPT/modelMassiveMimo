function [w_pre,w_comb] = blkdiagbfweights(Hchann_in,Ns,P_in)
%blkdiagbfweights  Multiuser MIMO beamforming using block diagonalization
%   [WP,WC] = blkdiagbfweights(HCHAN,NS) returns the precoding weights, WP,
%   and combining weights, WC, for the channel matrix, HCHAN.
%
%   HCHAN is an NU-element cell array containing the channel matrix for the
%   NU users. Each entry in HCHAN can be either a matrix or a 3-dimensional
%   array. If the kth entry is a matrix, it has a size of NtxNr(k) where Nt
%   is number of elements in the transmit array and Nr(k) is the number of
%   elements in the kth user's receive array. If the entry is a
%   3-dimensional array, its dimension is LxNtxNr(k) where L is the number
%   of subcarriers.
%
%   Ns is an Nu-element row array specifying the number of data streams at
%   each user.
%
%   WP is either a matrix or 3-dimensional array. If entries in HCHAN
%   are matrices, WP is an NstxNt matrix where Nst = sum(Ns). If entries in
%   HCHAN are 3-dimensional arrays, WP has a size of LxNstxNt.
%
%   WC is an NU-element cell array containing the combining weights for
%   users. If entries in HCHAN are matrices, the kth entry in WC is an
%   Nr(k)xNs(k) matrix. If entries in HCHAN are 3-dimensional arrays,
%   entries in WC are of sizes LxNr(k)xNs(k).
%
%   These weights together diagonalize the channel into independent
%   subchannels for each user so that in each subcarrier, the result of
%   WP*HCHAN{k}*WC{k} has all its off-diagonal elements equal to 0.
%
%   [...] = blkdiagbfweights(...,PT) specifies the total transmit power, PT
%   (in linear units), as a positive scalar or an L-element vector. The
%   transmit power is uniformly distributed among users.
%
%   If PT is a scalar, then all subcarriers have the same transmit power.
%   If PT is a vector, its element specifies the transmit power for the
%   corresponding subcarrier. The total power is distributed evenly across
%   Nt transmit elements at each subcarrier, and the result is included in
%   WP. The default value of PT is 1. 
%
%   % Example:
%   %   Given a base station with 16 antennas and two users with 8 and 4 
%   %   antennas, respectively.  Show that the block diagonalization-based
%   %   precoding and combining weights can achieve spatial multiplexing,
%   %   where the received signal at each user can be decoded without 
%   %   interference from the other user. Assume there are 2 data streams
%   %   at each user.
%   
%   % channel matrix and weights computation
%   txpos = (0:15)*0.5;
%   rxpos1 = (0:7)*0.5;
%   rxpos2 = (0:3)*0.5;
%   Hchan = {scatteringchanmtx(txpos,rxpos1,10),...
%       scatteringchanmtx(txpos,rxpos2,10)};
%   Ns = [2 2];
%   [w_pre,w_comb] = blkdiagbfweights(Hchan,Ns);
%
%   % signal propagation and decode
%
%   % generate 4 streams, two columns each for user 1 and user 2
%   x = 1-2.*randi([0 1],[20 4]);
%   % precoding
%   xp = x*w_pre;
%   % propagate to each user via fading channel and AWGN
%   y1 = xp*Hchan{1}+0.1*randn(20,8);
%   y2 = xp*Hchan{2}+0.1*randn(20,4);
%   % combine at each user
%   y = [y1*w_comb{1}, y2*w_comb{2}];
%
%   % plot the result
%   for m = 1:4
%       subplot(4,1,m);
%       s = stem([x(:,m) 2*((real(y(:,m))>0)-0.5)]);
%       s(1).LineWidth = 2;
%       s(2).MarkerEdgeColor = 'none';
%       s(2).MarkerFaceColor = 'r';
%       ylabel('Signal')
%       title(sprintf('User %d Stream %d',ceil(m/2),rem(m-1,2)+1));
%       if m==1
%           legend('Input','Recovered','Location','best');
%       end
%   end
%   xlabel('Samples')
%
%   See also phased, diagbfweights.

%   Copyright 2019 The MathWorks, Inc.

%   Reference
%   [1] Quentin H. Spencer, A. Lee Swindlehurst, and Martin Haardt,
%   Zero-forcing Methods for Downlink Spatial Multiplexing in Multiuser
%   MIMO Channels, IEEE Transactions on Signal Processing, Vol. 52, No. 2,
%   February, 2004

%#ok<*EMCLS>
%#ok<*EMCA>
%#codegen

narginchk(2,3);
validateattributes(Hchann_in,{'cell'},{'vector'},'blkdiagbfweights','HCHAN');
NU = numel(Hchann_in);
validateattributes(Hchann_in{1},{'double'},{'nonnan','nonempty','finite','3d'},...
    'blkdiagbfweights','HCHAN{1}');

isHmatrix = ismatrix(Hchann_in{1});
Nr = zeros(1,NU);
if isHmatrix
    H_sz = size(Hchann_in{1});
    Nt = H_sz(1);
    Nr(1) = H_sz(2);
else
    H_sz = size(Hchann_in{1});
    L = H_sz(1);
    Nt = H_sz(2);
    Nr(1) = H_sz(3);
end

for m = 2:NU
    if isHmatrix
        validateattributes(Hchann_in{m},{'double'},{'nonnan','finite','2d','nrows',Nt},...
            'blkdiagbfweights',sprintf('HCHAN{%d}',int64(m)));
        Nr(m) = size(Hchann_in{m},2);
    else
        validateattributes(Hchann_in{m},{'double'},{'nonnan','finite','3d','nrows',L,'ncols',Nt},...
            'blkdiagbfweights',sprintf('HCHAN{%d}',int64(m)));
        Nr(m) = size(Hchann_in{m},3);
    end
end

cond = (Nt<sum(Nr));  % Nt is larger than total number of receiving antennas
if cond
    coder.internal.errorIf(cond,'shared_channel:shared_channel:expectedMoreRows',...
        'HCHAN{1}',sum(Nr));
end

validateattributes(Ns,{'double'},{'row','positive','finite','integer','ncols',NU},...
    'blkdiagbfweights','NS');
for m = 1:NU
    cond = Ns(m)>Nr(m);  % Ns must be smaller than all Nr
    if cond
        coder.internal.errorIf(cond,'shared_channel:shared_channel:expectedLessThanOrEqualTo',...
            sprintf('Ns(%d)',int64(m)),Nr(m));
    end
end

if nargin < 3
    if isHmatrix
        P = 1;
    else
        P = ones(L,1);
    end
else
    if isHmatrix
        sigdatatypes.validatePower(P_in,'blkdiagbfweights','PT',{'scalar'});
        P = P_in;
    else
        if isscalar(P_in)
            sigdatatypes.validatePower(P_in,'blkdiagbfweights','PT',{'scalar'});
            P = P_in*ones(L,1);
        else
            sigdatatypes.validatePower(P_in,'blkdiagbfweights','PT',{'vector','numel',L});
            P = P_in(:);
        end
    end
end

if isHmatrix
    Hchann = permute(cat(2,Hchann_in{:}),[2 1 3]);  % sum(Nr)xNt
else
    Hchann = permute(cat(3,Hchann_in{:}),[3 2 1]);  % sum(Nr)xNtxL
end

Hchanngrp = cell(1,NU);
Htilde = cell(1,NU);
UserIdx = [0 cumsum(Nr)];
Nrt = sum(Nr);
for m = 1:NU
    Hchanngrp{m} = Hchann(UserIdx(m)+1:UserIdx(m+1),:,:);
    Htilde{m} = Hchann([1:UserIdx(m),UserIdx(m+1)+1:Nrt],:,:);
end

w_pre_temp = cell(1,NU);
E = cell(1,NU);
w_comb = cell(1,NU);
    
if isHmatrix
    lambda = sqrt(P/(NU));
    for m = 1:NU
        [~,~,Vtilde] = svd(Htilde{m});
        Vtilde0 = Vtilde(:,rank(Htilde{m})+1:Nt);
        Hprime = Hchanngrp{m}*Vtilde0;
        Lbar = rank(Hprime);
        cond = Ns(m)>Lbar;
        coder.internal.errorIf(cond,'shared_channel:shared_channel:expectedLessThanOrEqualTo',...
            sprintf('Ns(%d)',int64(m)),Lbar,'IfNotConst','CheckAtRunTime');
        [Uprime,Eprime,Vprime] = svd(Hprime);
        Vprime1 = Vprime(:,1:Ns(m));
        w_pre_temp{m} = (Vtilde0*Vprime1).'*lambda/sqrt(Ns(m));
        E{m} = diag(Eprime(1:Ns(m),1:Ns(m)));
        w_comb{m} = conj(Uprime(:,1:Ns(m)));
    end
    w_pre = cat(1,w_pre_temp{:});
else % 3D
    for m = 1:NU
        lambda = sqrt(P/(NU));
        w_pre_temp{m} = zeros(L,Ns(m),Nt,'like',1+1i);
        E{m} = zeros(L,Ns(m),'like',1+1i);
        w_comb{m} = zeros(L,Nr(m),Ns(m),'like',1+1i);
        for l = 1:L
            [~,~,Vtilde] = svd(Htilde{m}(:,:,l));
            Vtilde0 = Vtilde(:,rank(Htilde{m}(:,:,l))+1:Nt);
            Hprime = Hchanngrp{m}(:,:,l)*Vtilde0;
            Lbar = rank(Hprime);
            cond = Ns(m)>Lbar;
            coder.internal.errorIf(cond,'shared_channel:shared_channel:expectedLessThanOrEqualTo',...
                sprintf('Ns(%d)',int64(m)),Lbar,'IfNotConst','CheckAtRunTime');
            [Uprime,Eprime,Vprime] = svd(Hprime);
            Vprime1 = Vprime(:,1:Ns(m));
            w_pre_temp{m}(l,:,:) = (Vtilde0*Vprime1).'*lambda(l)/sqrt(Ns(m));
            E{m}(l,:) = diag(Eprime(1:Ns(m),1:Ns(m)));
            w_comb{m}(l,:,:) = conj(Uprime(:,1:Ns(m)));
        end
    end
    w_pre = cat(2,w_pre_temp{:});
end


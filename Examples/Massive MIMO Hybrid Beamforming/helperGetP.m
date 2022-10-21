function P = helperGetP(numTx)
% Return orthogonal mapping sequences per transmit antenna
% Allows numTx to be a value in the set of 
%   {1 2 4 8 16 32 64 128 256 512 1024}.

% Copyright 2017 The MathWorks, Inc.

% Base set
Pltf = [1 -1 1 1; 1 1 -1 1; 1 1 1 -1; -1 1 1 1];
if numTx==2
    P = Pltf(1:2,1:2);
elseif numTx==4
    P = Pltf;
elseif numTx==8
    P = [Pltf Pltf; Pltf -Pltf];
elseif numTx==16 
    P8 = [Pltf Pltf; Pltf -Pltf];    
    P = [P8 P8; P8 -P8];
elseif numTx==32
    P8 = [Pltf Pltf; Pltf -Pltf];    
    P16 = [P8 P8; P8 -P8];
    P = [P16 P16; P16 -P16];
elseif numTx==64
    P8 = [Pltf Pltf; Pltf -Pltf];    
    P16 = [P8 P8; P8 -P8];
    P32 = [P16 P16; P16 -P16];
    P = [P32 P32; P32 -P32];
elseif numTx==128
    P8 = [Pltf Pltf; Pltf -Pltf];    
    P16 = [P8 P8; P8 -P8];
    P32 = [P16 P16; P16 -P16];
    P64 = [P32 P32; P32 -P32];
    P = [P64 P64; P64 -P64];    
elseif numTx==256
    P8 = [Pltf Pltf; Pltf -Pltf];    
    P16 = [P8 P8; P8 -P8];
    P32 = [P16 P16; P16 -P16];
    P64 = [P32 P32; P32 -P32];
    P128 = [P64 P64; P64 -P64];    
    P = [P128 P128; P128 -P128];    
elseif numTx==512
    P8 = [Pltf Pltf; Pltf -Pltf];    
    P16 = [P8 P8; P8 -P8];
    P32 = [P16 P16; P16 -P16];
    P64 = [P32 P32; P32 -P32];
    P128 = [P64 P64; P64 -P64];    
    P256 = [P128 P128; P128 -P128];    
    P = [P256 P256; P256 -P256];    
elseif numTx==1024
    P8 = [Pltf Pltf; Pltf -Pltf];    
    P16 = [P8 P8; P8 -P8];
    P32 = [P16 P16; P16 -P16];
    P64 = [P32 P32; P32 -P32];
    P128 = [P64 P64; P64 -P64];    
    P256 = [P128 P128; P128 -P128];    
    P512 = [P256 P256; P256 -P256];    
    P = [P512 P512; P512 -P512];    
else % for SISO, numTx = 1;
    P = 1;
end

% For internal use only: 
%    Uncomment following code to cross-check mapping to be orthogonal
%
% cross = zeros(numTx,numTx);
% for i = 1:numTx
%     for j = 1:numTx
%         cross(i,j) = P(:,i)'*P(:,j);
%     end
% end

% [EOF]
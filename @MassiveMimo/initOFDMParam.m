function initOFDMParam(obj, varargin)
    if (nargin > 1)
        ofdm = varargin{1};
        obj.ofdm.numSubCarriers = ofdm.numSubCarriers;                           
        obj.ofdm.lengthFFT = ofdm.lengthFFT;                                
        obj.ofdm.numSymbOFDM = ofdm.numSymbOFDM;                               
        obj.ofdm.cyclicPrefixLength = ofdm.cyclicPrefixLength;
    else % По умолчанию
        obj.ofdm.numSubCarriers = 450;                           
        obj.ofdm.lengthFFT = 512;                                
        obj.ofdm.numSymbOFDM = 10;                               
        obj.ofdm.cyclicPrefixLength = 64; 
    end
end


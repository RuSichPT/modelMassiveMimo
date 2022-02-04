function initMainParam(obj, varargin)
    if (nargin > 1)
        main = varargin{1};
        obj.main.numTx = main.numTx;
        obj.main.numRx = main.numRx;
        obj.main.numUsers = main.numUsers;
        obj.main.numRxUsers = main.numRxUsers;
        obj.main.modulation = main.modulation;
        obj.main.freqCarrier = main.freqCarrier;
        obj.main.precoderType = main.precoderType;
        obj.main.numSTSVec = main.numSTSVec;
    else % По умолчанию
        obj.main.numTx = 8;
        obj.main.numUsers = 4;
        obj.main.numRx = obj.main.numUsers;
        obj.main.numSTSVec = ones(1, obj.main.numUsers); 
        obj.main.modulation = 4;                                   
        obj.main.freqCarrier = 28e9;                                                              
        obj.main.precoderType = 'ZF'; 
    end
end


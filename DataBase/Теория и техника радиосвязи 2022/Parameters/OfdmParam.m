classdef OfdmParam   
    properties
        numSubCarriers = 450;       % Кол-во поднессущих
        lengthFFT = 512;            % Длина FFT для OFDM
        numSymbOFDM = 10;           % Кол-во символов OFDM от каждой антенны
        cyclicPrefixLength = 64;    % Длина защитных интервалов
    end
    properties (Dependent, SetAccess = private)
        nullCarrierIndices;         % Длина нулевых интервалов
    end
    %% Constructor, get
    methods
        % Support name-value pair arguments when constructing object
        function obj = OfdmParam(args)
            arguments
                args.numSubCarriers = 450;
                args.lengthFFT = 512;
                args.numSymbOFDM = 10;
                args.cyclicPrefixLength = 64;
            end
            obj.numSubCarriers = args.numSubCarriers;
            obj.lengthFFT = args.lengthFFT;
            obj.numSymbOFDM = args.numSymbOFDM;
            obj.cyclicPrefixLength = args.cyclicPrefixLength;
        end        
        function v = get.nullCarrierIndices(obj) 
            tmpNCI = obj.lengthFFT - obj.numSubCarriers;
            v = [1:(tmpNCI / 2) (1 + obj.lengthFFT - tmpNCI / 2):obj.lengthFFT]';
        end
    end
end


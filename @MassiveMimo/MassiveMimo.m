classdef MassiveMimo < matlab.System & matlab.mixin.Copyable
    % ��������� ������:
    % RaylSpecialChannel(), RaylChannel(), ChannelForNeuralNet(), StaticChannel()
    
    properties        
        main = SystemParam();       	% ��������� �������                
        ofdm = OfdmParam();             % ��������� OFDM
        channel = ChannelParam();       % ��������� ������
        simulation = struct(...         % ��������� ���������
                "ber",              0,      ...  % ����������� ������� ������
                "snr",              0,      ...  % �������� ���
                "confidenceLevel",  0.95,   ...  % ������� �������������
                "coefConfInterval", 1/15 )     % ???
    end
    properties (Dependent, SetAccess = private)
        downChannel;                        % ���������� ����� 
    end
    %% Constructor, get
    methods
        function obj = MassiveMimo(varargin)
            setProperties(obj,nargin,varargin{:})
        end
        function v = get.downChannel(obj)
            v = createChannel(obj);
        end
    end
    %%
    methods 
        function channel = createChannel(obj)
            param = {
                    'numUsers',obj.main.numUsers...
                    'numTx',obj.main.numTx,...
                    'numRxUsers',obj.main.numRxUsers...
                    'sampleRate',obj.channel.sampleRate...
                    'averagePathGains',obj.channel.averagePathGains...
                    'tau',obj.channel.tau...
                    };
            switch obj.channel.type
                case 'RaylSpecialChannel'
                    channel = RaylSpecialChannel(param{:});
                case 'RaylChannel'
                    channel = RaylChannel(param{:});
                case 'ChannelForNeuralNet'
                    channel = ChannelForNeuralNet();
                case 'StaticChannel'
                    param = {
                    'numUsers',obj.main.numUsers...
                    'numTx',obj.main.numTx,...
                    'numRxUsers',obj.main.numRxUsers...
                            };
                    channel = StaticChannel(param{:});
            end
        end
    end
    %% ������
    methods
        [preambleOFDM, ltfSC]                    = generatePreambleOFDM(obj, numSTS, varargin)
        [ltfTx, ltfSC]                           = generatePreamble(obj, numSTS)
        [H_estim]                                = channelSounding(obj, snr)
        [H_estim]                                = estimateUplink(obj, snr)
        [outputData]                             = passChannel(obj, inputData, channel)        
        [estimH]                                 = channelEstimate(obj, rxData, ltfSC, numSTS)  
        [outputData, precodWeights, combWeights] = applyPrecod(obj, inputData, estimateChannel)
        [outputData]                             = applyComb(obj, inputData, combWeights)
        [outputData]                             = equalizerZFnumSC(obj, inputData, H_estim)         
        [numErrors]                              = calculateErrors(obj, inpData, outData)     
        [berconf, lenConfInterval]               = calculateBER(obj, allNumErrors, allNumBits)

        % �������  
        [figObj] = plotMeanBER(obj, lineStyle, lineWidth, flagSNR, legendStr, varargin)
        [figObj] = plotMeanCapacity(obj,lineStyle,lineWidth,legendStr,varargin)
        [figObj] = plotSTSBER(obj, lineStyle, lineWidth, flagSNR, partLegendStr, varargin)
        [figObj] = plotSpectrOFDM(obj, sampleRate_Hz)
        
        % ���������     
        simulate(obj, rangeSNR, maxNumZeroBER, minNumErrs, maxNumSimulation)
        simulateMutCorr(obj, rangeSNR, maxNumZeroBER, minNumErrs, maxNumSimulation, corrMatrix)
        
        [numErrors,numBits,SINR_dB] = simulateOneSNR(obj,snr)       
        [numErrors,numBits] = simulateOneSNRmutCorr(obj,snr,corrMatrix)

    end
end


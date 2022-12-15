classdef MassiveMimo < matlab.mixin.Copyable   
    properties  (SetAccess = private)
        main SystemConfig;              % ��������� ������������
        modulation;                     % ������� ���������        
        precoderType;                   % ��� ���������       
        ofdm OfdmParam;                 % ��������� OFDM
        downChannel;                    % ���������� �����
        sim SimulationConfig;           % ��������� ���������
        painter Painter;                % ����� ��� ���������
    end
    properties (Dependent, SetAccess = private)
        bps;                            % ���-�� ��� �� ������ � �������
    end
    %% Constructor, get
    methods
        function obj = MassiveMimo(args)
            arguments
                args.main = SystemConfig();
                args.modulation = 4;
                args.precoderType = 'ZF';
                args.ofdm = OfdmParam();
                args.downChannel = RaylSpecialChannel();
                args.sim = SimulationConfig();
            end
            addpath('functions');
            obj.check(args);
            obj.main = args.main;
            obj.modulation = args.modulation;
            obj.precoderType = args.precoderType;
            obj.ofdm = args.ofdm;
            obj.downChannel = args.downChannel;
            obj.sim = args.sim;
            obj.painter = Painter();
        end
        function v = get.bps(obj)
            v = log2(obj.modulation);
        end
    end
    %% ������
    methods
        [preamble, ltfSC]                        = generatePreamble(obj, numSTS)
        [Hestim, HestimCell]                     = channelSounding(obj, snr, soundAllChannels)
        [estimH]                                 = channelEstimate(obj, rxData, ltfSC, numSTS)
        [outputData]                             = equalizerZFnumSC(obj, inputData, H_estim)

        [figObj] = plotSTSBER(obj, lineStyle, lineWidth, flagSNR, partLegendStr, varargin)
        
        % ���������     
        simulate(obj)
        simulateMutCorr(obj, rangeSNR, maxNumZeroBER, minNumErrs, maxNumSimulation, corrMatrix)
        
        [numErrors,numBits,SINR_dB] = simulateOneSNR(obj,snr)       
        [numErrors,numBits] = simulateOneSNRmutCorr(obj,snr,corrMatrix)

    end
    %% ������� 
    methods
        function figObj = plotMeanBER(obj,args)
            % lineStyle - ���� �������, 'k','r','g','b','c' '-', '--', ':', '-.'
            % lineWidth - ������ �����,  
            % flagSNR = SNR or Eb/N0
            arguments
                obj;
                args.lineStyle = 'k';
                args.lineWidth = 2;
                args.flagSNR  = 'SNR';
                args.legendStr = ['Mean ' getLegend(obj)];
                args.figObj = figure();
            end
            lineStyle = args.lineStyle;
            lineWidth = args.lineWidth;
            flagSNR  = args.flagSNR;
            legendStr = args.legendStr;
            figObj = args.figObj;
            
            if isempty(obj.sim.ber)
                error("��� ������ ��� �������, �������� simulate")
            end
            meanBer = mean(obj.sim.ber,1);

            if flagSNR == "SNR"
                labelX = '��������� ������/���, ��';
            elseif flagSNR == "Eb/N0"
                labelX = 'E_b / N_0 , ��';
            else
                error('��� ������ ����. �������� SNR ��� Eb/N0')
            end

            obj.painter.plotBer(obj.sim.snr,meanBer,lineStyle,lineWidth,legendStr,figObj);
            hold on;
            xlabel(labelX);
            ylabel('����������� ������� ������');
            title(class(obj.downChannel));  
        end
        function [figObj] = plotCapacity(obj,args)
            % type = mean or all
            % lineStyle - ���� �������, 'k','r','g','b','c' '-', '--', ':', '-.'
            % lineWidth - ������ �����,  
            arguments
                obj;
                args.type = 'mean'
                args.lineStyle = 'k';
                args.lineWidth = 2;
                args.legendStr = 0;
                args.figObj = figure();
            end
            type = args.type;
            lineStyle = args.lineStyle;
            lineWidth = args.lineWidth;
            legendStr = args.legendStr;
            figObj = args.figObj;
            
            if isempty(obj.sim.capacity)
                error("��� ������ ��� �������, �������� simulate")
            end

            if type == "mean"            
                capacity = mean(obj.sim.capacity,1);
                if legendStr == 0
                    legendStr = ['Mean ' getLegend(obj)];
                end
            elseif type == "all" 
                capacity = sum(obj.sim.capacity,1);
                if legendStr == 0
                    legendStr = ['All STS ' getLegend(obj)];
                end
            else
                error('��� ������ ����. �������� mean ��� all')
            end

            obj.painter.plotCapacity(obj.sim.snr,capacity,lineStyle,lineWidth,legendStr,figObj);
            title(class(obj.downChannel));
        end
        function str = getLegend(obj)
            str = [obj.precoderType ' ' num2str(obj.main.numTx) 'x'  num2str(obj.main.numRx)...
                    'x'  num2str(obj.main.numSTS) ' u' num2str(obj.main.numUsers)];
        end
    end
    %% 
    methods   
        function figObj = plotSpectrOFDM(obj, sampleRate_Hz)
            snr = 10;
            numTx = 1;
            obj.simulateOneSNR(snr);
            figObj = plotESD(obj.dataOFDM(:,numTx), sampleRate_Hz);
        end
        function check(~,args) 
            if args.main.numUsers ~= args.downChannel.sysconf.numUsers
                str = ['���������� numUsers � ������ � � ������ ������ ���������, �.�.' newline...
                    'main.numUsers == downChannel.sysconf.numUsers.'];
                error(str);
            end
            if args.main.numTx ~= args.downChannel.sysconf.numTx
                str = ['���������� numTx � ������ � � ������ ������ ���������, �.�.' newline...
                    'main.numTx == downChannel.sysconf.numTx.'];
                error(str);
            end
        end
        function setChannel(obj,channel)
            obj.downChannel = channel;
        end

    end
end

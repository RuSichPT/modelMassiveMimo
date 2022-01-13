function [outputData, precodWeights, combWeights] = applyPrecod(obj, inputData, estimateChannel)
    
    % inputData - ������� ������ ������������ [numSC,numOFDM,numSTS]
    % numSC - ���-�� �����������
    % numOFDM - ���-�� �������� OFDM �� ������ �������
    % numSTS - ���-�� ������� ������;
    
    % estimateChannel - ������ ������ ������������ [numSC,numTx,numSTS]
    % numTx - ���-�� ���������� �����
    
    % outputData - �������� ������ ������������ [numSC,numOFDM,numTx]
    % precodWeights - ���� ��������������
    % combWeights - ���� ��������������
    
    switch obj.main.precoderType
        case {'MF'}
            [outputData, precodWeights] = applyPrecodMF(inputData, estimateChannel);
            combWeights = 0;
        case {'ZF'}
            [outputData, precodWeights] = applyPrecodZF(inputData, estimateChannel);
            combWeights = 0;
        case {'RZF'}
            [outputData, precodWeights] = applyPrecodRZF(inputData, estimateChannel, 0, 0.01);
            combWeights = 0;
        case {'EBM'}
            [outputData, precodWeights, combWeights] = applyPrecodEBM(inputData, estimateChannel);
        case {'NOT'}
            [outputData, precodWeights, combWeights] = applyPrecodNot(inputData, estimateChannel);
        case {'BD'}
            [outputData, precodWeights, combWeights] = applyPrecodBD(inputData, estimateChannel, obj.main.numSTSVec);
        case {'TPE'}
            [outputData, precodWeights] = applyPrecodTPE(inputData, estimateChannel, 3);
            combWeights = 0;
        case {'NSA'}
            % K = 1:3; K = 3 max � ����� ������ ��� ��������� == ZF => K = 2 
            [outputData, precodWeights] = applyPrecodNSA(inputData, estimateChannel, 2); 
            combWeights = 0;
        case {'NI'}
            % K = 1:2; K = 2 max � ����� ������ ��� ��������� == ZF => K = 1 (�� ���������� 1 �������� NSA)
            [outputData, precodWeights] = applyPrecodNI(inputData, estimateChannel, 1);  
            combWeights = 0;
        case {'NI-NSA'}
            [outputData, precodWeights] = applyPrecodNI_NSA(inputData, estimateChannel, 2);  
            combWeights = 0;
    end    
    
end


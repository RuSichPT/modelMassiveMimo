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
        case {'MFnorm'}
            [outputData, precodWeights] = applyPrecodMFnorm(inputData, estimateChannel);
            combWeights = 0;
        case {'ZF'}
            [outputData, precodWeights] = applyPrecodZF(inputData, estimateChannel);
            combWeights = 0;
        case {'RZF'}
            [outputData, precodWeights] = applyPrecodRZF(inputData, estimateChannel,0,5);
            combWeights = 0;
        case {'EBM'}
            [outputData, precodWeights, combWeights] = applyPrecodEBM(inputData, estimateChannel);
        case {'NOT'}
            [outputData, precodWeights, combWeights] = applyPrecodNot(inputData, estimateChannel);
        case {'BDA'}
            [outputData, precodWeights, combWeights] = applyPrecodBDA(inputData, estimateChannel, obj.main.numSTSVec);
    end    
    
end


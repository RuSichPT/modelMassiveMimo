function simulate(obj, rangeSNR, maxNumZeroBER, minNumErrs, maxNumSimulation)

    % rangeSNR - �������� ���
    % maxNumZeroBER - ����������� ���-�� �����, ��� BER = 0
    % minNumErrs - ����������� ���-�� ������
    % maxNumSimulation - ������������ ���-�� ���������
    
    addpath('functions');
    
    checkChannel(obj);
    
    coefConfInt = obj.simulation.coefConfInterval;
    numUsers = obj.main.numUsers;
    
    numZeroBER = 0;
    obj.simulation.ber = zeros(obj.main.numSTS, length(rangeSNR));
    obj.simulation.C = zeros(obj.main.numUsers, length(rangeSNR));
    obj.simulation.snr = rangeSNR;
    
    for indSNR = 1:length(rangeSNR)
        if (numZeroBER < maxNumZeroBER) 
            indSim = 0;
            allNumErrors = 0;
            allNumBits = 0; 
            condition = 1;
            capacity = zeros(maxNumSimulation,numUsers);
            while ( condition && (indSim < maxNumSimulation) )
                % BER
                [numErrors,numBits,SINR_dB] = obj.simulateOneSNR(rangeSNR(indSNR));

                allNumErrors = allNumErrors + numErrors;
                allNumBits = allNumBits + numBits;

                [berconf, lenConfInterval] = obj.calculateBER(allNumErrors, allNumBits);
                maxConfidenceInterval = berconf * coefConfInt;
                
                condition = max(((lenConfInterval > maxConfidenceInterval)|(numErrors < minNumErrs)));
                
                % Capacity
                for uIdx = 1:numUsers
                    capacity(indSim+1,uIdx) = mimoCapacitySINR(SINR_dB(uIdx));
                end
                indSim = indSim + 1;
            end
            obj.simulation.ber(:,indSNR) = berconf;
            obj.simulation.C(:,indSNR) = mean(capacity,1);
            
            if (berconf == 0)
                numZeroBER = numZeroBER + 1;
            end 
            
            fprintf('Complete SNR = %d dB, simulations = %d \n', rangeSNR(indSNR), indSim);
        end
    end
    str = ['Complete ' obj.main.precoderType '\n'];
    fprintf(str);
end

function checkChannel(obj)
    if ~isscalar(obj.downChannel)
        error('����� �� ������! ���������� �����!');
    end
    
    if obj.downChannel.numTx ~= obj.main.numTx
        error('���������� numTx � ������ � � ������ �� ���������');
    end
    
    if obj.downChannel.numRx ~= obj.main.numRx
        error('���������� numRx � ������ � � ������ �� ���������');
    end
    
    if obj.downChannel.numRxUsers ~= obj.main.numRxUsers
        error('���������� numRxUsers � ������ � � ������ �� ���������');
    end
    
    if obj.downChannel.numUsers ~= obj.main.numUsers
        error('���������� numRxUsers � ������ � � ������ �� ���������');
    end
end
function C = mimoCapacitySINR(SINR_dB)
    % SINR - � ��
    SINR = 10^(SINR_dB/10);

    C = log2(1+SINR);
end
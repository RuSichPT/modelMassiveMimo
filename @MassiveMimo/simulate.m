function simulate(obj, rangeSNR, maxNumZeroBER, minNumErrs, maxNumSimulation)

    % rangeSNR - �������� ���
    % maxNumZeroBER - ����������� ���-�� �����, ��� BER = 0
    % minNumErrs - ����������� ���-�� ������
    % maxNumSimulation - ������������ ���-�� ���������
    
    addpath("functions");
    coefConfInt = obj.simulation.coefConfInterval;
    
    numZeroBER = 0;
    obj.simulation.ber = zeros(obj.main.numSTS, length(rangeSNR));
    obj.simulation.snr = rangeSNR;
    
    for indSNR = 1:length(rangeSNR)
        if (numZeroBER < maxNumZeroBER) 
            indSim = 0;
            allNumErrors = 0;
            allNumBits = 0; 
            condition = 1;
            while ( condition && (indSim < maxNumSimulation) )
                if (obj.main.precoderType == "NOT")
                    [numErrors, numBits] = obj.simulateOneSNRphased(rangeSNR(indSNR));
                else
                    [numErrors, numBits] = obj.simulateOneSNR(rangeSNR(indSNR));
                end

                allNumErrors = allNumErrors + numErrors;
                allNumBits = allNumBits + numBits;

                [berconf, lenConfInterval] = obj.calculateBER(allNumErrors, allNumBits);
                maxConfidenceInterval = berconf * coefConfInt;
                
                condition = max(((lenConfInterval > maxConfidenceInterval)|(numErrors < minNumErrs)));

                indSim = indSim + 1;
            end
            
            obj.simulation.ber(:,indSNR) = berconf;
            
            if (berconf == 0)
                numZeroBER = numZeroBER + 1;
            end 
            fprintf('Complete SNR = %d dB, simulations = %d \n', rangeSNR(indSNR), indSim);
        end
    end
    str = ['Complete ' obj.main.precoderType '\n'];
    fprintf(str);
end

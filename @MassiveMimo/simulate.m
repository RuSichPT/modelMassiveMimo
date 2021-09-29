function simulate(obj, rangeSNR, maxNumZeroBER, minNumErrs, maxNumSimulation)

    % rangeSNR - диапазон ќ—Ў
    % maxNumZeroBER - максимально кол-во точек, где BER = 0
    % minNumErrs - минимальное кол-во ошибок
    % maxNumSimulation - максимальное кол-во симул€ций
    
    numZeroBER = 0;
    obj.ber = zeros(obj.numSTS, length(rangeSNR));
    obj.snr = rangeSNR;
    
    for indSNR = 1:length(rangeSNR)
        if (numZeroBER < maxNumZeroBER) 
            indSim = 0;
            allNumErrors = 0;
            allNumBits = 0; 
            condition = 1;
            while ( condition && (indSim < maxNumSimulation) )        
                [numErrors, numBits] = obj.simulateOneSNR(rangeSNR(indSNR));
                allNumErrors = allNumErrors + numErrors;
                allNumBits = allNumBits + numBits;

                [berconf, lenConfInterval] = obj.calculateBER(allNumErrors, allNumBits);
                maxConfidenceInterval = berconf * obj.coefConfInterval;
                
                condition = max(((lenConfInterval > maxConfidenceInterval)|(numErrors < minNumErrs)));

                indSim = indSim + 1;
            end
            
            obj.ber(:,indSNR) = berconf;
            
            if (berconf == 0)
                numZeroBER = numZeroBER + 1;
            end 
            fprintf('Complete indSNR = %d dB, simulations = %d \n', indSNR, indSim);
        end
    end
end

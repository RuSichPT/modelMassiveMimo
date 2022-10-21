function simulate(obj, rangeSNR, maxNumZeroBER, minNumErrs, maxNumSimulation)

    % rangeSNR - диапазон ќ—Ў
    % maxNumZeroBER - максимально кол-во точек, где BER = 0
    % minNumErrs - минимальное кол-во ошибок
    % maxNumSimulation - максимальное кол-во симул€ций
    
    addpath("functions");
    coefConfInt = obj.simulation.coefConfInterval;
    numSTS = obj.main.numSTS;
    numUsers = obj.main.numUsers;
    
    numZeroBER = 0;
    obj.simulation.ber = zeros(obj.main.numSTS, length(rangeSNR));
    obj.simulation.C = zeros(obj.main.numSTS, length(rangeSNR));
    obj.simulation.snr = rangeSNR;
    
    for indSNR = 1:length(rangeSNR)
        if (numZeroBER < maxNumZeroBER) 
            indSim = 0;
            allNumErrors = 0;
            allNumBits = 0; 
            condition = 1;
            capacity = zeros(maxNumSimulation,numUsers);
            while ( condition && (indSim < maxNumSimulation) )
                [numErrors,numBits,SINR_dB] = obj.simulateOneSNR(rangeSNR(indSNR));

                % BER
                allNumErrors = allNumErrors + numErrors;
                allNumBits = allNumBits + numBits;

                [berconf, lenConfInterval] = obj.calculateBER(allNumErrors, allNumBits);
                maxConfidenceInterval = berconf * coefConfInt;
                
                condition = max(((lenConfInterval > maxConfidenceInterval)|(numErrors < minNumErrs)));

                % Capacity
                HeffCell = obj.downChannel.channel;
%                 for uIdx = 1:numUsers
%                     capacity(indSim+1,uIdx) = mimoCapacity(HeffCell{uIdx},SINR_dB(uIdx),numSTS);
%                 end
                indSim = indSim + 1;
            end

            obj.simulation.ber(:,indSNR) = berconf;
%             obj.simulation.C(:,indSNR) = mean(capacity,1);
            
            if (berconf == 0)
                numZeroBER = numZeroBER + 1;
            end 
            fprintf('Complete SNR = %d dB, simulations = %d \n', rangeSNR(indSNR), indSim);
        end
    end
    str = ['Complete ' obj.main.precoderType '\n'];
    fprintf(str);
end

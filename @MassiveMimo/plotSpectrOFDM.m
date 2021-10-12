function figObj = plotSpectrOFDM(obj, sampleRate_Hz)
    snr = 10;
    numTx = 1;
    obj.simulateOneSNR(snr);
    figObj = plotESD(obj.dataOFDM(:,numTx), sampleRate_Hz);
end


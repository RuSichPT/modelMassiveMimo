function C = mimoCapacitySINR(SINR_dB)
    % SINR - в дБ
    SINR = 10^(SINR_dB/10);

    C = sum(log2(1+SINR));
end


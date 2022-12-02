classdef LOScustomAntElem < StaticLOSChannel   
    methods(Access = protected)
        function arrayTx = getArrayTx(obj)
            Az = -90:90;
            f = @(x)abs(sinc(2*pi/180*x));
            x = Az(1):Az(end);
            magSinc_dB = 20*log10(f(x));

            magnitude_dB = zeros(181,361);
            offset = 181;
            for i = 1:length(magSinc_dB)
                k = Az(i)+offset;
                magnitude_dB(:,k) = magSinc_dB(i);
            end
            custom = phased.CustomAntennaElement('MagnitudePattern',magnitude_dB);
            arrayTx = phased.URA('Size',obj.arraySize,'ElementSpacing',obj.elementSpacing,'Element',custom);
        end
    end
end


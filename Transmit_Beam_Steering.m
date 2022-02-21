function [wT, arrayTx] = Transmit_Beam_Steering(prm,numTx,fc,lambda,expFactorTx,isTxURA,flag_DN)
% Создаем ФАР на прд, на выходе весовые коэф
% Transmit antenna array definition 
if isTxURA
    % Uniform Rectangular array
    arrayTx = phased.URA([expFactorTx,prm.numSTS],[0.5 0.5]*lambda, ...
        'Element',phased.IsotropicAntennaElement('BackBaffled',true));
else
    % Uniform Linear array
    arrayTx = phased.ULA(numTx, ...
        'ElementSpacing',0.5*lambda, ...
        'Element',phased.IsotropicAntennaElement('BackBaffled',true));
end

% For evaluating weights for steering  
SteerVecTx = phased.SteeringVector('SensorArray',arrayTx, ...
    'PropagationSpeed',prm.cLight);

% Generate weights for steered direction
wT = SteerVecTx(fc,prm.steeringAngle_Tx);
if flag_DN ==1
    % Visualize the transmit pattern and steering
    h = figure('Position',figposition([10 55 30 35]),'MenuBar','none');
    h.Name = 'Transmit Array Response Pattern';
    pattern(arrayTx,fc,'PropagationSpeed',prm.cLight,'Weights',wT);
    h = figure('Position',figposition([54 55 22 35]),'MenuBar','none');
    h.Name = 'Transmit Array Azimuth Pattern';
    patternAzimuth(arrayTx,fc,'PropagationSpeed',prm.cLight,'Weights',wT);
    if isTxURA
        h = figure('Position',figposition([76 55 22 35]),'MenuBar','none');
        h.Name = 'Transmit Array Elevation Pattern';
        patternElevation(arrayTx,fc,'PropagationSpeed',prm.cLight, ...
            'Weights',wT);
    end        
end
end


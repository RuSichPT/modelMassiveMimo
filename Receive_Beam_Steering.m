function [wR, arrayRx] = Receive_Beam_Steering(prm,numRx,fc,lambda,expFactorRx,isRxURA,flag_DN)
% Создаем ФАР на прм, на выходе весовые коэф
% Receive array
if isRxURA 
    % Uniform Rectangular array
    arrayRx = phased.URA([expFactorRx,prm.numSTS],0.5*lambda, ...
        'Element',phased.IsotropicAntennaElement('BackBaffled',true));
else 
    % Uniform Linear array
    arrayRx = phased.ULA(numRx, ...
        'ElementSpacing',0.5*lambda, ...
        'Element',phased.IsotropicAntennaElement('BackBaffled',true));
end

% For evaluating receive-side steering weights 
SteerVecRx = phased.SteeringVector('SensorArray',arrayRx, ...
    'PropagationSpeed',prm.cLight);

% Generate weights for steered direction towards mobile
wR = SteerVecRx(fc,prm.steeringAngle_Rx);
if flag_DN ==1
    % Visualize the receive pattern and steering
    h = figure('Position',figposition([32 20 22 30]));
    h.Name = 'Receive Array Response Pattern';
    pattern(arrayRx,fc,'PropagationSpeed',prm.cLight,'Weights',wR);
    h = figure('Position',figposition([54 20 22 35]),'MenuBar','none');
    h.Name = 'Receive Array Azimuth Pattern';
    patternAzimuth(arrayRx,fc,'PropagationSpeed',prm.cLight,'Weights',wR);
    if isRxURA 
        figure('Position',figposition([76 20 22 35]),'MenuBar','none');
        h.Name = 'Receive Array Elevation Pattern';
        patternElevation(arrayRx,prm.fc,'PropagationSpeed',prm.cLight, ...
            'Weights',wR);
    end
end
end


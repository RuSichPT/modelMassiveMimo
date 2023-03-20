function [H] = createQuaDRiGa(no_rx, numChan)

    addpath("../QuaDriGa/quadriga_src/")
    
    [aBS, aMT] = antennasSetup();
    layout = quaDRiGaSetup(no_rx,aBS,aMT);

    H = generateChannels(layout,numChan);
    H = permute(H,[2 1 3]);

end
%% Antennas setup
function [aBS, aMT] = antennasSetup()
    % BS antenna configuration
    aBS = qd_arrayant('ula8');
    aBS.combine_pattern;                        % Calculate array response
    aBS.element_position(1, :) = 0.5;           % Distance from pole in [m]
    
    aMT = qd_arrayant('omni');                  % MT antenna configuration
end
%% QuaDRiGa Setup
% no_rx - Number of MTs (directly scales the simulation time)
function layout = quaDRiGaSetup(no_rx,aBS,aMT)
    s = qd_simulation_parameters;               % Set general simulation parameters
    s.center_frequency = 6e9;                   % Set center frequency for the simulation
    s.use_3GPP_baseline = 1;                    % Disable spherical waves
    s.show_progress_bars = 0;                   % Disable progress bar 
    
    isd = 300;                                  % Inter-site distance [m]
    no_go_dist = 35;                            % Min. UE-eNB 2D distance [m]
    
    layout = qd_layout.generate('regular', 1, isd, aBS);       
    layout.tx_position(3,:) = 25;               % meters BS height
    layout.simpar = s;                          % Set simulation parameters
    layout.name = 'UMa';
    layout.no_rx = no_rx;
    
    % Create UE positions
    ind = true(1, no_rx);                       % UMa / UMi placement
    while any(ind)
        layout.randomize_rx_positions(0.93 * isd, 1.5, 1.5, 0, ind);
        ind = sqrt(layout.rx_position(1, :) .^ 2 + layout.rx_position(2, :) .^ 2) < no_go_dist;
    end
    floor = randi(5, 1, layout.no_rx) + 3;      % Number of floors in the building
    for i = 1:layout.no_rx
        floor(i) = randi(floor(i));             % Floor level of the UE
    end
    layout.rx_position(3, :) = 3 * (floor - 1) + 1.5;
    
    indoor_rx = layout.set_scenario('3GPP_38.901_UMa', [], [], 0.8);
    layout.rx_position(3, ~indoor_rx) = 1.5;    % Set outdoor-users to 1.5 m height
    layout.rx_array = aMT;                      % MT antenna setting
end
%%  Generate channels
function H = generateChannels(layout,numChan)
    H = [];
    for i = 1:numChan
       tempH = generateChannel(layout);
       H = cat(3,H,tempH);
    end
end
function H = generateChannel(layout)
    b = layout.init_builder;                    % Generate builders
    sic = size(b);
    for ib = 1: numel(b)
        [i1, i2] = qf.qind2sub(sic, ib);
        scenpar = b(i1, i2).scenpar;            % Read scenario parameters
        scenpar.SC_lambda = 0;                  % Disable spatial consistency of SSF
        b(i1, i2).scenpar_nocheck = scenpar;    % Save parameters without check (faster)
    end
    
    gen_parameters(b);                          % Generate LSF and SSF parameters (uncorrelated)
    cm = get_channels(b);                       % Generate channels
    
    H = [];
    for i = 1:4
        temp = cm(i).coeff(:,:,1);
        H = cat(1,H,temp);
    end
end
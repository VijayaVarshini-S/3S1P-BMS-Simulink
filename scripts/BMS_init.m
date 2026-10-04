%% BMS Project - Initialization Script
% Run this before opening/simulating the Simulink model, or set it as the
% model's PreLoadFcn (Model Properties > Callbacks).

clear; clc;

%% --- Cell electrical parameters (per cell, Li-ion ~18650-type example) ---
Q_nom   = 2.5;      % Nominal capacity [Ah]
R0      = 0.05;      % Ohmic internal resistance [Ohm]
R1      = 0.02;      % RC branch resistance [Ohm]
C1      = 3000;       % RC branch capacitance [F]  (tau = R1*C1 ~ 60s)
V_nom   = 3.7;        % Nominal voltage [V]

%% --- OCV vs SoC lookup table (typical Li-ion NMC shape, 0-1 SoC) ---
SoC_table = (0:0.05:1)';
OCV_table = [3.00; 3.35; 3.45; 3.50; 3.55; 3.58; 3.62; 3.65; 3.68; 3.71; ...
    3.75; 3.79; 3.83; 3.87; 3.92; 3.98; 4.05; 4.11; 4.15; 4.18; 4.20];

%% --- Initial conditions (intentionally unbalanced for demo purposes) ---
SoC1_init = 0.90;   % Cell 1 starts higher (will be bled down)
SoC2_init = 0.85;
SoC3_init = 0.80;

SoC1_est_init = 0.92; 
SoC2_est_init = 0.87;
SoC3_est_init = 0.82;

Vrc1_init = 0;
Vrc2_init = 0;
Vrc3_init = 0;

% BMS Safety Limits (Simulation Assumptions)
V_cell_max    = 4.25;  % Overvoltage protection limit [V]
V_cell_min    = 2.80;  % Undervoltage protection limit [V]
I_pack_max    = 3.00;  % Overcurrent protection limit [A]
SoC_max_limit = 0.98;  % High SoC threshold [-]
SoC_min_limit = 0.05;  % Low SoC threshold [-]

%% --- Balancing controller parameters ---
SoC_thresh = 0.03;   % Turn ON bleed once 3% above the pack minimum
SoC_hyst   = 0.01;   % Turn OFF once within 2% (thresh - hyst) of minimum
R_bleed = 33;      % Bleed resistor value [Ohm] (sized for desired bleed current)

%% --- SoC estimator parameters ---
Ts_soc        = 1;     % SoC estimator sample time [s]
I_rest_thresh = 0.05;  % Current below this [A] treated as "at rest" for OCV correction

%% --- Simulation settings ---
Ts_sim = 0.1;           % Simulation fixed-step size [s]
Tend = 7200;          % Total simulation time [s] (2 hours)

%% --- BMS demonstration load profile ---

t_profile = (0:Ts_sim:Tend)';

period = 600;          % 600 s period
duty_cycle = 0.5;      % 50% duty cycle

phase = mod(t_profile, period) / period;

% 0.7 A / 0.3 A alternating discharge
I_profile = 0.5 + 0.2*(phase < duty_cycle) ...
    - 0.2*(phase >= duty_cycle);

% Final rest period for OCV recovery
I_profile(t_profile > Tend*0.8) = 0;

load_current = [t_profile, I_profile];

disp('BMS initialization complete. Parameters loaded to workspace.');
plot(t_profile, I_profile)


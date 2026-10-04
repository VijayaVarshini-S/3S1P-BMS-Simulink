%% Master Automated Execution Pipeline (run_pipeline.m)
clc; clear; close all;

% Add subdirectories to path
addpath(genpath(pwd));

fprintf('[1/4] Loading parameters and drive cycle...\n');
run('scripts/BMS_init.m');

fprintf('[2/4] Executing 3S1P pack simulation (ode4, 7200s)...\n');
simOut = sim('models/bms_pack.slx', 'ReturnWorkspaceOutputs', 'on');

if isprop(simOut, 'logsout')
    logsout = simOut.logsout;
end

fprintf('[3/4] Processing metrics and rendering dashboard...\n');
run('scripts/plot_bms_results.m');

fprintf('[4/4] Exporting assets...\n');
run('scripts/export_assets.m');

disp('Pipeline finished successfully.');

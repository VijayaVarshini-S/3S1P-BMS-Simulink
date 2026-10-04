%% BMS Verification & Plotting Engine (plot_bms_results.m)
assert(exist('logsout', 'var') == 1, 'Variable logsout not found. Run sim(''bms_pack'') first.');

% Extract and enforce uniform 1D column vectors
time   = logsout.get('I_pack').Values.Time(:);
I_pack = squeeze(logsout.get('I_pack').Values.Data);    I_pack = I_pack(:);
V1     = squeeze(logsout.get('V_cell1').Values.Data);    V1     = V1(:);
V2     = squeeze(logsout.get('V_cell2').Values.Data);    V2     = V2(:);
V3     = squeeze(logsout.get('V_cell3').Values.Data);    V3     = V3(:);
V_pack = squeeze(logsout.get('V_pack').Values.Data);     V_pack = V_pack(:);
SoC1   = squeeze(logsout.get('SoC1_true').Values.Data);  SoC1   = SoC1(:);
SoC2   = squeeze(logsout.get('SoC2_true').Values.Data);  SoC2   = SoC2(:);
SoC3   = squeeze(logsout.get('SoC3_true').Values.Data);  SoC3   = SoC3(:);
Bal1   = squeeze(logsout.get('Balancing1').Values.Data); Bal1   = Bal1(:);
Bal2   = squeeze(logsout.get('Balancing2').Values.Data); Bal2   = Bal2(:);
Bal3   = squeeze(logsout.get('Balancing3').Values.Data); Bal3   = Bal3(:);
Ib1    = squeeze(logsout.get('I_bleed1').Values.Data);   Ib1    = Ib1(:);
Ib2    = squeeze(logsout.get('I_bleed2').Values.Data);   Ib2    = Ib2(:);
Ib3    = squeeze(logsout.get('I_bleed3').Values.Data);   Ib3    = Ib3(:);

t_hr = time / 3600;

% Validation Metrics
DeltaSoC_init  = max([SoC1(1), SoC2(1), SoC3(1)]) - min([SoC1(1), SoC2(1), SoC3(1)]);
DeltaSoC_final = max([SoC1(end), SoC2(end), SoC3(end)]) - min([SoC1(end), SoC2(end), SoC3(end)]);
E_diss_Wh      = trapz(time, (Ib1.^2 + Ib2.^2 + Ib3.^2) * R_bleed) / 3600;

fprintf('\n=======================================================\n');
fprintf('           BMS PACK VALIDATION METRICS                \n');
fprintf('=======================================================\n');
fprintf('Initial SoC Spread (Max - Min) : %.2f%%\n', DeltaSoC_init * 100);
fprintf('Final SoC Spread   (Max - Min) : %.2f%%\n', DeltaSoC_final * 100);
fprintf('Imbalance Reduction            : %.1f%%\n', ((DeltaSoC_init - DeltaSoC_final)/DeltaSoC_init)*100);
fprintf('Total Balancing Dissipation    : %.3f Wh\n', E_diss_Wh);
fprintf('=======================================================\n');

% Render Full 6-Panel Figure
figure('Color', [1 1 1], 'Position', [80 80 1150 820], 'Name', 'BMS Simulation Dashboard');

% 1. Pack Current Profile
subplot(3, 2, 1);
plot(t_hr, I_pack, 'k', 'LineWidth', 1.2); grid on;
ylabel('Current [A]'); title('Pack Load Profile'); xlim([0 max(t_hr)]);

% 2. Total Pack Voltage
subplot(3, 2, 2);
plot(t_hr, V_pack, 'Color', [0 0.5 0], 'LineWidth', 1.2); grid on;
ylabel('Voltage [V]'); title('Total Pack Voltage (V_{pack})'); xlim([0 max(t_hr)]);

% 3. Cell State of Charge Convergence
subplot(3, 2, 3);
plot(t_hr, SoC1*100, 'r', 'LineWidth', 1.3); hold on;
plot(t_hr, SoC2*100, 'Color', [0.85 0.5 0], 'LineWidth', 1.3);
plot(t_hr, SoC3*100, 'b', 'LineWidth', 1.3); grid on;
ylabel('SoC [%]'); title('Cell State of Charge Convergence');
legend('Cell 1', 'Cell 2', 'Cell 3', 'Location', 'southwest'); xlim([0 max(t_hr)]);

% 4. Terminal Cell Voltages
subplot(3, 2, 4);
plot(t_hr, V1, 'r', 'LineWidth', 1.1); hold on;
plot(t_hr, V2, 'Color', [0.85 0.5 0], 'LineWidth', 1.1);
plot(t_hr, V3, 'b', 'LineWidth', 1.1); grid on;
ylabel('Voltage [V]'); title('Cell Terminal Voltages');
legend('V_1', 'V_2', 'V_3'); xlim([0 max(t_hr)]);

% 5. Imbalance Spread Tracking
subplot(3, 2, 5);
DeltaSoC_track = (max([SoC1, SoC2, SoC3], [], 2) - min([SoC1, SoC2, SoC3], [], 2)) * 100;
plot(t_hr, DeltaSoC_track, 'm', 'LineWidth', 1.4); grid on;
ylabel('\Delta SoC [%]'); xlabel('Time [Hours]'); title('Cell Imbalance Spread (\Delta SoC)');
xlim([0 max(t_hr)]);

% 6. Passive Bleed Switch Engagement
subplot(3, 2, 6);
stairs(t_hr, Bal1, 'r', 'LineWidth', 1.2); hold on;
stairs(t_hr, Bal2 + 1.2, 'Color', [0.85 0.5 0], 'LineWidth', 1.2);
stairs(t_hr, Bal3 + 2.4, 'b', 'LineWidth', 1.2); grid on;
ylim([-0.2 3.8]); yticks([0.5, 1.7, 2.9]); yticklabels({'Sw 1', 'Sw 2', 'Sw 3'});
ylabel('Bleed Status'); xlabel('Time [Hours]'); title('Passive Bleed Switch States');
xlim([0 max(t_hr)]);
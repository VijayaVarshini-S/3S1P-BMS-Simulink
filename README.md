# 3S1P Li-Ion Battery Management System (BMS) with Passive Balancing

An automotive-grade Model-Based Design (MBD) project implementing a 3-series, 1-parallel (3S1P) Lithium-ion Battery Management System in MATLAB/Simulink. This repository models multi-cell dynamic electrochemistry, closed-loop passive balancing with hysteresis switching, supervisory fault diagnostics, and automated verification testing.

---


## Technical Specifications

### Plant Parameters (1st-Order Thevenin ECM)
* **Nominal Cell Capacity ($Q_{\text{nom}}$):** $2.5\text{ Ah}$
* **Ohmic Resistance ($R_0$):** $50\text{ m}\Omega$
* **Polarization Resistance ($R_1$):** $20\text{ m}\Omega$
* **Polarization Capacitance ($C_1$):** $3000\text{ F}$ (Time constant $\tau = R_1 C_1 = 60\text{ s}$)
* **State of Charge (SoC):** Coulomb-counting integrator with non-linear $V_{\text{OCV}}(\text{SoC})$ mapping.

### Balancing & Protection Thresholds
* **Passive Shunts:** $R_{\text{bleed}} = 33\ \Omega$ ($I_{\text{bleed}} \approx 120\text{ mA}$)
* **Balancing Strategy:** Cell-to-Minimum SoC hysteresis comparator.
  * Turn ON threshold: $\Delta\text{SoC}_i \ge 3.0\%$
  * Turn OFF threshold: $\Delta\text{SoC}_i \le 2.0\%$
* **Safety Monitoring:**
  * Over-Voltage Protection (OVP): $4.25\text{ V}$
  * Under-Voltage Protection (UVP): $2.80\text{ V}$
  * Over-Current Protection (OCP): $3.00\text{ A}$

---

## Key Engineering Highlights

* **Algebraic Loop Elimination:** Resolved direct feedthrough circular loops ($I_{\text{pack}} \rightarrow V_{\text{term}} \rightarrow I_{\text{bleed}} \rightarrow I_{\text{pack}}$) by decoupling the shunt paths from instantaneous terminal voltage and referencing them to the internal continuous open-circuit voltage ($\text{OCV}$) state.
* **Solver Stability:** Configured for fixed-step execution (`ode4` Runge-Kutta, step size $\Delta t = 0.1\text{ s}$) to match automotive embedded controller implementation constraints.
* **Zero Relay Chatter:** A $1.0\%$ hysteresis deadband prevents rapid switching around the threshold boundary.

---

## Simulation Results & Verification

Simulation run over a $7200\text{ s}$ (2-hour) multi-rate dynamic pulse-discharge and rest drive cycle[cite: 4, 6].

| Metric | Target / Spec | Simulated Result | Verification Status |
| :--- | :--- | :--- | :--- |
| **Initial SoC Imbalance** | $10.00\%$ | $10.00\%$ ($90\%, 85\%, 80\%$)[cite: 4] | Baseline Set |
| **Final SoC Imbalance** | $\le 2.00\%$ | **$2.00\%$**[cite: 4] | Pass (Target Met) |
| **Imbalance Reduction** | $\ge 75.0\%$ | **$80.0\%$**[cite: 4] | Pass |
| **Total Energy Dissipated** | Sizing budget | **$1.087\text{ Wh}$**[cite: 4] | Verified |
| **Master Fault Flags** | `0` (Normal) | `0`[cite: 1] | Pass (Within Envelope) |

### Verification Dashboard
![Simulation Dashboard](figures/bms_simulation_dashboard.png)[cite: 4, 6]

1. **Pack Load Profile:** Pulsed discharging followed by a settling period[cite: 4, 6].
2. **Total Pack Voltage ($V_{\text{pack}}$):** Tracks ohmic drops and rest relaxation curves[cite: 4, 6].
3. **Cell SoC Convergence:** Higher cells (Cell 1 and Cell 2) discharge faster through shunt bleed assist until converging with Cell 3[cite: 4, 6].
4. **Terminal Cell Voltages:** Dynamic tracking across each independent cell[cite: 4, 6].
5. **Imbalance Spread ($\Delta\text{SoC}$):** Monotonic descent from $10\%$ to lock at $2.0\%$[cite: 4, 6].
6. **Bleed Switch States:** Hysteresis relays turn off sequentially (Sw 2 at $t \approx 0.65\text{ h}$, Sw 1 at $t \approx 1.68\text{ h}$) with zero chattering[cite: 4, 6].


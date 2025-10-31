# 16-bit CORDIC Core in Verilog

##  Overview
This repository contains the Verilog implementation of a **16-bit CORDIC (Coordinate Rotation Digital Computer)** circuit designed to calculate **sine and cosine** values efficiently.  
The design uses only **adders, subtractors, and bit-shifters**, completely avoiding hardware multipliers.

This project was developed as part of the **eSim Hackathon 2025**, and was functionally verified using the **Makerchip IDE** simulation environment.

---

##  Features

- Calculates sine and cosine using the CORDIC Rotation Mode.  
- Operates on 16-bit signed fixed-point numbers (`WIDTH = 16`).  
- Performs 16 iterations for accurate convergence.  
- Hardware-efficient: uses only add, subtract, and shift operations.  
- Controlled by a 3-state Moore FSM (IDLE → CALC → DONE) for stable, glitch-free outputs.  
- Modular design with a dedicated LUT module (`angle_lut.v`) for precomputed constants.

---

##  Implementation Details

### Fixed-Point Scaling
Two different scaling methods are used:

- **Coordinates (x, y, cos_out, sin_out):** Scaled by 2¹³ (Q2.13 format).  
  Example: 1.0 is represented as 8192.  
- **Angles (angle input, internal angle_reg, LUT constants):** Scaled by mapping 180° to 2¹⁵ (32768).  
  Example: 45° is represented as 8192.

### Gain Correction
The inherent CORDIC gain (approximately 1.647) is compensated by pre-scaling the initial input vector.  
A scaling factor of 4974, representing (1/K × 2¹³), is applied to the initial `x_reg` at the start of computation.

---

##  Modules

- **cordic.v:** Contains the FSM controller and datapath logic for iterative rotation.  
- **angle_lut.v:** Combinational module providing pre-calculated arctangent constants (`atan(2⁻ⁱ)`) using the 2¹⁵ angle scaling.

---

##  Simulation and Verification

The design was simulated and verified using the Makerchip IDE.  
A testbench (`cordic_makechip_code.v`) was created to provide clock, reset, and stimulus inputs to the CORDIC module.

### Example Input Angles and Results

Input angles are scaled such that 180° = 32768.

- **30° (5461):**  
  - sin(30°) ≈ 0.500 → 4096 (fixed-point)  
  - cos(30°) ≈ 0.866 → 7094 (fixed-point)
  - ![30](https://raw.githubusercontent.com/NavyStudent2893/16-bit-CORDIC-Circuit/refs/heads/main/30.png)


- **45° (8192):**  
  - sin(45°) ≈ 0.707 → 5792 (fixed-point)  
  - cos(45°) ≈ 0.707 → 5792 (fixed-point)
  - ![45](https://raw.githubusercontent.com/NavyStudent2893/16-bit-CORDIC-Circuit/refs/heads/main/45.png)

- **60° (10923):**  
  - sin(60°) ≈ 0.866 → 7094 (fixed-point)  
  - cos(60°) ≈ 0.500 → 4096 (fixed-point)
  - ![60](https://raw.githubusercontent.com/NavyStudent2893/16-bit-CORDIC-Circuit/refs/heads/main/60.png)

Waveforms were captured in `cordic_makerchip_waveform.vcd` for verification.  
The FSM and datapath behaved as expected, and results matched theoretical values within CORDIC’s fixed-point accuracy limits.


---

##  How to Run

### Simulation
1. Load `cordic.v` and `angle_lut.v` into your Verilog simulator.  
2. Optionally use `cordic_tb.v` or the built-in Makerchip testbench.  
3. Apply a clock and reset.  
4. Input angles should be scaled such that 180° = 32768.  
5. Observe `cos_out`, `sin_out`, and `done` signals in the waveform.

Supported simulators include Makerchip IDE, Icarus Verilog (`iverilog`), ModelSim, and Vivado XSim.

### Synthesis / Implementation
The RTL code is fully synthesizable and compatible with ASIC and FPGA flows.  
You can use:
- Yosys + OpenROAD for open-source ASIC design  
- Vivado, Quartus, or Lattice Diamond for FPGA design

Physical design targeting the IHP SG13G2 PDK was not completed during the hackathon phase.

---

## 📊 Project Status

- RTL Design: Completed  
- Functional Simulation: Verified using Makerchip  
- Synthesis and Physical Design: Pending / Future Work  

---

##  References

- Jack E. Volder, “The CORDIC Trigonometric Computing Technique,” *IRE Transactions on Electronic Computers*, 1959.  
- Ray Andraka, “A Survey of CORDIC Algorithms for FPGA-Based Computers,” *FPGA Conference*, 1998.  
- [Makerchip IDE](https://makerchip.com)

---

##  Author

**Mohd Maaz Quraishi**  
eSim Hackathon 2025 Participant  
Department of Electronics and Communication Engineering ,
Jamia Millia Islamia

---

## 🏁 Summary
A **16-bit CORDIC circuit** was successfully designed and verified in Verilog.  
The project demonstrates how **hardware-efficient trigonometric computation** can be achieved using iterative vector rotation without multipliers.

---

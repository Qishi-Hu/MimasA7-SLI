# MimasA7-SLI

This repository serves a structured light illumination (SLI) system orchestrated by an FPGA controller. The system is based on the Numato Mimas A7 Rev3 board, which is powered by an Artix-7 FPGA. The board includes two HDMI shields: one for input and one for output.

In this project, the FPGA:
- Takes HDMI video input from a host PC and outputs HDMI video to a DLP projector.
- Synchronizes the projection and capture of each frame by interacting with a PC and a camera module through the GPIO header using a handshake protocol.
- Utilizes a [customized PCB](https://github.com/ruffner/MojoV3_HDMI_Interface/tree/master/pcb/LauCameraTrigger_MimasA7) to bridge the GPIO header with the PC and camera via a DB9 port.

The camera module captures SLI patterns reflected by the scanned object and provides them to the host PC for 3-D reconstruction.

## FPGA Controller Modes

### 1. Pass-through with Top-Left Pixel Detection
- The FPGA functions as an HDMI pass-through capable of **720p@60Hz**. The PC is responsible for playing back the SLI patterns.
- The FPGA reads the top-left pixel (TLP) value of each frame and displays it (in hexadecimal) on a 7-segment display.
- If the current frame has a different TLP value from the previous frame, the FPGA sends a pulse to trigger the camera shutter during the next VSYNC period.
- The host PC waits for confirmation that the camera is ready before playing the next frame.

### 2. SD Pattern Generation
- The FPGA takes input from the HDMI source and replaces the visible pixels of each frame with those from a predefined pattern before passing them to the HDMI output.
- The current pattern is a 24-frame sequence, where each row of a frame contains identical pixel values corresponding to the row index.
- The very first frame is defined by a **Look-Up Table (LUT)**, and subsequent frames are derived by modifying the spatial and temporal frequencies of the first frame.
- The `indexMapping.m` script maps the combination of a pixel’s row index and frame index to an index in the predefined LUT.
- The LUT is pre-generated using the `SLI_LUT.m` script and stored as a raw file (`LUT.raw`) on the SD card. During boot, it is loaded into on-chip memory.
- Each pixel’s row index is mapped to the corresponding LUT index using a read-only memory (ROM) module, initialized by a coefficient file (`indexMap.coe`) generated by the `indexMapping.m` script.
- The FPGA increments the frame index and triggers the camera on VSYNC, as long as the camera signals it is ready.

## Licensing

Building an HDMI pass-through is a foundational element of this project. For this, I adapted the design by [hamsternz](https://github.com/hamsternz/Artix-7-HDMI-processing/tree/master) (MIT License).

## Demo Version

A [demo verison](https://github.com/Qishi-Hu/MimasA7-SLI-Demo/tree/main) of this project (before the integration of PCB) is capable of demosntrating each pattern frame at slow motion.

## Directory Structure
root/
├── README.md         # Overview of the repository  
├── SLI_CAM_1.0.xpr.zip  # Archive of the Vivado 2024.1 project  
├── Bitsrteam/        # Final bitstream files  
├── src_1/            # Source HDLand Matlab code  
├── sim_1/            # Test benches for simulation  
└── constr_1/         #  Xlinx Design Constarint  


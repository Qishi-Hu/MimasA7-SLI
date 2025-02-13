# MimasA7-SLI

This repository serves a structured light illumination (SLI) system orchestrated by an FPGA controller. The system is based on the Numato Mimas A7 Rev3 board, which is powered by an Artix-7 FPGA. The board includes two HDMI shields: one for input and one for output.

In this project, the FPGA:
- Takes HDMI video input from a host PC and outputs HDMI video to a DLP projector.
- Synchronizes the projection and capture of each frame by interacting with a PC and a camera module through the GPIO header using a handshake protocol.
- Utilizes a [customized PCB](https://github.com/ruffner/MojoV3_HDMI_Interface/tree/master/pcb/LauCameraTrigger_MimasA7) to bridge the GPIO header with the PC and camera via a DB9 port.

The camera module captures SLI patterns reflected by the scanned object and provides them to the host PC for 3-D reconstruction.

## How to configure the bitstream?

1. Download and install the latest version of Tenagra FPGA System Manager from [NumatoLab](https://numato.com/product/tenagra-fpga-system-management-software/).
2. Download `Bitstream\SLI-CAM.bin` to your local machine.
3. Power on the Mimas A7 board and connect it to your PC via USB.
4. Open Tenagra =>  **Program Device** => select **Flash Memory** => click **Add More Configurations** => select `SLI-CAM.bin`=> click **Run** => wait until the GUI confirms that the configuration is completed successfully.


## FPGA Controller Modes

### 1. Pass-through with Top-Left Pixel Detection
- The FPGA functions as an HDMI pass-through capable of **720p@60Hz**. The PC is responsible for playing back the SLI patterns.
- The FPGA reads the **top-left pixel (TLP)** value of each frame and displays it (in hexadecimal) on a 7-segment display.
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

## Tips for setting FPS and resoultion for HDMI Input
The HDMI input should be automtcially conifgured after it reads the EDID from the FPGA. To confirm it in Windows, go to **System > Display > Advanced Settings > Sletect Display "NUMATOmA7"**. The display info should be similar to the screenshot below.
<div style="margin-left: 40px;">
  <img src="https://github.com/user-attachments/assets/7602d3e7-48bc-4e80-92ad-71f2a9ab148b" alt="image (2)">
</div>

The **Active Signal Mode** is the actual setting of the HDMI signal, if it is not for 720p@60Hz (59.xx Hz or 60.xx Hz are also acceptable), please go to **System > Display > Advanced Settings > Adapter Properties > List All Modes** to manually set the correct mode.


## LED, Push Buttons, and DIP Swicthes
### 1. LED indicators
| LED (Index) | Indication                                                      |
|-------------|------------------------------------------------------------------|
| 7           | HSYNC                                                           |
| 6           | VSYNC                                                           |
| 5           | LUT successfully read from SD card                                       |
| 4           | Scan Direction; On for horizontal strips, off for  vertical strips |
| 3           | Mode (0 for SD pattern, 1 for pass-through)                     |
| 2           | Camera trigger is ready                                                   |
| 1           | First frame of the pattern                                                   |
| 0           | Trigger                                                        |

* LED0 is the one closest to the GPIO header
### 2. 7-segment display (two digits enabled)
For passthrough mode, it shows the TLP value in hexdecimal. For SD pattern generation mode, one digit represent the current spatial frequency index (frq) and the other digit represents the frame/phase index (frm) under the current spatial frequency. If it shows "88" after boot up, that means no valid input pixel clock as each segment is set to default value '0' (on).
### 3. BTNU push button
This button is located right next to the Artix-7 trademark. It can be used to reset the HDMI output port during runtime.
### 4. DIP Swicthes Control
| LED (Index) | Indication                                                      |
|-------------|------------------------------------------------------------------|
| 8           | On to disable Red channel                                                           |
| 7           | On to disable Green channel                                                           |
| 6           | On to disable Blue channel                                      |
| 5           | Unused |
| 4           | Unused                     |
| 3           | Unused                                                   |
| 2           | On for vertical strips,off for horizontal strips                       |
| 1           | Unused                                                       |
## GPIO pin assignments
| BASLR Cam  | FPGA Pins | DB9 Pins | Purpose                                         | I/O (from FPGA's POV)             |
|------------|-----------|----------|-------------------------------------------------|-----------------------------------|
| Line 1     | A31_1     | 5        | Trigger the camera                              | Output                            |
| Line 2     | A28_1     | 9        | Mode (0 for SD pattern, 1 for pass-through)     | Input                             |
| Line 3     | A29_1     | 4        | First frame of the pattern                      | Output                            |
| Line 4     | A32_1     | 8        | Camera is ready for the next trigger            | Input                             |
| GND        | A40_1     | 1        | Ground                                          | -                                 |
| VCC(3.3V)  | A9_1      |          | 3.3 V reference for the PCB                     | -                                 |

## Directory Structure
<pre>
├── README.md           # Overview of the repository  
├── SLI_CAM_1.0.xpr.zip    # Archive of the Vivado 2024.1 project  
├── Bitsrteam/          # Final bitstream files  
├── Matlab/             # .m scripts and output files  
├── src_1/              # Source HDLand Matlab code  
├── sim_1/              # Test benches for simulation  
└── constr_1/           #  Xlinx Design Constarint  
</pre>

## Licensing

Building an HDMI pass-through is a foundational element of this project. For this, I adapted the design by [hamsternz](https://github.com/hamsternz/Artix-7-HDMI-processing/tree/master) (MIT License).

## Demo Version

A [demo verison](https://github.com/Qishi-Hu/MimasA7-SLI-Demo/tree/main) of this project (before the integration of PCB) is capable of demosntrating each pattern frame at slow motion.

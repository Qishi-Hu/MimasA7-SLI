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

## Tips for setting FPS and resoultion for HDMI Input
The HDMI input should be automtcially conifgured after it reads the EDID from the FPGA. To confirm it in Windows, go to **System > Display > Advanced Settings > Sletect Display "NUMATOmA7"**. The display info should be similar to the screenshot below.
> ![image (2)](https://github.com/user-attachments/assets/7602d3e7-48bc-4e80-92ad-71f2a9ab148b)

The **Active Signal Mode** is the actual setting of the HDMI signal, if it is not for 720p@60Hz (59.xx Hz or 60.xx Hz are also acceptable), please go to **System > Display > Advanced Settings > Adapter Properties > List All Modes** to manually set the correct mode.

## Specifications of FPGA Controller Modes

### 1. Pass-through with Top-Left Pixel Detection
- The FPGA functions as an HDMI pass-through capable of **720p@60Hz**. The PC is responsible for playing back the SLI patterns.
- The FPGA reads the **top-left pixel (TLP)** value of each frame.
- If the current frame has a different TLP value from the previous frame, the FPGA sends a pulse to trigger the camera shutter during the next VSYNC period.
- The host PC waits for confirmation that the camera is ready before playing the next frame.

### 2. SD Pattern Generation
- The FPGA replaces the input HDMI frames with locally generated SLI patterns. If the HDMI input is absent, it simply creates the pattern locally. 
- The current pattern is a 24-frame sequence, where each row of a frame contains identical pixel values corresponding to the row index.
- The start frame is defined by a **Look-Up Table (LUT)**, and subsequent frames are



## GPIO pin assignments
| Camera Interface  | FPGA Pins | DB9 Pins | Purpose                                         | I/O (from FPGA's POV)             |
|------------|-----------|----------|-------------------------------------------------|-----------------------------------|
| Line 1 (Cam1)    | A23     | 5        | Trigger the camera                              | Output                            |
| Line 2  (Cam1)     | A35     | 9        | Mode (1 local patterns, 0 pass-through)     | Input                             |
| Line 3  (Cam1)      | A29     | 4        | First frame of the pattern                      | Output                            |
| Line 4  (Cam1)     | A17     | 8        | Camera is ready for the next trigger            | Input                             |
| Line 1 (Cam2)    | A24     | 6        | Trigger the camera                              | Output                            |
| Line 2  (Cam2)     | A36     | 2        | Mode (1 local patterns, 0 pass-through)     | Input                             |
| Line 3  (Cam2)      | A30    | 3        | First frame of the pattern                      | Output                            |
| Line 4  (Cam2)     | A18     | 7        | Camera is ready for the next trigger            | Input                             |
| GND        | G     | 1        | Ground                                          | -                                 |




| Other  Signals |  FPGA Pins | Function                            |
|------------|----------|----------------------------------------|
|3.3V  |  V+ / DN /2.5 (Ctrl Bank)    | 3.3 V reference  |
|5V  |  R  (Ctrl Bank)   |  5 V reference |
| SW[3]          |A12     | Enable (1) / Disable(0) the Red channel        |
| SW[2]           |A11     | Enable (1) / Disable(0) the  Green channel      |
| SW[1]           |A6     | Enable (1) / Disable(0) the  Blue channel       |
|SW[0]          |A5     | 0 for vertical stripes, 1 for horizontal stripes |

## Directory Structure
<pre>
├── README.md           # Overview of the repository  
├── Au2_SLI.xpr.zip    # Archive of the Vivado 2024.1 project  
├── Bitsrteam/          # Final bitstream files  
├── Matlab/             # .m scripts and output files  
├── src_1/              # Source HDLand Matlab code  
└── constr_1/           #  Xlinx Design Constarint  
</pre>

## Licensing

Building an HDMI pass-through is a foundational element of this project. For this, I adapted the design by [hamsternz](https://github.com/hamsternz/Artix-7-HDMI-processing/tree/master) (MIT License).

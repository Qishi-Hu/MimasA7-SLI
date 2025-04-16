`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Qishi Hu
//  
// Create Date: 01/08/2025 04:30:30 PM
// Design Name: 
// Module Name: clk_selector
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Orinally created to detect wether hmdi input is plugged and select clock source accrodinhly.
//  However, even unpluged, we can still detect tmds_clk using a counter and a LED, this weird ghost clock 
//    can also be slowed down when the shield is plugged and the cable is not connected to any video source
// Such a weird phenomeon make me decide to create a sperate Vivado project for the offline version of SLI_CAM
// where only local on-board clock is utilized.
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module clk_selector (
    input online,
    input hdmi_clk,hdmi_clk1,hdmi_clk5, clk73, clk367,
    output oclk, oclk1, oclk5
);

    
   
    BUFGMUX mux (
    .O(oclk),  // Output clock
    .I0(clk73),    // Input clock 1
    .I1(hdmi_clk),    // Input clock 2
    .S(online)    // Select signal
    );
    
    BUFGMUX mux_x1 (
    .O(oclk1),  // Output clock
    .I0(clk73),    // Input clock 1
    .I1(hdmi_clk1),    // Input clock 2
    .S(online)    // Select signal
    );
    
    BUFGMUX mux_x5 (
    .O(oclk5),  // Output clock
    .I0(clk367),    // Input clock 1
    .I1(hdmi_clk5),    // Input clock 2
    .S(online)    // Select signal
    );

endmodule

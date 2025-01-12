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
    input rx, tmds_clk,
    input hdmi_clk, hdmi_clk1, hdmi_clk5, vsync,
    input clk75, clk375,    
    output sel,oclk, oclk1, oclk5
);
    
    reg s= 1'b0; reg L = 1'b0; reg H = 1'b0;
    reg [27:0] count = 0;  // check period 
    reg [21:0] cnt =0;
    always@(posedge tmds_clk) begin
        cnt<=cnt+1'b1;
    end
//   always@(posedge clk75) begin
//        count<= count+1;
//        if (count[27]) begin
//            if(H & L ) s<=1'b0;
//            else s<= 1'b1;
//        end
//        else if (count[26]) begin
//            if(cnt[8]) begin H <=1'b1; L<=L; end
//            else begin H <=H; L<=1'b1; end           
//        end
//        else begin
//            L<=1'b0; H<=1'b0;
//        end     
//   end
    
    assign sel =cnt[21];
   
//    BUFGMUX mux (
//    .O(oclk),  // Output clock
//    .I0(hdmi_clk),    // Input clock 1
//    .I1(clk75),    // Input clock 2
//    .S(s)    // Select signal
//    );
    
//    BUFGMUX mux_x1 (
//    .O(oclk1),  // Output clock
//    .I0(hdmi_clk1),    // Input clock 1
//    .I1(clk75),    // Input clock 2
//    .S(s)    // Select signal
//    );
    
//    BUFGMUX mux_x5 (
//    .O(oclk5),  // Output clock
//    .I0(hdmi_clk5),    // Input clock 1
//    .I1(clk375),    // Input clock 2
//    .S(s)    // Select signal
//    );

endmodule

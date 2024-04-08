`timescale 1ns / 1ps

module vga_top(
    input CLK100MHZ,
    input btnU, btnD, btnL, btnR,
    //vga outputs
    output [3:0] vgaRed, vgaGreen, vgaBlue,
    output Hsync, Vsync,
    output [6:0] seg,
    output [3:0] an
    );
    
    //clock frequency confersion instantiation
    conv100MHZ40 clock_inst(.CLK100MHZ(CLK100MHZ), .CLK40MHZ(CLK40MHZ));
    
    //instantiating vga video timing generator
    VGA_800x600at60HZ vga_inst(.CLK40MHZ(CLK40MHZ), .Hsync(Hsync), .Vsync(Vsync), .HorizontalCounter(Hindex), .VerticalCounter(Vindex));
    
    wire [11:0] Hindex, Vindex;
    //instantiating the compute in memory video rom
    image_logic(.seg(seg), .an(an), .CLK100MHZ(CLK100MHZ), .Hindex(Hindex), .Vindex(Vindex), .btnU(btnU), .btnD(btnD), .btnL(btnL), .btnR(btnR), .pixel_data({vgaBlue, vgaGreen ,vgaRed}));
endmodule

`timescale 1ns / 1ps

module VGA_800x600at60HZ(
    input  CLK40MHZ,
    output Hsync, Vsync,
    reg [11:0] HorizontalCounter = 0, VerticalCounter = 0
    );

   
   assign HorizontalIndex = HorizontalCounter;
   assign VerticalIndex = VerticalCounter;
   
   assign CanvasValid = (HorizontalCounter <= 'd800) & (VerticalCounter <= 'd600);


   //Counting the pixels
    always@(posedge CLK40MHZ)begin
        if(HorizontalCounter == 'd1056)begin
            HorizontalCounter <= 'h0;
            if(VerticalCounter == 'd628)begin
                VerticalCounter <= 'h0;
            end
            else VerticalCounter <= VerticalCounter + 1;
        end
        else HorizontalCounter <= HorizontalCounter + 1;
    end
    
    assign Hsync = (HorizontalCounter <= 'd840) | (HorizontalCounter >= 'd968);
    assign Vsync = (VerticalCounter <= 'd601) | (VerticalCounter >= 'd605);
    
endmodule

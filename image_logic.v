	module image_logic(
    input CLK100MHZ,
    input [11:0] Hindex, Vindex, input canvas_valid,
    input btnU, btnD, btnR, btnL,
    output reg [11:0] pixel_data,
    output [6:0] seg,
    output reg [3:0] an
    );
    
    //left peddale
    reg [11:0] left_paddle_horizontal_index = 12'd10;
    reg [11:0] left_paddle_vertical_index = 12'd10;    
    localparam left_param_width = 12'd10;
    localparam left_param_lenght = 12'd50;
    
    //right peddale
    reg [11:0] right_paddle_horizontal_index = 12'd730;
    reg [11:0] right_paddle_vertical_index = 12'd10;    
    localparam right_param_width = 12'd10;
    localparam right_param_lenght = 12'd50;
    
    //ball
    reg [11:0] ball_hi = 12'd400;
    reg [11:0] ball_vi = 12'd300;
    localparam ball_w = 12'd5;
    localparam ball_h = 12'd5;
    
	//ball control
	reg [3:0] ball_dir = 4'b1010;
    
    //object active flag
    wire ball_active = (Hindex >= ball_hi & Hindex < (ball_hi + ball_w)) & (Vindex >= ball_vi & Vindex < (ball_vi + ball_h));
    wire left_paddle_active = (Hindex >= left_paddle_horizontal_index & Hindex <= (left_paddle_horizontal_index + left_param_width)) & (Vindex >= left_paddle_vertical_index & Vindex <= left_paddle_vertical_index + left_param_lenght);
    wire right_paddle_active = (Hindex >= right_paddle_horizontal_index & (Hindex < right_paddle_horizontal_index + right_param_width) & (Vindex >= right_paddle_vertical_index & Vindex <= (right_paddle_vertical_index + right_param_lenght)));
    
    //ball collision markers
    wire top_hit = ball_vi == 12'd0;
    wire bottom_hit = (ball_vi + ball_h) >= 12'd600;
    //paddle hit
	wire left_paddle_hit = (((left_paddle_horizontal_index + left_param_width) >= ball_hi) & ((left_paddle_vertical_index <= ball_vi) & ((left_paddle_vertical_index + left_param_lenght) >= ball_vi)));
    wire right_paddle_hit = ((right_paddle_horizontal_index <= ball_hi) & ((right_paddle_vertical_index <= ball_vi) & ((right_paddle_vertical_index + right_param_lenght) >= ball_vi)));    //wall hit
	
    wire left_hit = ball_hi == 12'd0;
    wire right_hit = ball_hi == 12'd800;
    
    always@(*)begin//left paddle image generation
        if(left_paddle_active | right_paddle_active | ball_active)begin
            pixel_data <= 12'hfff;
        end
        else begin
            pixel_data <= 12'h000;
        end
    end    
    //200 hz clock
    reg [18:0] CLK40MHZ_200HZ = 19'd0;
    always@(posedge CLK100MHZ) CLK40MHZ_200HZ <= CLK40MHZ_200HZ + 1;
    wire CLK200MHZ = CLK40MHZ_200HZ[18];
    
    //driver for moving the paddle
always@(posedge CLK200MHZ)begin
        if(btnU)begin
            if(left_paddle_vertical_index != 0)begin
                left_paddle_vertical_index <= left_paddle_vertical_index - 1;
            end
        end
        else if(btnL)begin
            if(left_paddle_vertical_index <= 12'd550)begin
                left_paddle_vertical_index <= left_paddle_vertical_index + 1;
            end
        end
        
        if(btnR)begin
            if(right_paddle_vertical_index != 0)begin
                right_paddle_vertical_index <= right_paddle_vertical_index - 1;
            end
        end
        else if(btnD)begin
            if(right_paddle_vertical_index <= 12'd550)begin
                right_paddle_vertical_index <= right_paddle_vertical_index + 1;
            end
        end
    end
	
//reset regestry 
reg reset = 0;


reg [3:0] score_left = 0;
reg [3:0] score_right = 0;

//driver for ball movement
always@(posedge CLK200MHZ)begin
    if(reset)begin
        ball_hi <= 12'd400;
        ball_vi <= 12'd300;
        reset <= 0;
    end else 
    begin
        //ball direction
        //right
        if (ball_dir[0])
           ball_hi = ball_hi + 1;
        //left   
        if (ball_dir[1])
           ball_hi = ball_hi - 1;
        //down   
        if (ball_dir[2])
           ball_vi = ball_vi + 1;
        //up
        if (ball_dir[3])
           ball_vi = ball_vi - 1;
           //ball direction control
        if(left_paddle_hit)begin 
            ball_dir[0] <= 1;
            ball_dir[1] <= 0;
            ball_hi = ball_hi + 1;		
       end else 
        if(right_paddle_hit)begin
            ball_dir[0] <= 0;
            ball_dir[1] <= 1;
            ball_hi <= ball_hi - 1;
        end else
        if(top_hit)begin
            ball_dir[2] <= 1;
            ball_dir[3] <= 0;
            ball_vi <= ball_vi + 1;
         end else
        if(bottom_hit)begin
            ball_dir[2] <= 0;
            ball_dir[3] <= 1;
            ball_vi <= ball_vi - 1;
         end else
        if(left_hit)begin
            reset <= 1;
            ball_dir[0] <= 1;
            ball_dir[1] <= 0;
            score_right = score_right + 1;
        end else 
        if(right_hit)begin
            reset <= 1;
            ball_dir[0] <= 0;
            ball_dir[1] <= 1;
            score_left = score_left + 1;
        end 
    end
end


//7segmentdisplay part
//score registers


reg [9:0] counter = 0;

reg [3:0] sw;
wire [6:0] dekoder [15:0];
    //assigning dumping a meme file to the rom
assign dekoder[0]  = 7'b1000000; //0
assign dekoder[1]  = 7'b1111001; //1
assign dekoder[2]  = 7'b0100100; //2
assign dekoder[3]  = 7'b0110000; //3
assign dekoder[4]  = 7'b0011001; //4
assign dekoder[5]  = 7'b0010010; //5
assign dekoder[6]  = 7'b0000010; //6
assign dekoder[7]  = 7'b1111000; //7
assign dekoder[8]  = 7'b0000000; //8
assign dekoder[9]  = 7'b0010000; //9
assign dekoder[10] = 7'b0001000; //a
assign dekoder[11] = 7'b0000011; //b
assign dekoder[12] = 7'b0100111; //c
assign dekoder[13] = 7'b0100001; //d
assign dekoder[14] = 7'b0000110; //e
assign dekoder[15] = 7'b0001110; //f    
    
assign seg = dekoder[sw];   
reg [3:0] sel = 4'b0001;
always@(posedge CLK200MHZ)begin
    counter <= counter + 1;
    if (counter[9:8] == 1)begin
       sel <= sel << 1;
       sel [0] <= sel[3];
       if(sel[0])begin
            sw <= score_right;
            an <= 4'b0111;
       end
       if(sel[3])begin
            sw <= score_left;
            an <= 4'b1101;
       end      
    end
end
endmodule

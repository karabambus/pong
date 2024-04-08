	module image_logic(
    input CLK100MHZ,
    input [11:0] Hindex, Vindex, input canvas_valid,
    input btnU, btnD, btnR, btnL,
    output reg [11:0] pixel_data
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
	wire left_paddle_hit = (ball_hi == left_paddle_horizontal_index + left_param_width) & (ball_vi >= left_paddle_vertical_index - ball_h) & (ball_vi >= left_paddle_vertical_index + left_param_lenght + ball_h);
    wire right_paddle_hit = ((ball_hi + ball_w) == right_paddle_horizontal_index) & (ball_vi >= right_paddle_vertical_index - ball_h) & (ball_vi >= right_paddle_vertical_index + right_param_lenght + ball_h);    //wall hit
	
    wire left_hit = ball_hi == 12'd0;
    wire right_hit = ball_hi == 12'd800
    
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
	
//driver for collisions   
always@(posedge CLK200MHZ)begin
	if(left_paddle_hit)begin
		ball_dir[0] = 1;
		ball_dir[1] = 0;		
	end else if(right_paddle_hit)begin
		ball_dir[1] = 1;
		ball_dir[0] = 0;
	end else if(left_hit)begin
		//score player 2
	end	else if(right_hit)begin
		//score player 1
	end else if(top_hit)begin
		ball_dir[2] = 1;
		ball_dir[3] = 0;
	end else if(top_hit)begin
		ball_dir[2] = 0;
		ball_dir[3] = 1;
	end
end

//driver for ball movement
always@(posedge CLK200MHZ)begin
	case(true)
	ball_dir[0]: ball_hi = ball_hi + 1;
	ball_dir[1]: ball_hi =ball_hi - 1;
	ball_dir[2]: ball_vi = ball_vi + 1;
	ball_dir[3]: ball_vi = ball_vi - 1;
end

   
   
   
   
endmodule

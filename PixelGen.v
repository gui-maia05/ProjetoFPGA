module PixelGen(
    input wire clk, rstn,
    input wire video_on, p_tick,
    input wire right_k, left_k,
    input wire [9:0] pixel_x, pixel_y,
    output reg [3:0] r, g, b
);

    localparam BACKGROUND_COLOR = 12'h000;

    reg [3:0] r_reg, g_reg, b_reg;
    wire [11:0] paddle_rgb, ball_rgb;
    wire paddle_on, ball_on;
    wire refr_tick;
    wire [9:0] paddle_x, paddle_y;

    assign refr_tick = (pixel_y == 481) && (pixel_x == 0);
    
    Paddle paddle(
        .clk(clk), 
        .rstn(rstn), 
        .refr_tick(refr_tick),
        .turn_r(right_k), 
        .turn_l(left_k),
        .y(pixel_y), 
        .x(pixel_x), 
        .paddle_rgb(paddle_rgb),
        .paddle_on(paddle_on),
        .paddle_x(paddle_x), 
        .paddle_y(paddle_y)
    );

    Ball ball(
        .clk(clk), 
        .rstn(rstn), 
        .refr_tick(refr_tick),
        .x(pixel_x), 
        .y(pixel_y), 
        .paddle_x(paddle_x),
        .paddle_y(paddle_y),  
        .ball_rgb(ball_rgb),
        .ball_on(ball_on)
    );

    always@* begin
        if (~video_on)
            {r, g, b} = 12'h000;  
        else if (ball_on)
            {r, g, b} = ball_rgb;  
        else if (paddle_on)
            {r, g, b} = paddle_rgb;  
        else
            {r, g, b} = BACKGROUND_COLOR;  
    end

endmodule

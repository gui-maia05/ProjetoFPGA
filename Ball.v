module Ball (
    input wire clk, rstn, refr_tick,
    input wire [9:0] x, y, paddle_x, paddle_y,
    output wire [11:0] ball_rgb,
    output wire ball_on
);
    localparam MAX_X = 640;
    localparam MAX_Y = 480;
    
    localparam BALL_SIZE = 8;
    localparam BALL_COLOR = 12'hF00;
    
    integer ball_x = 320;  // Posição inicial
    integer ball_y = 240;
    integer ball_dx = 2;   // Velocidade X
    integer ball_dy = -2;  // Velocidade Y
    
    assign ball_rgb = BALL_COLOR;
    assign ball_on = (x > ball_x && x < ball_x + BALL_SIZE) &&
                     (y > ball_y && y < ball_y + BALL_SIZE);
    
    always @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            ball_x <= 320;
            ball_y <= 240;
            ball_dx <= 2;
            ball_dy <= -2;
        end else if (refr_tick) begin
            // Movimento da bola
            ball_x <= ball_x + ball_dx;
            ball_y <= ball_y + ball_dy;
            
            // Colisão com paredes
            if (ball_x <= 0 || ball_x >= (MAX_X - BALL_SIZE))
                ball_dx <= -ball_dx;
            
            if (ball_y <= 0)  // Bateu no topo
                ball_dy <= -ball_dy;
            
            // Colisão com a barra
            if (ball_y + BALL_SIZE >= paddle_y && 
                ball_x + BALL_SIZE >= paddle_x && 
                ball_x <= paddle_x + 100) begin
                ball_dy <= -ball_dy;
            end
        end
    end
endmodule

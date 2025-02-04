module Ball (
    input wire clk, rstn,
    input wire refr_tick, 
    input wire [9:0] paddle_y_l, paddle_y_r,
    output wire [11:0] ball_rgb,
    output wire ball_on,
    output reg [9:0] ball_x, ball_y
);
    // Constantes
    localparam BALL_SIZE = 8;
    localparam BALL_X_START = 320;
    localparam BALL_Y_START = 240;
    localparam BALL_COLOR = 12'hF00;
    localparam BALL_STEP = 2;
    
    localparam PADDLE_X_L = 20;
    localparam PADDLE_X_R = 600;

    reg ball_x_dir, ball_y_dir;  // 0 = esquerda/cima, 1 = direita/baixo

    // Atualizar posição da bola
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            ball_x <= BALL_X_START;
            ball_y <= BALL_Y_START;
            ball_x_dir <= 1;
            ball_y_dir <= 1;
        end 
        else if (refr_tick) begin
            // Movimento horizontal
            if (ball_x_dir)
                ball_x <= ball_x + BALL_STEP;
            else
                ball_x <= ball_x - BALL_STEP;

            // Movimento vertical
            if (ball_y_dir)
                ball_y <= ball_y + BALL_STEP;
            else
                ball_y <= ball_y - BALL_STEP;
        end
    end

    // Colisão com as bordas da tela
    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            ball_y_dir <= 1;
        else if (ball_y <= 0) 
            ball_y_dir <= 1;
        else if (ball_y >= 480 - BALL_SIZE) 
            ball_y_dir <= 0;
    end

    // Colisão com as raquetes
    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            ball_x_dir <= 1;
        else begin
            // Colisão com a raquete esquerda
            if (ball_x <= PADDLE_X_L + 10 && 
                ball_y >= paddle_y_l && 
                ball_y <= paddle_y_l + 50) 
                ball_x_dir <= 1;

            // Colisão com a raquete direita
            if (ball_x >= PADDLE_X_R - BALL_SIZE && 
                ball_y >= paddle_y_r && 
                ball_y <= paddle_y_r + 50) 
                ball_x_dir <= 0;
        end
    end

    // Reset da bola ao sair da tela
    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            ball_x <= BALL_X_START;
        else if (ball_x <= 0 || ball_x >= 640 - BALL_SIZE) begin
            ball_x <= BALL_X_START;
            ball_y <= BALL_Y_START;
            ball_x_dir <= ~ball_x_dir;
        end
    end

    // Desenhar a bola
    assign ball_rgb = BALL_COLOR;
    assign ball_on = (pixel_x >= ball_x) && (pixel_x < ball_x + BALL_SIZE) && (pixel_y >= ball_y) && (pixel_y < ball_y + BALL_SIZE);


endmodule

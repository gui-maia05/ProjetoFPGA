module Ball(
    input wire clk, rstn,
    input wire video_on, p_tick,
    input wire [9:0] pixel_x, pixel_y,
    input wire [9:0] paddle_x, paddle_y, paddle_height,  // Posição da raquete
    output reg [3:0] r, g, b
);

    // Definições da bola
    localparam BALL_SIZE = 8;
    localparam SCREEN_WIDTH = 640;
    localparam SCREEN_HEIGHT = 480;
    localparam BALL_COLOR = 12'hF00;  // Vermelho

    reg [9:0] ball_x_reg, ball_y_reg, ball_x_next, ball_y_next;
    reg ball_x_dir, ball_y_dir;  // 0 = esquerda/cima, 1 = direita/baixo

    // Atualização da posição da bola
    always @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            ball_x_reg <= SCREEN_WIDTH / 2;
            ball_y_reg <= SCREEN_HEIGHT / 2;
            ball_x_dir <= 0;  // Começa indo para a esquerda
            ball_y_dir <= 0;  // Começa indo para cima
        end else begin
            ball_x_reg <= ball_x_next;
            ball_y_reg <= ball_y_next;
        end
    end

    always @* begin
        // Movimento normal
        ball_x_next = ball_x_reg + (ball_x_dir ? 2 : -2);
        ball_y_next = ball_y_reg + (ball_y_dir ? 2 : -2);

        // Rebote na parede superior/inferior
        if (ball_y_reg <= 0)
            ball_y_dir = 1;  // Muda para baixo
        else if (ball_y_reg + BALL_SIZE >= SCREEN_HEIGHT)
            ball_y_dir = 0;  // Muda para cima

        // Rebote na raquete
        if ((ball_x_reg <= paddle_x + 10) &&   // Toca a raquete
            (ball_y_reg + BALL_SIZE >= paddle_y) &&
            (ball_y_reg <= paddle_y + paddle_height)) begin
            ball_x_dir = 1;  // Muda para a direita
        end

        // Se a bola sair completamente da tela pela esquerda (perdeu)
        if (ball_x_reg <= 0)
            ball_x_next = SCREEN_WIDTH / 2;  // Reseta posição

        // Se a bola sair pela direita, apenas continua o jogo
        if (ball_x_reg + BALL_SIZE >= SCREEN_WIDTH)
            ball_x_dir = 0;  // Muda para a esquerda
    end

    // Desenha a bola
    wire ball_on = (pixel_x >= ball_x_reg) && (pixel_x < ball_x_reg + BALL_SIZE) &&
                   (pixel_y >= ball_y_reg) && (pixel_y < ball_y_reg + BALL_SIZE);

    always @* begin
        if (~video_on)
            {r, g, b} = 12'h000;
        else if (ball_on)
            {r, g, b} = BALL_COLOR;
    end

endmodule

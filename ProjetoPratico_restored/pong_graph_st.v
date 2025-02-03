module pong_graph_st (
    input wire video_on,
    input wire [9:0] pix_x, pix_y,
    output reg [2:0] graph_rgb
);

// Constantes para as coordenadas do display (640x480)
localparam MAX_X = 640;
localparam MAX_Y = 480;

// Definição da parede (borda esquerda)
localparam WALL_X_L = 32;
localparam WALL_X_R = 35;

// Definição da barra (paddle) direita
localparam BAR_X_L = 600;
localparam BAR_X_R = 603;
localparam BAR_Y_SIZE = 72;
localparam BAR_Y_T = MAX_Y / 2 - BAR_Y_SIZE / 2;  // Posição inicial no meio da tela
localparam BAR_Y_B = BAR_Y_T + BAR_Y_SIZE - 1;

// Definição da bola
localparam BALL_SIZE = 8;
localparam BALL_X_L = 580;
localparam BALL_X_R = BALL_X_L + BALL_SIZE - 1;
localparam BALL_Y_T = 238;
localparam BALL_Y_B = BALL_Y_T + BALL_SIZE - 1;

// Sinais para ativação dos objetos
wire wall_on, bar_on, sq_ball_on;
wire [2:0] wall_rgb, bar_rgb, ball_rgb;

// Lógica para desenhar a parede esquerda
assign wall_on = (WALL_X_L <= pix_x) && (pix_x <= WALL_X_R);
assign wall_rgb = 3'b001;  // Azul

// Lógica para desenhar a barra direita (paddle)
assign bar_on = (BAR_X_L <= pix_x) && (pix_x <= BAR_X_R) &&
                (BAR_Y_T <= pix_y) && (pix_y <= BAR_Y_B);
assign bar_rgb = 3'b010;  // Verde

// Lógica para desenhar a bola
assign sq_ball_on = (BALL_X_L <= pix_x) && (pix_x <= BALL_X_R) &&
                    (BALL_Y_T <= pix_y) && (pix_y <= BALL_Y_B);
assign ball_rgb = 3'b100;  // Vermelho

// Multiplexação dos sinais RGB (define a cor do pixel)
always @* begin
    if (~video_on)
        graph_rgb = 3'b000;  // Tela preta quando o vídeo está desligado
    else if (wall_on)
        graph_rgb = wall_rgb;  // Azul para a parede
    else if (bar_on)
        graph_rgb = bar_rgb;  // Verde para a barra
    else if (sq_ball_on)
        graph_rgb = ball_rgb;  // Vermelho para a bola
    else
        graph_rgb = 3'b110;  // Amarelo como fundo padrão
end

endmodule

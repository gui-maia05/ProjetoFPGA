module pong_graph_animate
(
    input wire clk, reset,
    input wire video_on,
    input wire [1:0] btn,
    input wire [9:0] pix_x, pix_y,
    output reg [2:0] graph_rgb
);

// Declaração de constantes e sinais
// Coordenadas x, y (0,0) até (639, 479)
localparam MAX_X = 640;
localparam MAX_Y = 480;
wire refr_tick;

// Paredes verticais como limite
// Limite esquerdo e direito da parede
localparam WALL_X_L = 32;
localparam WALL_X_R = 35;

// Barra vertical à direita
// Limite esquerdo e direito da barra
localparam BAR_X_L = 600;
localparam BAR_X_R = 603;
// Limite superior e inferior da barra
wire [9:0] bar_y_t, bar_y_b;
localparam BAR_Y_SIZE = 72;
// Registro para rastrear o limite superior da barra (a posição x é fixa)
reg [9:0] bar_y_reg, bar_y_next;
// Velocidade de movimento da barra quando o botão é pressionado
localparam BAR_V = 4;

// Bola quadrada
localparam BALL_SIZE = 8;
// Limite esquerdo e direito da bola
wire [9:0] ball_x_l, ball_x_r;
// Limite superior e inferior da bola
wire [9:0] ball_y_t, ball_y_b;
// Registro para rastrear a posição da bola (x e y)
reg [9:0] ball_x_reg, ball_y_reg;
wire [9:0] ball_x_next, ball_y_next;
// Registro para rastrear a velocidade da bola
reg [9:0] x_delta_reg, x_delta_next;
reg [9:0] y_delta_reg, y_delta_next;
// A velocidade da bola pode ser positiva ou negativa
localparam BALL_V_P = 2;
localparam BALL_V_N = -2;

// Imagem da bola redonda
wire [2:0] rom_addr, rom_col;
reg [7:0] rom_data;
wire rom_bit;
// Sinais de saída do objeto
wire wall_on, bar_on, sq_ball_on, rd_ball_on;
wire [2:0] wall_rgb, bar_rgb, ball_rgb;

// Imagem da bola redonda - ROM
always @*
case (rom_addr)
    3'h0: rom_data = 8'b00111100;
    3'h1: rom_data = 8'b01111110; 
    3'h2: rom_data = 8'b11111111; 
    3'h3: rom_data = 8'b11111111; 
    3'h4: rom_data = 8'b11111111; 
    3'h5: rom_data = 8'b11111111; 
    3'h6: rom_data = 8'b01111110; 
    3'h7: rom_data = 8'b00111100; 
endcase

// Registros
always @(posedge clk, posedge reset)
if (reset)
begin
    bar_y_reg <= 0;
    ball_x_reg <= 0;
    ball_y_reg <= 0;
    x_delta_reg <= 10'h004;
    y_delta_reg <= 10'h004;
end
else
begin
    bar_y_reg <= bar_y_next;
    ball_x_reg <= ball_x_next;
    ball_y_reg <= ball_y_next;
    x_delta_reg <= x_delta_next;
    y_delta_reg <= y_delta_next;
end

// refr_tick: Tique do relógio - sinal assertado no início do v-sync
// Ou seja, quando a tela for atualizada (60Hz)
assign refr_tick = (pix_y == 481) && (pix_x == 0);

// (parede) faixa vertical esquerda
// Pixel dentro da parede
assign wall_on = (WALL_X_L <= pix_x) && (pix_x <= WALL_X_R);
// Saída RGB da parede
assign wall_rgb = 3'b001; // azul

// Barra vertical direita
assign bar_y_t = bar_y_reg;
assign bar_y_b = bar_y_t + BAR_Y_SIZE - 1;
// Pixel dentro da barra
assign bar_on = (BAR_X_L <= pix_x) && (pix_x <= BAR_X_R) &&
                (bar_y_t <= pix_y) && (pix_y <= bar_y_b);
// Saída RGB da barra
assign bar_rgb = 3'b010; // verde

// Nova posição da barra
always @*
begin
    bar_y_next = bar_y_reg; // sem movimento
    if (refr_tick)
        if (btn[1] && (bar_y_b < (MAX_Y-1 - BAR_V)))
            bar_y_next = bar_y_reg + BAR_V; // mover para baixo
        else if (btn[0] && (bar_y_t > BAR_V))
            bar_y_next = bar_y_reg - BAR_V; // mover para cima
end

// Bola quadrada
// Limites
assign ball_x_l = ball_x_reg;
assign ball_y_t = ball_y_reg;
assign ball_x_r = ball_x_l + BALL_SIZE - 1;
assign ball_y_b = ball_y_t + BALL_SIZE - 1;
// Pixel dentro da bola
assign sq_ball_on = (ball_x_l <= pix_x) && (pix_x <= ball_x_r) &&
                    (ball_y_t <= pix_y) && (pix_y <= ball_y_b);
// Mapeia a localização atual do pixel para o endereço da ROM / coluna
assign rom_addr = pix_y[2:0] - ball_y_t[2:0];
assign rom_col = pix_x[2:0] - ball_x_l[2:0];
assign rom_bit = rom_data[rom_col];
// Pixel dentro da bola
assign rd_ball_on = sq_ball_on & rom_bit;
// Saída RGB da bola
assign ball_rgb = 3'b100; // vermelho

// Nova posição da bola
assign ball_x_next = (refr_tick) ? ball_x_reg + x_delta_reg : ball_x_reg;
assign ball_y_next = (refr_tick) ? ball_y_reg + y_delta_reg : ball_y_reg;

// Nova velocidade da bola
always @*
begin
    y_delta_next = y_delta_reg;
    if (ball_y_t < 1) // atingiu o topo
        y_delta_next = BALL_V_P;
    else if (ball_y_b > (MAX_Y-1)) // atingiu o fundo
        y_delta_next = BALL_V_N;
    else if (ball_x_l <= WALL_X_R) // atingiu a parede
        x_delta_next = BALL_V_P; // rebater
    else if ((BAR_X_L <= ball_x_r) && (ball_x_r <= BAR_X_R) &&
             (bar_y_t <= ball_y_b) && (ball_y_t <= bar_y_b)) // atingiu a barra
        x_delta_next = BALL_V_N;
end

// Multiplexação de cores RGB
always @*
if (video_on)
    graph_rgb = 3'b000; // tela preta
else if (wall_on)
    graph_rgb = wall_rgb;
else if (bar_on)
    graph_rgb = bar_rgb;
else if (rd_ball_on)
    graph_rgb = ball_rgb;
else
    graph_rgb = 3'b110; // fundo amarelo
endmodule

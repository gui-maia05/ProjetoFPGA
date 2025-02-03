module bitmap_gen
(
    input wire clk, reset,
    input wire video_on,
    input wire [1:0] btn,
    input wire [9:0] pix_x, pix_y,
    output reg [2:0] bitmap_rgb
);

// Declaração de constantes e sinais
wire refr_tick, load_tick;

// Vídeo RAM
wire we;
wire [13:0] addr_r, addr_w;
wire [2:0] din, dout;

// Localização e velocidade do ponto
localparam MAX_X = 128;
localparam MAX_Y = 128;
localparam DOT_V_P = 1;
localparam DOT_V_N = -1;

// Registradores para controlar a posição do ponto
reg [6:0] dot_x_reg, dot_y_reg;
wire [6:0] dot_x_next, dot_y_next;

// Registradores para controlar a velocidade do ponto
reg [6:0] v_x_reg, v_y_reg;
wire [6:0] v_x_next, v_y_next;

// Sinais de saída do objeto
wire bitmap_on;
wire [2:0] bitmap_rgb_signal;

// Instanciação do circuito de debounce para o botão
debounce deb_unit
(
    .clk(clk), .reset(reset), .sw(btn[0]),
    .db_level(load_tick), .db_tick(load_tick)
);

// Instanciação da memória RAM de vídeo de dois portos
xilinx_dual_port_ram_sync
#( .ADDR_WIDTH(14), .DATA_WIDTH(3) ) video_ram
(
    .clk(clk), .we(we), .addr_a(addr_w), .addr_b(addr_r),
    .din_a(din), .dout_a(), .dout_b(dout)
);

// Interface de vídeo RAM
assign addr_w = {dot_y_reg, dot_x_reg};
assign addr_r = {pix_y[6:0], pix_x[6:0]};
assign we = load_tick;
assign din = btn[1:0];
assign bitmap_rgb_signal = dout;

// Registradores para a posição do ponto
always @(posedge clk or posedge reset)
begin
    if (reset)
    begin
        dot_x_reg <= 0;
        dot_y_reg <= 0;
        v_x_reg <= DOT_V_P;
        v_y_reg <= DOT_V_P;
    end
    else
    begin
        dot_x_reg <= dot_x_next;
        dot_y_reg <= dot_y_next;
        v_x_reg <= v_x_next;
        v_y_reg <= v_y_next;
    end
end

// refr_tick: Sinal assertado no início do v-sync
assign refr_tick = (pix_y == 481) && (pix_x == 0);

// Localização do ponto
assign bitmap_on = (pix_x <= 127) && (pix_y <= 127);

// Atualização da posição do ponto
assign dot_x_next = (load_tick) ? pix_x[6:0] : (refr_tick) ? dot_x_reg + v_x_reg : dot_x_reg;
assign dot_y_next = (load_tick) ? pix_y[6:0] : (refr_tick) ? dot_y_reg + v_y_reg : dot_y_reg;

// Atualização da velocidade do ponto (reage às bordas da tela)
assign v_x_next = (dot_x_reg == 0) ? DOT_V_P :
                  (dot_x_reg == (MAX_X - 2)) ? DOT_V_N : v_x_reg;

assign v_y_next = (dot_y_reg == 0) ? DOT_V_P :
                  (dot_y_reg == (MAX_Y - 2)) ? DOT_V_N : v_y_reg;

// Multiplexação de cores RGB
always @*
begin
    if (~video_on)
        bitmap_rgb = 3'b000; // Tela apagada
    else if (bitmap_on)
        bitmap_rgb = bitmap_rgb_signal; // Cor do bitmap
    else
        bitmap_rgb = 3'b110; // Fundo amarelo
end

endmodule

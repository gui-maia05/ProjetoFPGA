module pong_top_an (
    input wire clk, reset,          // Entrada de clock e reset
    input wire [1:0] btn,           // Entrada para botões de controle (provavelmente para movimentar a barra)
    output wire hsync, vsync,       // Saídas para os sinais de sincronização horizontal e vertical
    output wire [2:0] rgb          // Saída para a cor RGB (para exibição na tela)
);

// Declaração de sinais internos
wire [9:0] pixel_x, pixel_y;      // Coordenadas X e Y do pixel na tela
wire video_on, pixel_tick;        // Sinal para saber se o vídeo está ligado e sinal de contagem de pixels
reg [2:0] rgb_reg;                // Registrador para armazenar a cor RGB atual
wire [2:0] rgb_next;              // Cor RGB próxima a ser exibida

// Instanciação do módulo de sincronização VGA
vga-sync vsync_unit 
	(.clk(clk), .reset(reset), .hsync(hsync), .vsync(vsync),
    .video_on(video_on), .p-tick(pixel_tick), 
	 .pixel_x(pixel_x), .pixel_y(pixel_y)
);

// Instanciação do módulo de animação gráfica do Pong
pong-graph-animate pong-graph-an-unit (
    .clk(clk), .reset(reset), .btn(btn), 
    .video_on(video_on), .pix_x(pixel_x),
	 .pix_y(pixel_y), .graph_rgb(rgb_next)
);

// Atualização da cor RGB
always @(posedge clk) 
    if (pixel_tick) 
        rgb_reg <= rgb_next;  // Atualiza o registrador de cor com a próxima cor RGB

// Saída da cor RGB
assign rgb = rgb_reg;

endmodule

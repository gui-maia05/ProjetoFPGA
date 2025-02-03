module pong_top_st (
    input wire clk, reset,
    output wire hsync, vsync,
    output wire [2:0] rgb
);

// Declaração de sinais
wire [9:0] pixel_x, pixel_y;
wire video_on, pixel_tick;
reg [2:0] rgb_reg;
wire [2:0] rgb_next;

// Instanciação do circuito de sincronização VGA
vga_sync vsync_unit (
    .clk(clk),
    .reset(reset),
    .hsync(hsync),
    .vsync(vsync),
    .video_on(video_on),
    .p_tick(pixel_tick),
    .pixel_x(pixel_x),
    .pixel_y(pixel_y)
);

// Instanciação do gerador gráfico do Pong
pong_graph_st pong_grf_unit (
    .video_on(video_on),
    .pix_x(pixel_x),
    .pix_y(pixel_y),
    .graph_rgb(rgb_next)
);

// Buffer para sincronizar o RGB com o VGA
always @(posedge clk)
    if (pixel_tick)
        rgb_reg <= rgb_next;

// Saída final do RGB
assign rgb = rgb_reg;

endmodule

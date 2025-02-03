module dot_top
(
    input wire clk, reset,
    input wire [1:0] btn,
    input wire [2:0] sw,
    output wire hsync, vsync,
    output wire [2:0] rgb
);

// Declaração de sinais
wire [9:0] pixel_x, pixel_y;
wire video_on, pixel_tick;
reg [2:0] rgb_reg;
wire [2:0] rgb_next;

// Corpo principal
// Instancia o circuito de sincronização VGA
vga_sync vsync_unit
(
    .clk(clk),
    .reset(reset),
    .hsync(hsync),
    .vsync(vsync),
    .video_on(video_on),
    .p_tick(pixel_tick),
    .pixel_x(pixel_x),
    .pixel_y(pixel_y)
);

// Instancia o gerador gráfico com bitmap
bitmap_gen bitmap_unit
(
    .clk(clk),
    .reset(reset),
    .btn(btn),
    .sw(sw),
    .video_on(video_on),
    .pix_x(pixel_x),
    .pix_y(pixel_y),
    .bit_rgb(rgb_next)
);

// Buffer de RGB
always @(posedge clk)
    if (pixel_tick)
        rgb_reg <= rgb_next;

// Saída
assign rgb = rgb_reg;

endmodule

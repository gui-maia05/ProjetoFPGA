module PixelGen(
    input wire clk, rstn,
    input wire video_on, p_tick,
    input wire right_k, left_k,
    input wire [9:0] pixel_x, pixel_y,
    output reg [3:0] r, g, b
);

    localparam BACKGROUND_COLOR = 12'h000;

    reg [3:0] r_reg, g_reg, b_reg;
    wire [3:0] square_control;
    wire [11:0] square_rgb;
    wire square_on;
    wire refr_tick;
    
    // refr_tick: 1-clock tick asserted at start of v-sync
    //            i.e., when the screen is refreshed (60 Hz)
    assign refr_tick = (pixel_y == 481) && (pixel_x == 0);
    
    // Instancia o módulo da raquete (Square)
    Square sq (.clk(clk), 
                .rstn(rstn), 
                .refr_tick(refr_tick),
                .turn_r(right_k), 
                .turn_l(left_k),
                .y(pixel_y), 
                .x(pixel_x), 
                .square_rgb(square_rgb),
                .square_on(square_on));

    // Aqui deve ser adicionado a lógica para a bola
    // Exemplo simplificado de controle de bola
    wire ball_on; // Controle da bola (detectar se a bola está em um pixel)
    wire [11:0] ball_rgb; // Cor da bola

    // Lógica para a bola (você precisa ajustar isso conforme a implementação da bola)
    Ball ball(
        .clk(clk),
        .rstn(rstn),
        .refr_tick(refr_tick),
        .x(pixel_x),
        .y(pixel_y),
        .ball_rgb(ball_rgb),
        .ball_on(ball_on)
    );

    // Lógica de output do RGB
    always @* begin
        if (~video_on)
            {r, g, b} = 12'h000; // Preto fora da área visível
        else if (ball_on)
            {r, g, b} = ball_rgb; // Desenha a bola
        else if (square_on)
            {r, g, b} = square_rgb; // Desenha a raquete
        else
            {r, g, b} = BACKGROUND_COLOR; // Cor de fundo
    end

endmodule

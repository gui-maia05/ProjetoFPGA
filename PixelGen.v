module PixelGen(
    input wire clk, rstn,
    input wire video_on, p_tick,
    input wire [1:0] paddle_control,  // Controle da raquete
    input wire [9:0] pixel_x, pixel_y,
    output reg [3:0] r, g, b
);

    localparam BACKGROUND_COLOR = 12'h000;
    localparam PADDLE_COLOR = 12'h0F0;  // Verde para a raquete

    // Definição do tamanho e posição da raquete
    localparam PADDLE_X = 20;
    localparam PADDLE_WIDTH = 10;
    localparam PADDLE_HEIGHT = 50;
    localparam SCREEN_HEIGHT = 480;

    reg [9:0] paddle_y_reg, paddle_y_next;

    // Atualização da posição da raquete
    always @(posedge clk, negedge rstn) begin
        if (!rstn)
            paddle_y_reg <= (SCREEN_HEIGHT - PADDLE_HEIGHT) / 2;  // Centraliza no início
        else
            paddle_y_reg <= paddle_y_next;
    end

    always @* begin
        paddle_y_next = paddle_y_reg;  // Mantém a posição se não houver input

        if (paddle_control[0] && paddle_y_reg > 0)
            paddle_y_next = paddle_y_reg - 5;  // Move para cima
        else if (paddle_control[1] && paddle_y_reg < (SCREEN_HEIGHT - PADDLE_HEIGHT))
            paddle_y_next = paddle_y_reg + 5;  // Move para baixo
    end

    // Verifica se o pixel atual pertence à raquete
    wire paddle_on = (pixel_x >= PADDLE_X && pixel_x < (PADDLE_X + PADDLE_WIDTH)) &&
                     (pixel_y >= paddle_y_reg && pixel_y < (paddle_y_reg + PADDLE_HEIGHT));

    // Sinais da bola
    wire [3:0] ball_r, ball_g, ball_b;
    wire ball_on;

    // Instância da bola
    Ball ball_unit (
        .clk(clk),
        .rstn(rstn),
        .video_on(video_on),
        .p_tick(p_tick),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .paddle_x(PADDLE_X),
        .paddle_y(paddle_y_reg),
        .paddle_height(PADDLE_HEIGHT),
        .r(ball_r),
        .g(ball_g),
        .b(ball_b)
    );

    // Saída de cores
    always @* begin
        if (~video_on)
            {r, g, b} = 12'h000;
        else if (paddle_on)
            {r, g, b} = PADDLE_COLOR;
        else if (ball_on)
            {r, g, b} = {ball_r, ball_g, ball_b};  // Cor da bola
        else
            {r, g, b} = BACKGROUND_COLOR;
    end

endmodule

module Square (
    input wire clk, rstn, 
    input wire refr_tick,
    input wire turn_r, turn_l,
    input wire [9:0] x, y,  // Posição da raquete do jogador
    output wire [11:0] square_rgb,
    output wire square_on
);
    // Definições de parâmetros
    localparam MAX_X = 640;
    localparam MAX_Y = 480;
    
    // Atributos da raquete
    localparam SQUARE_SIZE = 25;
    localparam SQUARE_X = 100;
    localparam SQUARE_Y = 150;
    localparam SQUARE_COLOR = 12'h5AF;
    localparam SQUARE_STEP = 1;
    
    integer x_count;
    integer y_count;
    
    wire x_updown, x_en;

    assign square_rgb = SQUARE_COLOR;
    assign square_on = (pixel_x >= x_count) && (pixel_x < x_count + SQUARE_SIZE) && (pixel_y >= y_count) && (pixel_y < y_count + SQUARE_SIZE);

    
    // Lógica para definir a direção da movimentação (somente horizontal)
    always @* begin
        // Inicialmente, desativa os sinais de movimento
        x_updown = 0;
        x_en = 0;

        // Movimento horizontal
        if (turn_r) begin
            x_updown = 1; // Direção direita
            x_en = 1;     // Ativa o movimento
        end else if (turn_l) begin
            x_updown = 0; // Direção esquerda
            x_en = 1;     // Ativa o movimento
        end
    end

    // Controla o movimento horizontal da raquete
    always @(posedge clk, negedge rstn) begin
        if (rstn == 0)
            x_count <= SQUARE_X;
        else if (x_en == 1 && refr_tick == 1'b1)
            if (x_updown == 1)
                x_count <= (x_count < MAX_X - 1 - SQUARE_STEP) ? x_count + SQUARE_STEP : 0;
            else if (x_updown == 0)
                x_count <= (x_count > SQUARE_STEP) ? x_count - SQUARE_STEP : MAX_X - 1;
    end

    // Controle vertical da raquete (se necessário, para fins de exibição ou interação com a bola)
    always @(posedge clk, negedge rstn) begin
        if (rstn == 0)
            y_count <= SQUARE_Y;
        else
            y_count <= y; // Mantém a posição y da raquete igual à posição do jogador
    end
endmodule

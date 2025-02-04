module Paddle (
    input wire clk, rstn,
    input wire up, down,  // Controles da raquete do jogador
    input wire refr_tick, // Atualiza a posição no refresh da tela
    output reg [9:0] paddle_y // Posição da raquete em Y
);

    localparam PADDLE_HEIGHT = 50;
    localparam PADDLE_STEP = 4;
    localparam MAX_Y = 480 - PADDLE_HEIGHT;

    always @(posedge clk, negedge rstn) begin
        if (!rstn)
            paddle_y <= (MAX_Y / 2); // Inicializa no meio da tela
        else if (refr_tick) begin
            if (up && paddle_y > PADDLE_STEP)
                paddle_y <= paddle_y - PADDLE_STEP;
            else if (down && paddle_y < MAX_Y - PADDLE_STEP)
                paddle_y <= paddle_y + PADDLE_STEP;
        end
    end

endmodule

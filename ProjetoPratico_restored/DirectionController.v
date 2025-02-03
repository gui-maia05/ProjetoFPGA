module DirectionController 
(
    input wire clk, 
    input wire reset, 
    input wire [1:0] btn,      // Botões de controle
    input wire [9:0] max_x,    // Largura máxima da tela
    input wire [9:0] max_y,    // Altura máxima da tela
    output reg [9:0] bar_x,    // Posição X da barra
    output reg [9:0] bar_y     // Posição Y da barra
);

    // Parâmetros
    localparam BAR_V = 1; // Velocidade da barra (pode ser ajustado)

    // Registradores de posição das barras
    reg [9:0] bar_x_reg, bar_y_reg;
    wire [9:0] bar_x_next, bar_y_next;

    // Lógica para controle de movimento da barra
    always @ (posedge clk or posedge reset) begin
        if (reset) begin
            bar_x_reg <= 0;    // Reseta posição da barra
            bar_y_reg <= max_y / 2; // Posição inicial no centro vertical
        end else begin
            bar_x_reg <= bar_x_next;   // Atualiza posição da barra
            bar_y_reg <= bar_y_next;
        end
    end

    // Lógica para movimentar a barra dependendo dos botões pressionados
    assign bar_x_next = (btn[0] && bar_x_reg > 0) ? bar_x_reg - BAR_V :  // Movimento para a esquerda
                        (btn[1] && bar_x_reg < max_x) ? bar_x_reg + BAR_V : bar_x_reg;  // Movimento para a direita

    assign bar_y_next = (btn[0] && bar_y_reg > 0) ? bar_y_reg - BAR_V :  // Movimento para cima
                        (btn[1] && bar_y_reg < max_y) ? bar_y_reg + BAR_V : bar_y_reg;  // Movimento para baixo

    // Atribui as saídas para a posição da barra
    assign bar_x = bar_x_reg;
    assign bar_y = bar_y_reg;

endmodule

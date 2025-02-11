module Paddle (
    input wire clk, rstn, 
    input wire refr_tick,
    input wire turn_r, turn_l,
    input wire [9:0] x, y,
    output wire [11:0] paddle_rgb,
    output wire paddle_on,
    output wire [9:0] paddle_x,  // Adicionando saída para posição X
    output wire [9:0] paddle_y   // Adicionando saída para posição Y
);
    localparam MAX_X = 640;
    localparam MAX_Y = 480;
    
    // paddle attributes
    localparam PADDLE_WIDTH = 100;  
    localparam PADDLE_HEIGHT = 10;  
    localparam PADDLE_X = 290;      
    localparam PADDLE_Y = 450;      
    localparam PADDLE_COLOR = 12'h5AF;
    localparam PADDLE_STEP = 2;    

    reg [9:0] x_count; // Alterado para reg de 9 bits
    reg [9:0] y_count;

    wire x_updown, x_en, y_updown, y_en;
    
    assign paddle_rgb = PADDLE_COLOR;
    assign paddle_on = (x_count < x) && (x < x_count + PADDLE_WIDTH) && 
                       (y_count < y) && (y < y_count + PADDLE_HEIGHT);

    // Saída das coordenadas
    assign paddle_x = x_count;
    assign paddle_y = y_count;
    
    always @(posedge clk, negedge rstn) begin
        if (!rstn)
            x_count <= PADDLE_X;
        else if (x_en && refr_tick) begin
            if (x_updown) 
                x_count <= (x_count < MAX_X - PADDLE_WIDTH - PADDLE_STEP) ? x_count + PADDLE_STEP : MAX_X - PADDLE_WIDTH;
            else 
                x_count <= (x_count > PADDLE_STEP) ? x_count - PADDLE_STEP : 0;
        end
    end

    always @(posedge clk, negedge rstn) begin
        if (!rstn)
            y_count <= PADDLE_Y;
    end

    DirectionController direction_ctrl (
        .clk(clk), 
        .rstn(rstn), 
        .turn_right(turn_r), 
        .turn_left(turn_l), 
        .data_out({y_updown,y_en,x_updown,x_en})
    );
endmodule

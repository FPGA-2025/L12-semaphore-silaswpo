module Semaphore #(
    parameter CLK_FREQ = 100_000_000  // Frequência do clock
) (
    input wire clk,         // Clock de entrada
    input wire rst_n,       // Reset ativo baixo
    input wire pedestrian,  // Botão de pedestre (input)
    output wire green,      // Sinal verde
    output wire yellow,     // Sinal amarelo
    output wire red         // Sinal vermelho
);

    // Definindo os estados da máquina de estados
    localparam [2:0]
        RED    = 3'b100,  // Estado vermelho
        YELLOW = 3'b010,  // Estado amarelo
        GREEN  = 3'b001;  // Estado verde

    // Definindo o tempo para cada sinal (em ciclos de clock)
    localparam integer
        RED_TIME    = CLK_FREQ * 5,    // Tempo do sinal vermelho (5 segundos)
        GREEN_TIME  = CLK_FREQ * 7,    // Tempo do sinal verde (7 segundos)
        YELLOW_TIME = CLK_FREQ / 2;    // Tempo do sinal amarelo (0.5 segundos)

    reg [2:0] state, next_state;    // Registradores para armazenar o estado atual e o próximo estado
    reg [31:0] counter;             // Contador para controlar o tempo

    // Máquina de estados sequencial
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= RED;   // Reset: começa no estado vermelho
            counter <= 32'd0; // Contador reiniciado
        end else begin
            state <= next_state;  // Atualiza o estado atual

            if (state != next_state)  // Se houver mudança de estado, reinicia o contador
                counter <= 32'd0;
            else
                counter <= counter + 1;  // Caso contrário, incrementa o contador
        end
    end

    // Lógica de transição entre estados
    always @(*) begin
        case (state)
            RED: begin
                if (counter >= RED_TIME - 1)  // Se o tempo do vermelho acabou
                    next_state = GREEN;      // Vai para o estado verde
                else
                    next_state = RED;        // Continua no estado vermelho
            end

            GREEN: begin
                if (pedestrian)            // Se o pedestre apertou o botão
                    next_state = YELLOW;   // Vai para o estado amarelo imediatamente
                else if (counter >= GREEN_TIME - 1)  // Se o tempo do verde acabou
                    next_state = YELLOW;   // Vai para o estado amarelo
                else
                    next_state = GREEN;    // Continua no estado verde
            end

            YELLOW: begin
                if (counter >= YELLOW_TIME - 1)  // Se o tempo do amarelo acabou
                    next_state = RED;         // Volta para o estado vermelho
                else
                    next_state = YELLOW;      // Continua no estado amarelo
            end

            default: next_state = RED;  // Caso de erro, volta para o estado vermelho
        endcase
    end

    // Controle das saídas de sinal (vermelho, amarelo e verde)
    assign red    = (state == RED);    // Se o estado atual for vermelho, ativa o sinal vermelho
    assign yellow = (state == YELLOW); // Se o estado atual for amarelo, ativa o sinal amarelo
    assign green  = (state == GREEN);  // Se o estado atual for verde, ativa o sinal verde

endmodule
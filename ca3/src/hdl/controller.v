module controller (
    input wire clk,        
    input wire rst, 

    input wire start,     

    input wire cntr_dual_co,
    input wire end_shift1,       
    input wire end_shift2,       

    // counters
    output wire cntr_3bit_en,
    output wire cntr_dual_en,
    output wire cntr_dual_end,
    output wire load_shift1,
    output wire load_shift2,
    output wire en_shift1,
    output wire en_shift2,
    output wire sel_sh1,
    output wire sel_insh2,
    output wire sel_sh2,
    output wire done
);

    // State encoding
    parameter IDLE         = 7'b0000001; 
    parameter START        = 7'b0000010;
    parameter LOAD         = 7'b0000100; 
    parameter SHIFT        = 7'b0001000; 
    parameter LOAD_RESULT  = 7'b0010000; 
    parameter SHIFT_RESULT = 7'b0100000; 
    parameter DONE         = 7'b1000000;

    reg [6:0] ns;
    wire [6:0] ps;
    reg state_shift;

    always @(*) begin
        ns = ps;
        state_shift = 1'b0;
        case (ps)
            IDLE: begin
                ns = start ? START : IDLE;
                state_shift = start;
            end

            START: begin
                ns = start ? START : LOAD;
                state_shift = (start==1'b0);
            end

            LOAD: begin
                ns = SHIFT;
                state_shift = 1'b1;
            end

            SHIFT: begin
                ns = (end_shift1 || end_shift2) ? SHIFT : LOAD_RESULT;
                state_shift = (end_shift1 || end_shift2) == 1'b0;
            end

            LOAD_RESULT: begin
                ns = SHIFT_RESULT;
                state_shift = 1'b1;
            end

            SHIFT_RESULT: begin
                ns = cntr_dual_co ? DONE : SHIFT_RESULT;
                state_shift = cntr_dual_co;
            end

            DONE: begin
                ns = IDLE;
                state_shift = 1'b1;
            end

        endcase
    end
        
    // always @(*) begin
    //     cntr_3bit_en = 0;
    //     cntr_dual_en = 0;
    //     cntr_dual_end = 0;
    //     load_shift1 = 0;
    //     load_shift2 = 0;
    //     en_shift1 = 0;
    //     en_shift2 = 0;
    //     sel_sh1 = 0;
    //     sel_insh2 = 0;
    //     sel_sh2 = 0;
    //     done = 0;

    //     case (ps)
    //         LOAD: begin
    //             load_shift1 = 1;
    //             load_shift2 = 1;
    //         end

    //         SHIFT: begin
    //             cntr_3bit_en = 1;
    //             cntr_dual_en = 1;
    //         end

    //         LOAD_RESULT: begin
    //             sel_sh1 = 1;
    //             sel_sh2 = 1;
    //             load_shift1 = 1;
    //             load_shift2 = 1;
    //         end

    //         SHIFT_RESULT: begin
    //             cntr_dual_end = 1;
    //             en_shift1 = 1;
    //             en_shift2 = 1;
    //             sel_insh2 = 1;
    //         end

    //         DONE: begin
    //             done = 1;
    //         end
    //     endcase
    // end

    // LOAD
    wire loads_states;
    or_mod or_loads (
        .a(p[2]),
        .b(p[4]),
        .y(loads_states)
    );
    assign load_shift1 = loads_states;
    assign load_shift2 = loads_states;

    // SHIFT
    assign cntr_3bit_en = p[3];
    assign cntr_dual_en = p[3];

    // LOAD_RESULT
    assign sel_sh1 = p[4];
    assign sel_sh2 = p[4];

    // SHIFT_RESULT
    assign cntr_dual_end = p[5];
    assign en_shift1 = p[5];
    assign en_shift2 = p[5];
    assign sel_insh2 = p[5];

    // DONE
    assign done = p[6];

    ShiftRegister #(
        .WIDTH(7)
    ) sh1 (
        .clk(clk),
        .rst(1'b0),
        .load(rst),
        .shift_en(state_shift),
        .in(IDLE),
        .in_sh(ps[6]),
        .out(ps)
    );

endmodule
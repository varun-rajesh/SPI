module spi_interface_tb;

    localparam WIDTH = 32;
    logic               sys_clk;
    logic               sys_reset_n;
    logic               spi_clk;
    logic               spi_mosi;
    logic               spi_miso;
    logic               spi_cs_n;
    logic[WIDTH-1:0]    mosi_buffer;
    logic               mosi_buffer_valid;

    logic internal_spi_clk;
    assign spi_clk = internal_spi_clk & ~spi_cs_n;

    logic[WIDTH-1:0] message;

    initial begin
        sys_clk = 1'b0;
        sys_reset_n = 1'b0;

        sys_reset_n <= 1'b1;
        forever #5 sys_clk <= ~sys_clk;
    end

    initial begin
        internal_spi_clk = 1'b0;
        forever #1000 internal_spi_clk <= ~internal_spi_clk;
    end

    initial begin
        repeat (10) @ (posedge sys_clk);

        message = 32'hdeadbeef;

        @ (posedge sys_clk);
        @ (negedge internal_spi_clk);
        #1;

        spi_cs_n = 1'b0;
        spi_mosi = message[31];
        
        for (integer i = 30; i >= 0; i--) begin
            @ (negedge internal_spi_clk);
            spi_mosi <= message[i];
        end

        @ (negedge internal_spi_clk);
        spi_mosi <= 0;
        spi_cs_n = 1'b1;

        repeat (2) @ (negedge internal_spi_clk);

        $stop;
        $finish;
    end

    spi_interface #(WIDTH) dut (.*);

endmodule : spi_interface_tb
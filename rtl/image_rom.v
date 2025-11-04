
module image_rom (
    input  [15:0] addr,
    output [7:0]  pixel
);
    reg [15:0] rom [0:65535];
    initial $readmemh("image.hex", rom);
    assign pixel = rom[addr];
endmodule
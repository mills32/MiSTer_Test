
module mycore
(
	input         clk,
	input         reset,
	
	input         pal,
	input         scandouble,

	output reg    ce_pix,

	output reg    HBlank,
	output reg    HSync,
	output reg    VBlank,
	output reg    VSync,

	output  [7:0] video
);

// ======================================================
// VGA 640x400 @ 70Hz timing constants
// ======================================================
localparam H_ACTIVE = 640;
localparam H_FP     = 16;
localparam H_SYNC   = 96;
localparam H_BP     = 48;
localparam H_TOTAL  = H_ACTIVE + H_FP + H_SYNC + H_BP; // 800

localparam V_ACTIVE = 400;
localparam V_FP     = 1;
localparam V_SYNC   = 2;
localparam V_BP     = 46;
localparam V_TOTAL  = V_ACTIVE + V_FP + V_SYNC + V_BP; // 449

reg   [9:0] hc;
reg   [9:0] vc;
reg   [15:0] SCX_REG;


wire [7:0] image_pixel;

/////
//Get VRAM and draw it to screen
wire [15:0] img_addr = {(vc>>1) * 320 + (hc>>1) + SCX_REG};

image_rom ROM(.addr(img_addr), .pixel(image_pixel));


always @(posedge clk or posedge reset) begin
    if (reset) begin
        hc <= 0;
        vc <= 0;
		SCX_REG <= 0;
        ce_pix <= 1'b0;
    end else begin
        ce_pix <= 1'b1; // pixel enable always active for each pixel
        if (hc == H_TOTAL - 1) begin
            hc <= 0;
            if (vc == V_TOTAL - 1) begin 
				vc <= 0;
				SCX_REG <= SCX_REG + 1'd1;
            end else
                vc <= vc + 1'd1;
        end else begin
            hc <= hc + 1'd1;
        end
    end
end

// ======================================================
// Generate Sync & Blank signals
// ======================================================
always @(posedge clk) begin
    // Horizontal
    HSync  <= (hc >= (H_ACTIVE + H_FP)) && (hc < (H_ACTIVE + H_FP + H_SYNC));
    HBlank <= (hc >= H_ACTIVE);

    // Vertical
    VSync  <= (vc >= (V_ACTIVE + V_FP)) && (vc < (V_ACTIVE + V_FP + V_SYNC));
    VBlank <= (vc >= V_ACTIVE);
end

assign video = image_pixel;

endmodule



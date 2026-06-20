module instruction_Mem 
#(
// Parameter m?c ??nh, khi g?i module ? Wrapper c� th? truy?n t�n kh�c v�o
    parameter TEST_FILE = "prog_core3.txt" 
)
(
    input  [31:0] addr, // T??ng ???ng v?i t�n hi?u PC
    output [31:0] inst
);
    // T?ng l�n 256 ?? ch?a code tho?i m�i h?n, tr�nh b�o l?i tr�n
    reg [31:0] i_mem [0:255]; 
         // Kh?i t?o m?ng b?ng 0 ?? tr�nh r�c (N?u code ng?n h?n 256 d�ng)
        integer i;
    initial begin
   
        for (i = 0; i < 256; i = i + 1) begin
            i_mem[i] = 32'd0;
        end

        // N?p file linh ho?t theo parameter c?a b?n
        $readmemb(TEST_FILE, i_mem);
    end
     
    // B?T BU?C: T�nh offset b?ng c�ch tr? ?i ??a ch? g?c c?a v�ng Code
    wire [31:0] offset_addr = addr - 32'h00400000; 

    // Truy xu?t b? nh? d?a tr�n offset (C?t l?y bit 9:2 v� ROM c� 256 �)
    assign inst = i_mem[offset_addr[9:2]]; 
     
endmodule
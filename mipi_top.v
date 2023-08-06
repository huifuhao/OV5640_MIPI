module  mipi_top(
        // system signals
             
        input                   s_rst_n                 ,  
  
        //
        input                   mipi_clk_p              ,
        input                   mipi_clk_n              ,
        input           [ 1:0]  mipi_data_p             ,
        input           [ 1:0]  mipi_data_n             ,     
        // 
      
        // 
        output  wire            raw_vld                 ,       
        output  wire    [15:0]  raw_data                ,       
        output  wire            raw_vsync               ,       
        output  wire            packet_done                    
);

//========================================================================\
// =========== Define Parameter and Internal signals =========== 
//========================================================================/
   wire       [ 7:0]  lane0_data              ;     
   wire           [ 7:0]  lane1_data              ;       
wire    [ 7:0]                  lane0_byte_data                 ;       
wire                            lane0_byte_vld                  ;       

wire    [ 7:0]                  lane1_byte_data                 ;       
wire                            lane1_byte_vld                  ;       

wire    [15:0]                  word_data                       ;       
wire                            word_vld                        ;       
wire                            invalid_start                   ;       
// wire                            packet_done                     ;       
wire                   sclk                    ;  
 mipi_phy  mipi_phy1(
        // 
       .                 s_rst_n     (s_rst_n)            ,
        //
       .                  mipi_clk_p  (mipi_clk_p)            ,
        .                   mipi_clk_n    (mipi_clk_n)          ,
        .  mipi_data_p            (mipi_data_p) ,
        .           mipi_data_n     (mipi_data_n)        ,
        // 
       .          mipi_byte_clk        (sclk)   ,
       .  lane0_byte_data      (lane0_byte_data)   ,
        .lane1_byte_data   (lane1_byte_data)       
);
//=============================================================================
//**************    Main Code   **************
//=============================================================================
byte_align      byte_align_U0(
        // system signals
        .sclk                   (sclk                   ),
        .s_rst_n                (s_rst_n                ),
        // 
        .lane_data              (lane0_data             ),
        .mipi_byte_data         (lane0_byte_data        ),
        .mipi_byte_vld          (lane0_byte_vld         ),
        .re_find                (invalid_start | packet_done)
);

byte_align      byte_align_U1(
        // system signals
        .sclk                   (sclk                   ),
        .s_rst_n                (s_rst_n                ),
        // 
        .lane_data              (lane1_data             ),
        .mipi_byte_data         (lane1_byte_data        ),
        .mipi_byte_vld          (lane1_byte_vld         ),
        .re_find                (invalid_start | packet_done)
);


lane_align      lane_align_inst(
        // system signals
        .sclk                   (sclk                   ),
        .s_rst_n                (s_rst_n                ),
        // MIPI Lane Data
        .lane0_byte_data        (lane0_byte_data        ),
        .lane1_byte_data        (lane1_byte_data        ),
        .lane0_byte_vld         (lane0_byte_vld         ),
        .lane1_byte_vld         (lane1_byte_vld         ),
        // 
        .word_data              (word_data              ),
        .word_vld               (word_vld               ),
        .packet_done            (packet_done            ),
        .invalid_start          (invalid_start          )
);

packet_handler  packet_handler_inst(
        // system signals
        .sclk                   (sclk                   ),
        .s_rst_n                (s_rst_n                ),
        // Word 
        .word_data              (word_data              ),
        .word_vld               (word_vld               ),
        //
        .raw_vld                (raw_vld                ),
        .raw_data               (raw_data               ),
        .raw_vsync              (raw_vsync              ),
        .packet_done            (packet_done            )
);

endmodule

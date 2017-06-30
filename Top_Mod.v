`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:39:29 06/12/2017 
// Design Name: 	 Ecualizador
// Module Name:    Top_Mod 
// Project Name:   Proyecto Digitales
// Target Devices: Spartan 3A-Stater Board
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Top_Mod(
    input CLK_IN,
    input SPI_MISO,
	 
    output AD_CONV,
    output ready,
    output SPI_SCK,
    output SPI_MOSI,
    output SPI_SS_B,
    output DAC_CLR,
    output DAC_CS,
    output SF_CE0,
    output FPGA_INIT_B,
    output AMP_CS,
    output AMP_SHDN
    );

wire clock_lento; // frec_divider1
wire enable_amp, enable_adc, enable_dac; // controlador1
wire spi_mosi_amp, spi_sck_amp; //amp1
wire [0:11]datos_interno; // adc1
wire spi_sck_adc;
wire spi_mosi_dac, spi_sck_dac; // dac1

assign SPI_MOSI=spi_mosi_dac | spi_mosi_amp;
assign SPI_SCK=(spi_sck_amp | spi_sck_adc | spi_sck_dac);

frec_divider frec_divider1(
	.clock(CLK_IN),
	
	.clock_out(clock_lento)
);
	
controlador controlador1(
	.clock(clock_lento),
	
	.enable_amp(enable_amp), // interno
	.enable_adc(enable_adc), // interno
	.enable_dac(enable_dac), // interno
	.spi_ss_b(SPI_SS_B),
	.sf_ce0(SF_CE0),
	.fpga_init_b(FPGA_INIT_B)
);
	
amplificado amp1(
	.clock(clock_lento),
	.clock_enable(enable_amp),
	
	.spi_mosi(spi_mosi_amp), // interno
	.spi_sck(spi_sck_amp), // interno
	.amp_cs(AMP_CS),
	.amp_shdn(AMP_SHDN)
);

conversor_ADC adc1(
	.clock(clock_lento),
	.clock_enable(enable_adc),
	.spi_miso(SPI_MISO),
		
	.ad_conv(AD_CONV),
	.ready(ready),
	.spi_sck(spi_sck_adc), //interno
	.datos(datos_interno) // interno
);

conversor_DAC dac1(
	.clock(clock_lento),
	.clock_enable(enable_dac),
	.datos(datos_interno),
	
	.spi_mosi(spi_mosi_dac), // interno
	.dac_cs(DAC_CS),
	.spi_sck(spi_sck_dac), // interno
	.dac_clr(DAC_CLR)
);

endmodule
 
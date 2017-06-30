// modulo encargado del buen funcionamiento de AMP

module amplificado(
    input clock,
    input clock_enable,
	 
    output reg spi_mosi,
    output spi_sck,
    output reg amp_cs,
    output reg amp_shdn
    );

reg [3:0]bloque;	//AMP ocupa 1+8+1 cantos de reloj (del 1 al ...7,8,9,0)
						//Bloque extra para sincronizar y dejar AMP_CS en 1 (AMP deshabilitado)

//reg [0:7]amp=8'b0010_0010;	//AMP de -2 usual para aplicaciones de audio Min 1.025[V] y Max 2.275[V]
reg [0:7]amp=8'b0001_0001;	//AMP de -1 entrega Min 1.4[V] y Max 1.9[V]
//reg [0:7]amp=8'b0011_0011;	//AMP de -5 entrega Min 0.4[V] y Max 2.9[V]
//reg [0:7]amp=8'b0101_0101;	//AMP de -20 entrega Min 1.5875[V] y Max 1.7125[V]

reg estado_spi_sck;	//Para utilizar el SPI_SCK solo cuando sea necesario
assign spi_sck=estado_spi_sck?clock:0;	// si estado_spi_sck=1 entonces SPI_SCK será clock(se usa sck)
													// si no es 1 entonces SPI_SCK será 0(no se usa sck)				

initial begin	
	bloque<=0;	// inicializa bloque=0
	amp_cs<=1;	// inicializa AMP deshabilitado
	amp_shdn<=0;	//	inicializa no reseteado el AMP
	estado_spi_sck<=0;	// el spi_sck no se usa
	spi_mosi<=0;	//	inicializa en 0 porque si?
end

always@(posedge clock) begin
if(clock_enable)begin	// en cada canto de [reloj de habilitación]
	if(bloque==0) begin		
		bloque<=1;	// se establece bloque en 1
		amp_cs<=0;	// se habilita AMP (FPGA envia datos a AMP)	
	end
	else if(bloque==9) begin // si llegara al final del bloque 
		bloque<=0;				 // se reinicia el bloque
		estado_spi_sck<=0;	 // se deja de usar spi_sck como reloj de spi
		amp_cs<=1;				 // se deshabilita AMP (constantemente lee?)
	end
	else begin 
		bloque<=bloque+1;		// se aumenta el contador de cantos de reloj
		estado_spi_sck<=1;	// se usa spi_sck como clock
	end
end
end

always@(negedge clock)begin // en cada caida de reloj 
	if(bloque!=0 & bloque!=9) begin // mientras esta habilitado AMP 
		spi_mosi<=amp[bloque-1];	// FPGA envia ordenes bit a bit a AMP
	end
	else 
		spi_mosi<=0;	// si no envía el valor 0
end

endmodule

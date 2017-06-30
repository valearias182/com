// Modulo encargado de hacer la conversion en DAC
module conversor_DAC(
    input clock,
    input clock_enable,
    input [0:11]datos,
	 
    output reg spi_mosi,
    output reg dac_cs,
    output spi_sck,
    output dac_clr
    );

wire [0:11]datos_2compl;
assign datos_2compl[0]=~datos[0];
assign datos_2compl[1:11]=datos[1:11];	// se hace la reescalación de los datos en complemento
												// de 2 a un numero del tipo unsigned

//ADC escribe en complemento 2
//DAC lee en unsigned
	
//DAC necesita 1+32+1 bloques
//Bloque 34=0
//Ultimo bloque se utiliza para dejar DAC_CS en 1
// Asi no molestar a otros componentes del modulo SPI
reg [5:0]bloque;
reg estado_spi_sck;

reg [0:3]comando=4'b0011;	// comando para declarar las salidas del DAC antes de enviarlas
reg [0:3]direccion=4'b0000;	//Los datos del DAC salen en el pinA
//reg [0:3]direccion=4'b0001;	//Los datos del DAC salen en el pinB
//reg [0:3]direccion=4'b1111;	//Los datos del DAC salen en todos los pines

assign spi_sck=estado_spi_sck?clock:0;	// si el estado es uno se usa el SPI_SCK sino es 0
assign dac_clr=1;		// no esta activado el reseteo del DAC

initial begin
	dac_cs<=1;		// comienza el dac transformando datos no utilizando SPI
	bloque<=0;		// el resto de variables se inicializan en 0
	estado_spi_sck<=0;	
	spi_mosi<=0;	
end

always@(posedge clock) begin
if(clock_enable) begin	// si el canal SPI se habilita para la comunicacion con el DAC
	if(bloque==0) begin	
		bloque<=1;
		dac_cs<=0;	// se comienza la transmisión de datos hacia la FPGA
	end
	else if(bloque==33) begin	// se termina la transmision de los 32 bits de la GPGA 
		bloque<=0;					// se reinicia el conteo
		dac_cs<=1;					// se deshabilita la comunicacion con la FPGA y DAC transforma datos
		estado_spi_sck<=0;		// se deshabilita el uso del SPI_SCK como reloj
	end
	else begin 
		bloque<=bloque+1;			// mientras esta la comunicacion de los datos
		estado_spi_sck<=1;		// se comienza a utilizar el SPI_SCK como reloj
	end
end
end

always@(negedge clock) begin
	if(bloque>=9 & bloque<=12)				// despues de los 8 bits don't care
		spi_mosi<=comando[bloque-9];		// se envia el comando 0011
	else if(bloque>=13 & bloque<=16) 	// luego de enviar los comandos se envia la direccion del pin 
		spi_mosi<=direccion[bloque-13];	// de salida de la conversion
	else if(bloque>=17 & bloque<=28)		// luego enviado los protocolos se envia la señala convertir  
		spi_mosi<=datos_2compl[bloque-17];	// de 12 bits, se ordenan desde el bit LSB al MSB
		//spi_mosi<=datos_2compl[bloque-28];	//	se ordenan desde el bit LSB al MSB
	else
		spi_mosi<=0;	// en cualquier otro caso son bits don't care
end

endmodule

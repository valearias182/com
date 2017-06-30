// Modulo encargado de hacer la conversion en ADC
module conversor_ADC(
    input clock,
    input clock_enable,
    input spi_miso,
	 
	 output ad_conv,
    output reg [0:11]datos,
    output reg ready, //Puede ser util tener una señal de aviso
	 output spi_sck
    );

reg [5:0]bloque;	//Ocupa 1+34 bloques
						//1 para el impulso inicial
						//bloque 35=0
reg estado_ad_conv,estado_spi_sck;
 
reg [0:11]datos_temp;	//Variable para no estar cambiando los datos de salida
								//a cada momento. Puede ser util para evitar errores

assign ad_conv=estado_ad_conv?clock:0;	// si estado_ad_conv=1 continuamente se asigna a AD_CONV
													// el valor del clock o sino se asigna 0
assign spi_sck=estado_spi_sck?clock:0;	// si estado_spi_sck=1 continuamente se asigna a SPI_SCK
													// el valor del clock o sino se asigna 0

initial begin			
	estado_ad_conv<=0;	// se inicializa AD_CONV en 0 (se habilita envio de datos)
	estado_spi_sck<=0;	// se inicializa spi_sck en 0
	bloque<=0;				// se iniciliza bloque en 0
	ready<=0;				// se inicializa la señal de aviso en 0
end

always@(posedge clock) begin
if(clock_enable) begin	// Es importante que el clock enable inicie antes del posedge
								// Idealmente medio clock antes
	if(bloque==0) begin	
		bloque<=1;			// se asigna a bloque 1
		estado_ad_conv<=1;// se asigna a AD_CONV el valor del clock
	end
	else if(bloque==34) begin	 
		bloque<=0;					// se vuelve al inicio el bloque
	end
	else begin
		bloque<=bloque+1;		// si el bloque aumenta de 1 a 33 
		estado_ad_conv<=0;	// estado AD_CONV se desactiva a 0 (enviando datos a la FPGA)
	end
end
end

always@(negedge clock) begin
	if(bloque>=4 & bloque<=15)	// si pasaron 4 clocks de comunicacion con la fpga hasta que pasen los 12 bit 
		datos_temp[bloque-4]<=spi_miso;	// deja los primeros 12 bits MSB enviados desde el spi_miso
	else if(bloque==16)			// despues de asignar los bit mas significativos 
		datos<=datos_temp;		// se asignan los datos temporales a la salida datos
	else if(bloque==34)			// despues que se envie el valor del canal 2 
		ready<=1;					// se da la señal de que termino de enviarse los datos a la FPGA
	else if(bloque==0) begin	// si el bloque que determina el inicio del funcionamiento del ADC
		ready<=0;					// la señal de aviso se vuelve a 0
		estado_spi_sck<=0;		// y se deja de utilizar el spi_sck como reloj del SPI
	end
	else if(bloque==1)			// si el bloque comienzó su conteo
		estado_spi_sck<=1;		// se comienza a utiliza el spi_sck
// Se avisa en el ultimo bloque para no interrumpir el funcionamiento normal del adc
// Ready funciona con negedge en el ultimo bloque
end
		
endmodule

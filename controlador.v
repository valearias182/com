// Generara el control para la sincronización del AMP,ADC y DAC
// las salidos son las señales de habilitación para los dispositivos
 
module controlador(
    input clock,
    output reg enable_amp,
    output reg enable_adc,
    output reg enable_dac,
	 
	 // modulos del SPI a deshabilitar para el buen funcionamiento
	 // de ADC y DAC
    output reg spi_ss_b,
    output reg sf_ce0,
    output reg fpga_init_b
    );

reg [6:0]contador; // se genera un contador de 6 bits de 0 a 2^6
initial begin 	
	contador <=0;	// inicializa las variables en 0
	enable_amp<=0;	  
	enable_adc<=0;
	enable_dac<=0;
	
	spi_ss_b<=1;	// Deshabilita los modulos de spi que no se usan
	sf_ce0<=1;
	fpga_init_b<=0;
end

//10 cantos de reloj para gain (necesita 8 pero para dar holgura)
//35 para adc
//34 para dac
//Contador desde el 1 al "79"
//79=10 para el contador pues nunca se vuelve a "0" (gain solo una vez)
//Se vuelve a ADC

always@(negedge clock) begin	// en cada subida de reloj
	if(contador<10) begin	// se ejecuta 1 sola vez
		contador<=contador+1;
		enable_amp<=1;		// se mantiene la habilitación del AMP por 10 cantos de reloj
								// en donde se envian las configuraciones al AMP 
	end
	else if(contador<45) begin
		contador<=contador+1;	
		enable_amp<=0;				// se deshabilita AMP para que lea entradas
		enable_adc<=1;				//	
		enable_dac<=0;
	end
	else if(contador<78) begin
		contador<=contador+1;
		enable_adc<=0;
		enable_dac<=1;
	end
	else if(contador==78) // no poner else 
		contador<=10;
end

endmodule

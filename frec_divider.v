// Se encarga de realizar el divisor de reloj generando un reloj de menor 
// frecuencia especificamente la reduce 

module frec_divider(
    input clock,
    output reg clock_out
    );
//(69*(2*(8+1)/(50*10^6)))^(-1) ---> Fs ~40.3[kHz]
//counter--->8 Reemplazar ese numero para otras Fs

reg [15:0]contador=0; // Contador que va de 0 a 2^15
initial begin
	clock_out<=0;	// Inicializa la salida como 0
end

always@(posedge clock)			// En cada bajada del reloj de entrada
begin
	if(contador==16'd8) begin	// Si el contador es igual a 8 en hexagesimal
		contador<=16'd0;			// Se reinicia el contador a 0 en hexagesimal
		clock_out<=~clock_out;  // Si estaba en 0 sube a 1 y si estaba en 1 baja a 0
	end
	else begin						
		contador<=contador+1;	// si no ocurre lo anterior el contador aumenta en 1
	end
end

endmodule

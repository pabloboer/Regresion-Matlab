function [error_generalizacion,SalidaCapaSalida]=TestMLP(Input,Output,W,Ws,beta)
%% Feedforward
%%Capa de entrada
%Los datos estan organizados por columnas, es decir que cada set de
%patrones es una columna
SalidaCapaEntrada=Input;

%%Calculo la salida de la capa oculta
%Here we need to multiply the Output of the Input Layer with the -
%synaptic weight. That weight is in the matrix W.
h=W*SalidaCapaEntrada;

%%Salida de la capa oculta
%Uso la función tahn(beta*X) con parametro beta
SalidaCapaOculta=tanh(beta*h);
%Agrego bias de la capa oculta
SalidaCapaOculta=[ones(1,length(Input(1,:)));SalidaCapaOculta];

%%Calculo la entrada de la capa de salida
EntradaCapaSalida=Ws*SalidaCapaOculta;

%%Calculo la salida de la red
SalidaCapaSalida=tanh(beta*EntradaCapaSalida);
% SalidaCapaSalida=1./(1+exp(-beta*EntradaCapaSalida));

%% Error
error_generalizacion = 0.5*sqrt(sum(Output-SalidaCapaSalida).^2);

end

function [error delta_W delta_Ws SalidaCapaSalida] = EntrenarMLP(Input,Output,W,Ws,beta,n)

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
error = 0.5*sqrt(sum(Output-SalidaCapaSalida).^2);

%% Backpropagation
%%Calculo el delta de salida, desde salida-capa oculta
g_deriv=beta*(1-SalidaCapaSalida.^2);
% g_deriv=SalidaCapaSalida.*(1-SalidaCapaSalida.^2);
ds=g_deriv.*(Output-SalidaCapaSalida);

for i=1:length(SalidaCapaSalida(:,1))
    for j=2:length(SalidaCapaOculta(:,1))
        delta_Ws(i,j)=n*ds(i,j).*SalidaCapaOculta(i,j);
    end
end

%%Calculo el delta, desde capa oculta-entrada
g_deriv=beta*(1-SalidaCapaOculta.^2);
% g_deriv=SalidaCapaOculta.*(1-SalidaCapaOculta.^2);

d=g_deriv.*(Ws'*ds);

% for j=1:length(SalidaCapaOculta(:,1))-1
%     for k=1:length(SalidaCapaEntrada(:,1))
%         delta_W(j,k)=n*SalidaCapaEntrada(j,k)*d(j,k);
%     end
% end
delta_W=n*d(2:end,:)*SalidaCapaEntrada';
%delta_W=d.*Input(2:end,:);

end
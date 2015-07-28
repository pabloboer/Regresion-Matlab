% Trabajo Práctico N°2
% Autores
%   Pablo Boer
%   Lorena Mejia

%--------------------------------------------------------------------------
%   2. Implemente un perceptrón multicapa que aprenda la función lógica XOR 
%   de 4 entradas (utilizando el algoritmo Backpropagation).
%--------------------------------------------------------------------------

clc;clear all;

%Definicion de las entradas
X = [-1 -1 -1 -1 -1;
    -1 -1 -1 -1 1;
    -1 -1 -1 1 -1;
    -1 -1 -1 1 1;
    -1 -1 1 -1 -1;
    -1 -1 1 -1 1;
    -1 -1 1 1 -1;
    -1 -1 1 1 1;
    -1 1 -1 -1 -1;
    -1 1 -1 -1 1;
    -1 1 -1 1 -1;
    -1 1 -1 1 1;
    -1 1 1 -1 -1;
    -1 1 1 -1 1;
    -1 1 1 1 -1;
    -1 1 1 1 1];
%Definicion de las salidas
Y = [-1;1;1;-1;1;-1;-1;-1;-1;1;-1;-1;-1;-1;-1;-1];


% Inicialización de los parámetros de Backpropagation
deltaj=zeros(4,1);
h=zeros(5,1);
V=zeros(5,1);
n = 0.7;
beta=0.7;

% Inicializacion de la matriz de pesos sinápticos, de manera aleatoria
W = -1 +2.*rand(5,5);

% Inicialización de parámetros
reset_W=0;
max_actualiz=8000;
u=1;
error=zeros(max_actualiz,1);
actualizaciones=1;

while(u==1)             % Bucle principal
    
    YD = zeros(16,1);
    
    % Propagación de las entradas hacia la salida YD
    for j = 1:length (X(:,1))              
        for k=2:5
            %h(k)=0;
            %for l=1:5
                %h(k) = h(k)+X(j,l)*W(k-1,l);    
                h(k)=X(j,:)*W(k-1,:)';
            %end
            %h2=X(j,:)*W(j,:);
            V(k) = tanh(beta*h(k));            
        end
        V(1)= -1;        
        hs=V'*W(5,:)';        
        
        YD(j) =tanh(beta*hs);
        
        % Cálculo de las deltas necesaria para la actualización de los
        % pesos sinápticos, utilizando Backpropagation
        delta_i = beta*(1-(YD(j)).^2)*(Y(j)-YD(j));
        for d=1:4
            delta_j(d) = beta*(1-V(d+1).^2)*W(5,d+1)*delta_i;            
        end
        
        % Actualización de los pesos sinápticos
        for k = 1:5
            if k == 1
                for s=1:4
                    W(s,k) = W(s,k) + n*X(1,s)*delta_j(s);
                end
                W(5,k) = W(5,k) + n*X(1,5)*delta_i;
                
            else
                 for s=1:4
                    W(s,k) = W(s,k) + n*X(j,k)*delta_j(s);
                end
                W(5,k) = W(5,k) + n*V(k)*delta_i;
            end
        end
    end

    % Cálculo del error cuadrático medio por actualización
    for m=1:16
        error(actualizaciones)=error(actualizaciones)+sqrt(((Y(m)-YD(m))^2)*0.5);
    end
    
    % Condición de cierre del bucle de actualizaciónes, error < 3% 
    if(error(actualizaciones)<0.03)
        u=0;
        break;
    else
        % Reset de la matriz W si se queda en algun minimo local
        if actualizaciones>max_actualiz-1
            W = -1 +2.*rand(5,5);
            reset_W=reset_W+1;
            actualizaciones=0;
            error=zeros(max_actualiz,1);
        end              
    end
    actualizaciones=actualizaciones+1;
    
end

%% Salidas en pantalla
display(reset_W)
display(actualizaciones)
display(W)
display(YD)


%% Graficos
figure;
stem(YD,'r');
ylim([-2 2])
hold on;
stem(Y,'bx');
hold off;
title('Comparación salida real vs ideal')
xlabel('Vector de Salida');

figure;
stem(sqrt(((Y-YD).^2)*0.5),':b');
ylim([-0.05 0.05]);
title('Error cuadrático medio por bit de salida')
ylabel ('Error cuadrático medio');
xlabel('Vector de Salida');

figure;
plot(error)
ylim([0 2]);
title('Error cuadrático medio por actualización')
ylabel ('Error cuadrático medio');
xlabel('Cantidad de actualizaciónes');


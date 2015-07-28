% Trabajo Práctico N°2
% Autores
%   Pablo Boer
%   Lorena Mejia

%--------------------------------------------------------------------------
%   2. Implemente un perceptrón multicapa que aprenda la función lógica XOR
%   de 4 entradas (utilizando el algoritmo Backpropagation).
%--------------------------------------------------------------------------
clc;clear all;
inic=cputime;
fid = fopen('norm_31.txt','r');
% entradas = fscanf(fid,'%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f',20);
% salidas = fscanf(fid,'%f%f%f%f%f%f',6);
entradas = fscanf(fid,'%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f',18);
salidas = fscanf(fid,'%f%f%f%f%f%f%f',6); 
i=1;
while (entradas~=-1)
    x1(i,:)=entradas;
    YD(i,:)=salidas;
    
    entradas = fscanf(fid,'%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f',18);
    salidas = fscanf(fid,'%f%f%f%f%f%f',6);
    i=i+1;
end
fclose(fid);

% for i=1:length(YD)*length(YD(1,:))
% 	if(YD(i)==-1)
%         YD(i)=0;
%     end
% end
X=x1;
Y=YD';

% Definicion de constantes y parametros de la red Neuronal
i=length(Y(:,1));                        %Numero de Salidas
j=100;                        %Número de Neuronas en capa oculta
k=length(X(1,:));                        %Número de Entradas
u=length(X(:,1));           %Número de patrones de entrenamiento

aux=randperm(u);
aux2=randperm(k);
X=X';
for l=1:u
    for m=1:k
        X(m,l)=x1(aux(l),aux2(m));
        Y(:,l)=Y(:,aux(l));
    end
end
X=X';
%% Agrego el bias
%Los datos estan organizados por columnas, es decir que cada set de
%patrones es una columna
bias=ones(1,u)*-1;
%% Normalizacion del vector de entrada
X=[bias;X'];%./max(max(X));
X_train=X(:,1:floor(end*0.8));
X_test=X(:,floor(end*0.8)+1:end);

X=X_train;

Y_train=Y(:,1:floor(end*0.8));
Y_test=Y(:,floor(end*0.8)+1:end);

Y=Y_train; 
%% Definición de parámetros para Backpropagation
n =0.1;
beta=0.2;
actualizaciones =0;
max_actualiz=3000000;
error_max=0.0031;
%% Definición de las matrices de pesos sinápticos
W = rand(j,k+1);
Ws =rand(i,j+1);
salidaLoop=1;
reset_w=0;
Error_Mat= zeros(1,max_actualiz);
%error=zeros(max_actualiz,1);
%g=zeros(nNeur,k);
h=zeros(i,k);
hs=zeros(i,1);  
deltaj=zeros(1,j);
deltas=zeros(i,1);
%Y=zeros(size(YD))';
%dat=length(X(1,:));

% u=length(X_train(:,1));
%% Entrenamiento
[error delta_W delta_Ws Salida] = EntrenarMLP(X,Y,W,Ws,beta,n);
while sum(error)/(6*u)>error_max   %mean(error)>error_max
    actualizaciones=actualizaciones+1;
%     n=n*actualizaciones/(actualizaciones+0.005);
    %Guardo el error en una matriz para poder graficarlo
    Error_Mat(actualizaciones)=sum(error)/u;
    
    %Actualizo los valores de las matrices de pesos sinapticos
    W=W+delta_W;
    Ws=Ws+delta_Ws;
    if actualizaciones>max_actualiz
        W = rand(j,k+1);
        Ws =rand(i,j+1);
        actualizaciones=0;
        reset_w=reset_w+1;
        clear Error_Mat;
    end
    [error delta_W delta_Ws Salida] = EntrenarMLP(X,Y,W,Ws,beta,n);
    sum(error)/(6*u)
%     mean(error)
end

%Agrego la cuenta de la última actualización
actualizaciones=actualizaciones+1;
%Guardo el error en una matriz para poder graficarlo
Error_Mat(actualizaciones)=sum(error)/u;

%Calculo el error relativo
Error_Rel=sum(Error_Mat)/actualizaciones;
% errorbar(mean(Salida-Y_train),std(Salida-Y_train),'*b')

save prueba__norm_3.mat

%% Calculo del error de entrenamiento
alto=zeros(1,6);
bajo=zeros(1,6);
indec=zeros(1,6);
correctas=0;
malas=0;

for i=1:length(Salida(1,:))
    
    for j=1:length(Salida(:,1))
        if Salida(j,i)>0
            SalidaTrain(j,i)=1;
            alto(j)=alto(j)+1;
        else
            if Salida (j,i)<0
                SalidaTrain(j,i)=-1;
                bajo(j)=bajo(j)+1;
            else
                SalidaTrain(j,i)=0;
                indec(j)=indec(j)+1;
            end
        end
        if(abs(SalidaTrain(j,i)-Y_train(j,i))<=error_max)
            correctas=correctas+1;
        else
            malas=malas+1;
        end
    end
end
total=length(Salida(1,:))*length(Salida(:,1));
porc_train=100*correctas/total
% figure;
% errorbar(mean(Salida-Y_train),std(Salida-Y_train),'*r')

%% Test de generalización
[error_generalizacion,SalidaTest]=TestMLP(X_test,Y_test,W,Ws,beta);
% figure
% errorbar(mean(SalidaTest-Y_test),std(SalidaTest-Y_test),'*b')

alto=zeros(1,6);
bajo=zeros(1,6);
indec=zeros(1,6);
correctas=0;
correctas2=0;
malas=0;
malas2=0;
for i=1:length(SalidaTest(1,:))
    for j=1:length(SalidaTest(:,1))
        if SalidaTest(j,i)>=0
            SalidaTest2(j,i)=1;
            alto(j)=alto(j)+1;
        else
            if SalidaTest (j,i)<-0
                SalidaTest2(j,i)=-1;
                bajo(j)=bajo(j)+1;
            else
                SalidaTest2(j,i)=0;
                indec(j)=indec(j)+1;
            end
        end
        if(abs(SalidaTest(j,i)-Y_test(j,i))<=error_max)
            correctas=correctas+1;
        else
            malas=malas+1;
        end
    end

        if(abs(SalidaTest(:,i)-Y_test(:,i))<=error_max)
            correctas2=correctas2+1;
        else
            malas2=malas2+1;
        end
end
total_test=length(SalidaTest(1,:))*length(SalidaTest(:,1));
porc_test=100*correctas/total_test

e=cputime-inic;
e


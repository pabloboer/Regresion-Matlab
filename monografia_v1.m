%####### PROCESAMIENTO DISTRIBUCION GOTAS ######%
clear all; close all; clc;
load data2
%% Datos del archivo de entrada
opt=menu('Seleccione Lluvia','14/3','19/3','27/3','28/3','30/3','5/04');

switch opt
    case 1
        directorioArchivoIn = '.\20140314\';
        nombreArchivoIn = 'distribucionGotas0314';
        filename_in=[directorioArchivoIn nombreArchivoIn '.txt'];
        fid=fopen(filename_in,'r');
    case 2
        directorioArchivoIn = '.\20140319\';
        nombreArchivoIn = 'distribucionGotas0319';
        filename_in=[directorioArchivoIn nombreArchivoIn '.txt'];
        fid=fopen(filename_in,'r');
    case 3
        directorioArchivoIn = '.\20140327\';
        nombreArchivoIn = 'distribucionGotas0327';
        filename_in=[directorioArchivoIn nombreArchivoIn '.txt'];
        fid=fopen(filename_in,'r');
    case 4
        directorioArchivoIn = '.\20140328\';
        nombreArchivoIn = 'distribucionGotas0328';
        filename_in=[directorioArchivoIn nombreArchivoIn '.txt'];
        fid=fopen(filename_in,'r');
    case 5
        directorioArchivoIn = '.\20140330\';
        nombreArchivoIn = 'distribucionGotas0330';
        filename_in=[directorioArchivoIn nombreArchivoIn '.txt'];
        fid=fopen(filename_in,'r');
    case 6
        directorioArchivoIn = '.\20140405\';
        nombreArchivoIn = 'distribucionGotas0405';
        filename_in=[directorioArchivoIn nombreArchivoIn '.txt'];
        fid=fopen(filename_in,'r');
end




%% Leo los datos del archivo y los guardo en una matriz
i=1;
while 1
    line = fgetl(fid);
    if ~ischar(line); break; end
    if(size(line)~=0);
        %disp(line)
        newstream=zeros(1,1024);
        dia(i,:)=str2double(line(1:2));
        mes(i,:)=str2double(line(4:5));
        anio(i,:)=str2double(line(7:10));
        hora(i,:)=str2double(line(12:13));
        minu(i,:)=str2double(line(15:16));
        segund(i,:)=str2double(line(18:19));
        tensionGota(i,:)=str2double(line(21:size(line,2)-1));
        i=i+1;
    end
end

fclose(fid);

matrizGotas=[anio mes dia hora minu segund tensionGota];

%% Corrijo los valores menores a 0.04V
% for j=1:size(matrizGotas,1)
%     if(matrizGotas(j,7) < 0.04)
%         matrizGotas(j,7)= 0.045;
%     end
% end

potencia=1.1765;
cte=0.0256;

%% Calculo el volumen de cada gota, diametro y volumen normalizado a mm x m2
constanteVolumen = 39.26;
for j=1:size(matrizGotas,1)
    %Volumen de Gota
    matrizGotas(j,8)= matrizGotas(j,7)*39.26;
    %Diametro de Gota
    matrizGotas(j,9)= [(matrizGotas(j,8)*3/(4*pi))^(1/3)]*2;
    %% Volumen Normalizado a mmxm2 de gota. ACA VA LOGICA PARA HACER CALCULO DISTINTO A TENSION/50
    matrizGotas(j,10) = matrizGotas(j,7);
    %       matrizGotas(j,10) = matrizGotas(j,7)/39;
    %     if(matrizGotas(j,7) < 0.09)
    %         matrizGotas(j,10) = matrizGotas(j,7)/34;
    %     else
    %         matrizGotas(j,10) = matrizGotas(j,7)/48;
    %     end
    
    %    matrizGotas(j,10)= (cte*(matrizGotas(j,7))^potencia);
end

%Tips:
% - Para la lluvia del 03/14 si se le da mas ganancia a las gotas
%   grandes (se baja el 42) y se le da menos a las chicas (se sube el 44) el
%   grafico mejora
% - Para la lluvia del 03/19 el grafico mejora cuando se le da mas ganancia
%   a las gotas chicas

%% Separo en intervalos de 1 minuto

%Genero matriz con las entradas de cada minuto para todo el dia
for i=1:24
    for j=1:60
        volumenAcumuladoPorMinuto( (i-1)*60 +j ,:) = [(i-1) (j-1) 0];
    end
end
volumenAcumuladoPorMinuto(1,3) = 0;

lineasNoProcesadas = size(matrizGotas,1);
currentLine=1;
volumenAcumulado = 0;
i=1;
%Calculo el volumen para cada minuto
while(lineasNoProcesadas > 0)
    
    hora = matrizGotas(currentLine,4);
    minuto = matrizGotas(currentLine,5);
    volumenMinuto = matrizGotas(currentLine,10);
    cantidadGotas = 1;
    if(lineasNoProcesadas == 1)
        if(minuto ~= 59)
            volumenAcumuladoPorMinuto(hora*60 + minuto + 1 + 1,3) = volumenMinuto;
        else
            volumenAcumuladoPorMinuto(hora*60 + minuto + 1 + 1,3) = volumenMinuto;
        end
        break;
    else
        currentLine = currentLine + 1;
        lineasNoProcesadas = lineasNoProcesadas - 1;
        
        while(matrizGotas(currentLine,4)== hora && matrizGotas(currentLine,5)== minuto)
            volumenMinuto = volumenMinuto + matrizGotas(currentLine,10);
            cantidadGotas = cantidadGotas + 1;
            currentLine= currentLine+1;
            lineasNoProcesadas = lineasNoProcesadas - 1;
            if(lineasNoProcesadas == 0)
                break;
            end
        end
        
        volumenAcumuladoPorMinuto(hora*60 + minuto + 1 + 1,3) = volumenMinuto;
        i=i+1;
    end
end

%% Calculo el volumen Acumulado
volumenAcumuladoPorMinuto(1,4) = volumenAcumuladoPorMinuto(1,3);
for i=2:size(volumenAcumuladoPorMinuto,1)
    %     %ACA VA LOGICA PARA CORREGIR POR INTENSIDAD
    %     %volumenAcumuladoPorMinuto(i,4) = volumenAcumuladoPorMinuto(i,3) + volumenAcumuladoPorMinuto(i-1,4);
    %     if( volumenAcumuladoPorMinuto(i,3)*60 < 2 )
    %         volumenAcumuladoPorMinuto(i,4) = volumenAcumuladoPorMinuto(i,3)*1.3 + volumenAcumuladoPorMinuto(i-1,4);
    %     elseif( volumenAcumuladoPorMinuto(i,3)*60 < 10 )
    %         volumenAcumuladoPorMinuto(i,4) = volumenAcumuladoPorMinuto(i,3)*1.1 + volumenAcumuladoPorMinuto(i-1,4);
    %     elseif(volumenAcumuladoPorMinuto(i,3)*60 < 30)
    %         volumenAcumuladoPorMinuto(i,4) = volumenAcumuladoPorMinuto(i,3)*0.9 + volumenAcumuladoPorMinuto(i-1,4);
    %     elseif(volumenAcumuladoPorMinuto(i,3)*60 > 40)
    %         volumenAcumuladoPorMinuto(i,4) = volumenAcumuladoPorMinuto(i,3)*0.6 + volumenAcumuladoPorMinuto(i-1,4);
    %     else
    volumenAcumuladoPorMinuto(i,4) = volumenAcumuladoPorMinuto(i,3) + volumenAcumuladoPorMinuto(i-1,4);
    %     end
end
volumenAcumulado = volumenAcumuladoPorMinuto(size(volumenAcumuladoPorMinuto,1),4);

%% Agrego columna para volumen promediado
% volumenAcumuladoPorMinuto(1,4) = 0;
% volumenAcumuladoPorMinuto(2,4) = volumenAcumuladoPorMinuto(2,3);
% for i=3:size(volumenAcumuladoPorMinuto,1)
%     volumenAcumuladoPorMinuto(i,4) = (3*volumenAcumuladoPorMinuto(i-1,4) - volumenAcumuladoPorMinuto(i-2,4))/2 + (volumenAcumuladoPorMinuto(i,3) - volumenAcumuladoPorMinuto(i-1,3))/2;
% end


%% Guardo en archivo de Texto
directorioArchivoOut = directorioArchivoIn;
nombreArchivoOut = [nombreArchivoIn '_porMinuto'];
filename_out=[directorioArchivoOut nombreArchivoOut '.txt' ];
dlmwrite(filename_out, volumenAcumuladoPorMinuto, '\t')
fclose('all');

%% Ploteo
% plot(volumenAcumuladoPorMinuto(:,4),'r'); hold on;
% plot(SMN_0314)

%% RNA
%% Espacio de búsqueda
vAPM=volumenAcumuladoPorMinuto(:,4)';
x1 = 3/length(vAPM):3/length(vAPM):3; x2 = 0:1/length(vAPM):1-1/length(vAPM);
aux1=x1.*sqrt(vAPM);
aux2=sqrt(vAPM).^x2;
F=aux1'*aux2;

SMN_0314_resh=ones(1,1440)'*SMN_0314';

[X1,X2] = meshgrid(x1,x2);
% F = [x1.*vAPM.^x2 zeros(1,1440*1440-length(vAPM))];
% F = reshape(F,length(x2),length(x1));
% SMN_0314_resh=[SMN_0314' zeros(1,1440*1440-length(SMN_0314))];
% SMN_0314_resh=reshape(SMN_0314_resh,length(x2),length(x1));
asd=abs(SMN_0314_resh-F)./abs(SMN_0314_resh);
mesh(x1,x2,asd);
grid on

% vAPM=volumenAcumuladoPorMinuto(:,4)';
% x1 = 1:7/length(vAPM):8-7/length(vAPM); x2 = 1:7/length(vAPM):8-7/length(vAPM);
% F = x1.*vAPM.^x2;
%%
%f1=(0.4148.*vAPM.^0.5)/50;
for i=1:length(x1)
    f2(:,i)=x1(i).*sqrt(vAPM);
    f3(:,i)=sqrt(vAPM).^x2(:,i);
    real(:,i)=SMN_0314;
end
error=abs((real-f2.*f3)^2)./real;
[A,B]=min(error(701:end,701:end));

%plot((real-f3)./real);
mesh(x1,x2,error);

%% Pruebas. Aca es dónde pruebo 
xa=[0 1 2 3 4];
xb=[0.0 0.1 0.2 0.3 0.4];
aux=xa'*xb;
vA=[0 20 40 60 80]; 
freal=[0 22 43 66 87];


for i=1:length(xa)
    f22(:,i)=aux(i,:).*vA;
    freal2(:,i)=freal;
end
error=abs((freal2-f22)^2)./freal2;
%plot((real-f3)./real);
mesh(xa,xb,error);


% figure
% plot(SMN_0314-f1')



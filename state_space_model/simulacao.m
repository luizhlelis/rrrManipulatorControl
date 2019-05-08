clc;
clear all;
close all;

% Funcoes de transferencia da planta
Gs = tf([1],[1 0.2 0.26]);

%[A,B,C,D] = tf2ss([0.2315 0.2209],[1 -1.752 0.8694])
%K1 = acker(A,B,P)

A = [[0 1];[-.8694 1.75200]];
B = [0;1];
C = [.2209 .2315];
P = [.5 .6];

K = acker(A,B,P)
N = .4421;

Gz_des = tf([.1023 .0977],[1 -1.1 0.3],T)

%[A_mf,B_mf,C_mf,D_mf] = tf2ss([.1038 .09632],[1 -1.1 0.3])

%figure(1)
%step(Gz_des);
%title('Resposta ao degrau malha fechada desejado')
%grid

% Identidade e condicao inicial
I = [[1 0];[0 1]];

x(:,1)=[2 2];

% 1) Malha aberta -> Planta
for k = 1:50
    x(:,k+1) = A*x(:,k)+I*B;
    y(k) = C*x(:,k);
end

figure(1)
plot(1:50,y,'ro')
title('Resposta ao degrau planta - malha aberta')
grid

% Condicao inicial
x(:,1)=[2 2];

% 2) Malha fechada -> Regulador + Rastreador
for k = 1:50
    x(:,k+1) = (A-B*K)*x(:,k)+I*B*N;
    y(k) = C*x(:,k);
end

figure(2)
plot(1:50,y,'ro')
title('Resposta ao degrau malha fechada - Regulador + Rastreador')
grid

% Vetor G
P = [.15 .15];
G = acker(A',C',P);
G = G'

% Condicoes iniciais
x(:,1)=[2 2];
q(:,1)=[0 0];

% 3) Malha fechada -> Regulador + Rastreador + Observador
% x -> vetor de estados da planta
% u -> entrada da planta e do observador
% y -> saida da planta
% q -> vetor de estados estimados
% r -> referencia

r=zeros(50);
r_2=ones(50);

for k = 1:100
    % Lei de controle
    if k<=50
        u(k) = -K*q(:,k)+N*r(k);
    elseif k>50
        u(k) = -K*q(:,k)+N*r_2(k);
    end
    
    % Planta
    x(:,k+1) = A*x(:,k)+I*B*u(:,k);
    y(k) = C*x(:,k);
    
    % Observador
    q(:,k+1) = (A-G*C)*q(:,k)+G*y(k)+I*B*u(:,k);
end

figure(3)
plot(1:100,y,'ro')
title('Degrau malha fechada - Regulador + Rastreador + Observador')
grid

figure(4)
stairs(y);
title('Degrau malha fechada - Regulador + Rastreador + Observador')
grid

%sisotool(Gz);
clc;
clear all;
close all;

% ---------------------- DENAVIT - HATENBERG ------------------------

% Rodar o Matlab com um usuário com alto privilegio

% 1) Carregando a matriz de Denavit-Hatenberg
mat = load('matrix/DH.mat','-mat');
dh = mat.dh

dh_representation = SerialLink(dh)

% Carregando angulos iniciais das juntas (radianos)
theta_0 = 0;
theta_1 = 0;
theta_2 = 0;
q = [theta_0, theta_1, theta_2]

% Representacao grafica do manipulador
dh_representation.plot(q)
dh_representation.teach

% 2) Matrizes homogeneas

% Especificidades do manipulador em estudo
alpha_0 = -pi/2;
alpha_1 = 0;
alpha_2 = 0;

a0 = 0.065;
a1 = 0.172;
a2 = 0.235;

d0 = 0.085;
d1 = 0;
d2 = 0;


A_0 =   [
            [cos(theta_0)   -sin(theta_0)*cos(alpha_0)  sin(theta_0)*sin(alpha_0)   a0*cos(theta_0)];
            [sin(theta_0)   cos(theta_0)*cos(alpha_0)   -cos(theta_0)*sin(alpha_0)  a0*sin(theta_0)];
            [0              sin(alpha_0)                -cos(alpha_0)               d0             ];
            [0              0                           0                           1              ];
        ];
A_1 =   [
            [cos(theta_1)   -sin(theta_1)*cos(alpha_1)  sin(theta_1)*sin(alpha_1)   a1*cos(theta_1)];
            [sin(theta_1)   cos(theta_1)*cos(alpha_1)   -cos(theta_1)*sin(alpha_1)  a1*sin(theta_1)];
            [1              sin(alpha_1)                -cos(alpha_1)               d1             ];
            [0              0                           0                           1              ];
        ];
A_2 =   [
            [cos(theta_2)   -sin(theta_2)*cos(alpha_2)  sin(theta_2)*sin(alpha_2)   a2*cos(theta_2)];
            [sin(theta_2)   cos(theta_2)*cos(alpha_2)   -cos(theta_2)*sin(alpha_2)  a2*sin(theta_2)];
            [2              sin(alpha_2)                -cos(alpha_2)               d2             ];
            [0              0                           0                           1              ];
        ];

% Matriz homogenea resultante
A = A_0*A_1*A_2

% ----------------------- EULER - LAGRANGE -----------------------------
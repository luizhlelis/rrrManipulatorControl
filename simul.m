clc;
clear all;
close all;

% ---------------------- 1) DENAVIT - HATENBERG ------------------------

% Rodar o Matlab com um usuário com alto privilegio

% 1.1) Carregando a matriz de Denavit-Hatenberg
mat = load('matrix/DH.mat','-mat');
dh = mat.mat.dh

dh_representation = SerialLink(dh)

% Carregando angulos iniciais das juntas (radianos)
theta_0 = 0
theta_1 = 0;
theta_2 = 0;
theta_3 = 0;
q = [theta_0, theta_1, theta_2, theta_3]

% Representacao grafica do manipulador
dh_representation.plot(q)
dh_representation.teach

% 1.2) Matrizes homogeneas

% Especificidades do manipulador em estudo
alpha_0 = 0;
alpha_1 = -pi/2;
alpha_2 = 0;
alpha_3 = 0;

a0 = 0;
a1 = 0.065;
a2 = 0.172;
a3 = 0.235;

d0 = 0;
d1 = 0.085;
d2 = 0;
d3 = 0;


A_0 =   [
            [cos(theta_0)   -sin(theta_0)*cos(alpha_0)  sin(theta_0)*sin(alpha_0)   a0*cos(theta_0)];
            [sin(theta_0)   cos(theta_0)*cos(alpha_0)   -cos(theta_0)*sin(alpha_0)  a0*sin(theta_0)];
            [0              sin(alpha_0)                cos(alpha_0)                d0             ];
            [0              0                           0                           1              ];
        ];
A_1 =   [
            [cos(theta_1)   -sin(theta_1)*cos(alpha_1)  sin(theta_1)*sin(alpha_1)   a1*cos(theta_1)];
            [sin(theta_1)   cos(theta_1)*cos(alpha_1)   -cos(theta_1)*sin(alpha_1)  a1*sin(theta_1)];
            [0              sin(alpha_1)                cos(alpha_1)                d1             ];
            [0              0                           0                           1              ];
        ];
A_2 =   [
            [cos(theta_2)   -sin(theta_2)*cos(alpha_2)  sin(theta_2)*sin(alpha_2)   a2*cos(theta_2)];
            [sin(theta_2)   cos(theta_2)*cos(alpha_2)   -cos(theta_2)*sin(alpha_2)  a2*sin(theta_2)];
            [0              sin(alpha_2)                cos(alpha_2)                d2             ];
            [0              0                           0                           1              ];
        ];
A_3 =   [
            [cos(theta_3)   -sin(theta_3)*cos(alpha_3)  sin(theta_3)*sin(alpha_3)   a3*cos(theta_3)];
            [sin(theta_3)   cos(theta_3)*cos(alpha_3)   -cos(theta_3)*sin(alpha_3)  a3*sin(theta_3)];
            [0              sin(alpha_3)                cos(alpha_3)                d3             ];
            [0              0                           0                           1              ];
        ];

% Matriz homogenea resultante
T_0_1 = A_1;
T_0_2 = A_1.*A_2;
T_0_3 = A_1.*A_2.*A_3

% ----------------------- 2) EULER - LAGRANGE -----------------------------

% 2.1) Jacobiano

% z_i = terceira coluna / o_i = quarta coluna
z_0_1 = T_0_1(1:3,3);
o_0_1 = T_0_1(1:3,4);

z_0_2 = T_0_2(1:3,3);
o_0_2 = T_0_2(1:3,4);

z_0_3 = T_0_3(1:3,3);
o_0_3 = T_0_3(1:3,4);

% Jacobianos para as juntas revolutas (SPONG)
J_1 =   [
            [z_0_1.*(o_0_3-o_0_1)];
            [z_0_1];
        ];
J_2 =   [
            [z_0_2.*(o_0_3-o_0_2)];
            [z_0_2];
        ];
J_3 =   [
            [z_0_3.*(o_0_3-o_0_3)];
            [z_0_3];
        ];
    
J =     [
            [J_1     J_2     J_3];
        ]


% Elbow manipulator / articulated / revolute / anthropomorphic / RRR

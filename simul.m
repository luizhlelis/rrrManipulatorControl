clc;
clear all;
close all;

% ---------------------- 1) DENAVIT - HATENBERG ------------------------

% Rodar o Matlab com um usuário com alto privilegio

% 1.1) Carregando a matriz de Denavit-Hatenberg
% mat = load('matrix/DH.mat','-mat');
% dh = mat.mat.dh

dh = [
    0,  0,      0,      0;
    0,  0.085,  0.065,  -pi/2;
    0,  0,      0.172,  0;
    0,  0,      0.235,  0];

dh_representation = SerialLink(dh)

% Carregando angulos iniciais das juntas (radianos)
q = [0, 0, 0, 0]

% Representacao grafica do manipulador
%dh_representation.plot(q)
%dh_representation.teach

% 1.2) Matrizes homogeneas

% Especificidades do manipulador em estudo
syms theta_0 theta_1 theta_2 theta_3;

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

% Usar quando tiver valores nos thetas
% A_0 =   [
%             [cos(theta_0)   -sin(theta_0)*cos(alpha_0)  sin(theta_0)*sin(alpha_0)   a0*cos(theta_0)];
%             [sin(theta_0)   cos(theta_0)*cos(alpha_0)   -cos(theta_0)*sin(alpha_0)  a0*sin(theta_0)];
%             [0              sin(alpha_0)                cos(alpha_0)                d0             ];
%             [0              0                           0                           1              ];
%         ];
% A_1 =   [
%             [cos(theta_1)   -sin(theta_1)*cos(alpha_1)  sin(theta_1)*sin(alpha_1)   a1*cos(theta_1)];
%             [sin(theta_1)   cos(theta_1)*cos(alpha_1)   -cos(theta_1)*sin(alpha_1)  a1*sin(theta_1)];
%             [0              sin(alpha_1)                cos(alpha_1)                d1             ];
%             [0              0                           0                           1              ];
%         ];
% A_2 =   [
%             [cos(theta_2)   -sin(theta_2)*cos(alpha_2)  sin(theta_2)*sin(alpha_2)   a2*cos(theta_2)];
%             [sin(theta_2)   cos(theta_2)*cos(alpha_2)   -cos(theta_2)*sin(alpha_2)  a2*sin(theta_2)];
%             [0              sin(alpha_2)                cos(alpha_2)                d2             ];
%             [0              0                           0                           1              ];
%         ];
% A_3 =   [
%             [cos(theta_3)   -sin(theta_3)*cos(alpha_3)  sin(theta_3)*sin(alpha_3)   a3*cos(theta_3)];
%             [sin(theta_3)   cos(theta_3)*cos(alpha_3)   -cos(theta_3)*sin(alpha_3)  a3*sin(theta_3)];
%             [0              sin(alpha_3)                cos(alpha_3)                d3             ];
%             [0              0                           0                           1              ];
%         ];

syms s0 c0 s1 c1 s2 c2 s3 c3
% Usar para exibir resultado em funcao de theta (reultado simbolico)
A_0 =   [
            [c0     -s0*cos(alpha_0)    s0*sin(alpha_0)   a0*c0];
            [s0     c0*cos(alpha_0)     -c0*sin(alpha_0)  a0*s0];
            [0      sin(alpha_0)        cos(alpha_0)      d0   ];
            [0      0                   0                 1    ];
        ];
A_1 =   [
            [c1     -s1*cos(alpha_1)    s1*sin(alpha_1)   a1*c1];
            [s1     c1*cos(alpha_1)     -c1*sin(alpha_1)  a1*s1];
            [0      sin(alpha_1)        cos(alpha_1)      d1   ];
            [0      0                   0                 1    ];
        ];
A_2 =   [
            [c2     -s2*cos(alpha_2)	s2*sin(alpha_2)   a2*c2];
            [s2     c2*cos(alpha_2)     -c2*sin(alpha_2)  a2*s2];
            [0      sin(alpha_2)        cos(alpha_2)      d2   ];
            [0      0                   0                 1    ];
        ];
A_3 =   [
            [c3     -s3*cos(alpha_3)    s3*sin(alpha_3)   a3*c3];
            [s3     c3*cos(alpha_3)     -c3*sin(alpha_3)  a3*s3];
            [0      sin(alpha_3)        cos(alpha_3)      d3   ];
            [0      0                   0                 1    ];
        ];

% Matriz homogenea resultante - z0 = [0 0 1]' e o0 = [0 0 0]'
T_0_1 = A_1;
T_0_2 = A_1*A_2;
T_0_3 = A_1*A_2*A_3;
Tresp = vpa(T_0_3,3);

R_1 = T_0_1(1:3,1:3);
R_2 = T_0_2(1:3,1:3);
R_3 = T_0_3(1:3,1:3);

% ----------------------- 2) EULER - LAGRANGE -----------------------------

% 2.1) Jacobiano

% z_i = terceira coluna / o_i = quarta coluna
z_0 = A_0(1:3,3);
o_0 = A_0(1:3,4);

z_1 = T_0_1(1:3,3);
o_1 = T_0_1(1:3,4);

z_2 = T_0_2(1:3,3);
o_2 = T_0_2(1:3,4);

z_3 = T_0_3(1:3,3);
o_3 = T_0_3(1:3,4);

% Jacobianos para as juntas revolutas (SPONG)
J_parc_1 =  [
                cross(z_0,(o_3-o_0));
                z_0;
            ];
J_parc_2 =  [
                cross(z_1,(o_3-o_1));
                z_1;
            ];
J_parc_3 =  [
                cross(z_2,(o_3-o_2));
                z_2;
            ];

% Resultados
J_1 =   [
            J_parc_1     zeros(6,2);
        ];
J_2 =   [
            J_parc_1     J_parc_2     zeros(6,1);
        ];
J_3 =   [
            J_parc_1     J_parc_2     J_parc_3;
        ];

J_1 = vpa(J_1,3);
J_2 = vpa(J_2,3);
J_3 = vpa(J_3,3);

% ----------------------------- Matriz D(q) ---------------------------

% Elbow manipulator / articulated / revolute / anthropomorphic / RRR

% As tres primeiras linhas da matriz J correspondem a velocidade linear
% e as tres ultimas a velocidade angular
J_v1 = J_1(1:3,:);
J_w1 = J_1(4:6,:);
J_v2 = J_2(1:3,:);
J_w2 = J_2(4:6,:);
J_v3 = J_3(1:3,:);
J_w3 = J_3(4:6,:);

% Barra de comprimento L e massa m (Eixo de rotação no fim da barra)
% Iy = Iz = 1/3*m*L^2, onde o eixo x eh o unico paralelo a barra

% Caso a distribuição de massa do corpo seja simétrica em relação à
% estrutura do corpo, então os produtos cruzados de inércia são 
% idênticos a zero.
m_motor = .055;
m_elo = .010;
L_1 = .085;
L_2 = .172;
L_3 = .235;

m_1 = m_elo;
m_2 = m_elo+m_motor*2;
m_3 = m_elo+m_motor*4;

I_1 =   [
            1/12*m_1*L_1^2  0               0;
            0               1/12*m_1*L_1^2  0;
            0               0               0;
        ]
I_2 =   [
            0               0               0;
            0               0               0;
            0               0               1/3*m_2*L_2^2;
        ]
I_3 =   [
            0               0               0;
            0               0               0;
            0               0               1/3*m_3*L_3^2;
        ]

D1 = m_1*(J_v1).'*J_v1+J_w1.'*R_1*I_1*R_1.'*J_w1;
D2 = m_2*(J_v2).'*J_v2+J_w2.'*R_2*I_2*R_2.'*J_w2;
D3 = m_3*(J_v3).'*J_v3+J_w3.'*R_3*I_3*R_3.'*J_w3;

D = vpa(D1,3) + vpa(D2,3) + vpa(D3,3)
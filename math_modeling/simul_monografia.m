clc;
close all;

% ---------------------- 1) DENAVIT - HATENBERG ------------------------
% Rodar o Matlab com um usuario com alto privilegio
% 1.1) Carregando a matriz de Denavit-Hatenberg

dh = [
    0,  0,      0,      0;
    0,  0.085,  0.065,  -pi/2;
    0,  0,      0.172,  0;
    0,  0,      0.235,  0];
dh_representation = SerialLink(dh)

% Carregando angulos iniciais das juntas (radianos)
q = [0, 0, 0, 0]

% Representacao grafica do manipulador
dh_representation.plot(q)
dh_representation.teach

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

syms s0 c0 s1 c1 s2 c2 s3 c3
% Usar para exibir resultado em funcao de theta (resultado simbolico)
A_0 =   [
            [c0     -s0*1    s0*0   a0*c0];
            [s0     c0*1     -c0*0  a0*s0];
            [0      0        1      d0   ];
            [0      0        0      1    ];
        ];
A_1 =   [
            [c1     -s1*0    s1*-1   a1*c1];
            [s1     c1*0     -c1*-1  a1*s1];
            [0      -1        0      d1   ];
            [0      0         0      1    ];
        ];
A_2 =   [
            [c2     -s2*1	s2*0   a2*c2];
            [s2     c2*1     -c2*0  a2*s2];
            [0      0        1      d2   ];
            [0      0        0      1    ];
        ];
A_3 =   [
            [c3     -s3*1    s3*0   a3*c3];
            [s3     c3*1     -c3*0  a3*s3];
            [0      0        1      d3   ];
            [0      0        0      1    ];
        ];

% Matriz homogenea resultante - z0 = [0 0 1]' e o0 = [0 0 0]'
T_0_1 = A_1;
T_0_2 = A_1*A_2;
T_0_3 = A_1*A_2*A_3;
Tresp = vpa(T_0_3,3);

R_1 = T_0_1(1:3,1:3);
R_2 = T_0_2(1:3,1:3);
R_3 = T_0_3(1:3,1:3);

% -------------------- 2) EULER - LAGRANGE -----------------------------

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
J_3 = vpa(J_3,3)

% ----------------------------- Matriz D(q) ---------------------------

% Elbow manipulator / articulated / revolute / anthropomorphic / RRR

% As tres primeiras linhas da matriz J correspondem a velocidade 
% linear e as tres ultimas a velocidade angular
J_v1 = J_1(1:3,:);
J_w1 = J_1(4:6,:);
J_v2 = J_2(1:3,:);
J_w2 = J_2(4:6,:);
J_v3 = J_3(1:3,:);
J_w3 = J_3(4:6,:);

% Barra de comprimento L e massa m (Eixo de rotacao no fim da barra)
% Iy = Iz = 1/3*m*L^2, onde o eixo x eh o unico paralelo a barra

% Caso a distribuicao de massa do corpo seja simetrica em relacao a
% estrutura do corpo, entao os produtos cruzados de inercia sao 
% identicos a zero
m_motor = .055;
m_elo = .010;
Raio_1 = .085;
g = 9.8;
L_1 = .085;
L_2 = .172;
L_3 = .235;

m_1 = m_elo;
m_2 = m_elo+m_motor*2;
m_3 = m_elo+m_motor*4;

I_1 =   [
            0               0               0;
            0               0               0;
            0               0               1/2*m_1*Raio_1^2;
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

% -------------------- Simbolos de Christoffel -----------------------

% Derivadas: sen(x) = cos(x) / cos(x) = -sen(x)

syms theta_1 theta_2 theta_3
D_11 = (0.065*sin(theta_1) + 0.17*cos(theta_2)*sin(theta_1) + 
    0.24*cos(theta_2)*cos(theta_3)*sin(theta_1) - 
    0.24*sin(theta_1)*sin(theta_2)*sin(theta_3))*(0.015*sin(theta_1) +
    0.04*cos(theta_2)*sin(theta_1) +
    0.054*cos(theta_2)*cos(theta_3)*sin(theta_1) - 
    0.054*sin(theta_1)*sin(theta_2)*sin(theta_3)) + (0.065*sin(theta_1) + 
    0.17*cos(theta_2)*sin(theta_1) +
    0.24*cos(theta_2)*cos(theta_3)*sin(theta_1) - 
    0.24*sin(theta_1)*sin(theta_2)*sin(theta_3))*(7.8e-3*sin(theta_1) + 
    0.021*cos(theta_2)*sin(theta_1) +
    0.028*cos(theta_2)*cos(theta_3)*sin(theta_1) - 
    0.028*sin(theta_1)*sin(theta_2)*sin(theta_3)) +(0.065*cos(theta_1) + 
    0.17*cos(theta_1)*cos(theta_2) +
    0.24*cos(theta_1)*cos(theta_2)*cos(theta_3) - 
    0.24*cos(theta_1)*sin(theta_2)*sin(theta_3))*(6.5e-4*cos(theta_1) + 
    1.7e-3*cos(theta_1)*cos(theta_2) +
    2.4e-3*cos(theta_1)*cos(theta_2)*cos(theta_3) - 
    2.4e-3*cos(theta_1)*sin(theta_2)*sin(theta_3)) +(0.065*cos(theta_1) + 
    0.17*cos(theta_1)*cos(theta_2) +
    0.24*cos(theta_1)*cos(theta_2)*cos(theta_3) - 
    0.24*cos(theta_1)*sin(theta_2)*sin(theta_3))*(0.015*cos(theta_1) + 
    0.04*cos(theta_1)*cos(theta_2) +
    0.054*cos(theta_1)*cos(theta_2)*cos(theta_3) - 
    0.054*cos(theta_1)*sin(theta_2)*sin(theta_3)) + (0.065*cos(theta_1) + 
    0.17*cos(theta_1)*cos(theta_2) +
    0.24*cos(theta_1)*cos(theta_2)*cos(theta_3) - 
    0.24*cos(theta_1)*sin(theta_2)*sin(theta_3))*(7.8e-3*cos(theta_1) + 
    0.021*cos(theta_1)*cos(theta_2) +
    0.028*cos(theta_1)*cos(theta_2)*cos(theta_3) - 
    0.028*cos(theta_1)*sin(theta_2)*sin(theta_3)) + (6.5e-4*sin(theta_1) + 
    1.7e-3*cos(theta_2)*sin(theta_1) +
    2.4e-3*cos(theta_2)*cos(theta_3)*sin(theta_1) - 
    2.4e-3*sin(theta_1)*sin(theta_2)*sin(theta_3))*(0.065*sin(theta_1) + 
    0.17*cos(theta_2)*sin(theta_1) +
    0.24*cos(theta_2)*cos(theta_3)*sin(theta_1) - 
    0.24*sin(theta_1)*sin(theta_2)*sin(theta_3));

D_12 = 1.0*cos(theta_1)*(0.17*sin(theta_2) +
    0.24*cos(theta_2)*sin(theta_3) + 
    0.24*cos(theta_3)*sin(theta_2))*(0.015*sin(theta_1) +
    0.04*cos(theta_2)*sin(theta_1) + 
    0.054*cos(theta_2)*cos(theta_3)*sin(theta_1) -
    0.054*sin(theta_1)*sin(theta_2)*sin(theta_3)) + 
    1.0*cos(theta_1)*(0.17*sin(theta_2) + 0.24*cos(theta_2)*sin(theta_3) + 
    0.24*cos(theta_3)*sin(theta_2))*(7.8e-3*sin(theta_1) +
    0.021*cos(theta_2)*sin(theta_1) + 
    0.028*cos(theta_2)*cos(theta_3)*sin(theta_1) -
    0.028*sin(theta_1)*sin(theta_2)*sin(theta_3)) - 
    1.0*sin(theta_1)*(0.17*sin(theta_2) +
    0.24*cos(theta_2)*sin(theta_3) + 
    0.24*cos(theta_3)*sin(theta_2))*(0.015*cos(theta_1) +
    0.04*cos(theta_1)*cos(theta_2) + 
    0.054*cos(theta_1)*cos(theta_2)*cos(theta_3) -
    0.054*cos(theta_1)*sin(theta_2)*sin(theta_3)) - 
    1.0*sin(theta_1)*(0.17*sin(theta_2) + 0.24*cos(theta_2)*sin(theta_3) + 
    0.24*cos(theta_3)*sin(theta_2))*(7.8e-3*cos(theta_1) +
    0.021*cos(theta_1)*cos(theta_2) + 
    0.028*cos(theta_1)*cos(theta_2)*cos(theta_3) -
    0.028*cos(theta_1)*sin(theta_2)*sin(theta_3));

D_13 = 1.0*cos(theta_1)*(0.24*cos(theta_2)*sin(theta_3) + 
    0.24*cos(theta_3)*sin(theta_2))*(0.015*sin(theta_1) +
    0.04*cos(theta_2)*sin(theta_1) + 
    0.054*cos(theta_2)*cos(theta_3)*sin(theta_1) -
    0.054*sin(theta_1)*sin(theta_2)*sin(theta_3)) - 
    1.0*sin(theta_1)*(0.24*cos(theta_2)*sin(theta_3) +
    0.24*cos(theta_3)*sin(theta_2))*(0.015*cos(theta_1) + 
    0.04*cos(theta_1)*cos(theta_2) +
    0.054*cos(theta_1)*cos(theta_2)*cos(theta_3) - 
    0.054*cos(theta_1)*sin(theta_2)*sin(theta_3));

D_21 = 0.35*cos(theta_1)*(0.17*sin(theta_2) +
    0.24*cos(theta_2)*sin(theta_3) + 
    0.24*cos(theta_3)*sin(theta_2))*(0.065*sin(theta_1) +
    0.17*cos(theta_2)*sin(theta_1) + 
    0.24*cos(theta_2)*cos(theta_3)*sin(theta_1) -
    0.24*sin(theta_1)*sin(theta_2)*sin(theta_3)) - 
    0.35*sin(theta_1)*(0.17*sin(theta_2) +
    0.24*cos(theta_2)*sin(theta_3) + 
    0.24*cos(theta_3)*sin(theta_2))*(0.065*cos(theta_1) +
    0.17*cos(theta_1)*cos(theta_2) + 
    0.24*cos(theta_1)*cos(theta_2)*cos(theta_3) -
    0.24*cos(theta_1)*sin(theta_2)*sin(theta_3));

D_22 = (0.23*sin(theta_1)*(0.17*cos(theta_2)*sin(theta_1) + 
    0.24*cos(theta_2)*cos(theta_3)*sin(theta_1) -
    0.24*sin(theta_1)*sin(theta_2)*sin(theta_3)) + 
    0.23*cos(theta_1)*(0.17*cos(theta_1)*cos(theta_2) +
    0.24*cos(theta_1)*cos(theta_2)*cos(theta_3) - 
    0.24*cos(theta_1)*sin(theta_2)*sin(theta_3))) *
    (1.0*sin(theta_1)*(0.17*cos(theta_2)*sin(theta_1) +
    0.24*cos(theta_2)*cos(theta_3)*sin(theta_1) -
    0.24*sin(theta_1)*sin(theta_2)*sin(theta_3)) +
    1.0*cos(theta_1)*(0.17*cos(theta_1)*cos(theta_2) +
    0.24*cos(theta_1)*cos(theta_2)*cos(theta_3) - 
    0.24*cos(theta_1)*sin(theta_2)*sin(theta_3))) +
    (0.12*sin(theta_1)*(0.17*cos(theta_2)*sin(theta_1) + 
    0.24*cos(theta_2)*cos(theta_3)*sin(theta_1) -
    0.24*sin(theta_1)*sin(theta_2)*sin(theta_3)) + 
    0.12*cos(theta_1)*(0.17*cos(theta_1)*cos(theta_2) +
    0.24*cos(theta_1)*cos(theta_2)*cos(theta_3) - 
    0.24*cos(theta_1)*sin(theta_2)*sin(theta_3))) *
    (1.0*sin(theta_1)*(0.17*cos(theta_2)*sin(theta_1) + 
    0.24*cos(theta_2)*cos(theta_3)*sin(theta_1) -
    0.24*sin(theta_1)*sin(theta_2)*sin(theta_3)) + 
    1.0*cos(theta_1)*(0.17*cos(theta_1)*cos(theta_2) +
    0.24*cos(theta_1)*cos(theta_2)*cos(theta_3) - 
    0.24*cos(theta_1)*sin(theta_2)*sin(theta_3))) +
    cos(theta_1)^2*(4.2e-3*cos(theta_1)^2 + 
    4.2e-3*sin(theta_1)^2) + 0.35*cos(theta_1)^2*(0.17*sin(theta_2) +
    0.24*cos(theta_2)*sin(theta_3) + 
    0.24*cos(theta_3)*sin(theta_2))^2 +
    1.0*sin(theta_1)^2*(4.2e-3*cos(theta_1)^2 + 
    4.2e-3*sin(theta_1)^2) + cos(theta_1)^2*(1.2e-3*cos(theta_1)^2 +
    1.2e-3*sin(theta_1)^2) + 0.35*sin(theta_1)^2*(0.17*sin(theta_2) +
    0.24*cos(theta_2)*sin(theta_3) + 0.24*cos(theta_3)*sin(theta_2))^2 +
    1.0*sin(theta_1)^2*(1.2e-3*cos(theta_1)^2 + 1.2e-3*sin(theta_1)^2);

D_23 = (0.23*sin(theta_1)*(0.17*cos(theta_2)*sin(theta_1) + 
    0.24*cos(theta_2)*cos(theta_3)*sin(theta_1) -
    0.24*sin(theta_1)*sin(theta_2)*sin(theta_3)) + 
    0.23*cos(theta_1)*(0.17*cos(theta_1)*cos(theta_2) +
    0.24*cos(theta_1)*cos(theta_2)*cos(theta_3) - 
    0.24*cos(theta_1)*sin(theta_2)*sin(theta_3))) *
    (1.0*cos(theta_1)*(0.24*cos(theta_1)*cos(theta_2)*cos(theta_3) - 
    0.24*cos(theta_1)*sin(theta_2)*sin(theta_3)) +
    1.0*sin(theta_1)*(0.24*cos(theta_2)*cos(theta_3)*sin(theta_1) - 
    0.24*sin(theta_1)*sin(theta_2)*sin(theta_3))) +
    cos(theta_1)^2*(4.2e-3*cos(theta_1)^2 + 4.2e-3*sin(theta_1)^2) + 
    1.0*sin(theta_1)^2*(4.2e-3*cos(theta_1)^2 +
    4.2e-3*sin(theta_1)^2) +
    0.23*cos(theta_1)^2*(0.24*cos(theta_2)*sin(theta_3) + 
    0.24*cos(theta_3)*sin(theta_2))*(0.17*sin(theta_2) +
    0.24*cos(theta_2)*sin(theta_3) + 0.24*cos(theta_3)*sin(theta_2)) + 
    0.23*sin(theta_1)^2*(0.24*cos(theta_2)*sin(theta_3) +
    0.24*cos(theta_3)*sin(theta_2))*(0.17*sin(theta_2) + 
    0.24*cos(theta_2)*sin(theta_3) + 0.24*cos(theta_3)*sin(theta_2));

D_31 = 0.23*cos(theta_1)*(0.24*cos(theta_2)*sin(theta_3) + 
    0.24*cos(theta_3)*sin(theta_2))*(0.065*sin(theta_1) +
    0.17*cos(theta_2)*sin(theta_1) + 
    0.24*cos(theta_2)*cos(theta_3)*sin(theta_1) -
    0.24*sin(theta_1)*sin(theta_2)*sin(theta_3)) - 
    0.23*sin(theta_1)*(0.24*cos(theta_2)*sin(theta_3) +
    0.24*cos(theta_3)*sin(theta_2))*(0.065*cos(theta_1) + 
    0.17*cos(theta_1)*cos(theta_2) +
    0.24*cos(theta_1)*cos(theta_2)*cos(theta_3) - 
    0.24*cos(theta_1)*sin(theta_2)*sin(theta_3));

D_32 = (0.23*cos(theta_1)*(0.24*cos(theta_1)*cos(theta_2)*cos(theta_3) - 
    0.24*cos(theta_1)*sin(theta_2)*sin(theta_3)) +
    0.23*sin(theta_1)*(0.24*cos(theta_2)*cos(theta_3)*sin(theta_1) - 
    0.24*sin(theta_1)*sin(theta_2)*sin(theta_3)))*(1.0*sin(theta_1) * 
    (0.17*cos(theta_2)*sin(theta_1) + 
    0.24*cos(theta_2)*cos(theta_3)*sin(theta_1) -
    0.24*sin(theta_1)*sin(theta_2)*sin(theta_3)) + 
    1.0*cos(theta_1)*(0.17*cos(theta_1)*cos(theta_2) +
    0.24*cos(theta_1)*cos(theta_2)*cos(theta_3) - 
    0.24*cos(theta_1)*sin(theta_2)*sin(theta_3))) +
    cos(theta_1)^2*(4.2e-3*cos(theta_1)^2 + 
    4.2e-3*sin(theta_1)^2) + 1.0*sin(theta_1)^2*(4.2e-3*cos(theta_1)^2 +
    4.2e-3*sin(theta_1)^2) + 
    0.23*cos(theta_1)^2*(0.24*cos(theta_2)*sin(theta_3) +
    0.24*cos(theta_3)*sin(theta_2))*(0.17*sin(theta_2) +
    0.24*cos(theta_2)*sin(theta_3) + 0.24*cos(theta_3)*sin(theta_2)) + 
    0.23*sin(theta_1)^2*(0.24*cos(theta_2)*sin(theta_3) +
    0.24*cos(theta_3)*sin(theta_2))*(0.17*sin(theta_2) +
    0.24*cos(theta_2)*sin(theta_3) + 0.24*cos(theta_3)*sin(theta_2));

D_33 = 0.23*cos(theta_1)^2*(0.24*cos(theta_2)*sin(theta_3) + 
    0.24*cos(theta_3)*sin(theta_2))^2 +
    0.23*sin(theta_1)^2*(0.24*cos(theta_2)*sin(theta_3) + 
    0.24*cos(theta_3)*sin(theta_2))^2 +
    cos(theta_1)^2*(4.2e-3*cos(theta_1)^2 + 
    4.2e-3*sin(theta_1)^2) + 1.0*sin(theta_1)^2*(4.2e-3*cos(theta_1)^2 +
    4.2e-3*sin(theta_1)^2) + 
    (0.23*cos(theta_1)*(0.24*cos(theta_1)*cos(theta_2)*cos(theta_3) - 
    0.24*cos(theta_1)*sin(theta_2)*sin(theta_3)) + 
    0.23*sin(theta_1)*(0.24*cos(theta_2)*cos(theta_3)*sin(theta_1) - 
    0.24*sin(theta_1)*sin(theta_2)*sin(theta_3))) * 
    (1.0*cos(theta_1)*(0.24*cos(theta_1)*cos(theta_2)*cos(theta_3) - 
    0.24*cos(theta_1)*sin(theta_2)*sin(theta_3)) +
    1.0*sin(theta_1)*(0.24*cos(theta_2)*cos(theta_3)*sin(theta_1) - 
    0.24*sin(theta_1)*sin(theta_2)*sin(theta_3)));

del_d11_theta1 = diff(D_11,theta_1);
del_d11_theta2 = diff(D_11,theta_2);
del_d11_theta3 = diff(D_11,theta_3);

del_d12_theta1 = diff(D_12,theta_1);
del_d12_theta2 = diff(D_12,theta_2);
del_d12_theta3 = diff(D_12,theta_3);

del_d13_theta1 = diff(D_13,theta_1);
del_d13_theta2 = diff(D_13,theta_2);
del_d13_theta3 = diff(D_13,theta_3);

del_d21_theta1 = diff(D_21,theta_1);
del_d21_theta2 = diff(D_21,theta_2);
del_d21_theta3 = diff(D_21,theta_3);

del_d22_theta1 = diff(D_22,theta_1);
del_d22_theta2 = diff(D_22,theta_2);
del_d22_theta3 = diff(D_22,theta_3);

del_d23_theta1 = diff(D_23,theta_1);
del_d23_theta2 = diff(D_23,theta_2);
del_d23_theta3 = diff(D_23,theta_3);

del_d31_theta1 = diff(D_31,theta_1);
del_d31_theta2 = diff(D_31,theta_2);
del_d31_theta3 = diff(D_31,theta_3);

del_d32_theta1 = diff(D_32,theta_1);
del_d32_theta2 = diff(D_32,theta_2);
del_d32_theta3 = diff(D_32,theta_3);

del_d33_theta1 = diff(D_33,theta_1);
del_d33_theta2 = diff(D_33,theta_2);
del_d33_theta3 = diff(D_33,theta_3);

c_111 = .5*(del_d11_theta1 + del_d11_theta1 - del_d11_theta1);
c_112 = .5*(del_d21_theta1 + del_d21_theta1 - del_d11_theta2);
c_113 = .5*(del_d31_theta1 + del_d31_theta1 - del_d11_theta3);

c_121 = .5*(del_d12_theta1 + del_d11_theta2 - del_d12_theta1);
c_122 = .5*(del_d22_theta1 + del_d21_theta2 - del_d12_theta2);
c_123 = .5*(del_d32_theta1 + del_d31_theta2 - del_d12_theta3);

c_131 = .5*(del_d13_theta1 + del_d11_theta3 - del_d13_theta1);
c_132 = .5*(del_d23_theta1 + del_d21_theta3 - del_d13_theta2);
c_133 = .5*(del_d33_theta1 + del_d31_theta3 - del_d13_theta3);

c_211 = .5*(del_d11_theta2 + del_d11_theta1 - del_d11_theta1);
c_212 = .5*(del_d21_theta2 + del_d21_theta1 - del_d11_theta2);
c_213 = .5*(del_d31_theta2 + del_d31_theta1 - del_d11_theta3);

c_221 = .5*(del_d12_theta2 + del_d11_theta2 - del_d12_theta1);
c_222 = .5*(del_d22_theta2 + del_d21_theta2 - del_d12_theta2);
c_223 = .5*(del_d32_theta2 + del_d31_theta2 - del_d12_theta3);

c_231 = .5*(del_d13_theta2 + del_d11_theta3 - del_d13_theta1);
c_232 = .5*(del_d23_theta2 + del_d21_theta3 - del_d13_theta2);
c_233 = .5*(del_d33_theta2 + del_d31_theta3 - del_d13_theta3);

c_311 = .5*(del_d11_theta3 + del_d11_theta1 - del_d11_theta1);
c_312 = .5*(del_d21_theta3 + del_d21_theta1 - del_d11_theta2);
c_313 = .5*(del_d31_theta3 + del_d31_theta1 - del_d11_theta3);

c_321 = .5*(del_d12_theta3 + del_d11_theta2 - del_d12_theta1);
c_322 = .5*(del_d22_theta3 + del_d21_theta2 - del_d12_theta2);
c_323 = .5*(del_d32_theta3 + del_d31_theta2 - del_d12_theta3);

c_331 = .5*(del_d13_theta3 + del_d11_theta3 - del_d13_theta1);
c_332 = .5*(del_d23_theta3 + del_d21_theta3 - del_d13_theta2);
c_333 = .5*(del_d33_theta3 + del_d31_theta3 - del_d13_theta3);

% --------------------------- Energia Potencial ---------------------

phi_1 = 0;
phi_2 = m_2*g*L_2*cos(theta2);
phi_3 = m_3*g*L_3*cos(theta2 + theta3);
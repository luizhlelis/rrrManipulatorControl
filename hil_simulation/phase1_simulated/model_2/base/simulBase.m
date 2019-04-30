clc;
close all;

load('inputBase0_01.mat')
load('outputBase0_01.mat')
load('inputBase0_23.mat')
load('outputBase0_23.mat')

darkGreen = [0, 0.5, 0];
darknessGreen = [0, 0.1, 0];

tfBase0_01 = tf([0.0102],[1 -0.9898],0.01)

% Um polo - Discreto direto
tfBase0_23 = tf(1,[.92 1])
tfBase0_23 = c2d(tfBase0_23, 0.23,'zoh')
% Dois polos
tfBase0_23_segOrdem = tf([13.3384],[1 7.3043 13.3384])
tfBase0_23_segOrdem = c2d(tfBase0_23_segOrdem, 0.23,'zoh')

timeBase0_01 = 0:0.01:19.99;
timeBase0_23 = 0:0.23:19.78;

refBase0_23_estab = zeros(1,187);
timeBase0_23_estab = 0:0.23:42.78;

for idx = 1:187
    if idx <= 145
        refBase0_23_estab(1,idx) = 290;
    else
        refBase0_23_estab(1,idx) = 200;
    end
end

resultStepBase0_01 = lsim(tfBase0_01,inputBase0_01,timeBase0_01);

resultStepBase0_23 = lsim(tfBase0_23,refBase0_23_estab,timeBase0_23_estab);
resultStepBase0_23_segOrdem = lsim(tfBase0_23_segOrdem,refBase0_23_estab,timeBase0_23_estab);

figure(1)
stairs(timeBase0_01(1,:),inputBase0_01(:,1),'b', 'LineWidth', 1.5);
hold on
stairs(timeBase0_01(1,:),outputBase0_01(:,1),'r', 'LineWidth', 1.5);
hold on
stairs(timeBase0_01(1,:),resultStepBase0_01,'Color',[0,.5,0], 'LineWidth', 1.5);
axis([5 18 180 300])
legend('degrau','real','simulado')
title('Simulacao Base Manipulador Ts = 0.01s')

figure(2)
stairs(timeBase0_23(1,:),inputBase0_23(:,1),'b', 'LineWidth', 1.5);
hold on
stairs(timeBase0_23(1,:),outputBase0_23(:,1),'r', 'LineWidth', 1.5);
hold on
stairs(timeBase0_23(1,:),resultStepBase0_23(101:187,1),'Color',darkGreen, 'LineWidth', 1.5);
hold on
stairs(timeBase0_23(1,:),resultStepBase0_23_segOrdem(101:187,1),'g', 'LineWidth', 1.5);
axis([5 18 180 300])
legend('degrau','real','simulado', 'simulado c2d', 'simulado segOrdem')
title('Simulacao Base Manipulador Ts = 0.23s')

figure(3)
stairs(timeBase0_23(1,:),inputBase0_23(:,1),'b', 'LineWidth', 1.5);
hold on
stairs(timeBase0_23(1,:),outputBase0_23(:,1),'r', 'LineWidth', 1.5);
hold on
stairs(timeBase0_23(1,:),resultStepBase0_23_segOrdem(101:187,1),'Color',darkGreen, 'LineWidth', 1.5);
axis([5 18 180 300])
legend('degrau','real','simulado')
title('Simulacao Base Manipulador Ts = 0.23s')

% ---------------------------- Malha Fechada -------------------------

% C_BASE = C_FOREARM = ( 3.74*s + 3.4 ) / s
% 
% pid = kp + ki/s + kd*s
% 
% Zero = -0.909090
% Polo = 0
% 
% Kp = 3.74
% Ki = 3.4

%c_pi = tf([3.74 3.4],[1 0])
%c_pi = c2d(c_pi,0.23,'zoh')
c_pi = tf([0.41305 -0.200783605],[1 -1],0.23)
mf_Base = feedback(c_pi*tfBase0_23_segOrdem,1)

result_mf_step_base = lsim(mf_Base,refBase0_23_estab,timeBase0_23_estab);

figure(4)
stairs(timeBase0_23(1,:),inputBase0_23(:,1),'b', 'LineWidth', 1.5);
hold on
stairs(timeBase0_23(1,:),outputBase0_23(:,1),'r', 'LineWidth', 1.5);
hold on
stairs(timeBase0_23(1,:),result_mf_step_base(101:187,1),'b','Color',darkGreen, 'LineWidth', 1.5);
axis([5 18 180 300])
legend('degrau','real','simulado')
title('Simulacao MF Base Manipulador')
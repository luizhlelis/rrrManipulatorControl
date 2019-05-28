clc;
close all;

load('inputShoulder0_23.mat')
load('outputShoulder0_23.mat')

darkGreen = [0, 0.5, 0];
darknessGreen = [0, 0.1, 0];

% Um polo - Discreto direto
tfShoulder0_23 = tf(1,[.92 1])
tfShoulder0_23 = c2d(tfShoulder0_23, 0.23,'zoh')
% Dois polos c2d (MELHOR RESULTADO)
% tfShoulder0_23_segOrdem = tf([13.3384],[1 7.3043 13.3384])
tfShoulder0_23_segOrdem = tf([.9965*28.69898],[1 8.5714 28.69898])
tfShoulder0_23_segOrdem = c2d(tfShoulder0_23_segOrdem, 0.23,'zoh')

timeShoulder0_23 = 0:0.23:19.78;

refShoulder0_23_estab = zeros(1,187);
timeShoulder0_23_estab = 0:0.23:42.78;

for idx = 1:187
    if idx <= 145
        refShoulder0_23_estab(1,idx) = 40;
    else
        refShoulder0_23_estab(1,idx) = 80;
    end
end

resultStepShoulder0_23 = lsim(tfShoulder0_23,refShoulder0_23_estab,timeShoulder0_23_estab);
resultStepShoulder0_23_segOrdem = lsim(tfShoulder0_23_segOrdem,refShoulder0_23_estab,timeShoulder0_23_estab);

figure(1)
stairs(timeShoulder0_23(1,:),inputShoulder0_23(:,1),'b', 'LineWidth', 1.5);
hold on
stairs(timeShoulder0_23(1,:),outputShoulder0_23(:,1),'r', 'LineWidth', 1.5);
hold on
stairs(timeShoulder0_23(1,:),resultStepShoulder0_23(101:187,1),'Color',darkGreen, 'LineWidth', 1.5);
hold on
stairs(timeShoulder0_23(1,:),resultStepShoulder0_23_segOrdem(101:187,1),'g', 'LineWidth', 1.5);
axis([5 18 35 85])
legend('degrau','real','simulado', 'simulado segOrdem')
title('Simulacao Shoulder Manipulador T = 0.23s')

figure(2)
stairs(timeShoulder0_23(1,:),inputShoulder0_23(:,1),'b', 'LineWidth', 1.5);
hold on
stairs(timeShoulder0_23(1,:),outputShoulder0_23(:,1),'r', 'LineWidth', 1.5);
hold on
stairs(timeShoulder0_23(1,:),resultStepShoulder0_23_segOrdem(101:187,1),'Color',darkGreen, 'LineWidth', 1.5);
axis([5 18 35 85])
legend('degrau','real','simulado')
%title('Simulacao Shoulder Manipulador T = 0.23s')

% ---------------------------- Malha Fechada -------------------------

% C_BASE = C_FOREARM = C_SHOULDER = ( 3.74*s + 3.4 ) / s
% 
% pid = kp + ki/s + kd*s
% 
% Zero = -0.909090
% Polo = 0
% 
% Kp = 3.74
% Ki = 3.4

% c_pi = tf([3.74 3.4],[1 0])
% c_pi = c2d(c_pi,0.23,'zoh')
c_pi = tf([0.15724 0.065128808],[1 -1],0.23)

mf_shoulder = feedback(c_pi*tfShoulder0_23_segOrdem,1)

result_mf_step_shoulder = lsim(mf_shoulder,refShoulder0_23_estab,timeShoulder0_23_estab);

figure(3)
stairs(timeShoulder0_23(1,:),inputShoulder0_23(:,1),'b', 'LineWidth', 1.5);
hold on
stairs(timeShoulder0_23(1,:),outputShoulder0_23(:,1),'r', 'LineWidth', 1.5);
hold on
stairs(timeShoulder0_23(1,:),result_mf_step_shoulder(101:187,1),'b','Color',darkGreen, 'LineWidth', 1.5);
axis([5 18 35 85])
legend('degrau','real','simulado')
%title('Simulacao MF Shoulder Manipulador')

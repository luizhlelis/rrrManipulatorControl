clc;
close all;

load('inputForearm0_23.mat')
load('outputForearm0_23.mat')

darkGreen = [0, 0.5, 0];
darknessGreen = [0, 0.1, 0];

% Um polo - Discreto direto
tfForearm0_23 = tf(1,[.92 1])
tfForearm0_23 = c2d(tfForearm0_23, 0.23,'zoh')
% Dois polos c2d (MELHOR RESULTADO)
tfForearm0_23_segOrdem = tf([13.3384],[1 7.3043 13.3384])
tfForearm0_23_segOrdem = c2d(tfForearm0_23_segOrdem, 0.23,'zoh')

timeForearm0_23 = 0:0.23:19.78;

refForearm0_23_estab = zeros(1,187);
timeForearm0_23_estab = 0:0.23:42.78;

for idx = 1:187
    if idx <= 145
        refForearm0_23_estab(1,idx) = 32;
    else
        refForearm0_23_estab(1,idx) = 100;
    end
end

resultStepForearm0_23 = lsim(tfForearm0_23,refForearm0_23_estab,timeForearm0_23_estab);
resultStepForearm0_23_segOrdem = lsim(tfForearm0_23_segOrdem,refForearm0_23_estab,timeForearm0_23_estab);

figure(1)
stairs(timeForearm0_23(1,:),inputForearm0_23(:,1),'b', 'LineWidth', 1.5);
hold on
stairs(timeForearm0_23(1,:),outputForearm0_23(:,1),'r', 'LineWidth', 1.5);
hold on
stairs(timeForearm0_23(1,:),resultStepForearm0_23(101:187,1),'Color',darkGreen, 'LineWidth', 1.5);
hold on
stairs(timeForearm0_23(1,:),resultStepForearm0_23_segOrdem(101:187,1),'g', 'LineWidth', 1.5);
axis([5 18 20 115])
legend('degrau','real','simulado', 'simulado segOrdem')
title('Simulacao Forearm Manipulador T = 0.23s')

figure(2)
stairs(timeForearm0_23(1,:),inputForearm0_23(:,1),'b', 'LineWidth', 1.5);
hold on
stairs(timeForearm0_23(1,:),outputForearm0_23(:,1),'r', 'LineWidth', 1.5);
hold on
stairs(timeForearm0_23(1,:),resultStepForearm0_23_segOrdem(101:187,1),'Color',darkGreen, 'LineWidth', 1.5);
axis([5 18 20 115])
legend('degrau','real','simulado')
title('Simulacao Forearm Manipulador T = 0.23s')


% ----------------------------- MALHA FECHADA ----------------------------

% C_BASE = C_FOREARM = ( 3.74*s + 3.4 ) / s
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
c_pi = tf([0.41305 -0.200783605],[1 -1],0.23)
mf_forearm = feedback(c_pi*tfForearm0_23_segOrdem,1)

result_mf_step_forearm = lsim(mf_forearm,refForearm0_23_estab,timeForearm0_23_estab);

figure(3)
stairs(timeForearm0_23(1,:),inputForearm0_23(:,1),'b', 'LineWidth', 1.5);
hold on
stairs(timeForearm0_23(1,:),outputForearm0_23(:,1),'r', 'LineWidth', 1.5);
hold on
stairs(timeForearm0_23(1,:),result_mf_step_forearm(101:187,1),'b','Color',darkGreen, 'LineWidth', 1.5);
axis([5 18 20 115])
legend('degrau','real','simulado')
title('Simulacao MF Forearm Manipulador')

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
tfBase0_23 = tf([0.1657],[1 -0.8339],0.23)
% Um polo - Continuo e depois discreto c2d()
tfBase0_23_c2d = tf([0.2132],[1 -0.7864],0.23)
% Dois polos
% tfBase0_23_segOrdem = tf([0.06611 0 0],[1 -1.621 .6865],0.23)
% Tres polos
% tfBase0_23_segOrdem = tf([0.02781 0 0],[1 -2.431 2.077 -0.6184],0.23)
% Dois polos c2d (MELHOR RESULTADO)
tfBase0_23_segOrdem = tf([0.06258 0.05215],[1 -1.465 .5797],0.23)

timeBase0_01 = 0:0.01:19.99;
refBase0_01 = zeros(1,2000);

timeBase0_23 = 0:0.23:19.78;
refBase0_23 = zeros(1,87);

for idx = 1:2000
    if idx <= 1000
        refBase0_01(1,idx) = 290;
    else
        refBase0_01(1,idx) = 200;
    end
end

for idx = 1:87
    if idx <= 44
        refBase0_23(1,idx) = 290;
    else
        refBase0_23(1,idx) = 200;
    end
end

refBase0_23_estab = zeros(1,187);
timeBase0_23_estab = 0:0.23:42.78;

for idx = 1:187
    if idx <= 144
        refBase0_23_estab(1,idx) = 290;
    else
        refBase0_23_estab(1,idx) = 200;
    end
end

resultStepBase0_01 = lsim(tfBase0_01,refBase0_01,timeBase0_01);

resultStepBase0_23 = lsim(tfBase0_23,refBase0_23_estab,timeBase0_23_estab);
resultStepBase0_23_c2d = lsim(tfBase0_23_c2d,refBase0_23_estab,timeBase0_23_estab);
resultStepBase0_23_segOrdem = lsim(tfBase0_23_segOrdem,refBase0_23_estab,timeBase0_23_estab);

figure(1)
stairs(timeBase0_01(1,:),refBase0_01(1,:),'b', 'LineWidth', 1.5);
hold on
stairs(timeBase0_01(1,:),outputBase0_01(:,1),'r', 'LineWidth', 1.5);
hold on
stairs(timeBase0_01(1,:),resultStepBase0_01,'Color',[0,.5,0], 'LineWidth', 1.5);
axis([5 18 180 300])
legend('degrau','real','simulado')
title('Simulacao Base Manipulador Ts = 0.01s')

figure(2)
stairs(timeBase0_23(1,:),refBase0_23(1,:),'b', 'LineWidth', 1.5);
hold on
stairs(timeBase0_23(1,:),outputBase0_23(:,1),'r', 'LineWidth', 1.5);
hold on
stairs(timeBase0_23(1,:),resultStepBase0_23(101:187,1),'Color',darkGreen, 'LineWidth', 1.5);
hold on
stairs(timeBase0_23(1,:),resultStepBase0_23_c2d(101:187,1),'Color',darknessGreen, 'LineWidth', 1.5);
hold on
stairs(timeBase0_23(1,:),resultStepBase0_23_segOrdem(101:187,1),'g', 'LineWidth', 1.5);
axis([5 18 180 300])
legend('degrau','real','simulado', 'simulado c2d', 'simulado segOrdem')
title('Simulacao Base Manipulador Ts = 0.23s')

figure(3)
stairs(timeBase0_23(1,:),refBase0_23(1,:),'b', 'LineWidth', 1.5);
hold on
stairs(timeBase0_23(1,:),outputBase0_23(:,1),'r', 'LineWidth', 1.5);
hold on
stairs(timeBase0_23(1,:),resultStepBase0_23_segOrdem(101:187,1),'Color',darkGreen, 'LineWidth', 1.5);
axis([5 18 180 300])
legend('degrau','real','simulado')
title('Simulacao Base Manipulador Ts = 0.23s')
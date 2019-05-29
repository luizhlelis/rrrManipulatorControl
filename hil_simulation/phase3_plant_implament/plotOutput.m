clc;
close all;

load('data/step/base_215_150/outputBase0_23.mat')
load('data/step/shoulder_27_80/outputShoulder0_23.mat')
load('data/step/forearm_28_100/outputForearm0_23.mat')

darkGreen = [0, 0.5, 0];
darknessGreen = [0, 0.1, 0];

timeForearm0_23 = 0:0.23:19.78;

refBase0_23 = zeros(1,87);
refShoulder0_23 = zeros(1,87);
refForearm0_23 = zeros(1,87);

for idx = 1:87
    if idx <= 45
        refBase0_23(1,idx) = 215.0390625;
        refShoulder0_23(1,idx) = 27.685546875;
        refForearm0_23(1,idx) = 27.685546875;
    else
        refBase0_23(1,idx) = 150;
        refShoulder0_23(1,idx) = 80;
        refForearm0_23(1,idx) = 100;
    end
end

figure(1)
stairs(timeForearm0_23(1,:),refBase0_23(1,:),'b', 'LineWidth', 1.5);
hold on
stairs(timeForearm0_23(1,:),outputBase0_23(:,1),'Color',darkGreen, 'LineWidth', 1.5);
axis([5 18 140 225])
legend('degrau','resposta')

figure(2)
stairs(timeForearm0_23(1,:),refShoulder0_23(1,:),'b', 'LineWidth', 1.5);
hold on
stairs(timeForearm0_23(1,:),outputShoulder0_23(:,1),'Color',darkGreen, 'LineWidth', 1.5);
axis([5 18 20 85])
legend('degrau','resposta')

figure(3)
stairs(timeForearm0_23(1,:),refForearm0_23(1,:),'b', 'LineWidth', 1.5);
hold on
stairs(timeForearm0_23(1,:),outputForearm0_23(:,1),'Color',darkGreen, 'LineWidth', 1.5);
axis([5 18 20 110])
legend('degrau','resposta')


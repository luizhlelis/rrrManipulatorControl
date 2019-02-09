clc;
clear all;
close all;

load('base/input_base_01s.mat')
load('base/output_base_01s.mat')
load('shoulder/output_shoulder_01s.mat')
load('shoulder/input_shoulder_01s.mat')
load('forearm/output_forearm_01s.mat')
load('forearm/input_forearm_01s.mat')

tf_base = tf([1.005],[1 1.006])
time_base = 0:0.01:19.99;
ref_base = zeros(1,2000);

for idx = 1:2000
    if idx <= 1000
        ref_base(1,idx) = 290;
    else
        ref_base(1,idx) = 200;
    end
end

result_step_base = lsim(tf_base,ref_base,time_base);

figure(1)
plot(time_base(1,:),ref_base(1,:),'b');
hold on
plot(output_base_01s(:,1),output_base_01s(:,2),'r');
hold on
plot(time_base(1,:),result_step_base,'g');
axis([5 18 180 300])
legend('degrau','real','simulado')
title('Simulacao Base Manipulador')

tf_shoulder = tf([1.583],[1 1.596])
time_shoulder = 0:0.01:19.99;
ref_shoulder = zeros(1,2000);

for idx = 1:2000
    if idx <= 1000
        ref_shoulder(1,idx) = 40;
    else
        ref_shoulder(1,idx) = 80;
    end
end

result_step_shoulder = lsim(tf_shoulder,ref_shoulder,time_shoulder);

figure(2)
plot(time_shoulder(1,:),ref_shoulder(1,:),'b');
hold on
plot(output_shoulder_01s(:,1),output_shoulder_01s(:,2),'r');
hold on
plot(time_shoulder(1,:),result_step_shoulder,'g');
axis([5 20 30 100])
legend('degrau','real','simulado')
title('Simulacao Ombro Manipulador')


tf_forearm = tf([0.9556],[1 0.9407])
time_forearm = 0:0.01:19.99;
ref_forearm = zeros(1,2000);

for idx = 1:2000
    if idx <= 1000
        ref_forearm(1,idx) = 32;
    else
        ref_forearm(1,idx) = 100;
    end
end

result_step_forearm = lsim(tf_forearm,ref_forearm,time_forearm);

figure(3)
plot(time_forearm(1,:),ref_forearm(1,:),'b');
hold on
plot(output_forearm_01s(:,1),output_forearm_01s(:,2),'r');
hold on
plot(time_forearm(1,:),result_step_forearm,'g');
axis([5 20 20 110])
legend('degrau','real','simulado')
title('Simulacao Ombro Manipulador')
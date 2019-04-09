clc;
close all;

% SO PRO BILLA SABER QUAIS SAO AS FUNCOES DE TRANSFERENCIA

% tf_base = tf([1.005],[1 1.006]);
% tf_base = c2d(tf_base,0.01,'zoh')
% c_base = tf([3.762 3.42],[1 0])
% c_base = c2d(c_base,0.01,'zoh')
% 
% tf_shoulder = tf([1.583],[1 1.596])
% tf_shoulder = c2d(tf_shoulder,0.01,'zoh')
% c_shoulder = tf([2.2436 3.16],[1 0])
% c_shoulder = c2d(c_shoulder,0.01,'zoh')
% 
% tf_forearm = tf([0.9556],[1 0.9407])
% tf_forearm = c2d(tf_forearm,0.01,'zoh')
% c_forearm = tf([3.74 3.4],[1 0])
% c_forearm = c2d(c_forearm,0.01,'zoh')

% BASE
r_k_base = 290;
y_k_base = 290;
y_k_base_delay = 290;
u_k_base = 0;
u_k_base_delay = 0;
e_k_base = 0;
e_k_base_delay = 0;
y_k_base_Output = zeros(1,2000);
r_k_base_Output = zeros(1,2000);
u_k_base_Output = zeros(1,2000);

x_axis = zeros(1,2000);

% SHOULDER
r_k_shoulder = 40;
y_k_shoulder = 40;
y_k_shoulder_delay = 40;
u_k_shoulder = 0;
u_k_shoulder_delay = 0;
e_k_shoulder = 0;
e_k_shoulder_delay = 0;
y_k_shoulder_Output = zeros(1,2000);
r_k_shoulder_Output = zeros(1,2000);
u_k_shoulder_Output = zeros(1,2000);

% FOREARM
r_k_forearm = 32;
y_k_forearm = 32;
y_k_forearm_delay = 32;
u_k_forearm = 0;
u_k_forearm_delay = 0;
e_k_forearm = 0;
e_k_forearm_delay = 0;
y_k_forearm_Output = zeros(1,2000);
r_k_forearm_Output = zeros(1,2000);
u_k_forearm_Output = zeros(1,2000);

for idx = 1:2000
    
    if idx <= 1000
        r_k_base = 290;
        r_k_shoulder = 40;
        r_k_forearm = 32;
    else
        r_k_base = 200;
        r_k_shoulder = 80;
        r_k_forearm = 100;
    end
    
    e_k_base = r_k_base - y_k_base;
    e_k_shoulder = r_k_shoulder - y_k_shoulder;
    e_k_forearm = r_k_forearm - y_k_forearm;
    
    u_k_base = u_k_base_delay + 3.762*e_k_base - 3.728*e_k_base_delay;
    u_k_shoulder = u_k_shoulder_delay + 2.244*e_k_shoulder - 2.212*e_k_shoulder_delay;
    u_k_forearm = u_k_forearm_delay + 3.74*e_k_forearm - 3.706*e_k_forearm_delay;
    
    pause(0.01)
      
    y_k_base = 0.01*u_k_base_delay + 0.99*y_k_base_delay;
    y_k_shoulder = 0.0157*u_k_shoulder_delay + 0.9842*y_k_shoulder_delay;
    y_k_forearm = 0.0095*u_k_forearm_delay + 0.9906*y_k_forearm_delay;
    
    y_k_base_Output(idx) = y_k_base;
    y_k_shoulder_Output(idx) = y_k_shoulder;
    y_k_forearm_Output(idx) = y_k_forearm;
    
    r_k_base_Output(idx) = r_k_base;
    r_k_shoulder_Output(idx) = r_k_shoulder;
    r_k_forearm_Output(idx) = r_k_forearm;
    
    u_k_base_Output(idx) = u_k_base;
    u_k_shoulder_Output(idx) = u_k_shoulder;
    u_k_forearm_Output(idx) = u_k_forearm;
    
    x_axis(idx) = idx;
    
	y_k_base_delay = y_k_base;
	u_k_base_delay = u_k_base;
    e_k_base_delay = e_k_base;
    
	y_k_shoulder_delay = y_k_shoulder;
	u_k_shoulder_delay = u_k_shoulder;
    e_k_shoulder_delay = e_k_shoulder;
    
	y_k_forearm_delay = y_k_forearm;
	u_k_forearm_delay = u_k_forearm;
    e_k_forearm_delay = e_k_forearm;
end

figure(1)
stairs(x_axis(1,:),r_k_base_Output(1,:),'b');
hold on
stairs(x_axis(1,:),y_k_base_Output(1,:),'g');
legend('degrau','resposta')
title('Simulacao Base Manipulador')

figure(2)
stairs(x_axis(1,:),u_k_base_Output(1,:),'b');
title('Acao de Controle')

figure(3)
stairs(x_axis(1,:),r_k_shoulder_Output(1,:),'b');
hold on
stairs(x_axis(1,:),y_k_shoulder_Output(1,:),'g');
legend('degrau','resposta')
title('Simulacao shoulder Manipulador')

figure(4)
stairs(x_axis(1,:),u_k_shoulder_Output(1,:),'b');
title('Acao de Controle')

figure(5)
stairs(x_axis(1,:),r_k_forearm_Output(1,:),'b');
hold on
stairs(x_axis(1,:),y_k_forearm_Output(1,:),'g');
legend('degrau','resposta')
title('Simulacao forearm Manipulador')

figure(6)
stairs(x_axis(1,:),u_k_forearm_Output(1,:),'b');
title('Acao de Controle')
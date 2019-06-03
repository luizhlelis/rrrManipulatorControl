clc;
close all;

% BASE
r_k_base = 215;
y_k_base = 215;
y_k_base_delay = 215;
y_k_base_delay_2 = 215;
u_k_base = 215;
u_k_base_delay = 215;
u_k_base_delay_2 = 215;
e_k_base = 0;
e_k_base_delay = 0;
y_k_base_Output = zeros(1,87);
r_k_base_Output = zeros(1,87);
u_k_base_Output = zeros(1,87);

x_axis = zeros(1,87);

% SHOULDER
r_k_shoulder = 40;
y_k_shoulder = 40;
y_k_shoulder_delay = 40;
y_k_shoulder_delay_2 = 40;
u_k_shoulder = 40;
u_k_shoulder_delay = 40;
u_k_shoulder_delay_2 = 40;
e_k_shoulder = 0;
e_k_shoulder_delay = 0;
y_k_shoulder_Output = zeros(1,87);
r_k_shoulder_Output = zeros(1,87);
u_k_shoulder_Output = zeros(1,87);

% FOREARM
r_k_forearm = 32;
y_k_forearm = 32;
y_k_forearm_delay = 32;
y_k_forearm_delay_2 = 32;
u_k_forearm = 32;
u_k_forearm_delay = 32;
u_k_forearm_delay_2 = 32;
e_k_forearm = 0;
e_k_forearm_delay = 0;
y_k_forearm_Output = zeros(1,87);
r_k_forearm_Output = zeros(1,87);
u_k_forearm_Output = zeros(1,87);

for idx = 1:87
    
    if idx <= 45
        r_k_base = 215;
        r_k_shoulder = 40;
        r_k_forearm = 32;
    else
        r_k_base = 150;
        r_k_shoulder = 80;
        r_k_forearm = 100;
    end
    
    e_k_base = r_k_base - y_k_base;
    e_k_shoulder = r_k_shoulder - y_k_shoulder;
    e_k_forearm = r_k_forearm - y_k_forearm;
    
    % Sem sem zero nao minimo
    u_k_base = u_k_base_delay + 0.152*e_k_base + 0.032*e_k_base_delay;
    u_k_shoulder = u_k_shoulder_delay + 0.1572*e_k_shoulder + 0.06513*e_k_shoulder_delay;
    u_k_forearm = u_k_forearm_delay + 0.152*e_k_forearm + 0.032*e_k_forearm_delay;
      
    y_k_base = 0.8273*u_k_base_delay - 0.6543*u_k_base_delay_2 + 0.9515*y_k_base_delay - 0.1245*y_k_base_delay_2;
    y_k_shoulder = 0.3876*u_k_shoulder_delay + 0.198*u_k_shoulder_delay_2 + 0.5515*y_k_shoulder_delay - 0.1393*y_k_shoulder_delay_2;
    y_k_forearm = 0.8273*u_k_forearm_delay - 0.6543*u_k_forearm_delay_2 + 0.9515*y_k_forearm_delay - 0.1245*y_k_forearm_delay_2;
    
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
    
	y_k_base_delay_2 = y_k_base_delay;
	u_k_base_delay_2 = u_k_base_delay;    
	y_k_base_delay = y_k_base;
	u_k_base_delay = u_k_base;
    e_k_base_delay = e_k_base;
    
    y_k_shoulder_delay_2 = y_k_shoulder_delay;
    u_k_shoulder_delay_2 = u_k_shoulder_delay;
	y_k_shoulder_delay = y_k_shoulder;
	u_k_shoulder_delay = u_k_shoulder;
    e_k_shoulder_delay = e_k_shoulder;
    
    y_k_forearm_delay_2 = y_k_forearm_delay;
    u_k_forearm_delay_2 = u_k_forearm_delay;
	y_k_forearm_delay = y_k_forearm;
	u_k_forearm_delay = u_k_forearm;
    e_k_forearm_delay = e_k_forearm;
end

figure(1)
stairs(x_axis(1,:),r_k_base_Output(1,:),'b');
hold on
stairs(x_axis(1,:),y_k_base_Output(1,:),'r');
legend('degrau','resposta')
title('Simulacao Base Manipulador')

figure(2)
stairs(x_axis(1,:),u_k_base_Output(1,:),'b');
title('Acao de Controle')

figure(3)
stairs(x_axis(1,:),r_k_shoulder_Output(1,:),'b');
hold on
stairs(x_axis(1,:),y_k_shoulder_Output(1,:),'r');
legend('degrau','resposta')
title('Simulacao shoulder Manipulador')

figure(4)
stairs(x_axis(1,:),u_k_shoulder_Output(1,:),'b');
title('Acao de Controle')

figure(5)
stairs(x_axis(1,:),r_k_forearm_Output(1,:),'b');
hold on
stairs(x_axis(1,:),y_k_forearm_Output(1,:),'r');
legend('degrau','resposta')
title('Simulacao forearm Manipulador')

figure(6)
stairs(x_axis(1,:),u_k_forearm_Output(1,:),'b');
title('Acao de Controle')

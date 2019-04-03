clc;
close all;

r_k = 290;
y_k = 290;
y_k_delay = 290;
u_k = 0;
u_k_delay = 0;
e_k = 0;
e_k_delay = 0;
y_k_Output_Base = zeros(1,2000);
r_k_Output_Base = zeros(1,2000);
u_k_Output_Base = zeros(1,2000);
x_axis = zeros(1,2000);

for idx = 1:2000
    
    if idx <= 1000
        r_k = 290;
    else
        r_k = 200;
    end
    
    e_k = r_k - y_k;
    
    u_k = u_k_delay + 3.762*e_k - 3.728*e_k_delay;
    
    y_k = 0.01*u_k_delay + 0.09*y_k_delay;
    
    y_k_Output_Base(idx) = y_k;
    
    r_k_Output_Base(idx) = r_k;
    
    u_k_Output_Base(idx) = u_k;
    
    x_axis(idx) = idx;
    
	y_k_delay = y_k;
	u_k_delay = u_k;
end

figure(1)
stairs(x_axis(1,:),r_k_Output_Base(1,:),'b');
hold on
stairs(x_axis(1,:),y_k_Output_Base(1,:),'g');
legend('degrau','resposta')
title('Simulacao Base Manipulador')

figure(2)
stairs(x_axis(1,:),u_k_Output_Base(1,:),'b');
title('Acao de Controle')
# -*- coding: utf-8 -*-
#############################################################################
# HIL - Fase 2 Validando o controle do Hardware na planta simulada
# Planta Simulada
# Nome: Luiz Henrique Silva Lelis
#############################################################################
import os, time, random
import matplotlib.pyplot as plt
import serial

# maximum priority
os.nice(19)

############################################################
# definicoes globais
ser = serial.Serial(
 port='/dev/ttyUSB0',
 baudrate = 115200,
 parity=serial.PARITY_NONE,
 stopbits=serial.STOPBITS_ONE,
 bytesize=serial.EIGHTBITS,
 timeout=1
)

print(ser.name)

outputFileBaseControl 		= open('data/control/outputBase.txt', 'w')
outputFileShoulderControl 	= open('data/control/outputShoulder.txt', 'w')
outputFileForearmControl 	= open('data/control/outputForearm.txt', 'w')

outputFileBase 		= open('data/output/outputBase.txt', 'w')
outputFileShoulder 	= open('data/output/outputShoulder.txt', 'w')
outputFileForearm 	= open('data/output/outputForearm.txt', 'w')

time.sleep(3)

# variaveis de plot
x_axis_List			= list()
r_k_Input_Base		= list()
r_k_Input_Shoulder	= list()
r_k_Input_Forearm	= list()
y_k_Output_Base		= list()
y_k_Output_Shoulder	= list()
y_k_Output_Forearm	= list()

u_k = list()
y_k_delay = [290, 40, 32]
y_k_delay_2 = [290, 40, 32]
u_k_delay = [290, 40, 32]
u_k_delay_2 = [290, 40, 32]

# Condicaoes Iniciais [base, shoulder, forearm]
r_k = [290, 40, 32]
y_k = [290, 40, 32]
u_k_string = ""
y_k_string = ""

############################################################
# main loop
############################################################
print "---------------------------------\nInicializando a planta simulada..."

idx = 0

while idx <= 87: # tempo de simulacao

	# A referencia r(k) eh construida no controlador, ele 
	# esta aqui apenas para visualizacao grafica
	if idx <= 45:
		r_k = [290, 40, 32]
	else:
		r_k = [200, 80, 100]

	print "Iteracao: " + str(idx)

	y_k_string = ','.join(str(aux) for aux in y_k)

	print "Valor Escrito:"
	print y_k_string

	ser.write(y_k_string)

	# Espera ter valor escrito no buffer de entrada
	while u_k_string=="":
		u_k_string = ser.readline()

	print "Valor Lido:"

	# Tratando quando os dados sao recebidos como string
	if type(u_k_string) is str:
		u_k_string = u_k_string.split(',')

	if (type(u_k_string[0]) is str) or (type(u_k_string[1]) is str) or (type(u_k_string[2]) is str):
		for charac in u_k_string:
			u_k.append(float(charac))

	print u_k

	# BASE - Funcao de transferência da planta
	y_k[0] = 0.8273*u_k_delay[0] - 0.6543*u_k_delay_2[0] + 0.9515*y_k_delay[0] - 0.1245*y_k_delay_2[0]

	# SHOULDER - Funcao de transferência da planta
	y_k[1] = 0.3876*u_k_delay[1] + 0.198*u_k_delay_2[1] + 0.5515*y_k_delay[1] - 0.1393*y_k_delay_2[1];

	# FOREARM - Funcao de transferência da planta
	y_k[2] = 0.8273*u_k_delay[2] - 0.6543*u_k_delay_2[2] + 0.9515*y_k_delay[2] - 0.1245*y_k_delay_2[2];

	x_axis_List.append(idx)

	r_k_Input_Base.append(r_k[0])
	y_k_Output_Base.append(y_k[0])

	r_k_Input_Shoulder.append(r_k[1])
	y_k_Output_Shoulder.append(y_k[1])

	r_k_Input_Forearm.append(r_k[2])
	y_k_Output_Forearm.append(y_k[2])

	# Arquivo de saida acao de controle
	outputFileBase.write(str(idx) + ',' + str(y_k[0]) + '\n')
	outputFileShoulder.write(str(idx) + ',' + str(y_k[1]) + '\n')
	outputFileForearm.write(str(idx) + ',' + str(y_k[2]) + '\n')

	# Arquivo de saida y(k)
	outputFileBaseControl.write(str(idx) + ',' + str(u_k[0]) + '\n')
	outputFileShoulderControl.write(str(idx) + ',' + str(u_k[1]) + '\n')
	outputFileForearmControl.write(str(idx) + ',' + str(u_k[2]) + '\n')

	# Pegando os valores da iteracao anterior
	y_k_delay_2 = y_k_delay
	y_k_delay = y_k
	u_k_delay_2 = u_k_delay
	u_k_delay = u_k

	# Reinicializando os valores atuais
	u_k = list()
	u_k_string = ""

	idx+=1

############################################################
# destruindo objetos
outputFileBase.close()
outputFileBaseControl.close()
outputFileShoulderControl.close()
outputFileForearmControl.close()
outputFileBase.close()
outputFileShoulder.close()
outputFileForearm.close()

print "Finalizando..."

############################################################
# plota resultados
plt.figure(1)
plt.plot(x_axis_List, r_k_Input_Base, 'r.-', label='referencia')
plt.plot(x_axis_List, y_k_Output_Base, 'b.-', label='saida')
plt.legend(loc='lower right')

plt.figure(2)
plt.plot(x_axis_List, r_k_Input_Shoulder, 'r.-', label='referencia')
plt.plot(x_axis_List, y_k_Output_Shoulder, 'b.-', label='saida')
plt.legend(loc='lower right')

plt.figure(3)
plt.plot(x_axis_List, r_k_Input_Forearm, 'r.-', label='referencia')
plt.plot(x_axis_List, y_k_Output_Forearm, 'b.-', label='saida')
plt.legend(loc='lower right')

plt.show()
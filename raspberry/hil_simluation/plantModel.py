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
 baudrate = 9600,
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
y_k_delay = [0, 0, 0]
u_k_delay = [0, 0, 0]

# Condicaoes Iniciais [base, shoulder, forearm]
r_k = [290, 40, 32]
y_k = [290, 40, 32]
e_k = [0, 0, 0]
u_k_string = ""
e_k_string = ""

############################################################
# main loop
############################################################
print "---------------------------------\nInicializando a planta simulada..."

idx = 0

while idx <= 200: # tempo de simulacao

	print "Iteracao: " + str(idx)

	# Construindo a referencia r(k)
	if idx <= 100:
		r_k = [290, 40, 32]
	else:
		r_k = [200, 80, 100]

	e_k[0] = r_k[0] - y_k[0]
	e_k[1] = r_k[1] - y_k[1]
	e_k[2] = r_k[2] - y_k[2]

	e_k_string = ','.join(str(aux) for aux in e_k)

	print "Valor Escrito:"
	print e_k_string

	ser.write(e_k_string)

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
	y_k[0] = 0.01*u_k_delay[0] + 0.09*y_k_delay[0]

	# SHOULDER - Funcao de transferência da planta
	y_k[1] = 1.583*u_k_delay[1] - 1.596*y_k_delay[1]

	# FOREARM - Funcao de transferência da planta
	y_k[2] = 0.9556*u_k_delay[2] - 0.9407*y_k_delay[2]

	x_axis_List.append(idx)

	r_k_Input_Base.append(r_k[0])
	y_k_Output_Base.append(y_k[0])

	r_k_Input_Shoulder.append(r_k[0])
	y_k_Output_Shoulder.append(y_k[0])

	r_k_Input_Forearm.append(r_k[0])
	y_k_Output_Forearm.append(y_k[0])

	# Arquivo de saida acao de controle
	outputFileBase.write(str(idx) + ',' + str(y_k[0]) + '\n')
	outputFileShoulder.write(str(idx) + ',' + str(y_k[0]) + '\n')
	outputFileForearm.write(str(idx) + ',' + str(y_k[0]) + '\n')

	# Arquivo de saida y(k)
	outputFileBaseControl.write(str(idx) + ',' + str(u_k[0]) + '\n')
	outputFileShoulderControl.write(str(idx) + ',' + str(u_k[0]) + '\n')
	outputFileForearmControl.write(str(idx) + ',' + str(u_k[0]) + '\n')

	# Pegando os valores da iteracao anterior
	y_k_delay = y_k
	u_k_delay = u_k

	# Reinicializando os valores atuais
	e_k = [0, 0, 0]
	u_k = list()
	u_k_string = ""
	e_k_string = ""

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
plt.legend()

plt.figure(2)
plt.plot(x_axis_List, r_k_Input_Shoulder, 'r.-', label='referencia')
plt.plot(x_axis_List, y_k_Output_Shoulder, 'b.-', label='saida')
plt.legend()

plt.figure(3)
plt.plot(x_axis_List, r_k_Input_Forearm, 'r.-', label='referencia')
plt.plot(x_axis_List, y_k_Output_Forearm, 'b.-', label='saida')
plt.legend()

plt.show()
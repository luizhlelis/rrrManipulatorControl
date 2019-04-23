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

inputFile = open('inputFile.txt', 'r')

time.sleep(3)

# variaveis de plot
x_axis_List		= list()
reference_plot	= list()
response_plot	= list()

receivedData = ""

############################################################
# main loop
############################################################
print "---------------------------------\nInicializando a planta simulada..."

idx = 0

for line in inputFile:

	print "Iteracao: " + str(idx)

	print "Valor Escrito:"
	print line

	ser.write(line)

	# Espera ter valor escrito no buffer de entrada
	while receivedData=="":
		receivedData = ser.readline()

	print "Valor Lido:"

	# Tratando quando os dados sao recebidos como string
	if type(receivedData) is str:
		receivedData = receivedData.split(',')

	if (type(receivedData[0]) is str) or (type(receivedData[1]) is str) or (type(receivedData[2]) is str):
		for strValue in receivedData:
			u_k.append(float(strValue))

	print u_k

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
	y_k_delay = y_k
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
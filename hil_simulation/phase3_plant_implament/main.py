#!/usr/bin/env python
#############################################################################
# Programa de controle dos manipuladores
# Nome: Armando Alves Neto
# DELT/UFMG
#############################################################################
import crustcrawler_class as cc
import os, time, random
import matplotlib.pyplot as plt

# maximum priority
os.nice(19)

############################################################
# definicoes globais
MASTER_PORT = "/dev/ttyUSB0"

############################################################
# create master robot
master = cc.Crustcrawler(MASTER_PORT, True)
# create slave robot
#slave = cc.Crustcrawler(SLAVE_PORT, False)
# esperando robos irem para a posicao inicial
outputFile_base = open('data/output_base.txt', 'w')
outputFile_shoulder = open('data/output_shoulder.txt', 'w')
outputFile_forearm = open('data/output_forearm.txt', 'w')
time.sleep(3)

# variaveis de plot
x_axis_List = list()

qInput_base = list()
qOutput_base = list()
qInput_shoulder = list()
qOutput_shoulder = list()
qInput_forearm = list()
qOutput_forearm = list()

inputData_base = 290
inputData_shoulder = 40
inputData_forearm = 32

masterdata = master.get()

idx = 0

############################################################
# main loop
############################################################
print "---------------------------------\nControl begin..."
while idx <= 2000: # tempo de simulacao
	
	#print master.getBase()

	if idx <= 1000:
		inputData_base = 290
		inputData_shoulder = 40
		inputData_forearm = 32
	else:
		inputData_base = 200
		inputData_shoulder = 80
		inputData_forearm = 100

	masterdata[0] = (inputData_base, 350)
	masterdata[1] = (inputData_shoulder, 350)
	masterdata[2] = (inputData_forearm, 350)
	master.set(masterdata)

	outputData = master.getBase()

	LOGID = 0

	x_axis_List.append(idx)

	qInput_base.append(inputData_base)
	qInput_shoulder.append(inputData_shoulder)
	qInput_forearm.append(inputData_forearm)

	aux1 = outputData[0]
	qOutput_base.append(a)
	aux2 = outputData[1]
	qOutput_shoulder.append(a)
	aux3 = outputData[2]
	qOutput_forearm.append(a)

	outputFile_base.write(str(idx) + ',' + str(aux1) + '\n')
	outputFile_shoulder.write(str(idx) + ',' + str(aux2) + '\n')
	outputFile_forearm.write(str(idx) + ',' + str(aux3) + '\n')

	idx++;

	time.sleep(.01)

############################################################
# destruindo objetos
outputFile.close()
print "Destruindo objetos..."
del master
#del slave

############################################################
# plota resultados
plt.figure(1)
plt.plot(x_axis_List, qInput_base, 'r.-', label='referencia')
plt.plot(x_axis_List, qOutput_base, 'b.-', label='saida')
plt.legend()

plt.figure(2)
plt.plot(x_axis_List, qInput_shoulder, 'r.-', label='referencia')
plt.plot(x_axis_List, qOutput_shoulder, 'b.-', label='saida')
plt.legend()

plt.figure(3)
plt.plot(x_axis_List, qInput_forearm, 'r.-', label='referencia')
plt.plot(x_axis_List, qOutput_forearm, 'b.-', label='saida')
plt.legend()

plt.show()
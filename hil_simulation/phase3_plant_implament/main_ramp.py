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
master = cc.Crustcrawler(MASTER_PORT, "ramp")
# create slave robot
#slave = cc.Crustcrawler(SLAVE_PORT, False)
# esperando robos irem para a posicao inicial

inputFile_base = open('data/ramp/input_base.txt', 'w')
inputFile_shoulder = open('data/ramp/input_shoulder.txt', 'w')
inputFile_forearm = open('data/ramp/input_forearm.txt', 'w')

outputFile_base = open('data/ramp/output_base.txt', 'w')
outputFile_shoulder = open('data/ramp/output_shoulder.txt', 'w')
outputFile_forearm = open('data/ramp/output_forearm.txt', 'w')
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

# teste cond inicial
inputData_forearm = master.getForearm()[0]
inputData_base = master.getBase()[0]
print "inputData_base" + "\n"
print str(inputData_base)

# master.initialize(inputData_base, inputData_shoulder, inputData_forearm)
# time.sleep(5)

############################################################
# main loop
############################################################
print "---------------------------------\nControl begin..."
comecou = time.time()
while time.time() - comecou <= 20.0: # tempo de simulacao
	
	tNow = time.time().real - comecou

	if (tNow >= 2.0) and (tNow <= 4.0):
		inputData_base = 208
		inputData_shoulder = 80;
		inputData_forearm = 100;
	elif (tNow > 4.0) and (tNow <= 8.0):
		inputData_base = 200
		inputData_shoulder = 80;
		inputData_forearm = 100;
	elif (tNow > 8.0) and (tNow <= 10.0):
		inputData_base = 192;
		inputData_shoulder = 80;
		inputData_forearm = 100;
	elif (tNow > 10.0) and (tNow <= 12.0):
		inputData_base = 184;
		inputData_shoulder = 80;
		inputData_forearm = 100;
	elif (tNow > 12.0) and (tNow <= 14.0):
		inputData_base = 176;
		inputData_shoulder = 80;
		inputData_forearm = 100;
	elif (tNow > 14.0) and (tNow <= 16.0):
		inputData_base = 168;
		inputData_shoulder = 80;
		inputData_forearm = 100;
	elif (tNow > 16.0) and (tNow <= 18.0):
		inputData_base = 160;
		inputData_shoulder = 80;
		inputData_forearm = 100;
	elif (tNow > 18.0):
		inputData_base = 150;
		inputData_shoulder = 80;
		inputData_forearm = 100;


	masterdata[0] = (inputData_base, 350)
	# masterdata[1] = (inputData_shoulder, 350)
	# masterdata[2] = (inputData_forearm, 350)

	master.set(masterdata)

	# outputData = master.get()
	outputData = master.getBase()

	x_axis_List.append(tNow)

	# print 'idx-> '+ str(tNow) + '\n'

	qInput_base.append(inputData_base)
	# qInput_shoulder.append(inputData_shoulder)
	# qInput_forearm.append(inputData_forearm)

	aux1 = outputData
	qOutput_base.append(aux1[0])
	# aux2 = outputData
	# qOutput_shoulder.append(aux2[0])
	# aux3 = outputData
	# qOutput_forearm.append(aux3[0])

	# aux1 = outputData[0]
	# qOutput_base.append(aux1)
	# aux2 = outputData[1]
	# qOutput_shoulder.append(aux2)
	# aux3 = outputData[2]
	# qOutput_forearm.append(aux3)

	outputFile_base.write(str(aux1[0]) + '\n')
	inputFile_base.write(str(inputData_base) + '\n')
	# outputFile_shoulder.write(str(aux2) + '\n')
	# outputFile_shoulder.write(str(aux2) + '\n')
	# outputFile_forearm.write(str(aux3[0]) + '\n')
	# inputFile_forearm.write(str(inputData_forearm) + '\n')

	time.sleep(.23)

############################################################
# destruindo objetos
outputFile_base.close()
# outputFile_shoulder.close()
# outputFile_forearm.close()
print "Destruindo objetos..."
del master
#del slave

############################################################
# plota resultados
plt.figure(1)
plt.plot(x_axis_List, qInput_base, 'r.-', label='referencia')
plt.plot(x_axis_List, qOutput_base, 'b.-', label='saida')
plt.legend(loc='lower right')

# plt.figure(2)
# plt.plot(x_axis_List, qInput_shoulder, 'r.-', label='referencia')
# plt.plot(x_axis_List, qOutput_shoulder, 'b.-', label='saida')
# plt.legend(loc='lower right')

# plt.figure(3)
# plt.plot(x_axis_List, qInput_forearm, 'r.-', label='referencia')
# plt.plot(x_axis_List, qOutput_forearm, 'b.-', label='saida')
# plt.legend(loc='lower right')

plt.show()
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
master = cc.Crustcrawler(MASTER_PORT, "ramp")

inputFile_base = open('data/ramp/input_base.txt', 'w')
inputFile_shoulder = open('data/ramp/input_shoulder.txt', 'w')
inputFile_forearm = open('data/ramp/input_forearm.txt', 'w')
inputFile_grip = open('data/ramp/input_forearm.txt', 'w')

outputFile_base = open('data/ramp/output_base.txt', 'w')
outputFile_shoulder = open('data/ramp/output_shoulder.txt', 'w')
outputFile_forearm = open('data/ramp/output_forearm.txt', 'w')
outputFile_grip = open('data/ramp/output_grip.txt', 'w')
time.sleep(3)

# variaveis de plot
x_axis_List = list()

qInput_base = list()
qOutput_base = list()
qInput_shoulder = list()
qOutput_shoulder = list()
qInput_forearm = list()
qInput_grip = list()
qOutput_forearm = list()
qOutput_grip = list()
qTorque_base = list()
qTorque_shoulder = list()
qTorque_forearm = list()

inputData_base = 290
inputData_shoulder = 40
inputData_forearm = 32
inputData_grip = 32

masterdata = master.get()

# teste cond inicial
inputData_forearm = master.getForearm()[0]
inputData_shoulder = master.getShoulder()[0]
inputData_base = master.getBase()[0]
inputData_grip = master.getGrip()[0]
print "inputData_forearm" + "\n"
print str(inputData_forearm)

# [230.56640625, 159.228515625, 121.2890625, 149.4140625]
# [230.56640625, 159.228515625, 121.2890625, 192.7734375]
# [230.56640625, 29.00390625, 121.2890625, 192.7734375]
# [230.56640625, 29.00390625, 32.2265625, 192.7734375]
# [58.0078125, 29.00390625, 32.2265625, 192.7734375]
# [58.0078125, 140.43359375, 32.2265625, 192.7734375]
# [58.0078125, 140.43359375, 32.2265625, 149.4140625]

# ------------------- INICIAL --------------------------:
# base = garra para a esquerda (pos no getBase)
# shoulder = repouso (pos no getShoulder)
# forearm = repouso (pos no getForearm)
# grip = aberta (pos no getGrip)
# [236.71875, 29.150390625, 27.685546875, 149.70703125]
# ------------------- Pos  2 --------------------------:
# forearm = 70
# ------------------- Pos  3 --------------------------:
# shoulder = 90
# ------------------- Pos  4 --------------------------:
# grip = 195
# ------------------- Pos  5 --------------------------:
# shoulder = 30
# ------------------- Pos  6 --------------------------:
# forearm = 33
# base = 145
# ------------------- Pos  7 --------------------------:
# base = 60
# ------------------- Pos  8 --------------------------:
# shoulder = 90
# ------------------- Pos  9 --------------------------:
# grip = 145

############################################################
# main loop
############################################################
transitionTime = 1

print "---------------------------------\nControl begin..."
comecou = time.time()
while time.time() - comecou <= 40.0: # tempo de simulacao
	
	tNow = time.time().real - comecou

	# if (tNow >= 2.0) and (tNow <= 7.0):
	# 	inputData_forearm = 70
	# elif (tNow > 7.0) and (tNow <= 12.0):
	# 	inputData_shoulder = 90
	# elif (tNow > 12.0) and (tNow <= 17.0):
	# 	inputData_grip = 195
	# elif (tNow > 17.0) and (tNow <= 22.0):
	# 	inputData_shoulder = 30
	# elif (tNow > 22.0) and (tNow <= 27.0):
	# 	inputData_base = 145
	# 	inputData_forearm = 33
	# elif (tNow > 27.0) and (tNow <= 32.0):
	# 	inputData_base = 60
	# elif (tNow > 32.0) and (tNow <= 37.0):
	# 	inputData_shoulder = 90
	# elif (tNow > 37):
	# 	inputData_grip = 90

	if (tNow >= 2.0) and (tNow <= 7.0):
		inputData_forearm = 65
		inputData_shoulder = 90
	elif (tNow > 7.0) and (tNow <= 12.0):
		inputData_grip = 203
	elif (tNow > 12.0) and (tNow <= 17.0):
		inputData_shoulder = 30
		inputData_forearm = 33
	elif (tNow > 17.0) and (tNow <= 22.0):
		inputData_base = 145
	elif (tNow > 22.0) and (tNow <= 27.0):
		inputData_base = 60
	elif (tNow > 27.0) and (tNow <= 32.0):
		inputData_shoulder = 90
	elif (tNow > 32.0) and (tNow <= 37.0):
		inputData_grip = 90

	masterdata[0] = (inputData_base, 350)
	masterdata[1] = (inputData_shoulder, 400)
	masterdata[2] = (inputData_forearm, 350)
	masterdata[3] = (inputData_grip, 350)

	master.set(masterdata)

	outputData = master.get()

	x_axis_List.append(tNow)

	qInput_base.append(inputData_base)
	qInput_shoulder.append(inputData_shoulder)
	qInput_forearm.append(inputData_forearm)
	qInput_grip.append(inputData_grip)

	aux1 = outputData[0]
	qOutput_base.append(aux1[0])
	aux2 = outputData[1]
	qOutput_shoulder.append(aux2[0])
	aux3 = outputData[2]
	qOutput_forearm.append(aux3[0])
	aux4 = outputData[3]
	qOutput_grip.append(aux4[0])

	torqueBase = aux1[1]
	torqueShoulder = aux2[1]
	torqueForearm = aux3[1]

	qTorque_base.append(torqueBase)
	qTorque_shoulder.append(torqueShoulder)
	qTorque_forearm.append(torqueForearm)

	outputFile_base.write(str(aux1[0]) + '\n')
	inputFile_base.write(str(inputData_base) + '\n')
	outputFile_shoulder.write(str(aux2[0]) + '\n')
	inputFile_shoulder.write(str(inputData_shoulder) + '\n')
	outputFile_forearm.write(str(aux3[0]) + '\n')
	inputFile_forearm.write(str(inputData_forearm) + '\n')
	outputFile_grip.write(str(aux4[0]) + '\n')
	inputFile_grip.write(str(inputData_grip) + '\n')

	time.sleep(.23)

############################################################
# destruindo objetos
outputFile_base.close()
outputFile_shoulder.close()
outputFile_forearm.close()
outputFile_grip.close()
print "Destruindo objetos..."
del master

############################################################
# plota resultados
plt.figure(1)
plt.plot(x_axis_List, qInput_base, 'r.-', label='referencia')
plt.plot(x_axis_List, qOutput_base, 'b.-', label='saida')
plt.legend(loc='upper right')

plt.figure(2)
plt.plot(x_axis_List, qInput_shoulder, 'r.-', label='referencia')
plt.plot(x_axis_List, qOutput_shoulder, 'b.-', label='saida')
plt.legend(loc='upper right')

plt.figure(3)
plt.plot(x_axis_List, qInput_forearm, 'r.-', label='referencia')
plt.plot(x_axis_List, qOutput_forearm, 'b.-', label='saida')
plt.legend(loc='upper right')

plt.figure(4)
plt.plot(x_axis_List, qInput_grip, 'r.-', label='referencia')
plt.plot(x_axis_List, qOutput_grip, 'b.-', label='saida')
plt.legend(loc='upper right')

plt.figure(5)
plt.plot(x_axis_List, qTorque_base, 'r.-', label='torque base')
plt.plot(x_axis_List, qTorque_shoulder, 'b.-', label='torque shoulder')
plt.plot(x_axis_List, qTorque_forearm, 'g.-', label='torque forearm')
plt.legend(loc='upper right')

plt.show()
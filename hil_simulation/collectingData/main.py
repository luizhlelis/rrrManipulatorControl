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
SLAVE_PORT	 = "/dev/ttyUSB1"

############################################################
# create master robot
master = cc.Crustcrawler(MASTER_PORT, True)
# create slave robot
#slave = cc.Crustcrawler(SLAVE_PORT, False)
# esperando robos irem para a posicao inicial
outputFile = open('data/base/output_0001s.txt', 'w')
time.sleep(3)

# variaveis de plot
tempo = list()
qInput = list()
qOutput = list()
#qslave = list()

masterdata = master.get()

############################################################
# main loop
############################################################
print "---------------------------------\nControl begin..."
comecou = time.time()
while time.time() - comecou <= 20.0: # tempo de simulacao
	
	#print master.getBase()

	if time.time() - comecou <= 10.0:
		inputData = 179.58984375
	else:
		inputData = 72.65625


	masterdata[0] = (inputData, 200)
	master.set(masterdata)

	outputData = master.getBase()

	# print str(outputData[0]) + "\n"

	if outputData[0] < (inputData + 0.5) and outputData[0] > (inputData - 0.5):
		print "entrou"

	LOGID = 0
	tNow = time.time().real - comecou

	tempo.append(tNow)
	qInput.append(inputData)
	a = outputData[0]
	qOutput.append(a)

	outputFile.write(str(tNow) + ',' + str(a) + '\n')

	time.sleep(.23)

############################################################
# destruindo objetos
outputFile.close()
print "Destruindo objetos..."
del master
#del slave

############################################################
# plota resultados
plt.plot(tempo, qInput, 'r.-', label='input')
plt.plot(tempo, qOutput, 'b.-', label='output')
plt.legend()
plt.show()

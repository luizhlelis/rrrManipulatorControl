#!/usr/bin/env python
#############################################################################
# Programa de controle dos manipuladores
# Nome: Luiz Henrique Silva Lelis
#############################################################################
import crustcrawler_class as cc
import os, time, random
import matplotlib.pyplot as plt

# maximum priority
os.nice(19)

############################################################
# definicoes globais
SERIAL_PORT = "/dev/ttyUSB0"

############################################################
# create master robot
master = cc.Crustcrawler(SERIAL_PORT)
# esperando robos irem para a posicao inicial
outputFile = open('data/base/output_0001s.txt', 'w')
time.sleep(3)

# variaveis de plot
tempo = list()
qInput = list()
qOutput = list()

masterdata = master.get()

############################################################
# main loop
############################################################
print "---------------------------------\nControl begin..."
comecou = time.time()
while time.time() - comecou <= 20.0: # tempo de simulacao
	
	#print master.getBase()

	if time.time() - comecou <= 10.0:
		inputData = 290
	else:
		inputData = 200

	masterdata[0] = (inputData, 350)
	master.set(masterdata)

	outputData = master.getBase()

	LOGID = 0
	tNow = time.time().real - comecou
	

	tempo.append(tNow)
	qInput.append(inputData)
	a = outputData[0]
	qOutput.append(a)

	outputFile.write(str(tNow) + ',' + str(a) + '\n')

	time.sleep(.01)

############################################################
# destruindo objetos
outputFile.close()
print "Destruindo objetos..."
del master

############################################################
# plota resultados
plt.plot(tempo, qInput, 'r.-', label='input')
plt.plot(tempo, qOutput, 'b.-', label='output')
plt.legend()
plt.show()

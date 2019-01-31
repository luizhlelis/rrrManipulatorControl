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
outputFile = open('data/base/output.txt', 'w')
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
	########################
	# escrita dos dados
	########################

	#print master.getBase()

	if time.time() - comecou <= 10.0:
		inputData = 290
	else:
		inputData = 200

	masterdata[0] = (inputData, 512)
	master.set(masterdata)

	########################
	# leitura dos dados
	########################
	outputData = master.getBase()
	
	########################
	# seta referencia de controle para as juntas
	########################
	#master.set(slavedata)
	#slave.set(masterdata)
	
	########################
	# log
	########################
	LOGID = 0
	tNow = time.time().real - comecou
	
	# dados para plot
	tempo.append(tNow)
	#
	# a, v = inputData[LOGID]
	qInput.append(inputData)
	#
	a = outputData[0]
	qOutput.append(a)

	outputFile.write(str(tNow) + ',' + str(a) + '\n')

	time.sleep(.01)

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

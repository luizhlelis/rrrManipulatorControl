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

############################################################
# main loop
############################################################
print "---------------------------------\nControl begin..."
comecou = time.time()
while time.time() - comecou <= 20.0: # tempo de simulacao
	########################
	# escrita dos dados
	########################
	if time.time() - comecou <= 10.0:
		master.setBase(50)
		inputData = 50
	else:
		master.setBase(250)
		inputData = 250

	########################
	# leitura dos dados
	########################
	outputData = master.getBase()
	outputFile.write(str(time.time()) + ',' + str(outputData) + '\n')
	
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
	#a, v = outputData[LOGID]
	qOutput.append(outputData)

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

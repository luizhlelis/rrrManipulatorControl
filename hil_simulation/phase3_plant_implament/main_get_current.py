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
master = cc.Crustcrawler(MASTER_PORT, "getCurrent")

outputFile_base = open('data/getCurrent/output_base.txt', 'w')
outputFile_shoulder = open('data/getCurrent/output_shoulder.txt', 'w')
outputFile_forearm = open('data/getCurrent/output_forearm.txt', 'w')
time.sleep(3)

# variaveis de plot
x_axis_List = list()

qInput_base = list()
qOutput_base = list()
qInput_shoulder = list()
qOutput_shoulder = list()
qInput_forearm = list()
qOutput_forearm = list()

############################################################
# main loop
############################################################
print "---------------------------------\nControl begin..."
comecou = time.time()
while time.time() - comecou <= 50.0: # tempo de simulacao
	
	tNow = time.time().real - comecou

	outputData = master.getForearm()

	print str(outputData[0])

	x_axis_List.append(tNow)

	qOutput_base.append(outputData[0])

	outputFile_base.write(str(outputData[0]) + '\n')

	time.sleep(.23)

############################################################
outputFile_base.close()
print "Destruindo objetos..."
del master

############################################################
# plota resultados
plt.figure(1)
plt.plot(x_axis_List, qOutput_base, 'b.-', label='saida')
plt.legend(loc='lower right')

plt.show()
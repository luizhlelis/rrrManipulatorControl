# -*- coding: utf-8 -*-
#############################################################################
# HIL - Fase 2 Validando o controle do Hardware na planta simulada
# Controladores simulados
# Nome: Luiz Henrique Silva Lelis
#############################################################################
import os, time, random
import serial

# maximum priority
os.nice(19)

############################################################
# definicoes globais
ser = serial.Serial(
 port='/dev/ttyS0',
 baudrate = 9600,
 parity=serial.PARITY_NONE,
 stopbits=serial.STOPBITS_ONE,
 bytesize=serial.EIGHTBITS,
 timeout=1
)

print(ser.name)

e_k_delay = [0, 0, 0]
u_k_delay = [0, 0, 0]

# Condicaoes Iniciais [base, shoulder, forearm]
e_k_string = ""
u_k_string = ""
e_k = list()
u_k = [0, 0, 0]
u_k_delay = [0, 0, 0]
e_k_delay = [0, 0, 0]

############################################################
# main loop
############################################################
print "---------------------------------\nControl begin..."

idx = 0

while idx <= 2000: # tempo de simulacao

	while e_k_string=="":
		e_k_string = ser.readline()

	print "Iteracao: " + str(idx)

	print "Valor Lido:"

	# Tratando quando os dados sao recebidos como string
	if type(e_k_string) is str:
		e_k_string = e_k_string.split(',')

	if (type(e_k_string[0]) is str) or (type(e_k_string[1]) is str) or (type(e_k_string[2]) is str):
		for charac in e_k_string:
			e_k.append(float(charac))

	print e_k

	# BASE - Funcao de transferência do controlador
	u_k[0] = u_k_delay[0] + 3.762*e_k[0] - 3.728*e_k_delay[0]

	# SHOULDER - Funcao de transferência do controlador
	u_k[1] = u_k_delay[1] + 2.244*e_k[1] - 2.212*e_k_delay[1]

	# FOREARM - Funcao de transferência do controlador
	u_k[2] = u_k_delay[2] + 3.74*e_k[2] - 3.706*e_k_delay[2]

	# Pegando os valores da iteracao anterior
	e_k_delay = e_k
	u_k_delay = u_k

	u_k_string = ','.join(str(aux) for aux in u_k)

	print "Valor Escrito:"
	print u_k_string

	ser.write(u_k_string)

	# Reinicializando os valores atuais
	e_k = list()
	u_k = [0, 0, 0]
	u_k_string = ""
	e_k_string = ""

	idx+=1

############################################################

print "Finalizando..."

############################################################
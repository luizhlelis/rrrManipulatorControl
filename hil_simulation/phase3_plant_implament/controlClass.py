#############################################################################
# HIL - Fase 3 Validando o controle do Hardware na planta real
# Controlador na raspberry
# Nome: Luiz Henrique Silva Lelis
#############################################################################
import time

# Ignorando erro com uma margem de erro
MARGIN = .8
# Valores maximos e minimos de posicoes possiveis (inerentes ao servo)
MAXP = 299.9 #1023
MINP = 0.1 #0

MAX_TORQUE = 1020 #1023

#############################################################################
class Controller:
	#########################################################################
	# construtor
	#########################################################################
	def __init__(self, KPgain, KIgain, u_kDelay, e_kDelay, ref):
		self.reference = ref
		self.Kp = KPgain
		self.Ki = KIgain
		self.u_k_delay = u_kDelay
		self.e_k_delay = e_kDelay
		self.torque_limit = 0
	
	#########################################################################
	# referencia de controle
	#########################################################################
	def setReference(self, ref, u_delay, e_delay):
		self.reference = ref
		self.u_k_delay = u_delay
		self.e_k_delay = e_delay
		
	#########################################################################
	# calcula acao de controle
	#########################################################################
	def get_U_k(self, y_k, torque):
		
		# Calcula lei de controle
		r_k = self.reference
		e_k = r_k - y_k

		torque = round(torque)
		torque = abs(int(torque))
		torque = min((torque, MAX_TORQUE))

		# Controle de posicao
		u_k = self.u_k_delay + self.Kp*e_k + self.Ki*self.e_k_delay

		if y_k <= (r_k + MARGIN) and y_k >= (r_k - MARGIN):
			torque = 0
			
		return u_k, e_k, torque
	
	#########################################################################
	# destrutor
	#########################################################################
	def __del__(self):
		self.reference = 0.0

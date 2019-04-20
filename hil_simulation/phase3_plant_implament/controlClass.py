#############################################################################
# HIL - Fase 3 Validando o controle do Hardware na planta real
# Controlador na raspberry
# Nome: Luiz Henrique Silva Lelis
#############################################################################
import time

# Ignorando erro com uma margem de erro
MARGIN = .5
# Valores maximos e minimos de posicoes possiveis (inerentes ao servo)
MAXP = 299.9 #1023
MINP = 0.1 #0

MAX_TORQUE = 1020 #1023

#############################################################################
class Controller:
	#########################################################################
	# construtor
	#########################################################################
	def __init__(self, KPgain, KIgain, KPgainTorque, KDgainTorque):
		self.reference = 0.0
		self.Kp = KPgain
		self.Ki = KIgain
		self.KpTorque = KPgainTorque
		self.KdTorque = KDgainTorque
		self.u_k_delay = 0
		self.e_k_delay = 0
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
	def get_U_k(self, y_k):
		
		# Calcula lei de controle
		r_k = self.reference
		e_k = r_k - y_k

		# Controle de posicao
		u_k = self.u_k_delay + self.Kp*e_k - self.Ki*self.e_k_delay

		torque = self.KpTorque*e_k

		# Determina para qual lado ir
		if y_k > (r_k + MARGIN):
			self.u_k = MINP
			self.torque_limit = torque
		elif y_k < (r_k - MARGIN):
			self.u_k = MAXP
			self.torque_limit = torque
		else:
			self.torque_limit = 0
			self.goal_position = y_k
			
		return u_k, e_k, self.torque_limit
	
	#########################################################################
	# destrutor
	#########################################################################
	def __del__(self):
		self.reference = 0.0

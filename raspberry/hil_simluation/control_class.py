#############################################################################
# Programa de controle dos manipuladores
# Nome: Luiz Henrique Silva Lelis
#############################################################################
import time

# We ignore errors within +/- this range.
MARGIN = .5
# Max and min values of possible positions (inherent to the servo)
MAXP = 299.9 #1023
MINP = 0.1 #0

MAX_TORQUE = 1020 #1023

#############################################################################
class Controller:
	#########################################################################
	# construtor
	#########################################################################
	def __init__(self, Pgain, Igain):
		self.reference = 0.0
		self.Kp = Pgain
		self.Ki = Igain
		self.torque_limit = 0
		self.goal_position = 0
	
	#########################################################################
	# referencia de controle
	#########################################################################
	def setReference(self, ref):
		self.reference = ref
		
	#########################################################################
	# calcula acao de controle
	#########################################################################
	def getU(self, y, u_delay, e_delay):
		
		# calcula lei de controle
		r = self.reference
		error = r - y
		torque = u_delay + self.Kp*error - self.Ki*e_delay

		torque = round(torque)
		torque = abs(int(torque))
		torque = min((torque, MAX_TORQUE))
		
		# Determine which way we need to move
		if y > (r + MARGIN):
			self.goal_position = MINP
			self.torque_limit = torque
		elif y < (r - MARGIN):
			self.goal_position = MAXP
			self.torque_limit = torque
		else:
			self.torque_limit = 0
			self.goal_position = y
			
		return self.torque_limit, self.goal_position
	
	#########################################################################
	# destrutor
	#########################################################################
	def __del__(self):
		self.reference = 0.0

#############################################################################
# Programa de controle dos manipuladores
# Nome: Armando Alves Neto
# DELT/UFMG
#############################################################################
import dynamixel
import controlClass as ctrl
import os, time, math
import threading

#############################################################################
# global definitions
BAUDRATE = 1000000
BASE_AXIS_ID = 1
SHOULDER_A_AXIS_ID = 2
SHOULDER_B_AXIS_ID = 3
FOREARM_A_AXIS_ID = 4
FOREARM_B_AXIS_ID = 5
GRIP_AXIS_ID = 7
HIGHESTSERVOID = 7

#########
# parametros do modelo
G0 = 9.78 #[m/s^2]
M1 = 0.055 # 55 g (peso da estrutura)
M2 = 5*0.055 # 4 servos + a estrutura
A1 =  0.172 # 17,2 cm 
AC1 = A1/2.0
A2 = 0.235 # 23,5 cm
AC2 = A2/2.0

#########
# conversoes de angulo
ANGULAR_CONV_RATIO = 0.29  #(300[deg]/1024)
A12_MIN_ANGLE = 0.0
A12_MAX_ANGLE = 300.0
A12_MIN_POS = 0
A12_MAX_POS = 1023

# limites de angulos das juntas
MIN_LIMIT_BASE = 0.0
MAX_LIMIT_BASE = 300.0
#
MIN_LIMIT_SHOULDER = 35.0
MAX_LIMIT_SHOULDER = 180.0
#
MIN_LIMIT_FOREARM = 35.0
MAX_LIMIT_FOREARM = 250.0
#
MIN_LIMIT_GRIP = 150.0
MAX_LIMIT_GRIP = 220.0

#########
# conversoes de velocidade
SPEED_CONV_RATIO   = 0.668621701 #(114[rpm] -> 684[deg/sec] / 0x3ff [1023])
A12_MIN_SPEED = -684.0
A12_MAX_SPEED = 684.0
A12_MIN_ROTATION = -1023
A12_MAX_ROTATION = 1023

#########
# conversoes de torque
A12_MIN_TORQUE = 0.0
A12_MAX_TORQUE = 2*1.61809725 # 16.5 kgf.cm -> Nm
A12_MIN_TORQUEBIN = 0
A12_MAX_TORQUEBIN = 1023
TORQUE_CONV_RATIO   = A12_MAX_TORQUE/A12_MAX_TORQUEBIN

#########
# ganhos de controle
# KPGAIN_BASE = 0.413
# KPGAIN_SHOULDER = 0.1572
# KPGAIN_FOREARM = 0.413
# KIGAIN_BASE = -0.2008
# KIGAIN_SHOULDER = 0.06513
# KIGAIN_FOREARM = -0.2008

# ganhos de controle (sem zero nao minimo)
KPGAIN_BASE = 0.152
KPGAIN_SHOULDER = 0.1572
KPGAIN_FOREARM = 0.152
KIGAIN_BASE = 0.032
KIGAIN_SHOULDER = 0.06513
KIGAIN_FOREARM = 0.032

KPGAIN_TORQUE = 8.0
KDGAIN_TORQUE = -1.0

#############################################################################
# classe para controle do manipulador
#############################################################################
class Crustcrawler:
	#########################################################################
	# construtor
	#########################################################################
	def __init__(self, portName, dataFolder):
		
		#########################################################################
		# Comunicacao com o robo
		#########################################################################
		# Establish a serial connection to the dynamixel network (requires a USB2Dynamixel)
		self.serial = dynamixel.SerialStream(port=portName, baudrate=BAUDRATE, timeout=1)
		self.net = dynamixel.DynamixelNetwork(self.serial)
	
		# Ping the range of servos that are attached
		#print "Scanning for Dynamixels..."
		self.net.scan(1, HIGHESTSERVOID)
		
		# cria atuadores da rede
		self.Actuators = []
		self.Actuators.append([]) # atuador ZERO (nunca sera usado)
		for dyn in self.net.get_dynamixels():
			#print dyn.id
			self.Actuators.append(self.net[dyn.id])
			
		# verifica se os atuadores foram criados
		if not self.Actuators:
			print 'No Dynamixels Found!'
			sys.exit(0)
		
		#########################################################################	
		# inicializacao dos atuadores
		#########################################################################
		for id in range(1, len(self.Actuators)):
			self.Actuators[id].stop()
			self.Actuators[id].ccw_compliance_margin = self.Actuators[id].cw_compliance_margin = 0
			self.Actuators[id].ccw_compliance_slope = self.Actuators[id].cw_compliance_slope = 1
			self.Actuators[id].punch = 8
			self.Actuators[id].moving_speed = abs(A12_MAX_ROTATION)
			self.Actuators[id].synchronized = True
			self.Actuators[id].torque_enable = False
			self.Actuators[id].torque_limit = 0
			self.Actuators[id].max_torque = A12_MAX_TORQUEBIN
			
		# envia informacoes aos servos
		self.update()
		
		#########################################################################
		# variaveis de entrada e saida
		#########################################################################
		self.angles = []
		self.angles.append([])
		self.speeds = []
		self.speeds.append([])
		self.torqueLelis = []
		self.torqueLelis.append([])
		for id in range(1, len(self.Actuators)):
			# le as informacoes de controle
			self.angles.append(self.Actuators[id].current_position)
			self.speeds.append(self.Actuators[id].current_speed)
			self.torqueLelis.append(self.Actuators[id].torque_limit)
			
		self.goals = []
		self.goals.append([])
		self.torques = []
		self.torques.append([])
		for dyn in self.net.get_dynamixels():
			self.goals.append(0.0)
			self.torques.append(0.0)

		#########################################################################
		# cria controladores de juntas
		#########################################################################
		# vetor de referencias dos angulos
		self.ref = []
		self.init_base = 0
		self.init_shoulder = 0
		self.init_forearm = 0
		self.init_grip = 0
		
		# setando condicoes iniciais
		self.initJoints()
		# self.initialize(290, 40, 32)

		self.BaseCtrl = ctrl.Controller(KPGAIN_BASE, KIGAIN_BASE, self.init_base, 0, self.init_base)
		self.ShoulderCtrl = ctrl.Controller(KPGAIN_SHOULDER, KIGAIN_SHOULDER, self.init_shoulder, 0, self.init_shoulder)
		self.ForearmCtrl = ctrl.Controller(KPGAIN_FOREARM, KIGAIN_FOREARM, self.init_forearm, 0, self.init_forearm)

		self.outputFile_base = open('data/'+dataFolder+'/controlAction_base.txt', 'w')
		self.outputFile_shoulder = open('data/'+dataFolder+'/controlAction_shoulder.txt', 'w')
		self.outputFile_forearm = open('data/'+dataFolder+'/controlAction_forearm.txt', 'w')

		self.u_k_base = self.init_base;
		self.e_k_base = 0;
		self.u_k_shoulder = self.init_shoulder;
		self.e_k_shoulder = 0;
		self.u_k_forearm = self.init_forearm;
		self.e_k_forearm = 0;
		
		#########################################################################
		# dispara thread principal de controle
		#########################################################################
		
		# torques gravitacionais
		self.Gq_shoulder = 0.0
		self.Gq_forearm   = 0.0
		
		# mutex para acesso aos dados
		self.mutex = threading.Lock()
		
		# thread
		self.t = threading.Thread(target=self.controlLoop, args=[])
		self.t.daemon = True # causes the thread to terminate when main process ends
		self.t.start()
		
		#########################################################################
		# Criando arquivo para salvar dados
		#########################################################################
		
		self.logfile = open('logs/' + time.ctime() + '_log.txt', 'w')
		# cabecalho
		self.logfile.write('%Data: ' + time.ctime() + '\n')
		self.logfile.write('%Control gains - BASE:\n')
		self.logfile.write('%\t(KP, KI): (' + str(KPGAIN_BASE) + ',' + str(KIGAIN_BASE) + ')\n')
		self.logfile.write('\n')
		self.logfile.write('%Control gains - SHOULDER:\n')
		self.logfile.write('%\t(KP, KI): (' + str(KPGAIN_SHOULDER) + ',' + str(KIGAIN_SHOULDER) + ')\n')
		self.logfile.write('\n')
		self.logfile.write('%Control gains - FOREARM:\n')
		self.logfile.write('%\t(KP, KI): (' + str(KPGAIN_FOREARM) + ',' + str(KIGAIN_FOREARM) + ')\n')
		self.logfile.write('\n')
		
		#########################################################################
		# informa condicao de criacao
		#########################################################################
		print "---------------------------------"
		print "Manipulator is ready!"
		print "---------------------------------"
	
	#########################################################################
	# initalize joint positions
	#########################################################################
	def initJoints(self):
		# pega valores medios das juntas
		self.init_base = self.getBase()[0]
		self.init_shoulder = self.getShoulder()[0]
		self.init_forearm = self.getForearm()[0]
		self.init_grip = self.getGrip()[0]

		print 'inicializou-> ' + str(self.init_base) + ',' + str(self.init_shoulder) + ',' + str(self.init_forearm) + ',' + str(self.init_grip) + '\n'

		initialCondition = [(0,0),(0,0),(0,0),(0,0)]
		initialCondition[0] = (self.init_base, 0)
		initialCondition[1] = (self.init_shoulder, 0)
		initialCondition[2] = (self.init_forearm, 0)
		initialCondition[3] = (self.init_grip, 0)

		# seta referencia de controle para o meio
		self.set(initialCondition)
	
	#########################################################################
	# le as informacoes de todas as juntas
	#########################################################################	
	def get(self):
		return [self.getBase(), self.getShoulder(), self.getForearm(), self.getGrip()]
		
	#########################################################################
	# seta referencias de posicao
	#########################################################################	
	def set(self, ref):
		self.ref = ref
	
	#########################################################################
	# thread de controle principal
	#########################################################################
	def controlLoop(self):
		print ">> Inicializando thread de controle..."
		# main loop
		idx = 0
		while 1:
		
			# le as irformacoes de todas as juntas
			self.mutex.acquire()
			self.read_all()
			self.mutex.release()
		
			# atualiza o torque gravitacional
			self.torque_grav()
			
			# seta a referencia de cada junta separadamente
			self.setBase(self.ref[0][0])
			self.setShoulder(self.ref[1][0])
			self.setForearm(self.ref[2][0])
			self.setGrip(self.ref[3][0])
		
			# escreve todo mundo
			self.mutex.acquire()
			self.write_all()
			self.mutex.release()

			# print str(idx)

			idx+=1
		self.outputFile_base.close()
		self.outputFile_shoulder.close()

	#########################################################################
	# condicoes iniciais
	#########################################################################
	def initialize(self, angle_base, angle_shoulder, angle_forearm):

		# seta a referencia de cada junta separadamente
		self.setBaseOpenLoop(angle_base)
		self.setShoulderOpenLoop(angle_shoulder)
		self.setForearmOpenLoop(angle_forearm)
				
	#########################################################################
	# read position and speed from all servos in the robot
	#########################################################################
	def read_all(self):
		# le as informacoes de controle
		for id in range(1, len(self.Actuators)):
			try:
				self.angles[id] = self.Actuators[id].current_position
				self.speeds[id] = self.Actuators[id].current_speed
				self.torqueLelis[id] = self.Actuators[id].torque_limit
				#torque = self.Actuators[id].current_load
			except:
				None
				
	#########################################################################
	# write torque and goal for all servos in the robot
	#########################################################################
	def write_all(self):
		# escreve nos atuadores
		for id in range(1, len(self.Actuators)):
			try:
				self.Actuators[id].goal_position = self.deg2pos(self.goals[id])
				self.Actuators[id].torque_limit = self.torques[id]
			except:
				None
				
		# atualiza servos
		self.update()
	
	#########################################################################
	# read information from the id-th joint axis
	#########################################################################
	def getJoint(self, id):
		#self.mutex.acquire()
		temp = self.pos2deg(self.angles[id]), self.torqueLelis[id]
		#self.mutex.release()
	
		# retorn position and speed		
		return temp
	
	#########################################################################
	# write to the id-th joint axis
	#########################################################################
	def setJoint(self, id, angle, torque):
		#self.mutex.acquire()
		self.goals[id] = angle
		self.torques[id] = torque
		#self.mutex.release()
		
	#########################################################################
	# read base axis
	#########################################################################
	def getBase(self):
		# read registers of the first servo
		return self.getJoint(BASE_AXIS_ID)
	
	#########################################################################
	# write base axis
	#########################################################################
	def setBase(self, angle_ref):

		# limitacao angular de colisao
		angle_ref = max(angle_ref, MIN_LIMIT_BASE)
		angle_ref = min(angle_ref, MAX_LIMIT_BASE)
		
		# seta a referencia do controlador
		self.BaseCtrl.setReference(angle_ref, self.u_k_base, self.e_k_base)
		
		# medindo posicao e velocidade correntes
		angle, speed = self.getBase()
		
		# pega a acao de controle
		self.u_k_base, self.e_k_base, torque = self.BaseCtrl.get_U_k(angle, self.ref[0][1])
		self.outputFile_base.write(str(self.u_k_base) + ',' + str(self.e_k_base) + '\n')
		
		# seta posicao do servo da base
		# print 'angle = ' + str(self.u_k_base) + ' vel = ' + str(self.ref[0][1]) + '\n'
		self.setJoint(BASE_AXIS_ID, self.u_k_base, torque)

	def setBaseOpenLoop(self, angle_ref):

		# limitacao angular de colisao
		angle_ref = max(angle_ref, MIN_LIMIT_BASE)
		angle_ref = min(angle_ref, MAX_LIMIT_BASE)

		self.setJoint(BASE_AXIS_ID, angle_ref, self.ref[0][1])
		
	#########################################################################
	# read shoulder axis
	#########################################################################
	def getShoulder(self):
		# read registers of 2nd and 3th servos
		angleA, rotationA = self.getJoint(SHOULDER_A_AXIS_ID)
		angleB, rotationB = self.getJoint(SHOULDER_B_AXIS_ID)
		
		# calcula posicao e velocidade media das duas juntas
		return (angleA + angleB)/2.0, (rotationA + rotationB)/2.0
			
	#########################################################################
	# write shoulder axis
	#########################################################################
	def setShoulder(self, angle_ref):

		# limitacao angular de colisao
		# angle_ref = max(angle_ref, MIN_LIMIT_SHOULDER)
		angle_ref = min(angle_ref, MAX_LIMIT_SHOULDER)
		
		# seta a referencia do controlador
		self.ShoulderCtrl.setReference(angle_ref, self.u_k_shoulder, self.e_k_shoulder)
		
		# medindo posicao e velocidade correntes
		angle, speed = self.getShoulder()
		
		# pega a acao de controle
		self.u_k_shoulder, self.e_k_shoulder, torque = self.ShoulderCtrl.get_U_k(angle, self.ref[1][1])
		self.outputFile_shoulder.write(str(self.u_k_shoulder) + ',' + str(self.e_k_shoulder) + '\n')
		
		# seta posicao do servo do ombro
		self.setJoint(SHOULDER_A_AXIS_ID, self.u_k_shoulder, torque)
		self.setJoint(SHOULDER_B_AXIS_ID, self.u_k_shoulder, torque)

	def setShoulderOpenLoop(self, angle_ref):

		# limitacao angular de colisao
		angle_ref = max(angle_ref, MIN_LIMIT_SHOULDER)
		angle_ref = min(angle_ref, MAX_LIMIT_SHOULDER)
		
		# seta posicao do servo do ombro
		self.setJoint(SHOULDER_A_AXIS_ID, angle_ref, self.ref[1][1])
		self.setJoint(SHOULDER_B_AXIS_ID, angle_ref, self.ref[1][1])
	
	#########################################################################
	# read forearm axis
	#########################################################################
	def getForearm(self):
		# read registers of 4th and 5th servos
		angleA, rotationA = self.getJoint(FOREARM_A_AXIS_ID)
		angleB, rotationB = self.getJoint(FOREARM_B_AXIS_ID)
		
		# calcula posicao e velocidade media das duas juntas
		return (angleA + angleB)/2.0, (rotationA + rotationB)/2.0
	
	#########################################################################
	# write forearm axis
	#########################################################################
	def setForearm(self, angle_ref):
		
		# limitacao angular de colisao
		# angle_ref = max(angle_ref, MIN_LIMIT_FOREARM)
		angle_ref = min(angle_ref, MAX_LIMIT_FOREARM)
		
		# seta a referencia do controlador
		self.ForearmCtrl.setReference(angle_ref, self.u_k_forearm, self.e_k_forearm)
		
		# medindo posicao e velocidade correntes
		angle, speed = self.getForearm()
		
		# pega a acao de controle
		self.u_k_forearm, self.e_k_forearm, torque = self.ForearmCtrl.get_U_k(angle, self.ref[2][1])
		self.outputFile_forearm.write(str(self.u_k_forearm) + ',' + str(self.e_k_forearm) + '\n')
		
		# seta posicao do servo do antebraco
		self.setJoint(FOREARM_A_AXIS_ID, self.u_k_forearm, torque)
		self.setJoint(FOREARM_B_AXIS_ID, self.u_k_forearm, torque)

	def setForearmOpenLoop(self, angle_ref):
		
		# limitacao angular de colisao
		angle_ref = max(angle_ref, MIN_LIMIT_FOREARM)
		angle_ref = min(angle_ref, MAX_LIMIT_FOREARM)
		
		# seta posicao do servo do antebraco
		self.setJoint(FOREARM_A_AXIS_ID, angle_ref, self.ref[2][1])
		self.setJoint(FOREARM_B_AXIS_ID, angle_ref, self.ref[2][1])

	def getGrip(self):
		# read registers of the last servo
		return self.getJoint(GRIP_AXIS_ID)

	def setGrip(self, angle_ref):
	
		# limitacao angular de colisao
		angle_ref = max(angle_ref, MIN_LIMIT_GRIP)
		angle_ref = min(angle_ref, MAX_LIMIT_GRIP)
		
		# seta posicao do servo da garra
		self.setJoint(GRIP_AXIS_ID, angle_ref, self.ref[3][1])
		
	#########################################################################
	# sincroniza todos os servos
	#########################################################################
	def update(self):
		# sincroniza todos os servos
		self.net.synchronize()
		
	#########################################################################
	# convert position to angle -> 0...300[deg]
	#########################################################################
	def pos2deg(self, pos):
		# satura posicao dentro dos limites
		pos = max(pos, A12_MIN_POS)
		pos = min(pos, A12_MAX_POS)
		# retorna posicao limitada
		return float(pos*ANGULAR_CONV_RATIO)
	
	#########################################################################
	# convert angle to position -> 0...1023
	#########################################################################
	def round_down(self, num, divisor):
		return num - (num%divisor)

	def deg2pos(self, angle):
		# satura angulo aos limites do servo A12+
		angle = max(angle, A12_MIN_ANGLE)
		angle = min(angle, A12_MAX_ANGLE)
		angle = self.round_down(angle, ANGULAR_CONV_RATIO)
		# retorna angulo limitado
		return int(angle/ANGULAR_CONV_RATIO)
	
	#########################################################################
	# convert speed to rotation -> 0...114[rpm]
	#########################################################################
	def speed2deg_sec(self, speed):
		# satura velocidade dentro dos limites
		speed = max(speed, A12_MIN_SPEED)
		speed = min(speed, A12_MAX_SPEED)
		# retorna velocidade limitada
		return speed*SPEED_CONV_RATIO 
	
	#########################################################################
	# convert rotation to speed -> 1...1023
	#########################################################################
	def deg_sec2speed(self, rotation):
		# satura rotacao aos limites do servo A12+
		rotation = max(rotation, A12_MIN_ROTATION)
		rotation = min(rotation, A12_MAX_ROTATION)
		# retorna angulo limitado
		return int(rotation/SPEED_CONV_RATIO)

	#########################################################################
	# convert torquebin to torque
	#########################################################################
	def bin2torque(self, torquebin):
		# satura torque dentro dos limites
		torquebin = max(torquebin, A12_MIN_TORQUEBIN)
		torquebin = min(torquebin, A12_MAX_TORQUEBIN)
		# retorna torque limitado
		return torquebin*TORQUE_CONV_RATIO 
	
	#########################################################################
	# convert torque to torquebin
	#########################################################################
	def torque2bin(self, torque):
		# satura torque aos limites do servo A12+
		torque = max(torque, A12_MIN_TORQUE)
		torque = min(torque, A12_MAX_TORQUE)
		# retorna angulo limitado
		return int(torque/TORQUE_CONV_RATIO)
		
	#########################################################################
	# calculo dos torques computacionais
	#########################################################################
	def torque_grav(self):
		# angulos dos links
		angle, speed = self.getShoulder()
		q1 = math.radians(angle - 5.0)
		angle, speed = self.getForearm()
		q2 = math.radians(angle - 5.0)
		
		# torque gravitacional
		G2q = abs(M2*G0*AC2*math.cos(q1+q2))
		G1q = abs(G0*(M1*AC1 + M2*A1)*math.cos(q1) + G2q)
		
		# torques gravitacionais
		self.Gq_shoulder = self.torque2bin(G1q)
		self.Gq_forearm = self.torque2bin(G2q)
		
		#print "1) Torque =", round(G1q, 2), "\tbin=", self.Gq_shoulder
		#print "2) Torque =", round(G2q, 2), "\tbin=", self.Gq_forearm
		#print "-----"
		
	#########################################################################
	# show all actuators data
	#########################################################################
	def show_all(self):
		m = 1
		print "---------------------------"
		print "Joint\tAngle[deg]\tSpeed[deg/s]"
		print "---------------------------"
		angle, speed = self.getBase()
		print "Base	 >>\t", round(angle, m), round(speed, m)
		angle, speed = self.getShoulder()
		print "Shoulder >>\t", round(angle, m), round(speed, m)
		angle, speed = self.getForearm()
		print "Forearm  >>\t", round(angle, m), round(speed, m)
		print "---------------------------"
	
	#########################################################################
	# salvando dados em arquivo
	#########################################################################
	def save(self):
		# salvando dados
		#self.logfile.write(str(tNow) + '\t') #current time
		#self.logfile.write(str(qm[LOGID]) + '\t' + str(vm[LOGID]) + '\t')
		#self.logfile.write(str(qs[LOGID]) + '\t' + str(vs[LOGID]) + '\t')
		# termina linha
		self.logfile.write('\n')
	
	#########################################################################
	# destrutor
	#########################################################################
	def __del__(self):
		# para tudo
		for id in range(1, len(self.Actuators)):
			self.Actuators[id].stop()
		# sincroniza todos os servos
		self.net.synchronize()
		#  fecha a serial
		self.serial.close()
		# fecha arquivo de log
		self.logfile.flush()
		self.logfile.close()

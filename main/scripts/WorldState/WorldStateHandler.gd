class_name WorldStateHandler

var Player1Frames = []
var Player2Frames = [] 

var player1 : PlayerHandler
var player2 : PlayerHandler

func reset():
	Player1Frames = []
	Player2Frames = []
	return

func saveFrame():
	Player1Frames.push_back(player1.getCurrentPlayerFrame())
	Player2Frames.push_back(player2.getCurrentPlayerFrame())
	print(Player1Frames.size())
	return
	

func rollback(timing : int):
	player1.returnToPlayerFrame(Player1Frames[timing])
	player2.returnToPlayerFrame(Player2Frames[timing])
	return


func setPlayers(p1 : PlayerHandler, p2 : PlayerHandler):
	player1 = p1
	player2 = p2
	return
	

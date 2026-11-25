class_name NetworkMessage
	
enum MessageType {ERROR, CONNECT, DISCONNECT, PING, MATCHINFO, LOADCOMPLETE, STARTMESSAGE, FRAMEDATAINPUT} #network message type
var mtype = MessageType.ERROR
var pArray : PackedByteArray
var matchInfoHolder : MatchInfo
var startMessageHolder : StartMessage
var frameDataHolder : FrameDataInput
var errorMessageHolder : ErrorMessage
var pingMessageHolder : PingMessage

func createConnectMessage() -> void:
	mtype = MessageType.CONNECT
	pArray = PackedByteArray()
	pArray.resize(1)
	pArray.encode_s8(0, MessageType.CONNECT)
	return
	

func createDisconnectMessage() -> void:
	mtype = MessageType.DISCONNECT
	pArray = PackedByteArray()
	pArray.resize(1)
	pArray.encode_s8(0, MessageType.DISCONNECT)
	return
	
	
func createPingMessage(origin : bool) -> void:
	mtype = MessageType.PING
	pingMessageHolder = PingMessage.new()
	pingMessageHolder.pingOrigin = int(origin)
	pArray = PackedByteArray()
	pArray.resize(2)
	pArray.encode_s8(0, MessageType.PING)
	pArray.encode_s8(1, int(origin))
	return
	
	
func createLoadCompleteMessage() -> void:
	mtype = MessageType.LOADCOMPLETE
	pArray = PackedByteArray()
	pArray.resize(1)
	pArray.encode_s8(0, MessageType.LOADCOMPLETE)
	return
	

func createMatchInfoMessage(frameDelay : int, roundsNumber : int, characterID : int, playerTimestamp : int) -> void:
	var matchI = MatchInfo.new()
	matchI.frameDelay = frameDelay
	matchI.roundsNumber = roundsNumber
	matchI.characterID = characterID
	matchI.playerTimestamp = playerTimestamp
	createMatchInfoMessageInternal(matchI)

func createMatchInfoMessageInternal(matchI : MatchInfo) -> void:
	mtype = MessageType.MATCHINFO
	matchInfoHolder = matchI
	pArray = PackedByteArray()
	pArray.resize(12)
	pArray.encode_s8(0, MessageType.MATCHINFO)
	pArray.encode_s8(1, matchInfoHolder.frameDelay)
	pArray.encode_s8(2, matchInfoHolder.roundsNumber)
	pArray.encode_s8(3, matchInfoHolder.characterID)
	pArray.encode_u64(4, matchInfoHolder.playerTimestamp) 
	return
	

func createStartMessage(startTiming : int, startType : int) -> void:
	var startM = StartMessage.new()
	startM.startTiming = startTiming
	startM.startType = startType
	createStartMessageInternal(startM)
	
func createStartMessageInternal(startM : StartMessage) -> void:
	mtype = MessageType.STARTMESSAGE
	startMessageHolder = startM
	pArray = PackedByteArray()
	pArray.resize(6)
	pArray.encode_s8(0, MessageType.STARTMESSAGE)
	pArray.encode_u32(1, startMessageHolder.startTiming)
	pArray.encode_s8(5, startMessageHolder.startType)
	return
	
func createFrameDataMessage(input : InputHolder, timing : int) -> void:
	var frameDataM = FrameDataInput.new()
	frameDataM.input = input
	frameDataM.timing = timing
	createFrameDataMessageInternal(frameDataM)

func createFrameDataMessageInternal(frameD : FrameDataInput) -> void:
	mtype = MessageType.FRAMEDATAINPUT
	frameDataHolder = frameD
	pArray = PackedByteArray()
	pArray.resize(10)
	pArray.encode_s8(0, MessageType.FRAMEDATAINPUT)
	pArray.encode_u32(1, frameD.timing) 
	pArray.encode_s8(5, frameD.input.direction)
	pArray.encode_s8(6, frameD.getPressNumber(frameD.input.A_Press, frameD.input.A_Release))
	pArray.encode_s8(7, frameD.getPressNumber(frameD.input.B_Press, frameD.input.B_Release))
	pArray.encode_s8(8, frameD.getPressNumber(frameD.input.C_Press, frameD.input.C_Press))
	pArray.encode_s8(9, frameD.getPressNumber(frameD.input.D_Press, frameD.input.D_Release))
	return
	

func createErrorMessage(errCode : int, dis : bool):
	var errM = ErrorMessage.new()
	errM.errorCode = errCode
	errM.causeDisconnect = dis
	createErrorMessageInternal(errM)
	return

func createErrorMessageInternal(errM : ErrorMessage) -> void:
	mtype = MessageType.ERROR
	errorMessageHolder = errM
	pArray = PackedByteArray()
	pArray.resize(2)
	pArray.encode_s8(MessageType.ERROR, 0)
	pArray.encode_s8(int(errM.causeDisconnect), 1)
	return
	

func toPackedByteArray() -> PackedByteArray:
	return pArray
	
	

func decodePacket(pa : PackedByteArray) -> void:
	var mt := pa.decode_s8(0)
	match mt:
		MessageType.CONNECT:
			mtype = MessageType.CONNECT
			pass
		MessageType.DISCONNECT:
			mtype = MessageType.DISCONNECT
			pass
		MessageType.LOADCOMPLETE:
			mtype = MessageType.LOADCOMPLETE
			pass
		MessageType.MATCHINFO:
			mtype = MessageType.MATCHINFO
			matchInfoHolder = MatchInfo.new()
			matchInfoHolder.frameDelay = pa.decode_s8(1)
			matchInfoHolder.roundsNumber = pa.decode_s8(2)
			matchInfoHolder.characterID = pa.decode_s8(3)
			matchInfoHolder.playerTimestamp = pa.decode_u64(4)
			pass
		MessageType.STARTMESSAGE:
			mtype = MessageType.STARTMESSAGE
			startMessageHolder = StartMessage.new()
			startMessageHolder.startTiming = pa.decode_u32(1)
			startMessageHolder.startType = pa.decode_s8(5)
			pass
		MessageType.FRAMEDATAINPUT:
			mtype = MessageType.FRAMEDATAINPUT
			frameDataHolder = FrameDataInput.new()
			frameDataHolder.timing = pa.decode_u32(1)
			frameDataHolder.input = InputHolder.new()
			frameDataHolder.input.direction = pa.decode_s8(5) as InputHolder.Direction
			var x = pa.decode_s8(6)
			frameDataHolder.input.A_Press = frameDataHolder.getPressNumberToPressBool(x)
			frameDataHolder.input.A_Release = frameDataHolder.getPressNumberToReleaseBool(x)
			x = pa.decode_s8(7)
			frameDataHolder.input.B_Press = frameDataHolder.getPressNumberToPressBool(x)
			frameDataHolder.input.B_Release = frameDataHolder.getPressNumberToReleaseBool(x)
			x = pa.decode_s8(8)
			frameDataHolder.input.C_Press = frameDataHolder.getPressNumberToPressBool(x)
			frameDataHolder.input.C_Release = frameDataHolder.getPressNumberToReleaseBool(x)
			x = pa.decode_s8(9)
			frameDataHolder.input.D_Press = frameDataHolder.getPressNumberToPressBool(x)
			frameDataHolder.input.D_Release = frameDataHolder.getPressNumberToReleaseBool(x)
			pass
		MessageType.ERROR:
			mtype = MessageType.ERROR
			errorMessageHolder = ErrorMessage.new()
			errorMessageHolder.causeDisconnect = bool(pa.decode_s8(1))
			pass
		MessageType.PING:
			mtype = MessageType.PING
			pingMessageHolder = PingMessage.new()
			pingMessageHolder.pingOrigin = pa.decode_s8(1)
		_:
			pass
	pass

func getMessageType() -> MessageType:
	return mtype
	
func getErrorMessage() -> ErrorMessage:
	return errorMessageHolder

func getStartMessage() -> StartMessage:
	return startMessageHolder
	
func getFrameDate() -> FrameDataInput:
	return frameDataHolder
	
func getMatchInfo() -> MatchInfo:
	return matchInfoHolder
		
		


class MatchInfo:
	var frameDelay : int
	var roundsNumber : int
	var characterID : int
	var playerTimestamp : int
	

class FrameDataInput:
	var input : InputHolder
	var timing : int
	
	func getPressNumber(pressBool : bool, releaseBool : bool) -> int:
		if pressBool && releaseBool:
			return 3
		elif releaseBool:
			return 2
		elif pressBool:
			return 1
		return 0
	
	func getPressNumberToPressBool(i : int) -> bool:
		match i:
			0:
				return false
			1:
				return true
			2:
				return false
			3:
				return true
			4:
				return false
		return false
		
	func getPressNumberToReleaseBool(i : int) -> bool:
		match i:
			0:
				return false
			1:
				return false
			2:
				return true
			3:
				return true
			4:
				return false
		return false
	

class StartMessage:
	var startTiming : int
	var startType : int #This is 0 for match and 1 for round
	

class ErrorMessage:
	var errorMessage : String
	var errorCode : int
	var causeDisconnect : bool
	

class PingMessage:
	var pingOrigin :  int

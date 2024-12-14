class networkMessage:
	
	enum MessageType {ERROR, STARTMESSAGE, FRAMEDATAINPUT} #network message type
	var mtype = MessageType.ERROR
	var pArray : PackedByteArray
	
	func createStartMessage() -> void:
		mtype = MessageType.STARTMESSAGE
		pArray = PackedByteArray()
		pArray.encode_s8(MessageType.STARTMESSAGE, 0)
		return
	
	func toPackedByteArray() -> PackedByteArray:
		return pArray
		
	
	func decodePacket(pa : PackedByteArray) -> void:
		var mt := pa.decode_s8(0)
		match mt:
			MessageType.STARTMESSAGE:
				pass
			MessageType.FRAMEDATAINPUT:
				pass
			MessageType.ERROR:
				pass
			_:
				pass
		pass
	

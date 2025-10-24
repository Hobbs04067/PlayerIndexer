local module = {}

function module.bitPack(data: {id: number, replicationAction: number})
	data.id = data.id or 0
	data.replicationAction = data.replicationAction or 0
	
	local packedAction = bit32.lshift(data.replicationAction, 16)
	
	local buff = buffer.create(2)
	buffer.writeu16(buff, 0, bit32.bor(packedAction, data.id))
	
	return buff
end

function module.bitUnpack(buff: buffer)
	local data = buffer.readu16(buff, 0)
	
	local unpackedAction = bit32.rshift(data, 16)
	local unpackedId = bit32.band(data, 0x0000FFFF)
	
	return unpackedAction, unpackedId
end

return module
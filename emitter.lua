Emitter = {}

function Emitter:new(obj)
	obj = obj or {}
	obj.emitter_callbacks = {}
	obj.on = Emitter.on
	obj.off = Emitter.off
	obj.trigger = Emitter.trigger
	return obj
end

function Emitter:on(event, callback)
	local event_callbacks = self.emitter_callbacks[event]
	if not event_callbacks then
		event_callbacks = {}
		self.emitter_callbacks[event] = event_callbacks
	end
	table.insert(event_callbacks, callback)
end

function Emitter:off(event, callback)
	if not callback then
		self.emitter_callbacks[event] = {}
	else
		local event_callbacks = self.emitter_callbacks[event]
		local do_continue = event_callbacks
		for i,v in ipairs(event_callbacks) do
			if v == callback then
				table.remove(event_callbacks, i)
				break
			end
		end
	end
end

local function fire_callbacks(ele, event, e, arg)
	local event_callbacks = ele.emitter_callbacks[event]
	if event_callbacks then
		local i = 1
		while not e.stop_propagation and i <= # event_callbacks do
			local callback = event_callbacks[i]
			callback(e, arg)
			i = i+1
		end
	end
	if ele.parent then fire_callbacks(ele.parent, event, e, arg) end
end

function Emitter:trigger(event, arg)
	local e = {
		name = event,
		target = self,
		stop_propagation = false
	}
	fire_callbacks(self, event, e, arg)
end

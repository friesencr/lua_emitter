Emitter = {}

-- initalize an event emitter, passing an object to mixin
function Emitter.new(obj)
	obj = obj or {}
	obj.emitter_callbacks = {}
	obj.on = Emitter.on
	obj.off = Emitter.off
	obj.trigger = Emitter.trigger
	obj.once = Emitter.once
	return obj
end

-- register an event callback
function Emitter:on(event, callback, this)
	assert(event)
	assert(callback)
	local event_callbacks = self.emitter_callbacks[event]
	if not event_callbacks then
		event_callbacks = {}
		self.emitter_callbacks[event] = event_callbacks
	end
	local registration = { callback = callback, this = this, event = event }
	table.insert(event_callbacks, registration)
	return registration
end

-- unregister an event callback
-- arg1 can be event or registration
function Emitter:off(arg1, callback)
	assert(arg1)
	if arg1.event then
		local event_callbacks = self.emitter_callbacks[arg1.event]
		for i,v in ipairs(event_callbacks) do
			if v == arg1 then
				table.remove(event_callbacks, i)
				break
			end
		end
	else
		if not callback then
			self.emitter_callbacks[arg1] = {}
		else
			local event_callbacks = self.emitter_callbacks[arg1]
			for i,v in ipairs(event_callbacks) do
				if v.callback == callback then
					table.remove(event_callbacks, i)
				end
			end
		end
	end
end

-- register a callback that only fires once
function Emitter:once(event, callback)
	assert(event)
	assert(callback)
	local event_callbacks = self.emitter_callbacks[event]
	if not event_callbacks then
		event_callbacks = {}
		self.emitter_callbacks[event] = event_callbacks
	end
	local registration = { callback = callback, this = this, once = true, event = event }
	table.insert(event_callbacks, registration)
	return registration
end

-- helper for firing callback
local function fire_callbacks(emitter, event, e, arg)
	local event_callbacks = emitter.emitter_callbacks[event]
	if event_callbacks then
		local i = 1
		while not e.stop_propagation and i <= # event_callbacks do
			local registration = event_callbacks[i]
			registration.callback(registration.this or self, e, arg)
			if registration.once then
				emitter:off(registration)
			end
			i = i+1
		end
	end
	if emitter.parent then
		fire_callbacks(emitter.parent, event, e, arg)
	end
end

-- trigger an event
function Emitter:trigger(event, arg)
	local e = {
		name = event,
		target = self,
		stop_propagation = false
	}
	fire_callbacks(self, event, e, arg)
end

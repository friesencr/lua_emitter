require 'emitter'

describe("new", function()

	it("should create an emitter", function()
		local emitter = Emitter.new()
		assert.truthy(emitter)
		assert.truthy(emitter.on)
		assert.truthy(emitter.off)
		assert.truthy(emitter.trigger)
	end)

	it("should mixin an emitter with the first argument", function()
		local obj = {}
		Emitter.new(obj)
		assert.truthy(obj.on)
		assert.truthy(obj.off)
		assert.truthy(obj.trigger)
	end)

end)

describe("on", function()

	it("should register a callback to the specified event", function()
		local emitter = Emitter.new()
		emitter:on('click', function() end)
		assert.equals(# emitter.emitter_callbacks.click, 1)
	end)

	it("should return a registration", function()
		local pizza = {}
		local emitter = Emitter.new()
		local registration = emitter:on("click", function() end, pizza)
		assert.truthy(registration.callback)
	end)

end)

describe("once", function()

	it("should register a callback to the specified event", function()
		local emitter = Emitter.new()
		emitter:once('click', function() end)
		assert.equals(# emitter.emitter_callbacks.click, 1)
	end)

	it("should return a registration", function()
		local pizza = {}
		local emitter = Emitter.new()
		local registration = emitter:once("click", function() end, pizza)
		assert.truthy(registration.callback)
	end)

end)

describe("off", function()

	it("should remove all registrations if just event is specified", function()
		local emitter = Emitter.new()
		emitter:on('click', function() end)
		emitter:on('click', function() end)
		assert.equals(# emitter.emitter_callbacks.click, 2)
		emitter:off('click')
		assert.equals(# emitter.emitter_callbacks.click, 0)
	end)

	it("removes all registrations equal to provided registration", function()
		local emitter = Emitter.new()
		emitter:on('click', function() end)
		local registration = emitter:on('click', function() end)
		assert.equals(# emitter.emitter_callbacks.click, 2)
		emitter:off(registration)
		assert.equals(# emitter.emitter_callbacks.click, 1)
	end)

	it("should remove by reference to callback", function()
		local emitter = Emitter.new()
		local function test() end
		emitter:on('click', test)
		assert.equals(# emitter.emitter_callbacks.click, 1)
		emitter:off('click', test)
		assert.equals(# emitter.emitter_callbacks.click, 0)
	end)

end)

describe("trigger", function()

	it("should trigger a registered callback", function()
		local emitter = Emitter.new()
		local counter = 0
		emitter:on('click', function() counter = counter + 1 end)
		emitter:trigger('click')
		assert.equals(counter, 1)
	end)

	it("should trigger multiple events", function()
		local emitter = Emitter.new()
		local counter = 0
		emitter:on('click', function() counter = counter + 1 end)
		emitter:on('click', function() counter = counter + 1 end)
		emitter:trigger('click')
		assert.equals(counter, 2)
	end)

	it("should fire registrations as long as they are registered", function()
		local emitter = Emitter.new()
		local counter = 0
		local reg = emitter:on('click', function() counter = counter + 1 end)
		emitter:trigger('click')
		emitter:trigger('click')
		assert.equals(counter, 2)
		emitter:off(reg)
		emitter:trigger('clikc')
		assert.equals(counter, 2)
	end)


	it("should unregister once registrations", function()
		local emitter = Emitter.new()
		local counter = 0
		emitter:once('click', function() counter = counter + 1 end)
		emitter:trigger('click')
		emitter:trigger('click')
		assert.equals(counter, 1)
	end)

	it("should take an extra argument paramater", function()
		local emitter = Emitter.new()
		local extra = nil
		emitter:on('click', function(sender, e, bonus) extra = bonus end)
		emitter:trigger('click', 'happiness')
		assert.equals(extra, 'happiness')
	end)

	describe("bubbling", function()

		it("should propagate events to parent if emitter has one", function()
			local emitter = Emitter.new()
			local parent = Emitter.new()
			local counter = 0
			parent:on('click', function() counter = counter + 1 end)
			emitter.parent = parent
			emitter:trigger('click')
			assert.equals(counter, 1)
		end)

		it("should stop propagation if stop_propagation is true", function()
			local child = Emitter.new()
			local parent = Emitter.new()
			local counter = 0
			parent:on('click', function() counter = counter + 1 end)
			child:on('click', function(sender, e) e.stop_propagation = true end)
			child.parent = parent
			child:trigger('click')
			assert.equals(counter, 0)
		end)

	end)

end)

Emitter
===========

Emitter allows for easy event binding and triggering between objects with a happy syntax.  The emitter
does not rely on metatables but duck typing.


To create an emitter
```lua
local emitter = Emitter.new()
```

An object can be passed into the constructor for easy mixin
```lua
local gui_element = Gui_Element.new()
Emitter.new(gui_element) -- yay for mixins
```

You bind with the on method

```lua
local jukebox = Emitter.new()
local function dance()
  every_body_dance_now()
end
jukebox:on('play', dance)
jukebox:trigger('play')
```

You unregister with the off method

```lua
local jukebox = Emitter.new()
local event_registration = jukebox:on('play', dance)

-- emergent undesirable behavior like finding out you need to take your car to the shop
jukebox:off('play') -- or
jukebox:off('play', dance) -- or
jukqbox:off(event_registration)
```

You can have an event only fire once

```lua
local emitter = Emitter.new()
local emitter:once('click', load_scene)
```

You can also specify a parent on the emitter

```lua
local child = Emitter.new()
local parent = Emitter.new()
child.parent = parent

parent:on('carnage', function() take_advil() end)
child.trigger('carnage')
```

There are quite a few subtlties not specified in the readme.  I would recommend reading the spec or the source.
## peleg-divingjob 

This resource supports QBCore, Qbox (qbx_core), and ESX frameworks, and integrates with ox_inventory, qb-inventory, and qs-inventory.

### Preview:
https://youtu.be/ylXodbn1s54

### What you need to add
- Metadata keys stored on the player: `divingLevel` (number) and `divingXP` (number)
- An inventory item named `diving_gear` in your inventory system

The resource reads/writes metadata via its bridge and registers `diving_gear` as a usable item for all supported frameworks.

### Config quick check
Set these in `config.lua` if you don’t want auto-detection:

```lua
--[[
    Framework: 'auto' | 'qb' | 'qbx' | 'esx'
    Inventory: 'auto' | 'ox' | 'qb'  | 'qs'
    Target:    'auto' | 'ox' | 'qb'  | 'drawtext'
]]
Config.Framework = 'auto'
Config.Inventory = 'auto'
Config.Target    = 'drawtext'
```

The resource updates these automatically as players loot containers. Adding sensible defaults in your framework ensures the values appear immediately on fresh characters.

### Add metadata defaults per framework

#### QBCore
Add defaults in your `qb-core` player metadata initialization (commonly `qb-core/server/player.lua`). Place the fields alongside your existing metadata defaults.

```lua
--[[ QBCore metadata defaults ]]
PlayerData.metadata = PlayerData.metadata or {
  hunger = 100,
  thirst = 100,
  divingLevel = 1,
  divingXP = 0,
}
```

### Define the diving gear item in your inventory
Item name must be `diving_gear`. Place an image named `diving_gear.png` in your inventory’s images folder. 
Adujst the path via `Config.InventoryImagesPath`.

#### ox_inventory (`ox_inventory/data/items.lua`)
```lua
--[[ ox_inventory item: diving_gear ]]
['diving_gear'] = {
  label = 'Diving Gear',
  weight = 1000,
  stack = false,
  close = true,
  description = 'Scuba mask and tank for underwater exploration',
  consume = 0,
},
```

#### qb-inventory (add in `qb-core/shared/items.lua`)
```lua
--[[ qb-inventory item: diving_gear ]]
['diving_gear'] = {
  ['name'] = 'diving_gear',
  ['label'] = 'Diving Gear',
  ['weight'] = 1000,
  ['type'] = 'item',
  ['image'] = 'diving_gear.png',
  ['unique'] = true,
  ['useable'] = true,
  ['shouldClose'] = true,
  ['combinable'] = nil,
  ['description'] = 'Scuba mask and tank for underwater exploration'
},
```

#### qs-inventory (items config, e.g. `qs-inventory/config/items.lua` or shared items file)
```lua
--[[ qs-inventory item: diving_gear ]]
['diving_gear'] = {
  name = 'diving_gear',
  label = 'Diving Gear',
  weight = 1000,
  type = 'item',
  image = 'diving_gear.png',
  unique = true,
  useable = true,
  shouldClose = true,
  description = 'Scuba mask and tank for underwater exploration',
},
```

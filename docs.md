## PlayerIndexer documentation

### Public API
- toPlayer(id: number): Player?  
  Returns the Player associated with the given numeric ID, or nil if none.
- toId(player: Player): number?  
  Returns the numeric ID associated with the given Player, or nil if none.

### Disclaimer:
- IDs are assigned and managed automatically on the server; do not attempt to assign IDs from user code unless you know what you're doing.
- This module uses a 'bi-directional' hash map for O(1) searches resulting in memory overhead.

### Examples:

Server-side (assignments happen automatically)
```lua
local PlayerIndexer = require(Path.To.PlayerIndexer)

game.Players.PlayerAdded:Connect(function(player)
    -- ID is assigned automatically; after assignment you can query it:
    local id = PlayerIndexer.toId(player)
    print("Assigned ID for", player.Name, id)
end)
```

Client-side (assignment is replicated upon players joining)
```lua
local PlayerIndexer = require(Path.To.PlayerIndexer)

-- get player by id
local player = PlayerIndexer.toPlayer(3)
if player then
    print("Player for id 3 is", player.Name)
else
    print("No player mapped to id 3")
end

-- get id for local player (may be nil until replicated)
local myId = PlayerIndexer.toId(game.Players.LocalPlayer)
print("My id is", myId)
```
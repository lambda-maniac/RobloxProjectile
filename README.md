# How to use
After creating the Module Script in your project, import it to any server script to use:
```lua
-- Load module.
local Projectile = require(...)
...
```
Now, load in the part for your projectile, it could be a premade one, or a `Instance.new("Part")` on the fly:
```lua
-- Your custom projectile, just a Part instance.
local projectilePart = game:GetService("...").projectilePart:Clone()
                    or Instance.new("Part")
...
```
Configuring the projectile's behaviour is also easy, here's a cheat table:
```lua
-- Configuring our projectile
local projectileInfo = {
    projectilePart    , -- Our part, that will represent the projectile.
    origin            , -- Spawn origin.
    originOffset      , -- Offset to add to the spawn origin.
    orientation       , -- Spawning orientation.
    orientationOffset , -- Offset to add to the spawn orientation.
    forwardOffset     , -- Offset to add to the LookVector (Projectile's forward direction).
    velocity          , -- Projectile's velocity.
    deadline          , -- Projectile's lifetime.
    mass              , -- Projectile's mass (Optional, 0 by default).
    target            , -- Target to seek for (Optional).
    rotationForce     , -- Angular rotation force applied to lock-on (Required if Target is not `nil`).
    acceleration        -- Projectile's acceleration over time (Optional).
}
...
```
We're almost done, now we just need to program the wanted behaviour on collision:
```lua
-- Let's define a simples one that destroys parts named "ToKill".
local function CheckCollision(infractor, projectile)
    if infractor.Name == "ToKill" then
        
        infractor:Destroy()
        
        return true -- Valid collision.
    end

    return false -- Not a valid collision.
end
...
```
> Just Remember that the CheckCollision function must have a signature of `Collision -> Part -> Bool`.

Now that everything is in place, we can instantiate a projectile and shoot it:
```lua
-- Create the projectile from the configuration table.
Projectile.new(
    table.unpack(projectileInfo)
):Act(CheckCollision) -- Spawning with the wanted collision function.
...
```
And that's it! Thank you for reading.

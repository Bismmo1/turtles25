--[[
================================================================================
Turtle Staircase Miner & Branch Miner (with Light Blocks)
================================================================================
Description:
This program will make a turtle mine a 1-wide, 4-high staircase (a 45-degree
tunnel) straight down until it encounters bedrock or Y-level -59.
It will place stair blocks (from slot 3) as it descends.

As it descends the staircase, it will place light blocks (like Glowstone,
from slot 4) in the right-hand wall every 5 blocks.

Once at the bottom, it will move back up 3 steps, turn left, and
dig a 2x1 branch mine for 10 blocks.

On its return trip up the branch mine, it will also place light blocks
(from slot 4) on the right-hand wall every 5 blocks.

It will then return to the start of the branch mine, place a chest,
and deposit all items except for slots 1-5.

Instructions:
1. Place the turtle where you want the staircase to begin.
2. Place fuel (coal, charcoal, etc.) in Slot 1.
3. Place a Chest in Slot 2.
4. Place Stair blocks in Slot 3.
5. Place Light Blocks (Glowstone, etc.) in Slot 4. (Slot 5 saved).
6. Make sure the turtle is equipped with a pickaxe.
7. Run the program.
================================================================================
--]]

---
-- Attempts to refuel the turtle from slot 1 if fuel is low.
-- @return boolean: true if successful or not needed, false if refuel failed.
---
local function checkFuel()
-- We'll set the low fuel threshold to 50 moves.
-- This will be checked before most movements.
if turtle.getFuelLevel() < 50 then
print("Low fuel, attempting to refuel from slot 1...")

local selectedSlot = turtle.getSelectedSlot() -- Remember currently selected slot
turtle.select(1) -- Switch to slot 1

-- Try to refuel one item
if turtle.refuel(1) then
print("Refueled successfully.")
else
print("Refuel failed! Make sure fuel is in slot 1.")
turtle.select(selectedSlot) -- Switch back to original slot
return false -- Report failure
end

turtle.select(selectedSlot) -- Switch back to original slot
end
return true -- Report success (or that fuel was fine)
end

-- --- FUNCTIONS FOR BEDROCK ROOM (PRE-MODIFICATION) ---
-- These functions (move, digAndClear, digLayer) are from a previous
-- version and are no longer called, but are kept for reference.

---
-- Moves the turtle forward a number of steps without digging.
-- @param steps (number): How many steps to move.
-- @return boolean: true if successful, false if out of fuel/obstructed
---
local function move(steps)
for i = 1, steps do
if not checkFuel() then
print("Room move: Out of fuel.")
return false
end
if not turtle.forward() then
print("Room move: Cannot move forward.")
return false
end
end
return true
end

---
-- Tries to dig in a direction (forward, up, down).
-- Handles gravel if digging forward.
-- Ignores failure if it's just air (per user request).
-- @param direction (string): "forward", "up", or "down"
-- @return boolean: true if successful or air, false if undiggable block.
---
local function digAndClear(direction)
local digFunc = turtle.dig
local inspectFunc = turtle.inspect
local attackFunc = turtle.attack

if direction == "up" then
digFunc = turtle.digUp
inspectFunc = turtle.inspectUp
attackFunc = turtle.attackUp
elseif direction == "down" then
digFunc = turtle.digDown
inspectFunc = turtle.inspectDown
attackFunc = turtle.attackDown
end

if not digFunc() then
-- Dig failed. Check if it was just air.
local hasBlock, data = inspectFunc()
if hasBlock then
-- It's not air. Try attacking.
print("Dig failed, trying to attack " .. direction .. "...")
if not attackFunc() then
print("Cannot break block " .. direction .. ". Stopping room dig.")
return false
end
end
-- If it was air, or attack succeeded, we're good.
end

-- Special gravel check only for digging forward
if direction == "forward" then
local retries = 0
local maxRetries = 10
local blockInWay = true

while retries < maxRetries do
sleep(0.5) -- Wait for fall
local hasBlock, data = inspectFunc()
if not hasBlock then
blockInWay = false
break
end

print("Room dig: Falling block detected! Clearing...")
if not digFunc() then
if not turtle.attack() then
print("Room dig: Failed to clear falling block.")
break -- leaves blockInWay = true
end
end
retries = retries + 1
end

if blockInWay then
print("Room dig: Could not clear path. Stopping room dig.")
return false
end
end

return true
end

---
-- Digs one 5x5 layer at the turtle's current Y-level.
-- Assumes turtle starts at (2, 0) [center of start row], facing "forward" (depth).
-- Ends at (2, 0) [center of start row], facing "forward".
-- @return boolean: true if successful, false if failed.
---
local function digLayer()
-- Turtle is at (2, 0), facing forward.
-- User: "mine two to the right and two to the left."
print("Digging layer: Clearing start row...")
turtle.turnLeft() -- Face left (x=0)
if not digAndClear("forward") then return false end
if not turtle.forward() then return false end -- At (1, 0)
if not digAndClear("forward") then return false end
if not turtle.forward() then return false end -- At (0, 0)

-- Now at (0, 0), facing left.
turtle.turnRight()
turtle.turnRight() -- Face right (x=4)

if not turtle.forward() then return false end -- At (1, 0)
if not turtle.forward() then return false end -- At (2, 0)

if not digAndClear("forward") then return false end
if not turtle.forward() then return false end -- At (3, 0)
if not digAndClear("forward") then return false end
if not turtle.forward() then return false end -- At (4, 0)

-- Now at (4, 0), facing right.

-- Start the lawnmower pattern for the next 4 rows
for row = 1, 4 do
print("Digging layer: row " .. (row+1) .. "/5")
-- Turn to face the next row
-- At (4, 0) facing right. Turn left to face "forward" (depth).
-- At (0, 1) facing left. Turn right to face "forward" (depth).
if row % 2 == 1 then
-- Odd row (1, 3): We are at x=4, face left
turtle.turnLeft() -- Face forward (depth)
if not digAndClear("forward") then return false end
if not turtle.forward() then return false end
turtle.turnLeft() -- Face left (x=0)
else
-- Even row (2, 4): We are at x=0, face right
turtle.turnRight() -- Face forward (depth)
if not digAndClear("forward") then return false end
if not turtle.forward() then return false end
turtle.turnRight() -- Face right (x=4)
end

-- Now dig across the 4 blocks in front
for i = 1, 4 do
if not digAndClear("forward") then return false end
if not turtle.forward() then return false end
end
end

-- After loop (row=4):
-- We are at (0, 4), facing left.
-- We need to end at (2, 0) facing forward.

-- Go to (0, 0)
turtle.turnRight() -- Face back
if not move(4) then return false end -- at (0,0) facing back

-- Go to (2, 0)
turtle.turnRight() -- Face right (x=4)
if not move(2) then return false end -- at (2,0) facing right

-- Face forward
turtle.turnRight() -- Face back
turtle.turnRight() -- Face forward

return true
end

-- --- NEW STAIRCASE FUNCTION ---

---
-- Places a stair from slot 3 behind the turtle.
-- @return boolean: true if successful, false if out of stairs
---
local function placeStair()
local selectedSlot = turtle.getSelectedSlot()
turtle.select(3)

if turtle.getItemCount(3) > 0 then
turtle.turnRight()
turtle.turnRight()

-- Try to place stair IN FRONT (which is behind original pos)
if not turtle.place() then
print("Stair WARNING: Could not place stair. Is block occupied?")
-- Still turn back, even if placement failed
end

turtle.turnRight()
turtle.turnRight()
turtle.select(selectedSlot)
return true
else
-- Out of stairs
print("Stair ERROR: Out of stairs in slot 3! Stopping staircase.")
turtle.select(selectedSlot)
return false
end
end


-- --- NEW FUNCTIONS FOR 2x1 MINESHAFT ---

---
-- Function to refuel the turtle from slot 1 for the mineshaft
---
local function mineshaft_refuel()
if turtle.getFuelLevel() < 10 then
local selectedSlot = turtle.getSelectedSlot()
turtle.select(1)
-- Refuel with a few items to be safe
if turtle.getItemCount(1) > 0 then
print("Mineshaft: Refueling...")
turtle.refuel(5)
else
print("Mineshaft WARNING: Out of fuel in slot 1!")
turtle.select(selectedSlot)
return false
end
turtle.select(selectedSlot)
end
return true
end

---
-- Function to dig forward for mineshaft, checking for obstacles
---
local function mineshaft_digForward()
-- Check and dig block in front
while turtle.detect() do
print("Mineshaft: Block in front, digging...")
turtle.dig()
sleep(0.5)
end
return turtle.forward()
end

---
-- Function to dig up for mineshaft, checking for obstacles
---
local function mineshaft_digUp()
while turtle.detectUp() do
print("Mineshaft: Block above, digging...")
turtle.digUp()
sleep(0.5)
end
end

---
-- NEW: Places a light block (Glowstone) from slot 4 on the right-hand wall.
-- It digs one block into the wall and places the light block inside.
---
local function placeLightBlockOnWall()
print("Placing light block...")
local selectedSlot = turtle.getSelectedSlot()
turtle.select(4) -- Slot 4 is for light blocks

if turtle.getItemCount(4) < 1 then
print("WARNING: Out of light blocks in slot 4!")
turtle.select(selectedSlot)
return
end

turtle.turnRight() -- Face the wall

-- 1. Dig the hole
if not turtle.dig() then
-- If dig fails (e.g., air), that's fine for placing a block.
-- If it's a hard block, try attacking.
local hasBlock, data = turtle.inspect()
if hasBlock then
print("Could not dig wall, trying to attack...")
if not turtle.attack() then
print("WARNING: Could not break wall block for light.")
turtle.turnLeft() -- Turn back
turtle.select(selectedSlot)
return -- Give up on this light
end
end
end

-- 2. Wait for falling blocks (gravel/sand)
sleep(0.5)
local hasBlock, data = turtle.inspect()
if hasBlock then
print("Block or liquid filled hole. Clearing...")
if not turtle.dig() then
if not turtle.attack() then
print("WARNING: Could not clear hole. Aborting placement.")
turtle.turnLeft()
turtle.select(selectedSlot)
return
end
end
end

-- 3. Place the light block
if not turtle.place() then
print("WARNING: Could not place light block.")
end

turtle.turnLeft() -- Turn back to original direction
turtle.select(selectedSlot)
end


---
-- Main function to run the 2x1 mineshaft
---
local function runMineshaft()
local tunnelLength = 10

print("Starting 2x1 branch mine program.")
print("Ensure fuel in slot 1, chest in 2, light blocks in 4.")
sleep(3) -- Give user time to read

-- Mining phase
for i = 1, tunnelLength do
print("Mineshaft: Mining segment " .. i .. "/" .. tunnelLength)

-- Ensure we have fuel
if not mineshaft_refuel() then
print("Mineshaft: Halting program due to lack of fuel.")
return
end

-- Dig upper block
mineshaft_digUp()

-- Dig lower block and move forward
if not mineshaft_digForward() then
print("Mineshaft: Cannot move forward. Obstruction?")
print("Mineshaft: Returning to start...")
break -- Exit loop if we can't move
end

-- After moving, dig the new upper block to clear the path
mineshaft_digUp()
end

print("Mineshaft: Mining complete. Returning to start...")

-- Return phase
turtle.turnLeft()
turtle.turnLeft()
for i = 1, tunnelLength do
if not mineshaft_refuel() then
print("Mineshaft: Halting program due to lack of fuel.")
return
end

-- NEW: Place light block logic
-- Place a light block every 5 blocks on the way back
if i % 5 == 0 then
placeLightBlockOnWall()
end

-- Try to move, if fails, dig and try again
if not turtle.forward() then
print("Mineshaft: Return blocked. Digging...")
turtle.dig()
sleep(0.5)
if not turtle.forward() then
print("Mineshaft: Still blocked. Giving up on return.")
return -- Critical failure
end
end
end

print("Mineshaft: Returned to start. Placing chest...")
turtle.turnLeft()
turtle.turnLeft() -- Turn back to original facing direction

-- Place chest from slot 2
turtle.select(2)
if turtle.getItemCount(2) < 1 then
print("Mineshaft ERROR: No chest in slot 2! Aborting deposit.")
return
end

if not turtle.place() then
print("Mineshaft: Failed to place chest. Is the spot blocked?")
print("Mineshaft: Trying to place above...")
if not turtle.placeUp() then
print("Mineshaft: Failed to place chest above. Aborting deposit.")
return
end
end

print("Mineshaft: Chest placed. Depositing items...")

-- Deposit items
-- MODIFIED: Skip slots 1-5 (fuel, chest, stairs, lights, spare)
local selectedSlot = turtle.getSelectedSlot() -- Save slot
for i = 6, 16 do
turtle.select(i)
local itemCount = turtle.getItemCount(i)
if itemCount > 0 then
print("Mineshaft: Depositing " .. itemCount .. " item(s) from slot " .. i)
turtle.drop() -- Drops the whole stack into the chest in front
end
end

turtle.select(selectedSlot) -- Restore original slot
print("Mineshaft: Item deposit complete.")
end


---
-- MODIFIED function. Was digBedrockRoom.
-- Now moves up 3 steps and starts the branch mine.
---
local function digBedrockBranch()
-- NEW: Clear space above before moving, as this is skipped on the last block
print("Bedrock reached. Clearing final headroom...")
if not turtle.digUp() then print("Could not dig headroom (1 above).") end
if turtle.up() then
if not turtle.digUp() then print("Could not dig headroom (2 above).") end
if turtle.up() then
if not turtle.digUp() then print("Could not dig headroom (3 above).") end
if not turtle.down() then print("Error moving down from 3-high.") end
end
if not turtle.down() then print("Error moving down from 2-high.") end
end
print("Headroom cleared.")


-- 1. Move 3 steps back up the staircase
print("Moving 3 steps back up the staircase to start branch mine...")
turtle.turnRight()
turtle.turnRight()

local movedUp = true
for i = 1, 3 do
if not checkFuel() then
print("Move up: Out of fuel.")
movedUp = false
break
end
if not turtle.up() then
print("Move up: Failed to move up (air?). Continuing...")
end
if not turtle.forward() then
print("Move up: Failed to move forward at step " .. i .. ". Obstruction?")
movedUp = false
break
end
end

if not movedUp then
print("Failed to move up 3 steps. Aborting branch mine.")
return -- Exit the function
end

-- 2. START OF NEW MINESHAFT LOGIC
print("Reached branch mine starting point.")
print("Turning left to start 2x1 mineshaft...")
turtle.turnLeft()

-- Call the new mineshaft function
runMineshaft()

print("Branch mine complete.")
end

-- --- Main Program ---

print("Starting 45-degree, 4-high staircase to bedrock.")
print("Place fuel in slot 1.")
print("Place a CHEST in slot 2.")
print("Place STAIRS in slot 3.")
print("Place LIGHT BLOCKS (Glowstone, etc.) in slot 4.")
print("Ensure the turtle has a suitable pickaxe.")

local keepMining = true
local staircaseBlocksMined = 0 -- NEW: Counter for light block placement
-- The main mining loop
while keepMining do
-- 1. Check fuel status and refuel if needed
if not checkFuel() then
print("Stopping due to fuel issue.")
keepMining = false
end

-- 2. Check Y-level and block below
if keepMining then
-- NEW: Check Y-level
-- This requires the GPS API to be available.
local x, y, z = gps.locate()

if y and y <= -59 then
print("Reached target Y-level -59. Stopping staircase.")
keepMining = false -- Stop the staircase part

-- Call function to dig the branch mine
print("Starting branch mine sequence...")
digBedrockBranch()
print("Branch mine sequence finished.")

-- Check block below (only if Y-level check didn't stop us)
elseif not turtle.digDown() then
print("Bedrock reached (or undiggable block)! Stopping staircase.")
keepMining = false -- Stop the staircase part

-- NEW: Call function to dig the branch mine
print("Starting branch mine sequence...")
digBedrockBranch()
print("Branch mine sequence finished.")

end
end

-- 3. Move down into the block we just dug
if keepMining then
if not turtle.down() then
print("Could not move down. Stopping.")
keepMining = false
end
end

-- 4. Clear headroom (level 1, for 2-high total)
if keepMining then
if not turtle.digUp() then
print("Could not dig headroom (1 above). Obstruction? Continuing...")
keepMining = true -- User request: Do not stop if this fails
end
end

-- 5. Move up to clear level 2 (for 3-high total)
if keepMining then
if not turtle.up() then
print("Could not move up. Stopping.")
keepMining = false
end
end

-- 6. Clear headroom (level 2)
if keepMining then
if not turtle.digUp() then
print("Could not dig headroom (2 above). Obstruction? Continuing...")
keepMining = true
end
end

-- 7. NEW: Move up to clear level 3 (for 4-high total)
if keepMining then
if not turtle.up() then
print("Could not move up. Stopping.")
keepMining = false
end
end

-- 8. NEW: Clear headroom (level 3)
if keepMining then
if not turtle.digUp() then
local hasBlock, data = turtle.inspectUp()
if hasBlock then
print("Could not dig extra headroom (3 above). Stopping.")
keepMining = false
else
print("No block for extra headroom (already 4-high or at build limit).")
end
end
end

-- 9. NEW: Move back down to the floor level
if keepMining then
if not turtle.down() then
print("Could not move back down. Stopping.")
keepMining = false
end
if not turtle.down() then
print("Could not move back down to floor level. Stopping.")
keepMining = false
end
end

-- 10. Dig the block in front
if keepMining then
if not turtle.dig() then
-- If digging fails (e.g., obsidian without a diamond pickaxe),
-- try to attack it. This will break blocks if it has a valid tool.
print("Could not dig, trying to attack...")
if not turtle.attack() then
print("Attack failed. Is it an unbreakable block? Stopping.")
keepMining = false -- This is an unminable block
end
end
end

-- 11. Check for falling blocks (gravel/sand)
if keepMining then
local retries = 0
local maxRetries = 10
local blockInWay = true

while retries < maxRetries do
sleep(0.5) -- Wait a moment for blocks to fall

local hasBlock, data = turtle.inspect()
if not hasBlock then
-- Nothing is in the way.
blockInWay = false
break -- Exit the gravel-check loop
end

-- A block is in the way. Dig it.
print("Falling block detected! Clearing... (Try " .. (retries + 1) .. "/" .. maxRetries .. ")")
if not turtle.dig() then
-- Failed to dig the falling block? Try attack.
if not turtle.attack() then
print("Failed to clear falling block. Stopping.")
blockInWay = true
break
end
end

retries = retries + 1
end

if blockInWay then
print("Could not clear path after " .. maxRetries .. " tries.Stopping.")
keepMining = false
end
end

-- 12. Move forward into the block we just cleared
if keepMining then
if not turtle.forward() then
-- If moving forward fails (e.g., attack failed, or an entity
-- like a mob is in the way), stop the program.
print("Cannot move forward. Obstruction? Stopping.")
keepMining = false
else
staircaseBlocksMined = staircaseBlocksMined + 1 -- Increment counter
end
end

-- 13. NEW: Place light block on staircase wall
if keepMining then
if staircaseBlocksMined > 0 and staircaseBlocksMined % 5 == 0 then -- Place every 5 blocks
print("Staircase: Placing light block...")
placeLightBlockOnWall()
end
end

-- 14. NEW: Place stair behind (was 13)
if keepMining then
if not placeStair() then
-- Out of stairs
keepMining = false
-- This stops the loop. digBedrockBranch() will not be called.
end
end

-- The loop repeats from here if keepMining is still true
end

print("Staircase and branch mining complete.")



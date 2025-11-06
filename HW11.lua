--[[
    This script creates an automated tunnel miner for a ComputerCraft turtle.
    It takes one argument: the number of levels (depth) to dig down initially.

    The main logic repeats the following pattern 4 times:
    1. Mine 5 blocks forward, then turn RIGHT.
    2. Mine 5 blocks forward, then turn LEFT.
    This creates a switchback, or zig-zag, pattern.
]]

-- Constants for the script
local TUNNEL_LENGTH = 5    -- The length of each forward segment
local PATTERN_REPEATS = 3  -- The number of times the full R/L sequence repeats

local args = { ... }

-- Function to handle startup and parameter checks
local function startup()
    if #args < 1 then
        print("Usage: miner <depth>")
        print(" <depth> is the number of vertical blocks to dig down.")
        print(" - Fuel should be placed in slot 1.")
        return false, nil
    end
    -- The first argument specifies how many blocks deep to dig.
    local depth = tonumber(args[1])
    if not depth or depth < 0 then
        print("Error: Depth must be a non-negative number.")
        return false, nil
    end
    print("Starting automated mining.")
    return true, depth
end

-- Function to check fuel and refuel if necessary
local function checkRefuel()
    local fuelLevel = turtle.getFuelLevel()
    print("Current fuel: " .. tostring(fuelLevel))

    if fuelLevel == "unlimited" then
        return
    end

    -- Refuel if less than a full segment's travel is left (5 blocks forward)
    if fuelLevel < (TUNNEL_LENGTH * 2 + 1) then
        turtle.select(1)
        -- Try to refuel 64 items (a stack)
        local success = turtle.refuel(64)
        if success then
            print("Refueled successfully!")
        else
            -- If refuel failed, check if slot 1 is empty or not fuel.
            print("Warning: Refuel failed. Check slot 1 for fuel.")
        end
    end
end

-- Function to dig down to the starting level
local function digDown(depth)
    print("Digging down " .. depth .. " levels...")
    for i = 1, depth do
        checkRefuel()
        turtle.digDown()
        if not turtle.down() then
            -- Blocked beneath, try to dig it again and move down
            turtle.digDown()
            turtle.down()
        end
    end
    print("Reached starting depth.")
end

-- Function to mine a single forward segment (e.g., 5 blocks)
local function mineSegment(length)
    print("Mining segment, length: " .. length)
    for i = 1, length do
        checkRefuel()
        
        -- 1. Dig the block in front
        turtle.dig()
        
        -- 2. Move forward
        if not turtle.forward() then
            -- If blocked after digging, maybe it was a falling block (gravel/sand).
            -- Try digging once more before stopping.
            turtle.dig()
            if not turtle.forward() then
                print("Tunnel blocked at step " .. i .. ". Stopping.")
                return false
            end
        end
        
        -- 3. Dig the block above (for a 2x1 tunnel)
        turtle.digUp()
    end
    return true
end

-- === MAIN PROGRAM START ===

local success, depth = startup()
if not success then return end

-- Step 1: Dig the initial vertical shaft
digDown(depth)

-- Step 2: Start the alternating switchback pattern
print("Starting " .. PATTERN_REPEATS .. " repetitions of the R/L tunnel pattern.")

-- This outer loop repeats the entire R/L sequence
for i = 1, PATTERN_REPEATS do
    
    -- === PART 1: MINE FORWARD, THEN TURN RIGHT ===
    
    if not mineSegment(TUNNEL_LENGTH) then return end
    print("Segment " .. (i * 2 - 1) .. " complete. Turning right.")
    
    -- Turn Right to start the next parallel path
    turtle.turnRight()
    turtle.dig()
    turtle.forward()
    turtle.digUp()
    turtle.turnRight()
    -- Move forward 1 block to clear the turn and prevent block clipping.
    -- This creates a 2-block wide clearance after the turn.
    -- === PART 2: MINE FORWARD, THEN TURN LEFT ===

    if not mineSegment(TUNNEL_LENGTH) then return end
    print("Segment " .. (i * 2) .. " complete. Turning left.")

    -- Turn Left to return to the original direction, but offset
    turtle.turnLeft()
    turtle.dig()
    turtle.forward()
    turtle.digUp()
    turtle.turnLeft()
    -- Move forward 1 block to clear the turn.
end
-- This loop iterates through all 16 inventory slots of the turtle.
for slot = 1, 16 do
  -- Get the details of the item in the current slot
  local details = turtle.getItemDetail(slot)
  
  -- Check if there is an item in the slot
  if details then
    -- Use 'print()' to automatically add a newline, putting each item on its own line.
    print("Slot " .. slot .. ": " .. details.name .. " x " .. details.count)
  end
end
print("Finished mining " .. (PATTERN_REPEATS * 2) .. " segments!")

-- The final step is typically to exit or return home, depending on your setup.
-- For this simple script, we just end.

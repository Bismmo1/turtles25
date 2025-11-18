--Maze Solver Turtle Script (Randomized Depth-First Search)
-- --- Configuration ---
local START_BLOCK = "green" -- Optional: block name for the start area
local END_BLOCK = "yellow"  -- Block name for the maze exit/victory area
local MAX_FUEL = 1000       -- Max fuel to check before starting
local DEBUG = false         -- Set to true to see more detailed logging

-- --- State Variables ---
local x, y, z = 0, 0, 0     -- Current relative position
local dir = 0               -- Current direction
local pathHistory = {}      -- Stack to store movement history
local visited = {}          -- Map of visited coordinates: "x-y-z" -> true

-- --- Utility Functions ---

--- Logs a message if DEBUG is true
local function log(message)
    if DEBUG then
        print("DEBUG: " .. message)
    end
end

--- Gets a unique key for the current position
local function getKey(px, py, pz)
    return px .. "-" .. py .. "-" .. pz
end

--- Record the current position as visited
local function recordVisit()
    visited[getKey(x, y, z)] = true
    log(string.format("Visited: (%d, %d, %d)", x, y, z))
end

--- Gets the position the turtle would move to given a specific direction
local function getNextPos(currentX, currentY, currentZ, movementDir)
    local nx, ny, nz = currentX, currentY, currentZ
    if movementDir == 0 then nz = nz - 1 -- North
    elseif movementDir == 1 then nx = nx + 1 -- East
    elseif movementDir == 2 then nz = nz + 1 -- South
    elseif movementDir == 3 then nx = nx - 1 -- West
    end
    return nx, ny, nz
end

--- Checks if the current direction is the exit.
local function checkExit()
    local ok, data = turtle.inspectDown()
    if ok and data.name:find(END_BLOCK) then
        print("\n[--- VICTORY! ---]")
        print("We finished the maze!")
        turtle.turnRight()
        turtle.turnRight()
        return true
    end
    return false
end

--- Turns the turtle to face a target horizontal direction.
local function turnTo(targetDir)
    if dir == targetDir then return end
    
    local rotations = (targetDir - dir + 4) % 4
    if rotations == 1 then
        log("Turning Right")
        turtle.turnRight()
    elseif rotations == 2 then
        log("Turning Back")
        turtle.turnRight()
        turtle.turnRight()
    elseif rotations == 3 then
        log("Turning Left")
        turtle.turnLeft()
    end
    dir = targetDir
end

--- Attempts to move the turtle forward
local function tryMove()
    local success, reason
    local nx, ny, nz = getNextPos(x, y, z, dir)

    -- Check if the new spot is already visited
    if visited[getKey(nx, ny, nz)] then
        log(string.format("Skipping (%d, %d, %d) - already visited.", nx, ny, nz))
        return false, "Visited"
    end
    
    -- Check for a block directly in front
    if turtle.detect() then
        return false, "Blocked"
    end

    -- Attempt the move
    success, reason = turtle.forward()
    if success then
        table.insert(pathHistory, {x = x, y = y, z = z, dir = dir}) 
        x, z = nx, nz
        recordVisit()
        log(string.format("Moved to (%d, %d, %d)", x, y, z))
        return true
    else
        log("Move failed: " .. (reason or "Unknown"))
        return false, reason
    end
end

--- Backtracks one step
local function backtrack()
    if #pathHistory == 0 then
        print("\n[--- DEAD END ---]")
        print("No more paths to explore. Maze unsolvable or we are back at the start.")
        return false -- Maze unsolvable
    end

    local last = table.remove(pathHistory)
    log(string.format("Backtracking from (%d, %d, %d) to (%d, %d, %d)", x, y, z, last.x, last.y, last.z))

    local success, reason
    turnTo((last.dir + 2) % 4)
    success, reason = turtle.forward()
    
    if success then
        x, y, z = last.x, last.y, last.z
        log(string.format("Backtracked horizontally to (%d, %d, %d)", x, y, z))
        turnTo(last.dir)
    end

    if not success then
        print("CRITICAL ERROR: Failed to backtrack (" .. (reason or "Unknown") .. "). Stuck at " .. getKey(x, y, z))
        return false
    end
    
    return true
end

-- --- Main Logic ---

local function solveMaze()
    print("--- Maze Turtle Initializing (2D Mode) ---")
    local fuel = turtle.getFuelLevel()
    if fuel < MAX_FUEL and fuel < 10 then
        print("WARN: Low fuel! Insert fuel in slot 1. Current level: " .. tostring(fuel))
        print("Will attempt to continue, but may stall.")
    end

    recordVisit()

    while true do
        if checkExit() then
            break
        end
        local possibleMoves = {}
        local originalDir = dir
        for i = 0, 3 do
            local newDir = (originalDir + i + 4) % 4 -- Current, Right, Back, Left
            local nx, ny, nz = getNextPos(x, y, z, newDir)

            if not visited[getKey(nx, ny, nz)] then
                -- Must face the direction to detect a block
                turnTo(newDir)
                if not turtle.detect() then
                    table.insert(possibleMoves, newDir)
                    log("Found unvisited horizontal path: " .. newDir)
                else
                    log("Horizontal path blocked: " .. newDir)
                end
            end
        end
        turnTo(originalDir)

        if #possibleMoves > 0 then
            -- Randomly choose one of the valid, unvisited paths
            local randomIndex = math.random(1, #possibleMoves)
            local chosenDirection = possibleMoves[randomIndex]

            turnTo(chosenDirection)
            local moved = tryMove() 
            if not moved then
                log("Failed horizontal move after selection. Retrying scan.")
            end
            
            os.sleep(0.1)
        else
          
            if not backtrack() then
                break -- No more history, we are stuck
            end
        end
    end
end

solveMaze()

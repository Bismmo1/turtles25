local args = { ... }
if #args < 1 then
    print("Will dig now!!!")
    print(" - Fuel in slot 1")
    
    return
end

local a = args[1]

local function refuel()
        turtle.select(1)
        turtle.refuel(10)
        print("Current fuel: " .. turtle.getFuelLevel())
end

for a = 1, a do
turtle.digDown()
turtle.down()
end

for a = 1, a-1 do
turtle.dig()
turtle.forward()
end


for a = 1, a-1 do
turtle.back()
end

for a = 1, a do
turtle.up()
end

print("I made it to the end!")

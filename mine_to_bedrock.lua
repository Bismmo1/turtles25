while true do                                                                              
    -- Mine one step of the staircase                                                      
    turtle.dig()                                                                           
    turtle.forward()                                                                       
                                                                                           
    -- Clear headroom for a player (3 blocks high)                                         
    turtle.digUp()                                                                         
    turtle.up()                                                                            
    turtle.digUp()                                                                         
    turtle.down()                                                                          
                                                                                           
    -- Descend to the next level                                                           
    turtle.digDown()                                                                       
    turtle.down()                                                                          
end                                                                                        
                                                                                           
print("Staircase mining stopped.")                                                         
-- Place a chest behind the starting position from slot 2.                                 
turtle.turnRight()                                                                         
turtle.turnRight()                                                                         
turtle.select(2)                                                                           
turtle.place()                                                                             
turtle.turnRight()                                                                         
turtle.turnRight()                                                                         
                                                                                           
local steps_down = 0                                                                       
                                                                                           
while true do                                                                              
    -- Check if inventory is full (slots 3-16).                                            
    local is_full = true                                                                   
    for i = 3, 16 do                                                                       
        if turtle.getItemCount(i) == 0 then                                                
            is_full = false                                                                
            break                                                                          
        end                                                                                
    end                                                                                    
                                                                                           
    -- If full, return to chest, deposit items, and go back to mining.                     
    if is_full then                                                                        
        -- Travel back up the staircase.                                                   
        for i = 1, steps_down do                                                           
            turtle.up()                                                                    
            turtle.back()                                                                  
        end                                                                                
                                                                                           
        -- Turn to face chest and deposit items.                                           
        turtle.turnRight()                                                                 
        turtle.turnRight()                                                                 
        for i = 3, 16 do                                                                   
            turtle.select(i)                                                               
            turtle.drop()                                                                  
        end                                                                                
        turtle.select(1) -- Reselect a non-chest slot.                                     
                                                                                           
        -- Turn back and travel down the staircase.                                        
        turtle.turnRight()                                                                 
        turtle.turnRight()                                                                 
        for i = 1, steps_down do                                                           
            turtle.forward()                                                               
            turtle.down()                                                                  
        end                                                                                
    end                                                                                    
                                                                                           
    -- Mine one step of the staircase                                                      
    turtle.dig()                                                                           
    turtle.forward()                                                                       
                                                                                           
    -- Clear headroom for a player (3 blocks high)                                         
    turtle.digUp()                                                                         
    turtle.up()                                                                            
    turtle.digUp()                                                                         
    turtle.down()                                                                          
                                                                                           
    -- Descend to the next level                                                           
    turtle.digDown()                                                                       
    turtle.down()                                                                          
                                                                                           
    steps_down = steps_down + 1                                                            
end                                                                                        
                                                                                           
print("Staircase mining stopped.")                                                         
                                                                                 
-- Place a chest from slot 2 behind the starting position.                                 
turtle.turnRight()                                                                         
turtle.turnRight()                                                                         
turtle.select(2)                                                                           
turtle.place()                                                                             
turtle.turnRight()                                                                         
turtle.turnRight()                                                                         
                                                                                           
local steps_down = 0                                                                       
                                                                                           
while true do                                                                              
    -- Check if inventory is full (slots 3-16).                                            
    local is_full = true                                                                   
    for i = 3, 16 do                                                                       
        if turtle.getItemCount(i) == 0 then                                                
            is_full = false                                                                
            break                                                                          
        end                                                                                
    end                                                                                    
                                                                                           
    -- If full, return to chest, deposit items, and go back to mining.                     
    if is_full then                                                                        
        -- Travel back up the staircase.                                                   
        for i = 1, steps_down do                                                           
            turtle.up()                                                                    
            turtle.back()                                                                  
        end                                                                                
                                                                                           
        -- Turn to face chest and deposit items from slots 3-16.                           
        turtle.turnRight()                                                                 
        turtle.turnRight()                                                                 
        for i = 3, 16 do                                                                   
            turtle.select(i)                                                               
            turtle.drop()                                                                  
        end                                                                                
        turtle.select(1) -- Reselect a non-chest slot (e.g. for fuel).                     
                                                                                           
        -- Turn back and travel down the staircase.                                        
        turtle.turnRight()                                                                 
        turtle.turnRight()                                                                 
        for i = 1, steps_down do                                                           
            turtle.forward()                                                               
            turtle.down()                                                                  
        end                                                                                
    end                                                                                    
                                                                                           
    -- Mine one step of the staircase                                                      
    if not turtle.dig() then break end                                                     
    if not turtle.forward() then break end                                                 
                                                                                           
    -- Clear headroom for a player (3 blocks high)                                         
    if not turtle.digUp() then break end                                                   
    if not turtle.up() then break end                                                      
    turtle.digUp() -- This can fail at the height limit, which is fine.                    
    if not turtle.down() then break end                                                    
                                                                                           
    -- Descend to the next level                                                           
    if not turtle.digDown() then break end                                                 
    if not turtle.down() then break end                                                    
                                                                                           
    steps_down = steps_down + 1                                                            
end                                                                                        
                                                                                           
print("Staircase mining stopped.")

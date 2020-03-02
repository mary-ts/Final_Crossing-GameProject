-- Called when the app's view has been resized
--local function onResize( event )
    -- re-layout the app's contents here
--end

--Runtime:addEventListener( "resize", onResize )

--Declare variables
local livesCount = 3
local livesText
local characterJumping = 0
local died = false
local background
local platform
local ground
local spikesStatic
local character

-- Looped background music obviously
local backgroundMusic = audio.loadStream( "backgroundMusic.mp3" )
audio.reserveChannels( 1 )
audio.setVolume( 0.5, { channel=1 } )
--audio.play( backgroundMusic, { channel=1, loops=-1 } )


local physics = require( "physics" )
physics.start()
physics.setGravity(0, 10)


-- Create background
background = display.newImageRect("light background.jpg", 1280, 800)
background.x = display.contentCenterX
background.y = display.contentCenterY


livesText = display.newText( "Lives: " .. livesCount, display.contentCenterX, 20, native.systemFont, 40 )
livesText:setFillColor( 1, 1, 1 )

--Create wall
--local cw, ch = display.actualContentWidth, display.actualContentHeight
--wall = display.newRect( display.contentCenterX+200, ch, 64, cw-20  )
--wall:setFillColor( 0.4, 0.4, 0.8 )

--physics.addBody( wall, "static", { bounce=0.6, friction=0 } )

--local cw, ch = display.actualContentWidth, display.actualContentHeight
--wall2 = display.newRect( display.contentCenterX-200, ch, 64, cw-20  )
--wall2:setFillColor( 0.4, 0.4, 0.8 )

--physics.addBody( wall2, "static", { bounce=0.6, friction=0 } )


-- Create ground object
local cw, ch = display.actualContentWidth, display.actualContentHeight
ground = display.newRect( display.contentCenterX, ch-64, cw, 64 )
ground:setFillColor( 0.4, 0.4, 0.8 )
ground.objType = "ground"

physics.addBody( ground, "static", { bounce=0.0, friction=0.3 } )

-- Create platform
platform = display.newImageRect("platform.png", 300, 40)
platform.x = display.contentCenterX+200
platform.y = display.contentCenterY+100
platform.myName = "platform"

physics.addBody( platform, "static", { bounce=0.0, friction=0.3 } )


--Move platform 1 way
transition.to( platform, { time=4000, x=(platform.x+250), iterations=0, transition = easing.continuousLoop  } )


-- Create spikes
spikesStatic = display.newImageRect("spikes.png", 300, 30)
spikesStatic.x = display.contentCenterX-400
spikesStatic.y = ground.y-46

physics.addBody( spikesStatic, "static", { bounce=0.0, friction=0.3 } )
spikesStatic.myName = "static spikes"


-- Create character
character = display.newImageRect("Portrait_-_Normal.png", 100, 120)
character.myName = "character"
character.x = display.contentCenterX
character.y = ground.y-150


physics.addBody( character, "dynamic", { density=1.0, bounce=0, radius =60})
-- Stop character falling
character.isFixedRotation = true


--Double jump method
local function jump(event)
  if ( direction == "left" and event.keyName == "space" and characterJumping<3) then
        character:applyLinearImpulse( -60, -60, character.x, character.y )
        characterJumping = characterJumping+1
      elseif ( direction == "right" and event.keyName == "space" and characterJumping<3) then
          character:applyLinearImpulse( 60, -60, character.x, character.y )
          characterJumping = characterJumping+1
        elseif ( event.keyName == "space" and characterJumping<3) then
            character:applyLinearImpulse( 0, -60, character.x, character.y )
            characterJumping = characterJumping+1
    end
--Resets jump to 0
    local function onCollision( self, event )
        --local self =
          if ( event.phase == "began" ) then
            characterJumping = 0
            character:setLinearVelocity( 0, 0 )
          end
        end

    character.collision = onCollision
    character:addEventListener( "collision" )
end

Runtime:addEventListener( "key", jump )


--Continuous move
local function move(event)
    if( event.phase == "up" ) then
      direction = nil
    elseif( event.phase == "down" ) then
      direction = event.keyName
    end
end

Runtime:addEventListener( "key", move)


--Direction
local function ButtonTrack(event)
    if( direction == "right" ) then
	    character.x = character.x + 8
      --main = "Portrait_-_talk.png"
    elseif( direction == "left" ) then
	    character.x = character.x - 8
    elseif( direction == "down" ) then
      character.y = character.y + 10
    end
  end

Runtime:addEventListener( "enterFrame", ButtonTrack )


--After death
local function restoreChar()

    character.isBodyActive = false
    character.x = display.contentCenterX
    character.y = ground.y - 150

-- Fade in the character
    transition.to( character, { alpha=1, time=1000, onComplete = function()
        character.isBodyActive = true
            died = false
        end
    } )
end


--Collision with spikesStatic
local function spikesCollision( event )
    if( event.phase == "began" ) then

      local obj1 = event.object1
      local obj2 = event.object2

        if( ( obj1.myName == "character" and obj2.myName == "static spikes" ) or ( obj1.myName == "static spikes" and obj2.myName == "character" ) )then
            if( died == false ) then
              died = true
                if( livesCount > 0 )then
                  --display.remove( character )
                  --Update lives
                  livesCount = livesCount - 1
                  livesText.text = "Lives: " .. livesCount
                  character.alpha = 0
                  timer.performWithDelay( 1000, restoreChar )
                else
                  character.alpha = 0
                  timer.performWithDelay( 1000, restoreChar )
                end
            end
        end
    end
end

    Runtime:addEventListener( "collision", spikesCollision )

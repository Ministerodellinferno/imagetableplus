

-- You can copy and paste this example directly as your main.lua file to see it in action
import "CoreLibs/graphics"

local gfx = playdate.graphics

-- Creating an image with a black circle
local circleDiameter = 25
local circleImage = gfx.image.new(circleDiameter, circleDiameter)
gfx.pushContext(circleImage)
    gfx.fillCircleInRect(0, 0, circleImage:getSize())
gfx.popContext()

-- Saving the original mask (the transparency in the corners of the image not covered by the circle)
local circleMask = circleImage:getMaskImage():copy()

-- Copying the original mask to preserve transparent regions around the circle
local ditherMask = circleMask:copy()
-- Drawing into mask with a dither effect
gfx.pushContext(ditherMask)
    gfx.setColor(gfx.kColorBlack)
    gfx.setDitherPattern(.4, gfx.image.kDitherTypeScreen)
    gfx.fillRect(0, 0, ditherMask:getSize())
gfx.popContext()

-- Copying the original mask to preserve transparent regions around the circle
local holeMask = circleMask:copy()
-- Drawing a hole into mask
gfx.pushContext(holeMask)
    gfx.setColor(gfx.kColorBlack)
    local width, height = holeMask:getSize()
    gfx.fillCircleAtPoint(width/2, height/2, width/4)
gfx.popContext()

function playdate.update()
    -- Circle is drawn with dithered regions transparent
    circleImage:setMaskImage(ditherMask)
    circleImage:drawAnchored(100, 120, 0.5, 0.5)

    -- Circle is drawn with hole in center
    circleImage:setMaskImage(holeMask)
    circleImage:drawAnchored(200, 120, 0.5, 0.5)

    -- Resetting the original mask returns the circle to normal
    circleImage:setMaskImage(circleMask)
    circleImage:drawAnchored(300, 120, 0.5, 0.5)
end

-- Technical details: Why copy the mask after getting it? :getMaskImage() returns a reference
-- to the mask image. Using :setMaskImage after will update that mask image to a new image, which
-- overwrites the referenced image and the original is lost. That's why we make a copy. Of course,
-- no :copy() calls are necessary if you don't intend to save the original mask.


require("sounds")

love.window.setMode(0, 0, {resizable=true})

b_quads = true

frames = {}
frame_number = 5
frame_index = 1
for i=1,frame_number do
    frames[i] = {}
    for j=1,12 do frames[i][j] = false end
end

bg_color = {238/256, 232/256, 213/256, 1}
fg_color = {131/256 , 148/256 , 150/256, 1}


function love.draw()
    disp_h = love.graphics.getHeight()
    disp_w = love.graphics.getWidth()
    love.graphics.clear(unpack(bg_color))
    love.graphics.push()
    if disp_w > disp_h then
        love.graphics.translate((disp_w-disp_h)/2, 0)
    end
    love.graphics.scale(math.min(disp_w, disp_h))
    draw_wheel(0, -.1, 1, frames[frame_index])
    draw_frames(0, 3/4, 1)
    love.graphics.pop()
end

function love.load(arg)
    love.graphics.setLineStyle("smooth")
end

function draw_wheel(dx, dy, length, frame)
    love.graphics.push()
    love.graphics.translate(dx, dy)
    love.graphics.scale(length, length)
    love.graphics.translate(.5, .5)

    quad_coords = {}

    for i=1,12 do
        love.graphics.setColor(unpack(fg_color))
        love.graphics.circle("fill",
        .25*math.sin((i-1)*math.pi/6),
        -.25*math.cos(-(i-1)*math.pi/6),
        .03, 15)
        if not frame[i] then
            love.graphics.setColor(unpack(bg_color))
            love.graphics.circle("fill",
            .25*math.sin((i-1)*math.pi/6),
            -.25*math.cos(-(i-1)*math.pi/6),
            .025, 15)
        else
            table.insert(quad_coords,
                .15*math.sin((i-1)*math.pi/6))
            table.insert(quad_coords,
                -.15*math.cos(-(i-1)*math.pi/6))
        end
    end

    love.graphics.setColor(unpack(fg_color))
    love.graphics.setLineWidth(.005)
    if #quad_coords == 4 then
        love.graphics.line(unpack(quad_coords))
    elseif #quad_coords > 4 then
        love.graphics.polygon("line", unpack(quad_coords))
    end

    love.graphics.pop()
end


border = .1
interior_size = 1-4*border
box_size = .05
function draw_frames(dx, dy, length)
    gap = (interior_size-frame_number*box_size) / (frame_number-1)
    love.graphics.push()
    love.graphics.translate(dx, dy)
    love.graphics.scale(length, height)
    love.graphics.setColor(unpack(bg_color))
    love.graphics.rectangle("fill", border, 0, 1-border*2, (1-border*2)*0.1)


    for i=1, frame_number do
        j = border*2 + (i-1)*(gap+box_size)
        love.graphics.setColor(unpack(fg_color))
        love.graphics.rectangle("fill", j, border*0.15, box_size, box_size)
        love.graphics.setColor(unpack(bg_color))
        love.graphics.rectangle("fill", j+.005, border*0.15+.005, box_size-.01, box_size-.01)

        -- Fill non-empty frames
        if not list_empty(frames[i]) then
            love.graphics.setColor(unpack(fg_color))
            love.graphics.rectangle("fill", j, border*0.15, box_size, box_size)
        end

    end

    -- Draw underline under current frame
    love.graphics.setColor(unpack(fg_color))
    love.graphics.rectangle("fill", (gap+box_size)*(frame_index-1)+border*2, box_size*1.5, box_size, .01)

    love.graphics.pop()
end

function  love.mousepressed(x, y, button, isTouch)
    disp_h = love.graphics.getHeight()
    disp_w = love.graphics.getWidth()

    if disp_w > disp_h then
        x = (x - (disp_w - disp_h)/2)/math.min(disp_w, disp_h)
    else
        x = x/math.min(disp_w, disp_h)
    end

    y = y/math.min(disp_w, disp_h)

    -- print(x, y)

    -- Get cursor position relative to wheel

    x_wheel = x - .5
    y_wheel = y +.1 - .5
    -- print(x_wheel, y_wheel)
    for i=1,12 do
        local c_x = .25*math.sin((i-1)*math.pi/6)
        local c_y = -.25*math.cos(-(i-1)*math.pi/6)
        -- print(i, )
        if math.sqrt((x_wheel-c_x)^2 + (y_wheel-c_y)^2) < .03 then
            frames[frame_index][i] = not frames[frame_index][i]
            if frames[frame_index][i] then
                play_sounds()
            end
        end
    end

    -- Get cursor position relative to frames
    x_frames = x
    y_frames = y - 3/4
    print(x_frames, y_frames)
    for i=1,frame_number do
        if x_frames < (i)*(box_size+gap) + border*2 and x_frames >= (i)*(box_size+gap) + box_size
        and
        y_frames > 0 and y_frames <= box_size
        then
            frame_index = i
            play_sounds()
        end
    end
end

function love.keypressed(key, scancode, isrepeat)
    if key == "space" then
        play_sounds()
    elseif key == "delete" then
        for j=1,12 do frames[frame_number][j] = false end
    elseif key == "left" then
        if frame_index > 1 then
            frame_index = frame_index - 1
        else
            frame_index = frame_number
        end
        play_sounds()
    elseif key == "right" then
        if frame_index < frame_number then
            frame_index = frame_index + 1
        else
            frame_index = 1
        end
        play_sounds()
    elseif key == "up" then
        if frame_number < 10 then
            frame_number = frame_number + 1
            frames[frame_number] = {}
            for j=1,12 do frames[frame_number][j] = false end
        end
    elseif key == "down" then
        if frame_number > 3 then
            frame_number = frame_number - 1
            frames[frame_number+1] = nil
            if frame_index > frame_number then frame_index = frame_number end
        end
    end
end

function play_sounds()
    d = .00858
    for i=1,12 do
        if frames[frame_index][i] then
            love.audio.newSource(pitches[i], "static"):play()
            -- local sound = sfxr.newSound()
            -- sound.frequency.start = .25+i*d --tone_frequencies[1]
            -- sound.lowpass.cutoff = .25
            -- sound.lowpass.sweep = .25
            -- sound.lowpass.resonance = .25
            -- sound.highpass.cutoff = 0
            -- sound.highpass.sweep = 0
            -- local sounddata = sound:generateSoundData()
            -- local source = love.audio.newSource(sounddata)
            -- source:play()
        end
    end
end

function list_empty(list)
    for i=1,#list do
        if list[i] == true then
            return false
        end
    end
    return true
end

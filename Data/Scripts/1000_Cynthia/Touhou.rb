def touhou()
    playingBGS = nil
    playingBGM = nil
    if $game_system && $game_system.is_a?(Game_System)
        playingBGS = $game_system.getPlayingBGS
        playingBGM = $game_system.getPlayingBGM
        $game_system.bgm_pause
        $game_system.bgs_pause
    end
    scene = TouhouScene.new()
    limit = 10000
    pbBGMPlay("Megalovania")
    loop do
        break if scene.result
        scene.update
    end
    if $game_system && $game_system.is_a?(Game_System)
        $game_system.bgm_resume(playingBGM)
        $game_system.bgs_resume(playingBGS)
    end
end

def touhouCreateUnown(scene, info)
    #type = rand(18)
    type = 0
    patterninfo = {}
    case type
    when 0 #normal
        patterninfo["patterntype"] = "single"
        patterninfo["delay"] = Graphics.frame_rate / 3
        patterninfo["bitmap"] = Bitmap.new("Graphics/Animations/eb191_3")
        patterninfo["bulletinfo"] = {
            "bitmap" => @bitmap1,
            "size" => 0.5
        }
    when 1 #fighting

    when 2 #flying

    when 3 #poison

    when 4 #ground

    when 5 #rock

    when 6 #bug

    when 7 #ghost

    when 8 #steel

    when 9 #fire

    when 10 #water

    when 11 #grass

    when 12 #electric

    when 13 #psychic

    when 14 #ice

    when 15 #dragon

    when 16 #dark

    when 17 #fairy

    end
    sprite = "201_" + rand(28).to_str
    shiny = false
    if rand(64) == 0
        sprite = "201s_" + rand(28.to_str)
        shiny = true
    end
    enemyinfo = {
        "enemy" => "Unown",
        "sprite" => sprite,
        "shiny" => shiny,

    }
    unown = TouhouEnemy.new(scene, enemyinfo)
    bulletpattern = BulletPattern.new(scene, patterninfo)
end

class TouhouScene
    attr_accessor :viewport
    attr_accessor :result
    attr_accessor :playerposition
    attr_accessor :playersprite
    attr_accessor :bulletsprites
    attr_accessor :bulletcache
    def update
        for i in 0..@playerspeed
            if Input.press?(Input::UP)
                if @playersprite.y - @playersprite.height > 1
                    @playersprite.y -= 1
                end
            end
            if Input.press?(Input::DOWN)
                if @playersprite.y < Graphics.height - 1
                    @playersprite.y += 1
                end
            end
            if Input.press?(Input::RIGHT)
                if @playersprite.x + @playersprite.width < Graphics.width - 1
                    @playersprite.x += 1
                end
            end
            if Input.press?(Input::LEFT)
                if @playersprite.x > 1
                    @playersprite.x -= 1
                end
            end
        end
        if Input.press?(Input::USE)
            fireBullet()
        end
        if @frameCounter < 1000
            @bulletcache.push(TouhouBullet.new(self))
        end
        if @frameCounter < 100
            @playerbulletcache.push(TouhouBullet.new(self))
        end
        if !(@requirerespawn > @frameCounter)
            if @requirerespawn == @frameCounter
                @playersprite.visible = true
                @playersprite.x = Graphics.width / 2 + @playersprite.width / 2
                @playersprite.y = Graphics.height / 2 - @playersprite.height
                @playerposition = [@playersprite.x + (@playersprite.width * 0.5), @playersprite.y - (@playersprite.height * 0.5)]
            end
            @playerposition = [@playersprite.x + (@playersprite.width * 0.5), @playersprite.y - (@playersprite.height * 0.5)]
            if Input.press?(Input::BACK)
                endScreen
            end
            # spawnBullet({
            #     "bitmap" => @bitmap1,
            #     "x" => Graphics.width / 2,
            #     "y" => 64,
            #     # "angle" => @attackoffset,
            #     "size" => 0.5,
            #     "speed" => 1
            # })
            # @attackoffset += 7
            # if @frameCounter % 100 == 0 && @frameCounter > 1
            #     angle = 0
            #     while angle < 360
            #         spawnBullet({
            #             "bitmap" => @bitmap2,
            #             "x" => Graphics.width / 2,
            #             "y" => 64,
            #             "angle" => angle,
            #             "speed" => 2
            #         })
            #         angle += 6
            #     end
            # end
        end

        bulletcount = @bulletsprites.length
        @bulletsprites.reverse_each do |bullet|
            bulletcount -= 1
            if !bullet.update()
                break if @requirerespawn > @frameCounter
                bullet.cacheBullet()
                @bulletcache.push(bullet)
                @bulletsprites.delete_at(bulletcount)
            end
        end
        bulletcount = @playerbulletsprites.length
        @playerbulletsprites.reverse_each do |bullet|
            bulletcount -= 1
            if !bullet.update()
                break if @requirerespawn > @frameCounter
                bullet.cacheBullet()
                @playerbulletcache.push(bullet)
                @playerbulletsprites.delete_at(bulletcount)
            end
        end
        Graphics.update
        Input.update
        @frameCounter += 1
    end

    def initialize
        @attackoffset = 0
        @activeenemies = []
        @frameCounter = 0
        @bitmap1 = Bitmap.new("Graphics/Animations/eb59_3")
        @bitmap2 = Bitmap.new("Graphics/Animations/eb195")
        @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport.z = 99999
        @sprites = {}
        @visibility = {}
        @bulletsprites = []
        @bulletcache = []
        @playerbulletsprites = []
        @playerbulletcache = []
        backgroundsprite = Sprite.new(@viewport)
        backgroundsprite.bitmap = Bitmap.new("Graphics/Battle animations/black_screen")
        addSprite("background",backgroundsprite)
        @playersprite = Sprite.new(@viewport)
        @playersprite.bitmap = Bitmap.new("Graphics/Undertale/PlayerHeart/Default/000")
        @playersprite.tone = Tone.new(0, 0, -255)
        @playersprite.angle += 90
        @playersprite.x = Graphics.width / 2 + @playersprite.width / 2
        @playersprite.y = Graphics.height / 2 - @playersprite.height
        addSprite("player", @playersprite)
        @playerposition = [0,0]
        @playerspeed = 2
        # @arceussprite = Sprite.new(@viewport)
        # @arceussprite.bitmap = Bitmap.new("Graphics/Characters/493_0")
        # @arceussprite.src_rect.height = 128
        # @arceussprite.src_rect.width = 128
        # @arceussprite.zoom_x = 0.5
        # @arceussprite.zoom_y = 0.5
        # @arceussprite.x = Graphics.width / 2
        # addSprite("arceus", @arceussprite)

        @firecooldown = 0
        @requirerespawn = 0
    end

    def addSprite(key,sprite)
        @sprites[key]    = sprite
        @visibility[key] = true
    end

    def killPlayer()
        cacheAllBullets()
        @playersprite.visible = false
        @requirerespawn = @frameCounter + (3*Graphics.frame_rate)
    end

    def endScreen()
        # Fade out all sprites
        pbBGMFade(1.0)
        pbFadeOutAndHide(@sprites)
        pbDisposeSpriteHash(@sprites)
        @result = true
    end

    def fireBullet()
        return if @firecooldown >= @frameCounter
        return if @requirerespawn >= @frameCounter
        return if @playerbulletcache.length == 0
        @playerbulletcache[0].spawnBullet({
            "bitmap" => @bitmap1,
            "x" => @playerposition[0],
            "y" => @playerposition[1],
            "angle" => 270,
            "size" => 0.5,
            "speed" => 10,
            "playerbullet" => true,
        })
        @playerbulletsprites.push(@playerbulletcache[0])
        @playerbulletcache.delete_at(0)
        @firecooldown = @frameCounter + (Graphics.frame_rate / 10)
    end

    def spawnBullet(info)
        return if @bulletcache.length == 0
        @bulletcache[0].spawnBullet(info)
        @bulletsprites.push(@bulletcache[0])
        @bulletcache.delete_at(0)
    end

    def cacheAllBullets()
        bulletcount = @bulletsprites.length
        @bulletsprites.reverse_each do |bullet|
            bulletcount -= 1
            bullet.cacheBullet()
            @bulletcache.push(bullet)
            @bulletsprites.delete_at(bulletcount)
        end
        bulletcount = @playerbulletsprites.length
        @playerbulletsprites.reverse_each do |bullet|
            bulletcount -= 1
            bullet.cacheBullet()
            @playerbulletcache.push(bullet)
            @playerbulletsprites.delete_at(bulletcount)
        end
    end
end

class TouhouBullet
    attr_accessor :cached
    def update
        @positionvector[0] += @anglevector[0]
        @positionvector[1] += @anglevector[1]
        @sprite.x = @positionvector[0].round
        @sprite.y = @positionvector[1].round
        if @sprite.x <= 0 || @sprite.x + width >= Graphics.width
            if @bounces > 0
                @anglevector[0] *= -1
                @bounces -= 1
            end
        end
        if @sprite.y <= 0
            if @bounces > 0
                @anglevector[1] *= -1
                @bounces -= 1
            end
        end
        if @opponent && 
          @sprite.x + (width * 0.20)  < @scene.playerposition[0] + (@scene.playersprite.width * 0.20) && @sprite.x + (width * 0.80) > @scene.playerposition[0] - (@scene.playersprite.width * 0.20) &&
          @sprite.y + (height * 0.20)  < @scene.playerposition[1] + (@scene.playersprite.width * 0.20) && @sprite.y + (height * 0.80) > @scene.playerposition[1] - (@scene.playersprite.width * 0.20)
            @scene.killPlayer()
            return false
        end
        if @sprite.x < -width || @sprite.x > Graphics.width + width
            cacheBullet()
            return false
        end
        if @sprite.y < -height || @sprite.y > Graphics.height + height
            cacheBullet()
            return false
        end
        return true
    end

    def initialize(scene)
        @scene = scene
        @bounces = 0
        @sprite = Sprite.new(@scene.viewport)
        cacheBullet()
    end

    def width
        return @sprite.width * @size
    end

    def height
        return @sprite.height * @size
    end

    def spawnBullet(info)
        @info = info
        @bounces = info["bounces"] || 0
        @sprite.bitmap = info["bitmap"]
        #@sprite.tone = Tone.new(rand(510) - 255,rand(510) - 255,rand(510) - 255)
        @size = info["size"] || 1
        @sprite.zoom_x *= @size
        @sprite.zoom_y *= @size
        @positionvector = [info["x"] - width / 2, info["y"] - height / 2]
        @sprite.x = @positionvector[0].round
        @sprite.y = @positionvector[1].round
        @sprite.z = 10000 - width - height
        @opponent = !info["playerbullet"]
        @speed = info["speed"] || 1
        if info["angle"]
            @angle = info["angle"] * 3.14 / 180
        else
            @angle = Math.atan2(@scene.playerposition[1] - @sprite.y - (height / 2), @scene.playerposition[0] - @sprite.x - (width / 2))
        end
        @anglevector = [Math.cos(@angle)*@speed, Math.sin(@angle)*@speed]
        # print(info["x"], " ", width / 2, " ", info["y"], " ", height / 2)
        # print(@sprite.x, " ", width, " ", @sprite.y, " ", height)
    end

    def cacheBullet()
        @sprite.x = -100
        @sprite.y = -100
        @sprite.z = 0
        @sprite.zoom_x = 1
        @sprite.zoom_y = 1
        @anglevector = [0, 0]
        @positionvector = [@sprite.x, @sprite.y]
    end
end

class TouhouEnemy
    def update
        @currentpattern.each do |pattern|
            pattern.update
        end
    end

    def x
        return @sprite.x
    end

    def width
        return @sprite.width * @size
    end

    def height
        return @sprite.height * @size
    end

    def initialize(scene, info)
        @scene = scene
        @bulletpatterns = info["bulletpatterns"]
        @currentpattern = @bulletpatterns[0]
        @sprite = Sprite.new(@scene.viewport)
        info["sprites"]
        @size = info["size"] || 1
    end
end

class BulletPattern
    def update
        return if @scene.requirerespawn >= @scene.frameCounter
        return if @delay >= @scene.frameCounter
        case patterntype
        when "single"

        when "circle"

        when "fan"

        when "rain"

        end
        @delay = @scene.frameCounter + @cooldown
    end

    def initialize(scene, info)
        @scene = scene
        @patterntype = info["patterntype"]
        @cooldown = info["cooldown"]
        @delay = @scene.frameCounter + (info["delay"] || 0)
        @bulletinfo = info["bulletinfo"]
        @enemy = info["enemy"]
    end
end
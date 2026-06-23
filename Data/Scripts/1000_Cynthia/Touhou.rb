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

class TouhouScene
    attr_accessor :viewport
    attr_accessor :result
    attr_accessor :playerposition
    attr_accessor :bulletsprites
    attr_accessor :bulletcache
    def update
        if Input.press?(Input::UP)
            if @playersprite.y - @playersprite.height > 2
                @playersprite.y -= 2
            end
        end
        if Input.press?(Input::DOWN)
            if @playersprite.y < Graphics.height - 2
                @playersprite.y += 2
            end
        end
        if Input.press?(Input::RIGHT)
            if @playersprite.x + @playersprite.width < Graphics.width - 2
                @playersprite.x += 2
            end
        end
        if Input.press?(Input::LEFT)
            if @playersprite.x > 2
                @playersprite.x -= 2
            end
        end
        if Input.press?(Input::USE)
            fireBullet()
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
            if @frameCounter < 1000
                @bulletcache.push(TouhouBullet.new(self))
            end
            spawnBullet(@bitmap1, Graphics.width / 2, 64, @attackoffset)
            @attackoffset += 7
            if @frameCounter % 100 == 0 && @frameCounter > 1
                angle = 0
                while angle < 360
                    spawnBullet(@bitmap2, Graphics.width / 2, 64, angle, 2)
                    angle += 6
                end
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
        end
        Graphics.update
        Input.update
        @frameCounter += 1
    end

    def initialize
        @attackoffset = 0
        @activeenemies = {}
        @frameCounter = 0
        @bitmap1 = Bitmap.new("Graphics/Animations/eb59_3")
        @bitmap2 = Bitmap.new("Graphics/Animations/eb195")
        @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport.z = 99999
        @sprites = {}
        @visibility = {}
        @bulletsprites = []
        @bulletcache = []
        backgroundsprite = Sprite.new(@viewport)
        backgroundsprite.bitmap = Bitmap.new("Graphics/Battle animations/black_screen")
        addSprite("background",backgroundsprite)
        @playersprite = Sprite.new(@viewport)
        @playersprite.bitmap = Bitmap.new("Graphics/Undertale/PlayerHeart/Default/000")
        @playersprite.tone = Tone.new(0, 0, -255)
        @playersprite.angle += 90
        @playersprite.x = Graphics.width / 2 + @playersprite.width / 2
        @playersprite.y = Graphics.height / 2 - @playersprite.height
        @playerposition = 0
        addSprite("player", @playersprite)
        @arceussprite = Sprite.new(@viewport)
        @arceussprite.bitmap = Bitmap.new("Graphics/Characters/493_0")
        @arceussprite.src_rect.height = 128
        @arceussprite.src_rect.width = 128
        @arceussprite.zoom_x = 0.5
        @arceussprite.zoom_y = 0.5
        @arceussprite.x = Graphics.width / 2
        addSprite("arceus", @arceussprite)

        @requirerespawn = 0
    end

    def addSprite(key,sprite)
        @sprites[key]    = sprite
        @visibility[key] = true
    end

    def killPlayer()
        cacheAllBullets()
        @playersprite.visible = false
        @requirerespawn = @frameCounter + 100
    end

    def endScreen()
        # Fade out all sprites
        pbBGMFade(1.0)
        pbFadeOutAndHide(@sprites)
        pbDisposeSpriteHash(@sprites)
        @result = true
    end

    def fireBullet()

    end

    def spawnBullet(bitmap, x, y, angle=0, speed=1)
        return if @bulletcache.length == 0
        @bulletcache[0].spawnBullet(bitmap, x, y, angle, speed)
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
    end
end

class TouhouBullet
    attr_accessor :cached
    def update
        @positionvector[0] += @anglevector[0]
        @positionvector[1] += @anglevector[1]
        @sprite.x = @positionvector[0]
        @sprite.y = @positionvector[1]
        if @sprite.x <= 0 || @sprite.x + (@sprite.width * @info["size"]) >= Graphics.width
            if @bounces > 0
                #@anglevector[0] *= 1
                @bounces -= 1
            end
        end
        if @sprite.y <= 0
            if @bounces > 0
                #@anglevector[1] *= 1
                @bounces -= 1
            end
        end
        if @opponent && 
          @sprite.x + (width * 0.20)  < @scene.playerposition[0] && @sprite.x + (width * 0.80) > @scene.playerposition[0] &&
          @sprite.y + (height * 0.20)  < @scene.playerposition[1] && @sprite.y + (height *0.80) > @scene.playerposition[1]
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
        return @sprite.width * @info["size"]
    end

    def height
        return @sprite.height * @info["size"]
    end

    def spawnBullet(info)
        @info = info
        @bounces = info["bounces"] || 0
        @sprite.bitmap = info["bitmap"]
        @sprite.zoom_x *= info["size"]
        @sprite.zoom_y *= info["size"]
        @sprite.x = info["x"]
        @sprite.x -= width
        @sprite.y = info["y"]
        @sprite.y -= width
        @opponent = info["opponent"]
        radian = info["angle"] * 3.14 / 180
        @anglevector = [Math.cos(radian)*speed, Math.sin(radian)*speed]
        @positionvector = [@sprite.x, @sprite.y]
    end

    def cacheBullet()
        @sprite.x = -100
        @sprite.y = -100
        @anglevector = [0, 0]
        @positionvector = [@sprite.x, @sprite.y]
    end
end

class TouhouEnemy
    def update

    end

    def initialize(scene)

    end
end

class BulletPattern
    def update

    end

    def initialize(scene)
    end
end
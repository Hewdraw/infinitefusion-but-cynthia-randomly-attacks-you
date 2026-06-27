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
    bulletpattern = TouhouBulletPattern.new(scene, patterninfo)
end

class TouhouScene
    attr_accessor :viewport
    attr_accessor :result
    attr_accessor :player
    attr_accessor :bulletsprites
    attr_accessor :bulletcache
    def update
        if @frameCounter < 1000
            @bulletcache.push(TouhouBullet.new(self))
            addSprite("bullet_#{@frameCounter}", @bulletcache[@bulletcache.length - 1].sprite)
        end
        if @frameCounter < 100
            @playerbulletcache.push(TouhouBullet.new(self))
            addSprite("playerbullet_#{@frameCounter}", @playerbulletcache[@playerbulletcache.length - 1].sprite)
        end
        @player.update()
        if Input.press?(Input::BACK)
            endScreen
        end
        print(3)
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
        print(4)
        Graphics.update
        Input.update
        @frameCounter += 1
        print(5)
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
        @player = TouhouPlayer.new(self)
        addSprite("player", @player.sprite)
        # @arceussprite = Sprite.new(@viewport)
        # @arceussprite.bitmap = Bitmap.new("Graphics/Characters/493_0")
        # @arceussprite.src_rect.height = 128
        # @arceussprite.src_rect.width = 128
        # @arceussprite.zoom_x = 0.5
        # @arceussprite.zoom_y = 0.5
        # @arceussprite.x = Graphics.width / 2
        # addSprite("arceus", @arceussprite)
    end

    def addSprite(key,sprite)
        @sprites[key]    = sprite
        @visibility[key] = true
    end

    def endScreen()
        # Fade out all sprites
        pbBGMFade(1.0)
        pbFadeOutAndHide(@sprites)
        pbDisposeSpriteHash(@sprites)
        @result = true
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

class TouhouEntity
    attr_accessor :sprite
    def x=(value)
        @sprite.x = value - width()
    end

    def y=(value)
        @sprite.y = value-height()
    end

    def x
        return @sprite.x + width()
    end

    def y
        return @sprite.y - height()
    end

    def width
        return @sprite.width * @size
    end

    def height
        return @sprite.height * @size
    end

    def collision_width
        return width * 0.25
    end

    def collision_height
        return height * 0.25
    end

    def initialize(scene, info={})
        @scene = scene
        @sprite = Sprite.new(@scene.viewport)
        @size = info["size"] || 1
    end
end

class TouhouPlayer < TouhouEntity
    def update
        for i in 0..@speed
            if Input.press?(Input::UP)
                if @sprite.y - @sprite.height > 1
                    @sprite.y -= 1
                end
            end
            if Input.press?(Input::DOWN)
                if @sprite.y < Graphics.height - 1
                    @sprite.y += 1
                end
            end
            if Input.press?(Input::RIGHT)
                if @sprite.x + @sprite.width < Graphics.width - 1
                    @sprite.x += 1
                end
            end
            if Input.press?(Input::LEFT)
                if @sprite.x > 1
                    @sprite.x -= 1
                end
            end
        end
        if Input.press?(Input::USE)
            fireBullet()
        end
    end

    def fireBullet()
        return if @firecooldown >= @scene.frameCounter
        return if @requirerespawn >= @scene.frameCounter
        return if @scene.playerbulletcache.length == 0
        @scene.playerbulletcache[0].spawnBullet({
            "bitmap" => @scene.bitmap1,
            "x" => x,
            "y" => y,
            "angle" => 270,
            "size" => 0.5,
            "speed" => 10,
            "playerbullet" => true,
        })
        @scene.playerbulletsprites.push(@playerbulletcache[0])
        @scene.playerbulletcache.delete_at(0)
        @firecooldown = @scene.frameCounter + (Graphics.frame_rate / 10)
    end

    def killPlayer()
        @scene.cacheAllBullets()
        @sprite.visible = false
        @requirerespawn = @frameCounter + (3*Graphics.frame_rate)
    end

    def initialize(scene)
        super
        @sprite = Sprite.new(@viewport)
        @sprite.bitmap = Bitmap.new("Graphics/Undertale/PlayerHeart/Default/000")
        @sprite.tone = Tone.new(0, 0, -255)
        @sprite.angle += 90
        x = Graphics.width / 2
        y = Graphics.height / 2
        @firecooldown = 0
        @requirerespawn = 0
        @speed = 2
    end
end

class TouhouEnemy < TouhouEntity
    def update
        @currentpattern.each do |pattern|
            pattern.update
        end
    end

    def initialize(scene, info)
        super
        @bulletpatterns = info["bulletpatterns"] || []
        @currentpattern = @bulletpatterns[0]
        @sprite.bitmap = info["sprites"]
    end
end

class TouhouBulletPattern
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

class TouhouBullet < TouhouEntity
    def update
        x += @anglevector[0]
        x += @anglevector[1]
        if x - (width * 0.5) <= 0 || x+ (width * 0.5) >= Graphics.width
            if @bounces > 0
                @anglevector[0] *= -1
                @bounces -= 1
            end
        end
        if y - (height * 0.5) <= 0
            if @bounces > 0
                @anglevector[1] *= -1
                @bounces -= 1
            end
        end
        if @opponent && 
          x - collision_width  < @scene.player.x + @scene.player.collision_width && x + collision_width  > @scene.player.x - @scene.player.collision_width &&
          y - collision_height  < @scene.player.y + @scene.player.collision_height && y + collision_height  > @scene.player.y - @scene.player.collision_height
            @scene.player.killPlayer()
            return false
        end
        if x + width < 0 || x - width > Graphics.width
            cacheBullet()
            return false
        end
        if y + height < 0 || y - width > Graphics.height
            cacheBullet()
            return false
        end
        return true
    end

    def initialize(scene)
        super
        cacheBullet()
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
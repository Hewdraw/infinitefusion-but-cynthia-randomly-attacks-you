def touhou()
    playingBGS = nil
    playingBGM = nil
    if $game_system && $game_system.is_a?(Game_System)
        playingBGS = $game_system.getPlayingBGS
        playingBGM = $game_system.getPlayingBGM
        $game_system.bgm_pause
        $game_system.bgs_pause
    end
    $PokemonGlobal.speedupdisabled = true
    scene = TouhouScene.new()
    pbBGMPlay("Megalovania")
    loop do
        break if scene.result
        scene.update
    end
    $PokemonGlobal.speedupdisabled = false
    if $game_system && $game_system.is_a?(Game_System)
        $game_system.bgm_resume(playingBGM)
        $game_system.bgs_resume(playingBGS)
    end
end

def touhouCreateUnown(scene, info={}, movementinfo=[], type=nil)
    type = rand(5) if !type
    patterninfo = {}
    case type
    when 0 #normal
        patterninfo["patterntype"] = "single"
        patterninfo["cooldown"] = Graphics.frame_rate / 3
        patterninfo["bitmap"] = Bitmap.new("Graphics/Animations/eb191_3")
        patterninfo["bulletinfo"] = {
            "bitmap" => @bitmap1,
            "size" => 0.5,
            "color" => Tone.new(0, 0, 0, 0),
        }
    when 1 #fighting
        patterninfo["patterntype"] = "single"
        patterninfo["cooldown"] = Graphics.frame_rate
        patterninfo["bitmap"] = Bitmap.new("Graphics/Animations/eb191_3")
        patterninfo["bulletinfo"] = {
            "bitmap" => @bitmap1,
            "size" => 0.5,
            "speed" => 4,
            "color" => Tone.new(255, 0, 0),
        }
    when 2 #flying
        patterninfo["patterntype"] = "fan"
        patterninfo["spread"] = 5
        patterninfo["count"] = 5
        patterninfo["cooldown"] = Graphics.frame_rate
        patterninfo["bitmap"] = Bitmap.new("Graphics/Animations/eb191_3")
        patterninfo["bulletinfo"] = {
            "bitmap" => @bitmap1,
            "size" => 0.3,
            "speed" => 2,
            "color" => Tone.new(0, 0, 0, 255),
        }
    when 3 #poison
        patterninfo["patterntype"] = "single"
        patterninfo["cooldown"] = Graphics.frame_rate * 5
        patterninfo["bitmap"] = Bitmap.new("Graphics/Animations/eb191_3")
        patterninfo["bulletinfo"] = {
            "bitmap" => @bitmap1,
            "size" => 2,
            "speed" => 0.2,
            "color" => Tone.new(255, 0, 255),
        }
    when 4 #ground
        patterninfo["patterntype"] = "circle"
        patterninfo["spread"] = 8
        patterninfo["cooldown"] = Graphics.frame_rate * 10
        patterninfo["bitmap"] = Bitmap.new("Graphics/Animations/eb191_3")
        patterninfo["bulletinfo"] = {
            "bitmap" => @bitmap1,
            "size" => 0.5,
            "speed" => 1,
            "color" => Tone.new(0, 255, 0),
        }
    when 5 #rock

    when 6 #bug

    when 7 #ghost

    when 8 #steel

    when 9 #fire
        # patterninfo["patterntype"] = "circle"
        # patterninfo["spread"] = 72
        # patterninfo["cooldown"] = Graphics.frame_rate * 5
        # patterninfo["bitmap"] = Bitmap.new("Graphics/Animations/eb191_3")
        # patterninfo["burst"] = 5
        # patterninfo["burstdelay"] = 10
        # patterninfo["bulletinfo"] = {
        #     "bitmap" => @bitmap1,
        #     "size" => 2,
        #     "speed" => 2,
        #     "color" => Tone.new(255, 0, 0),
        # }
    when 10 #water

    when 11 #grass
        direction = (rand(2) + 1) * 2 - 3
        patterninfo["patterntype"] = "single"
        patterninfo["cooldown"] = Graphics.frame_rate
        patterninfo["angleoffset"] = -20 * direction
        patterninfo["bitmap"] = Bitmap.new("Graphics/Animations/eb191_3")
        patterninfo["burst"] = 10
        patterninfo["burstchanges"] = {"speed" => 0.1, "angle" => 4 * direction}
        patterninfo["burstdelay"] = 10
        patterninfo["bulletinfo"] = {
            "bitmap" => @bitmap1,
            "size" => 0.5,
            "speed" => 1,
            "color" => Tone.new(0, 255, 0, 0),
        }
    when 12 #electric
        patterninfo["patterntype"] = "single"
        patterninfo["cooldown"] = Graphics.frame_rate
        patterninfo["bitmap"] = Bitmap.new("Graphics/Animations/eb191_3")
        patterninfo["burst"] = 10
        patterninfo["burstchanges"] = {"speed" => 0.2}
        patterninfo["burstdelay"] = 2
        patterninfo["bulletinfo"] = {
            "bitmap" => @bitmap1,
            "size" => 0.5,
            "speed" => 1,
            "color" => Tone.new(255, 255, 0, 0),
        }

    when 13 #psychic

    when 14 #ice

    when 15 #dragon

    when 16 #dark

    when 17 #fairy

    end
    sprite = "201_#{rand(28)}"
    shiny = false
    if rand(64) == 0
        sprite = "201s_#{rand(28)}"
        shiny = true
    end
    bitmap = Bitmap.new("Graphics/Characters/#{sprite}")
    enemyinfo = {
        "enemy" => "Unown",
        "sprite" => bitmap,
        "shiny" => shiny,
    }
    enemyinfo = enemyinfo.merge(info)
    unown = TouhouEnemy.new(scene, enemyinfo, [patterninfo], movementinfo)
    return unown
end

class TouhouScene
    attr_accessor :viewport
    attr_accessor :result
    attr_accessor :player
    attr_accessor :opponents
    attr_accessor :bulletsprites
    attr_accessor :bulletcache
    attr_accessor :playerbulletsprites
    attr_accessor :playerbulletcache
    attr_accessor :frameCounter
    attr_accessor :bitmap1
    attr_accessor :width
    attr_accessor :height
    def update
        @frameCounter += 1
        if @frameCounter <= 1000
            @bulletcache.push(TouhouBullet.new(self))
            addSprite("bullet_#{@frameCounter}", @bulletcache[@bulletcache.length - 1].sprite)
        end
        if @frameCounter <= 100
            @playerbulletcache.push(TouhouBullet.new(self))
            addSprite("playerbullet_#{@frameCounter}", @playerbulletcache[@playerbulletcache.length - 1].sprite)
        end
        @player.update()
        if @frameCounter % 100 == 0
            @opponents.push(touhouCreateUnown(self, {
                "y" => -10,
                "x" => @width / 3,
                "size" => 0.5,
            },
            [{
                "y" => 100
            },
            {
                "x" => @width + 100
            }
        ]))
        end
        if (@frameCounter + 50) % 100 == 0
            @opponents.push(touhouCreateUnown(self, {
                "y" => -10,
                "x" => @width / 3 * 2,
                "size" => 0.5,
            },
            [{
                "y" => 100
            },
            {
                "x" => -100
            }
        ]))
        end
        opponentindex = @opponents.length
        @opponents.reverse_each do |opponent|
            opponentindex -= 1
            if opponent.x <= -100 && opponent.y <= -100 || opponent.x >= @width + 100 || opponent.y >= @height + 100
                @opponents.delete_at(opponentindex)
                next
            end
            opponent.update
        end
        # if @player.requirerespawn < @frameCounter
        #     spawnBullet({
        #         "bitmap" => @bitmap1,
        #         "x" => Graphics.width / 2,
        #         "y" => 64,
        #         "angle" => @attackoffset,
        #         "size" => 0.5,
        #         "speed" => 1
        #     })
        #     @attackoffset += 7
        #     if @frameCounter % 100 == 0 && @frameCounter > 1
        #         angle = 0
        #         while angle < 360
        #             spawnBullet({
        #                 "bitmap" => @bitmap2,
        #                 "x" => Graphics.width / 2,
        #                 "y" => 64,
        #                 "angle" => angle,
        #                 "size" => 0.5,
        #                 "speed" => 2
        #             })
        #             angle += 6
        #         end
        #     end
        # end

        bulletcount = @bulletsprites.length
        @bulletsprites.reverse_each do |bullet|
            bulletcount -= 1
            if !bullet.update()
                break if @player.requirerespawn > @frameCounter
                bullet.cacheBullet()
                @bulletcache.push(bullet)
                @bulletsprites.delete_at(bulletcount)
            end
        end
        bulletcount = @playerbulletsprites.length
        @playerbulletsprites.reverse_each do |bullet|
            bulletcount -= 1
            if !bullet.update()
                break if @player.requirerespawn > @frameCounter
                bullet.cacheBullet()
                @playerbulletcache.push(bullet)
                @playerbulletsprites.delete_at(bulletcount)
            end
        end
        if Input.press?(Input::BACK)
            endScreen
        end
        Graphics.update
        Input.update
    end

    def initialize
        @leftborder = 16
        @width = Graphics.width * 2 / 3
        @topborder = 8
        @height = Graphics.height - 16
        @spriteLoader = BattleSpriteLoader.new
        @attackoffset = 0
        @activeenemies = []
        @sprites = {}
        @visibility = {}
        @bulletsprites = []
        @bulletcache = []
        @playerbulletsprites = []
        @playerbulletcache = []
        @frameCounter = 0
        @bitmap1 = Bitmap.new("Graphics/Animations/eb59_3")
        @bitmap2 = Bitmap.new("Graphics/Animations/eb195")
        @uiviewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @uiviewport.z = 999
        uibackgroundsprite = Sprite.new(@uiviewport)
        uibackgroundsprite.bitmap = Bitmap.new("Graphics/Battle animations/black_screen")
        addSprite("uibackground", uibackgroundsprite)
        @viewport = Viewport.new(@leftborder, @topborder, @width, @height)
        @viewport.z = 99999
        backgroundsprite = Sprite.new(@viewport)
        backgroundsprite.bitmap = Bitmap.new("Graphics/Pictures/HallOfFame/hallfamebg_multiline")
        backgroundsprite.x = 0
        backgroundsprite.y = 0
        backgroundsprite.src_rect.width = @width
        backgroundsprite.src_rect.height = @height
        addSprite("background",backgroundsprite)
        @player = TouhouPlayer.new(self)
        addSprite("player", @player.sprite)
        @opponents = []
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
        @opponents.each do |opponent|
            opponent.sprite.dispose
        end
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
    attr_reader :x
    attr_reader :y
    def set_x(value)
        @x = value
        @sprite.x = @x.round()
        @sprite.ox = @sprite.width / 2
    end

    def set_y(value)
        @y = value
        @sprite.y = @y.round()
        @sprite.oy = @sprite.height / 2
    end

    def width
        return @sprite.width * @size
    end

    def height
        return @sprite.height * @size
    end

    def collision_width
        return width * 0.20
    end

    def collision_height
        return height * 0.20
    end

    def initialize(scene, info={})
        @scene = scene
        @sprite = Sprite.new(@scene.viewport)
        @size = info["size"] || 1
        set_x(info["x"] || -100)
        set_y(info["y"] || -100)
    end
end

class TouhouPlayer < TouhouEntity
    attr_accessor :requirerespawn

    def collision_width
        return width * 0.10
    end

    def collision_height
        return height * 0.10
    end

    def update
        if @requirerespawn == @scene.frameCounter
            @sprite.visible = true
            set_x(@scene.width / 2)
            set_y(@scene.height / 2)
        end
        if Input.press?(Input::ACTION)
            @speed = 1
        else
            @speed = 2
        end
        for i in 0..@speed
            if Input.press?(Input::UP)
                if @y - (height / 2) > 1
                    set_y(@y-1)
                end
            end
            if Input.press?(Input::DOWN)
                if @y + (height / 2) < @scene.height - 1
                    set_y(@y+1)
                end
            end
            if Input.press?(Input::LEFT)
                if @x - (width / 2) > 1
                    set_x(@x-1)
                end
            end
            if Input.press?(Input::RIGHT)
                if @x + (width / 2) < @scene.width - 1
                    set_x(@x + 1)
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
        return if @scene.playerbulletcache.length < 3
        angle = 270
        bulletinfo = {
            "bitmap" => @projectilebitmap,
            "x" => @x,
            "y" => @y - 10,
            "angle" => angle,
            "size" => 0.5,
            "speed" => 10,
            "playerbullet" => true,
        }
        for i in 0...3
            bulletinfo["angle"] = 5 + angle - (5*i)
            bulletinfo["x"] = 5 + @x - (5*i)
            @scene.playerbulletcache[0].spawnBullet(bulletinfo)
            @scene.playerbulletsprites.push(@scene.playerbulletcache[0])
            @scene.playerbulletcache.delete_at(0)
        end
        @firecooldown = @scene.frameCounter + (Graphics.frame_rate / 10)
    end

    def damage()
        @scene.cacheAllBullets()
        @sprite.visible = false
        @requirerespawn = @scene.frameCounter + (3*Graphics.frame_rate)
    end

    def initialize(scene)
        super
        @projectilebitmap = Bitmap.new("Graphics/Animations/MysteriousBalm")
        @sprite.bitmap = Bitmap.new("Graphics/Undertale/PlayerHeart/Default/000")
        @sprite.tone = Tone.new(0, 0, -255)
        @sprite.angle += 90
        @sprite.z = 1000002
        # @sprite.zoom_x = 0.5
        # @sprite.zoom_y = 0.5
        @sprite.visible = true
        set_x(@scene.width / 2)
        set_y(@scene.height / 2)
        @firecooldown = 0
        @requirerespawn = 0
        @speed = 2
    end
end

class TouhouEnemy < TouhouEntity
    def update
        if @movementpatterns.length == 0 && @movementinfo.length > 0
            createMovementPattern(@movementinfo[0])
            @movementinfo.delete_at(0)
        end
        if @movementpatterns.length > 0
            tempindex = @movementpatterns.length
            @movementpatterns.reverse_each do |pattern|
                tempindex -= 1
                next if pattern.update
                @movementpatterns.delete_at(tempindex)
            end
        end
        if @bulletpatterns.length == 0 && @bulletinfo.length > 0
            createBulletPattern(@bulletinfo[0])
            @bulletinfo.delete_at(0)
        end
        if @bulletpatterns.length > 0
            tempindex = @bulletpatterns.length
            @bulletpatterns.reverse_each do |pattern|
                tempindex -= 1
                next if pattern.update
                @bulletpatterns.delete_at(tempindex)
            end
        end
    end

    def initialize(scene, info, bulletinfo, movementinfo)
        super(scene, info)
        @movementpatterns = []
        @movementinfo = movementinfo || []
        @bulletpatterns = []
        @bulletinfo = bulletinfo || []
        @sprite.bitmap = info["sprite"]
        @sprite.src_rect.height /= 4
        @sprite.src_rect.width /= 4
        @sprite.z = 1000000
        set_x(info["x"] || @scene.width / 2)
        set_y(info["y"] || 32)
    end

    def damage()
        set_x(-100)
        set_y(-100)
    end

    def createMovementPattern(info)
        extrainfo = {
            "enemy" => self,
        }
        @movementpatterns.push(TouhouMovementPattern.new(@scene, extrainfo.merge(info)))
    end

    def createBulletPattern(info)
        extrainfo = {
            "enemy" => self,
        }
        @bulletpatterns.push(TouhouBulletPattern.new(@scene, extrainfo.merge(info)))
    end
end

class TouhouMovementPattern
    def update
        return false if @distance <= 0
        @enemy.set_x(@enemy.x + @anglevector[0])
        @enemy.set_y(@enemy.y + @anglevector[1])
        @distance -= @speed
        return true
    end

    def initialize(scene, info)
        @scene = scene
        @enemy = info["enemy"]
        @nexty = info["y"] || @enemy.y
        @nextx = info["x"] || @enemy.x
        @speed = info["speed"] || 1
        @hp = info["hp"] || 
        @angle = Math.atan2(@nexty - @enemy.y, @nextx - @enemy.x)
        @anglevector = [Math.cos(@angle)*@speed, Math.sin(@angle)*@speed]
        @distance = Math.sqrt((@enemy.y - @nexty)**2 + (@enemy.x - @nextx)**2)

    end
end

class TouhouBulletPattern
    def update
        return true if @scene.player.requirerespawn >= @scene.frameCounter
        return true if @delay > @scene.frameCounter
        if !@currentangle
            @currentangle = @bulletinfo["angle"]
            @currentangle = Math.atan2(@scene.player.y - @enemy.y, @scene.player.x - @enemy.x) * 180 / 3.14 if !@currentangle
            @currentangle += @angleoffset if @angleoffset
        end

        case @patterntype
        when "single"
            extrainfo = {
                "x" => @enemy.x,
                "y" => @enemy.y,
                "angle" => @currentangle,
            }
            spawnBullet(extrainfo.merge(@bulletinfo))
        when "circle"
            @count = (360 / @spread)
            for i in 0...@count
                angle = @currentangle + (@spread * i)
                extrainfo = {
                    "x" => @enemy.x,
                    "y" => @enemy.y,
                    "angle" => angle,
                }
                spawnBullet(extrainfo.merge(@bulletinfo))
            end
        when "fan"
            for i in 0...@count
                angle = ((@count - 1) * @spread / 2) + @currentangle - (@spread * i)
                extrainfo = {
                    "x" => @enemy.x,
                    "y" => @enemy.y,
                    "angle" => angle,
                }
                spawnBullet(extrainfo.merge(@bulletinfo))
            end
        when "rain"

        end
        if @activeburst < @burst
            @activeburst += 1
            @delay = @scene.frameCounter + @burstdelay
            self.update if @burstdelay == 0
        else
            @currentangle = nil
            @activeburst = 1
            @delay = @scene.frameCounter + @cooldown
        end
        return true
    end

    def spawnBullet(info)
        if @activeburst > 1
            for key in info.keys()
                next unless @burstchanges[key]
                info[key] = info[key] + @burstchanges[key] * (@activeburst - 1)
            end
        end
        @scene.spawnBullet(info)
    end

    def initialize(scene, info)
        @scene = scene
        @patterntype = info["patterntype"]
        @cooldown = info["cooldown"] || Graphics.frame_rate
        @delay = @scene.frameCounter + (info["delay"] || 0)
        @bulletinfo = info["bulletinfo"] || {}
        @enemy = info["enemy"]
        @spread = info["spread"] || 6
        @count = info["count"] || 1
        @burst = info["burst"] || 1
        @activeburst = 1
        @burstdelay = info["burstdelay"] || 0
        @burstchanges = info["burstchanges"] || {}
        @currentangle = nil
        @angleoffset = info["angleoffset"]
    end
end

class TouhouBullet < TouhouEntity
    def update
        @sprite.z -= 1
        set_x(@x + @anglevector[0])
        set_y(@y + @anglevector[1])
        if @x - (width * 0.5) <= 0 || @x + (width * 0.5) >= @scene.width
            if @bounces > 0
                @anglevector[0] *= -1
                @bounces -= 1
            end
        end
        if @y - (height * 0.5) <= 0
            if @bounces > 0
                @anglevector[1] *= -1
                @bounces -= 1
            end
        end
        collision_check = [@scene.player]
        collision_check = @scene.opponents if @player
        for target in collision_check
            next unless @x - collision_width() < target.x + target.collision_width()
            next unless @x + collision_width() > target.x - target.collision_width()
            next unless @y - collision_height() < target.y + target.collision_height()
            next unless @y + collision_height() > target.y - target.collision_height()
            target.damage()
            return false
        end
        if @x + (width*0.5) < 0 || @x - (width*0.5) > @scene.width
            cacheBullet()
            return false
        end
        if @y + (height*0.5) < 0 || @y - (height*0.5) > @scene.height
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
        @sprite.tone = info["color"] if info["color"]
        @size = info["size"] || 1
        @sprite.zoom_x *= @size
        @sprite.zoom_y *= @size
        set_x(info["x"])
        set_y(info["y"])
        @sprite.z = 1000000 - (width * 1000) - (height * 1000)
        @player = info["playerbullet"]
        @sprite.z = 100 if @player
        @sprite.opacity = 100 if @player
        @speed = info["speed"] || 1
        if info["angle"]
            @angle = info["angle"] * 3.14 / 180
        else
            @angle = Math.atan2(@scene.player.y - @y, @scene.player.x - @x)
        end
        @sprite.angle = @angle
        @anglevector = [Math.cos(@angle)*@speed, Math.sin(@angle)*@speed]
    end

    def cacheBullet()
        @sprite.x = -100
        @sprite.y = -100
        @sprite.z = 0
        @sprite.opacity = 255
        @sprite.zoom_x = 1
        @sprite.zoom_y = 1
        @anglevector = [0, 0]
        set_x(-100)
        set_y(-100)
    end
end
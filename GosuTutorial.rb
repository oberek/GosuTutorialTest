require 'gosu'

module ZOrder
  Background, Coins, Player, UI = *0..3
end

$background_image = Gosu::Image.new("media/china.jpg", :tileable => true, :retro => true)
$window_x = 1920
$window_y = 1080

$fx = $window_x/$background_image.width
$fy = $window_y/$background_image.height

class GameWindow < Gosu::Window
  def initialize
    super $window_x, $window_y
    self.caption = 'Gosu Tutorial Game'

    @player = Player.new
    @player.warp(320, 240)

    @coin_anim = Gosu::Image::load_tiles("media/star.png", 25, 25)
    @coins = Array.new
    @china_all_the_time = Gosu::Song.new(self,"media/china.ogg")
    @font = Gosu::Font.new(20)
  end

  def update
    if Gosu::button_down? Gosu::KbLeft or Gosu::button_down? Gosu::GpLeft then
  @player.turn_left
    end
    if Gosu::button_down? Gosu::KbRight or Gosu::button_down? Gosu::GpRight then
      @player.turn_right
    end
    if Gosu::button_down? Gosu::KbUp or Gosu::button_down? Gosu::GpButton0 then
      @player.accelerate
    end
    @player.move
    @player.move
    @player.collect_coins(@coins)

    if rand(100) < 4 and @coins.size < 250 then
      @coins.push(Coin.new(@coin_anim))
    end
  end

  def draw
    @player.draw
    $background_image.draw_as_quad(0, 0, 0xffffffff, $window_x, 0, 0xffffffff, $window_x, $window_y, 0xffffffff, 0, $window_y, 0xffffffff, 0)
    @coins.each{ |coin| coin.draw }
    @font.draw("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
    @china_all_the_time.play()
  end

  def button_down(id)
      if id == Gosu::KbEscape
        close
      end
  end
end

class Coin
  attr_reader :x, :y

  def initialize(animation)
    @animation = animation
    @color = Gosu::Color.new(0xff_000000)
    @color.red = rand(256 - 40) + 40
    @color.green = rand(256 - 40) + 40
    @color.blue = rand(256 - 40) + 40
    @x = rand * $window_x
    @y = rand * $window_y
  end

  def draw
    img = @animation[Gosu::milliseconds / 100 % @animation.size];
    img.draw(@x - img.width / 2.0, @y - img.height / 2.0,
        ZOrder::Coins, 1, 1, @color, :add)
  end
end

class Player
  def initialize
    @image = Gosu::Image.new("media/trump.png")
    @beep = Gosu::Sample.new("media/china.wav")
    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @score = 0
  end

  def warp(x, y)
    @x, @y = x, y
  end

  def turn_left
    @angle -= 4.5
  end

  def turn_right
    @angle += 4.5
  end

  def accelerate
    @vel_x += Gosu::offset_x(@angle, 0.5)
    @vel_y += Gosu::offset_y(@angle, 0.5)
  end

  def move
    @x += @vel_x
    @y += @vel_y
    @x %= $window_x
    @y %= $window_y

    @vel_x *= 0.95
    @vel_y *= 0.95
  end

  def score
    @score
  end

  def collect_coins(coins)
    coins.reject! do |coin|
      if Gosu::distance(@x, @y, coin.x, coin.y) < 35 then
        @score += 10
        @beep.play
        true
      else
        false
      end
    end
  end

  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end
end
window = GameWindow.new
window.show

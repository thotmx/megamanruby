class Play < GameState
	trait :viewport
	def initialize
		super
    destroy_instances
		self.input = {:p => Pause, :e => :edit}
		self.viewport.lag = 0
		self.viewport.game_area = [0,0,5000,600]
		load_game_objects
		@parallax = Parallax.new(:x => 0, :y=>0, :rotation_center => :top_left)
    @parallax << { :image => "background.jpg", :repeat_x => true, :repeat_y => true}
		@megaman = Megaman.create(:x => 80, :y => 200)
		@lifebar = Lifebar.create(:x => 30, :y => 100)
	end

  #when a user decide to continue(from lose screen) chingu load for default instances of previous objects
  def destroy_instances
    #puts Megaman.all
    Megaman.destroy_all
    EnemyFace.destroy_all
  end

	def edit
    push_game_state(GameStates::Edit.new(:grid => [18,18], :classes => [EnemyFace, EnemyTiny, Floor, Lifeball]))
  end

  def draw
  	super
  	@lifebar.draw_position(self.viewport.x)
  	@parallax.draw
  end

	def update
		super

    #lose the game if your life is 0
    push_game_state(Lose) if @lifebar.health == 0

    #lose the game if megaman jump to hollow
    push_game_state(Lose) if @megaman.y > $window.height

    #move the background
		self.viewport.center_around(@megaman)
		@parallax.camera_x, @parallax.camera_y = self.viewport.x.to_i, self.viewport.y.to_i
		@parallax.update

    #balls are destroyed if they are outside the view
    Ball.all.each do |ball|
      ball.destroy unless self.viewport.inside?(ball)
    end

    #make the EnemyFace follow megaman
		EnemyFace.all.each do |face|
    	if face.x < @megaman.x
    		face.x += 1 
    		face.direction = :right
    	else
    		face.x -= 1
    		face.direction = :left
    	end
    	face.y < @megaman.y - @megaman.height/2 ? face.y += 1 : face.y -= 1
    end

    #make the EnemyFace follow megaman
    EnemyTiny.all.each do |tiny|
      unless (@megaman.x - tiny.x).abs > 300
        tiny.direction = :walk
        if tiny.x < @megaman.x
          tiny.x += 1 
          tiny.factor_x = -1
        else
          tiny.x -= 1
          tiny.factor_x = 1
        end
      end
      #tiny.y < @megaman.y - @megaman.height/2 ? face.y += 1 : face.y -= 1
    end

    #destroy EnemyFace and ball if collision  
    Ball.each_collision(EnemyFace) do |ball, face|
	    face.destroy
	    ball.destroy
    end

    #down life if megaman collision with EnemyFace
    @megaman.each_collision(EnemyFace) do |me, face|
    	me.take_damage
      @lifebar.downlife(face.power)
    end

    #up life if megaman take the lifeball
    @megaman.each_collision(Lifeball) do |me, lifeball|
      @lifebar.uplife
      lifeball.destroy
    end
	end
end
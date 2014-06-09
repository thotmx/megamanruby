class EnemyFace < Chingu::GameObject
	traits :bounding_circle, :collision_detection
	attr_accessor :direction
	
	def setup
		@animations= Chingu::Animation.new(:file => "enemyface.png", :size => [56,48], :delay => 400)
		@animations.frame_names = { :left => 0..3, :right => 4..7}
		@direction = :left
		@image = @animations[@direction].next
		@zorder = 999999
	end

	def update
		@image = @animations[@direction].next
	end
end
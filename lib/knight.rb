require_relative 'piece'
require_relative 'stepable'

class Knight < Piece  

    include Stepable

    def initialize(color, symbol, position, board, name)
        super 
    end 

    private 

    def move_dirs
        [knight_dirs]
    end 

end 
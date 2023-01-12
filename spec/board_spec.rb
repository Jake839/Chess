require 'rspec'
require 'game'
require 'board'

describe Board do
    subject(:g) { Game.new('Jake', 'Ann') }

    it "doesn't throw an error when a black pawn reaches the final row" do 
         g.board.move_piece!([1, 1], [7, 1])
         expect(g.board.checkmate?(:white)).to eq(false)
    end 

end 
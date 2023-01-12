require 'rspec'
require 'game'
require 'rook'

describe Rook do
    subject(:g) { Game.new('Jake', 'Ann') }

    context "when moving the rook during castling" do
        it "moves the white rook when castling king-side" do 
            g.board.move_piece!([7, 5], [5, 5])
            g.board.move_piece!([7, 6], [5, 6])
            g.board.move_piece([7, 4], [7, 6])

            expect(g.board[7, 5].class).to eq(Rook) 
            expect(g.board[7, 5].color).to eq(:white) 
        end 

        it "moves the white rook when castling queen-side" do 
            g.board.move_piece!([7, 1], [5, 1])
            g.board.move_piece!([7, 2], [5, 2])
            g.board.move_piece!([7, 3], [5, 3])
            g.board.move_piece([7, 4], [7, 2])
            
            expect(g.board[7, 3].class).to eq(Rook) 
            expect(g.board[7, 3].color).to eq(:white) 
        end 

         it "moves the black rook when castling king-side" do 
            g.board.move_piece!([0, 5], [2, 5])
            g.board.move_piece!([0, 6], [2, 6])
            g.board.move_piece([0, 4], [0, 6])

            expect(g.board[0, 5].class).to eq(Rook) 
            expect(g.board[0, 5].color).to eq(:black)
         end 

         it "moves the black rook when castling queen-side" do 
            g.board.move_piece!([0, 1], [2, 1])
            g.board.move_piece!([0, 2], [2, 2])
            g.board.move_piece!([0, 3], [2, 3])
            g.board.move_piece([0, 4], [0, 2])

            expect(g.board[0, 3].class).to eq(Rook) 
            expect(g.board[0, 3].color).to eq(:black) 
         end 
    end 
end 
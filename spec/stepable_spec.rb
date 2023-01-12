require 'rspec'
require 'game'
require 'stepable'

describe Stepable do
    subject(:g) { Game.new('Jake', 'Ann') }

    describe "#moves" do 
        context "when evaluating whether the king can castle on the king's side" do 
            it "returns the correct moves for a white king when it can castle king-side. considers 2 empty spaces b/t king & rook." do 
                g.board.move_piece!([7, 5], [5, 5])
                g.board.move_piece!([7, 6], [5, 6])
            
                expect(g.board[7, 4].moves).to eq([[7, 5], [7, 6]]) 
            end 

            it "doesn't let a white king castle king-side when knight's square is under attack" do 
                g.board.move_piece!([1, 3], [3, 3])
                g.board.move_piece!([1, 4], [3, 4])
                g.board.move_piece!([1, 5], [3, 5])
                g.board.move_piece!([0, 5], [3, 2])
                g.board.move_piece!([6, 5], [4, 5])
                g.board.move_piece!([6, 6], [4, 6])
                g.board.move_piece!([7, 6], [5, 7]) 
                g.board.move_piece!([7, 5], [6, 6]) 
    
                expect(g.board[7, 4].moves).to eq([[7, 5]]) 
            end 

            it "returns the correct moves for a black king when it can castle king-side. considers 2 empty spaces b/t king & rook." do 
                g.board.move_piece!([0, 5], [2, 5])
                g.board.move_piece!([0, 6], [2, 6])
                 
                expect(g.board[0, 4].moves).to eq([[0, 5], [0, 6]]) 
            end 

             it "doesn't let a black king castle king-side when knight's square is under attack" do 
                g.board.move_piece!([1, 5], [3, 5])
                g.board.move_piece!([1, 6], [3, 6])
                g.board.move_piece!([0, 5], [2, 5])
                g.board.move_piece!([0, 6], [2, 6])
                g.board.move_piece!([7, 5], [4, 2])
                
                expect(g.board[0, 4].moves).to eq([[0, 5]]) 
            end 
        end 

        context "when evaluating whether the king can castle on the queen's side" do 
            it "returns the correct moves for a white king when it can castle queen-side. considers 3 empty spaces b/t king & rook." do 
                g.board.move_piece!([7, 1], [5, 1])
                g.board.move_piece!([7, 2], [5, 2])
                g.board.move_piece!([7, 3], [5, 3])
            
                expect(g.board[7, 4].moves).to eq([[7, 3], [7, 2]]) 
            end 

            it "doesn't let a white king castle queen-side when bishop's square is under attack" do 
                g.board.move_piece!([0, 5], [4, 5])
                g.board.move_piece!([6, 3], [4, 3])
                g.board.move_piece!([7, 1], [5, 1])
                g.board.move_piece!([7, 2], [5, 2])
                g.board.move_piece!([7, 3], [5, 3])

                expect(g.board[7, 4].moves).to eq([[7, 3]]) 
            end 

            it "returns the correct moves for a black king when it can castle queen-side. considers 3 empty spaces b/t king & rook." do
                g.board.move_piece!([0, 1], [2, 1])
                g.board.move_piece!([0, 2], [2, 2])
                g.board.move_piece!([0, 3], [2, 3])

                expect(g.board[0, 4].moves).to eq([[0, 3], [0, 2]])
            end 

            it "doesn't let a black king castle queen-side when bishop's square is under attack" do 
                g.board.move_piece!([0, 1], [2, 1])
                g.board.move_piece!([0, 2], [2, 2])
                g.board.move_piece!([0, 3], [2, 0])
                g.board.move_piece!([1, 3], [2, 3])
                g.board.move_piece!([7, 5], [4, 6])

                expect(g.board[0, 4].moves).to eq([[0, 3]])
            end 
        end 
    end 

end 
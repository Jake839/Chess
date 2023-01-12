require 'rspec'
require 'game'
require 'board'
require 'king'
require 'queen'
require 'rook'
require 'bishop'

describe Game do
    subject(:g) { Game.new('Jake', 'Ann') }

    describe "#checkmate?" do 
        context "when evaluating checkmate" do 
            it "returns true when white is in checkmate" do 
                g.board.clear_board
                
                g.board[6, 7] = King.new(:white, g.board.icon(g.board.unicode('white king')), [6, 7], g.board, 'King')
                g.board[5, 5] = King.new(:black, g.board.icon(g.board.unicode('black king')), [5, 5], g.board, 'King')
                g.board[6, 6] = Queen.new(:black, g.board.icon(g.board.unicode('black queen')), [6, 6], g.board, 'Queen')
                
                expect(g.checkmate?).to eq(true) 
            end 

            it "returns true when black is in checkmate" do 
                g.board.clear_board
                g.current_player = g.player2 

                g.board[1, 2] = King.new(:white, g.board.icon(g.board.unicode('white king')), [1, 2], g.board, 'King')
                g.board[1, 1] = Rook.new(:white, g.board.icon(g.board.unicode('white rook')), [1, 1], g.board, 'Rook')
                g.board[2, 1] = Knight.new(:white, g.board.icon(g.board.unicode('white knight')), [2, 1], g.board, 'Knight')
                g.board[0, 0] = King.new(:black, g.board.icon(g.board.unicode('black king')), [0, 0], g.board, 'King')
                 
                expect(g.checkmate?).to eq(true) 
            end 

            it "returns false when white isn't in checkmate" do 
                g.board.clear_piece([0, 3])
                g.board.clear_piece([0, 4])
                g.board.clear_piece([0, 5])
                g.board.clear_piece([0, 7])
                g.board.clear_piece([1, 5])
                g.board.clear_piece([1, 7])
                g.board.clear_piece([6, 3])
                g.board.clear_piece([6, 4])
                g.board.clear_piece([6, 5])
                g.board.clear_piece([6, 6])
                g.board.clear_piece([7, 3])
                g.board.clear_piece([7, 5])
                g.board.clear_piece([7, 7])

                g.board[1, 4] = Queen.new(:black, g.board.icon(g.board.unicode('black queen')), [1, 4], g.board, 'Queen')
                g.board[1, 6] = Bishop.new(:black, g.board.icon(g.board.unicode('black bishop')), [1, 6], g.board, 'Bishop')
                g.board[3, 7] = Pawn.new(:black, g.board.icon(g.board.unicode('black pawn')), [3, 7], g.board, 'Pawn')
                g.board[5, 5] = Pawn.new(:black, g.board.icon(g.board.unicode('black pawn')), [5, 5], g.board, 'Pawn')
                g.board[7, 4] = Rook.new(:black, g.board.icon(g.board.unicode('black rook')), [7, 4], g.board, 'Rook')
                g.board[7, 6] = King.new(:white, g.board.icon(g.board.unicode('white king')), [7, 6], g.board, 'King')
                g.board[4, 5] = Pawn.new(:white, g.board.icon(g.board.unicode('white pawn')), [4, 5], g.board, 'Pawn')

                expect(g.checkmate?).to eq(false)
            end 
        end
    end 
    
    describe "#stalemate?" do 
        it "returns true when there is a stalemate" do 
            g.board.clear_board

            g.board[5, 6] = King.new(:white, g.board.icon(g.board.unicode('white king')), [5, 6], g.board, 'King')
            g.board[1, 6] = King.new(:black, g.board.icon(g.board.unicode('black king')), [1, 6], g.board, 'King')
            g.board[6, 3] = Queen.new(:black, g.board.icon(g.board.unicode('black queen')), [6, 3], g.board, 'Queen')
            g.board[4, 5] = Rook.new(:black, g.board.icon(g.board.unicode('black rook')), [4, 5], g.board, 'Rook')
            g.board[2, 4] = Bishop.new(:black, g.board.icon(g.board.unicode('black bishop')), [2, 4], g.board, 'Bishop')
            g.board[2, 7] = Bishop.new(:black, g.board.icon(g.board.unicode('black bishop')), [2, 7], g.board, 'Bishop')
            
            expect(g.stalemate?).to eq(true) 
        end 
    end 

    describe "#draw?" do 
        context "when evaluating whether there is a draw" do 
            it "returns true for a king vs king draw" do 
                g.board.clear_board

                g.board[5, 6] = King.new(:white, g.board.icon(g.board.unicode('white king')), [5, 6], g.board, 'King')
                g.board[1, 6] = King.new(:black, g.board.icon(g.board.unicode('black king')), [1, 6], g.board, 'King')
            
                expect(g.draw?).to eq(true) 
            end 

            it "returns true for a white king and bishop vs black king draw" do 
                g.board.clear_board

                g.board[1, 2] = King.new(:white, g.board.icon(g.board.unicode('white king')), [1, 2], g.board, 'King')
                g.board[1, 1] = Bishop.new(:white, g.board.icon(g.board.unicode('white bishop')), [1, 1], g.board, 'Bishop')
                g.board[0, 0] = King.new(:black, g.board.icon(g.board.unicode('black king')), [0, 0], g.board, 'King')
                
                expect(g.draw?).to eq(true) 
            end 

            it "returns true for a black king and bishop vs white king draw" do 
                g.board.clear_board

                g.board[1, 2] = King.new(:black, g.board.icon(g.board.unicode('black king')), [1, 2], g.board, 'King')
                g.board[1, 1] = Bishop.new(:black, g.board.icon(g.board.unicode('black bishop')), [1, 1], g.board, 'Bishop')
                g.board[0, 0] = King.new(:white, g.board.icon(g.board.unicode('white king')), [0, 0], g.board, 'King')
                
                expect(g.draw?).to eq(true) 
            end 

            it "returns true for a white king and knight vs black king draw" do 
                g.board.clear_board

                g.board[1, 2] = King.new(:white, g.board.icon(g.board.unicode('white king')), [1, 2], g.board, 'King')
                g.board[1, 1] = Knight.new(:white, g.board.icon(g.board.unicode('white knight')), [1, 1], g.board, 'Knight')
                g.board[0, 0] = King.new(:black, g.board.icon(g.board.unicode('black king')), [0, 0], g.board, 'King')

                expect(g.draw?).to eq(true) 
            end 

            it "returns true for a black king and knight vs white king draw" do  
                g.board.clear_board

                g.board[1, 2] = King.new(:black, g.board.icon(g.board.unicode('black king')), [1, 2], g.board, 'King')
                g.board[1, 1] = Knight.new(:black, g.board.icon(g.board.unicode('black knight')), [1, 1], g.board, 'Knight')
                g.board[0, 0] = King.new(:white, g.board.icon(g.board.unicode('white king')), [0, 0], g.board, 'King')
                
                expect(g.draw?).to eq(true) 
            end 

            it "returns true for a white king and non-color bishop vs black king and non-color bishop draw" do 
                g.board.clear_board

                g.board[3, 2] = King.new(:white, g.board.icon(g.board.unicode('white king')), [3, 2], g.board, 'King')
                g.board[3, 1] = Bishop.new(:white, g.board.icon(g.board.unicode('white bishop')), [3, 1], g.board, 'Bishop')
                g.board[0, 0] = King.new(:black, g.board.icon(g.board.unicode('black king')), [0, 0], g.board, 'King')
                g.board[1, 1] = Bishop.new(:black, g.board.icon(g.board.unicode('black bishop')), [1, 1], g.board, 'Bishop')
            
                expect(g.draw?).to eq(true) 
            end 

            it "returns true for a white king and color bishop vs black king and color bishop draw" do 
                g.board.clear_board

                g.board[3, 2] = King.new(:white, g.board.icon(g.board.unicode('white king')), [3, 2], g.board, 'King')
                g.board[4, 3] = Bishop.new(:white, g.board.icon(g.board.unicode('white bishop')), [4, 3], g.board, 'Bishop')
                g.board[0, 0] = King.new(:black, g.board.icon(g.board.unicode('black king')), [0, 0], g.board, 'King')
                g.board[1, 2] = Bishop.new(:black, g.board.icon(g.board.unicode('black bishop')), [1, 2], g.board, 'Bishop')
                
                expect(g.draw?).to eq(true) 
            end 

            it "returns false for a white king and color bishop vs black king and non-color bishop" do 
                g.board.clear_board

                g.board[3, 2] = King.new(:white, g.board.icon(g.board.unicode('white king')), [3, 2], g.board, 'King')
                g.board[4, 3] = Bishop.new(:white, g.board.icon(g.board.unicode('white bishop')), [4, 3], g.board, 'Bishop')
                g.board[0, 0] = King.new(:black, g.board.icon(g.board.unicode('black king')), [0, 0], g.board, 'King')
                g.board[1, 1] = Bishop.new(:black, g.board.icon(g.board.unicode('black bishop')), [1, 1], g.board, 'Bishop')
                
                expect(g.draw?).to eq(false) 
            end 
        end 
    end 

end 
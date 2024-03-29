require_relative 'board'
require_relative 'piece'

class Pawn < Piece  

    def initialize(color, symbol, position, board, name)
        super 
    end 

    def moves
        all_moves = forward_steps + side_attacks + [en_passant_attack]
        all_moves.delete([])
        all_moves
    end 

    def side_attacks
        side_attack_moves = []
        side_attack_squares = get_side_attack_squares 
        side_attack_squares.each { |square| side_attack_moves << square if board[square.first, square.last].color == opponent_color }         
        side_attack_moves
    end 

    def squares_beside 
        squares_beside_pawn = []
        row, col = position 
        
        squares_beside_pawn << [row, col + 1] if Board.valid_position?([row, col + 1])
        squares_beside_pawn << [row, col - 1] if Board.valid_position?([row, col - 1])

        squares_beside_pawn
    end 

    private

    def square_in_front(row, col)
        if color == :white 
            [row -=1, col]
        else 
            [row += 1, col]
        end 
    end 

    def at_start_row? 
        if color == :white 
            position.first == 6 
        else 
            position.first == 1 
        end 
    end

    def forward_steps 
        forward_moves = []
        row, col = get_row_col(position) 
        return [] if row == 7 
        square_in_front_of_pawn = square_in_front(row, col)

        if square_occupied?(square_in_front_of_pawn) 
            return []
        else 
            forward_moves << square_in_front_of_pawn
            square_two_squares_in_front_of_pawn = square_in_front(square_in_front_of_pawn.first, square_in_front_of_pawn.last) 
            if at_start_row? 
                forward_moves << square_two_squares_in_front_of_pawn unless square_occupied?(square_two_squares_in_front_of_pawn)
            end 
        end 
            
        forward_moves
    end 

    def get_side_attack_squares
        side_attack_squares = []

        if color == :white 
            #get square up and to the left 
            row, col = get_row_col(position)     
            row -= 1 
            col -= 1 
            side_attack_squares << [row, col] if Board.valid_position?([row, col])

            #get square up and to the right 
            row, col = get_row_col(position)  
            row -= 1 
            col += 1 
            side_attack_squares << [row, col] if Board.valid_position?([row, col])
        else 
            #get square down and to the left 
            row, col = get_row_col(position)  
            row += 1 
            col -= 1 
            side_attack_squares << [row, col] if Board.valid_position?([row, col])

            #get square down and to the right 
            row, col = get_row_col(position)  
            row += 1 
            col += 1 
            side_attack_squares << [row, col] if Board.valid_position?([row, col]) 
        end 

        side_attack_squares
    end 

    def en_passant_attack 
        board.en_passant_move(position)
    end 

end 
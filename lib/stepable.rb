require_relative 'board'

module Stepable 

    private 

    def on_board?(coordinate)
        (0..7).include?(coordinate)
    end 

    #method returns moves a king can make 
    def king_dirs 
        king_moves = []

        #get moves up 
        row, column = get_row_col(position) 
        row -= 1 
        if on_board?(row)
            (column - 1).upto(column + 1) do |col_idx| 
                if on_board?(col_idx) 
                    if square_has_same_color_piece?(row, col_idx) 
                        next 
                    else 
                        king_moves << [row, col_idx]  
                    end
                end 
            end 
        end 

        #get side moves 
        row, column = get_row_col(position) 
        (column - 1).upto(column + 1) do |col_idx| 
            if on_board?(col_idx)
                next if col_idx == column
                if square_has_same_color_piece?(row, col_idx) 
                    next 
                else 
                    king_moves << [row, col_idx]  
                end
            end 
        end 

        #get moves down 
        row, column = get_row_col(position) 
        row += 1 
        if on_board?(row)
            (column - 1).upto(column + 1) do |col_idx| 
                if on_board?(col_idx)
                    if square_has_same_color_piece?(row, col_idx) 
                        next 
                    else 
                        king_moves << [row, col_idx]  
                    end
                end 
            end 
        end 

        #get king-side castle move
        if color == :white
            left_square = board[7, 5]
            right_square = board[7, 6]
            rook = board[7, 7]
            left_square_position = [7, 5]
            right_square_position = [7, 6]
        else 
            left_square = board[0, 5]
            right_square = board[0, 6]
            rook = board[0, 7]
            left_square_position = [0, 5]
            right_square_position = [0, 6]
        end 
        king_moves << right_square_position if castle?([left_square, right_square], [left_square_position, right_square_position], rook)

        #get queen-side castle move
        if color == :white 
            left_square =  board[7, 1]
            middle_square = board[7, 2]
            right_square = board[7, 3]
            rook = board[7, 0]
            left_square_position = [7, 1]
            middle_square_position = [7, 2]
            right_square_position = [7, 3]
        else 
            left_square = board[0, 1]
            middle_square = board[0, 2] 
            right_square = board[0, 3]
            rook = board[0, 0]
            left_square_position = [0, 1]
            middle_square_position = [0, 2]
            right_square_position = [0, 3]     
        end 
        king_moves << middle_square_position if castle?([left_square, middle_square, right_square], [left_square_position, middle_square_position, right_square_position], rook)

        king_moves
    end 

    #method returns moves a knight can make 
    def knight_dirs 
        knight_moves = []

        #get move up and to the left 
        row, column = get_row_col(position) 
        row -= 2 
        column -= 1 
        if Board.valid_position?([row, column])
            knight_moves << [row, column] unless square_has_same_color_piece?(row, column)
        end 

        #get move up and to the right 
        row, column = get_row_col(position) 
        row -=2 
        column += 1 
        if Board.valid_position?([row, column])
            knight_moves << [row, column] unless square_has_same_color_piece?(row, column)
        end 

        #get move to the right and up 
        row, column = get_row_col(position) 
        row -= 1 
        column += 2 
        if Board.valid_position?([row, column])
            knight_moves << [row, column] unless square_has_same_color_piece?(row, column)
        end 

        #get move to the right and down 
        row, column = get_row_col(position) 
        row += 1 
        column += 2 
        if Board.valid_position?([row, column])
            knight_moves << [row, column] unless square_has_same_color_piece?(row, column)
        end

        #get move down and to the right 
        row, column = get_row_col(position) 
        row += 2 
        column += 1 
        if Board.valid_position?([row, column])
            knight_moves << [row, column] unless square_has_same_color_piece?(row, column)
        end 

        #get move down and to the left 
        row, column = get_row_col(position) 
        row += 2 
        column -= 1 
        if Board.valid_position?([row, column])
            knight_moves << [row, column] unless square_has_same_color_piece?(row, column)
        end 

        #get move to the left and down 
        row, column = get_row_col(position) 
        row += 1 
        column -= 2 
        if Board.valid_position?([row, column])
            knight_moves << [row, column] unless square_has_same_color_piece?(row, column)
        end 

        #get move to the left and up 
        row, column = get_row_col(position) 
        row -= 1 
        column -=2 
        if Board.valid_position?([row, column])
            knight_moves << [row, column] unless square_has_same_color_piece?(row, column)
        end 

        knight_moves
    end 

    def castle?(squares, positions, rook)
        return false if rook.class != Rook 

        if !already_moved && !rook.already_moved
            if squares.all? { |square| square.class == NullPiece } 
                return true if [self.position, *positions, rook.position].none? { |position| board.any_pieces_attacking?(position, opponent_color) }  
            end 
        end 
        false 
    end 

end 
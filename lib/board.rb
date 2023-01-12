require_relative 'piece'
require_relative 'rook'
require_relative 'knight'
require_relative 'bishop'
require_relative 'queen'
require_relative 'king'
require_relative 'pawn'
require_relative 'null_piece'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
class Board 

    attr_accessor :black_piece_ct, :grey_squares, :last_piece_moved, :message_allowed, :null_piece, :red_squares, :rows, :white_piece_ct

    def self.valid_position?(position)
        position.all? { |i| (0..7).include?(i) }
    end 

    def initialize 
        @rows = Array.new(8) { Array.new(8) }
        @null_piece = NullPiece.instance
        @last_piece_moved = nil 
        @message_allowed = false 
        reset_white_piece_ct_and_black_piece_ct
        set_null_pieces 
        set_pieces(:white)
        set_pieces(:black)
        set_grey_and_red_squares 
    end 

    def [](row, col)            
        rows[row][col]
    end 

    def []=(row, col, value)
        @rows[row][col] = value
    end 

    def move_piece(start_pos, end_pos) 
        unless end_position_has_same_color_piece?(start_pos, end_pos)
            if !move_results_in_check?(start_pos, end_pos)
                if legal_move?(start_pos, end_pos)
                    if !move_to_king_position?(start_pos, end_pos)
                        evaluate_for_castling(start_pos, end_pos)    
                        make_move(start_pos, end_pos) 
                        return true                                                                                                                                                                                                                                                                                                         
                    else 
                        cant_move_message("A piece can't move to the king's position.")
                    end 
                else 
                    cant_move_message("That is an illegal move.")
                end 
            else 
                cant_move_message("This move can't be made, because it would result in check.")
            end 
        else 
            cant_move_message("The end position has a piece of the same color as the piece at the start position. The piece can't be moved there.")
        end 
        false 
    end 

    def move_piece!(start_pos, end_pos) 
        make_move(start_pos, end_pos)
    end 

    def prompt_to_continue_move
        puts "Press return/enter to continue."
        gets 
        false 
    end 

    def cant_move_message(message)
        if message_allowed
            puts message 
            prompt_to_continue_move
        end 
    end 

    def piece_color(position) 
        self[position.first, position.last].color 
    end 
 
    def null_piece?(row_idx, col_idx)
        self[row_idx, col_idx].class == NullPiece
    end 

    def find_king(color)
        rows.each_with_index do |row, row_idx| 
            row.each_with_index { |piece, col_idx| return piece if king?(row_idx, col_idx, color) } 
        end 
    end 

    def any_pieces_attacking?(position, color) 
        return true if king_in_adjacent_square?(position, color)

        rows.each do |row|  
            row.each { |piece| return true if piece_attacking_position?(piece, position, color) } 
        end 

        false 
    end 

    def last_piece_moved_meets_en_passant_requirements?(pawn)  
        return true if last_piece_moved.class == Pawn && last_piece_moved.color == pawn.opponent_color && pawn.squares_beside.include?(last_piece_moved.position) && last_piece_moved.first_move? 
        false 
    end 

    def en_passant_square(pawn_color)
        if pawn_color == :white 
            [2, last_piece_moved.position.last]
        else 
            [5, last_piece_moved.position.last]
        end
    end 

    def en_passant_square_is_null_piece?(pawn)
        return true if self[*en_passant_square(pawn.color)].class == NullPiece
        false 
    end 

    def en_passant_move(position)
        return [] if last_piece_moved == nil || self[position.first, position.last].class != Pawn 

        pawn = self[position.first, position.last]
        
        if last_piece_moved_meets_en_passant_requirements?(pawn) && en_passant_square_is_null_piece?(pawn)
            en_passant_square(pawn.color)
        else    
            []
        end 
    end 

    def in_check?(color)
        king = find_king(color)
        king_position = king.position 
        any_pieces_attacking?(king_position, king.opponent_color)
    end 

    def checkmate?(color)
        king = find_king(color)
        return false if !king_under_attack?(king)

        rows.each do |row|
            row.each do |piece| 
                if piece.color == color 
                    return false if !piece.valid_moves.empty? 
                end 
            end  
        end 

        true 
    end 

    def stalemate?(color)
        king = find_king(color)
        king.valid_moves.empty? && !king_under_attack?(king)
    end 

    def draw? 
        piece_ct_calculation
        return true if king_against_king? || king_against_king_and_bishop? || king_against_king_and_knight? || king_and_bishop_against_king_and_bishop_where_both_bishops_are_on_same_color_square?
        false 
    end 

    def any_moves?(color)
        rows.each do |row|
            row.each do |piece| 
                if piece.color == color 
                    return true if !piece.valid_moves.empty? 
                end 
            end  
        end 
        false 
    end 

    def duplicate 
        board_copy = Board.new 
        board_copy.null_piece = null_piece
        board_copy.rows = copy_rows
    
        #update each piece to reference board copy
        board_copy.rows.each do |row| 
            row.each { |piece| piece.board = board_copy } 
        end 

        board_copy
    end

    def clear_board 
        (0..7).each do |row| 
            (0..7).each { |col| self[row, col] = null_piece } 
        end 
    end 

    def clear_piece(position)
        self[position.first, position.last] = null_piece
    end 

    #method translates chess piece unicode into a chess icon 
    def icon(code) 
        code.encode('utf-8')
    end 

    #returns unicode for a chess piece 
    def unicode(piece) 
        case piece 
        when 'white king'
            "\u2654"
        when 'white queen'
            "\u2655"
        when 'white rook'
            "\u2656"
        when 'white bishop'
            "\u2657"
        when 'white knight'
            "\u2658"
        when 'white pawn'
            "\u2659"
        when 'black king'
            "\u265A"
        when 'black queen'
            "\u265B"
        when 'black rook'
            "\u265C"
        when 'black bishop'
            "\u265D"
        when 'black knight'
            "\u265E"
        when 'black pawn'
            "\u265F"
        end 
    end 

    private 

    def set_null_pieces
        (2..5).each do |row| 
            (0..7).each { |col| self[row, col] = null_piece } 
        end 
    end 

    def set_pieces(color)
        #set rooks 
        if color == :white 
            self[7, 0] = Rook.new(:white, icon(unicode('white rook')), [7, 0], self, 'Rook')
            self[7, 7] = Rook.new(:white, icon(unicode('white rook')), [7, 7], self, 'Rook')
        else 
            self[0, 0] = Rook.new(:black, icon(unicode('black rook')), [0, 0], self, 'Rook')
            self[0, 7] = Rook.new(:black, icon(unicode('black rook')), [0, 7], self, 'Rook')
        end 

        #set knights 
        if color == :white 
            self[7, 1] = Knight.new(:white, icon(unicode('white knight')), [7, 1], self, 'Knight')
            self[7, 6] = Knight.new(:white, icon(unicode('white knight')), [7, 6], self, 'Knight')
        else 
            self[0, 1] = Knight.new(:black, icon(unicode('black knight')), [0, 1], self, 'Knight')
            self[0, 6] = Knight.new(:black, icon(unicode('black knight')), [0, 6], self, 'Knight')
        end 

        #set bishops 
        if color == :white 
            self[7, 2] = Bishop.new(:white, icon(unicode('white bishop')), [7, 2], self, 'Bishop')
            self[7, 5] = Bishop.new(:white, icon(unicode('white bishop')), [7, 5], self, 'Bishop')
        else 
            self[0, 2] = Bishop.new(:black, icon(unicode('black bishop')), [0, 2], self, 'Bishop')
            self[0, 5] = Bishop.new(:black, icon(unicode('black bishop')), [0, 5], self, 'Bishop')
        end 

        #set queen 
        if color == :white 
            self[7, 3] = Queen.new(:white, icon(unicode('white queen')), [7, 3], self, 'Queen')
        else 
            self[0, 3] = Queen.new(:black, icon(unicode('black queen')), [0, 3], self, 'Queen')
        end 

        #set king 
        if color == :white 
            self[7, 4] = King.new(:white, icon(unicode('white king')), [7, 4], self, 'King')
        else 
            self[0, 4] = King.new(:black, icon(unicode('black king')), [0, 4], self, 'King')
        end 

        #set pawns 
        if color == :white 
            (0..7).each { |col| self[6, col] = Pawn.new(:white, icon(unicode('white pawn')), [6, col], self, 'Pawn') }  
        else 
            (0..7).each { |col| self[1, col] = Pawn.new(:black, icon(unicode('black pawn')), [1, col], self, 'Pawn') }  
        end 
    end 

    def get_grey_squares
        grey_squares = []

        (0..7).each do |x| 
            if x.even? 
                y = 0 
                while y <= 6 
                    grey_squares << [x, y]
                    y += 2 
                end 
            else  
                y = 1 
                while y <= 7 
                    grey_squares << [x, y] 
                    y += 2 
                end 
            end 
        end 

        grey_squares
    end 

    def get_red_squares 
        red_squares = []

        (0..7).each do |x| 
            if x.even? 
                y = 1 
                while y <= 7 
                    red_squares << [x, y] 
                    y += 2 
                end   
            else   
                y = 0 
                while y <= 6 
                    red_squares << [x, y]
                    y += 2 
                end 
            end 
        end 

        red_squares
    end 

    def set_grey_and_red_squares 
        @grey_squares = get_grey_squares
        @red_squares = get_red_squares 
    end 

    def copy_rows
        copy_of_rows = []

        rows.each do |row| 
            individual_row = []
            row.each do |piece| 
                if piece.class != NullPiece 
                    individual_row << piece.dup 
                else 
                    individual_row << piece 
                end 
            end 
            copy_of_rows << individual_row  
        end 

        copy_of_rows
    end 

    def piece_at_position?(position)
        self[position.first, position.last] != null_piece 
    end 

    def piece_attacking_position?(piece, position, color)
        if ![King, NullPiece].include?(piece.class) && piece.color == color 
            if piece.class == Pawn 
                return true if piece.side_attacks.include?(position) 
            else 
                return true if piece.moves.include?(position) 
            end 
        end 
    end 

    def end_position_has_same_color_piece?(start_pos, end_pos)
        piece_color(start_pos) == piece_color(end_pos) 
    end 

    def move_piece_from_startposition_to_endposition(start_pos, end_pos)
        self[end_pos.first, end_pos.last] = self[start_pos.first, start_pos.last]
    end 

    def make_start_position_nullpiece(start_pos)
        self[start_pos.first, start_pos.last] = null_piece
    end 

    def update_piece_position(position)
        self[position.first, position.last].position = position
    end 

    def make_move(start_pos, end_pos)
        move_piece_from_startposition_to_endposition(start_pos, end_pos)
        make_start_position_nullpiece(start_pos)
        update_piece_position(end_pos)
    end 

    def move_results_in_check?(start_pos, end_pos)
        self[start_pos.first, start_pos.last].move_into_check?(end_pos) 
    end 

    def king?(row, col, color)
        self[row, col].color == color && self[row, col].class == King
    end 

    def move_to_king_position?(start_pos, end_pos)
        self[start_pos.first, start_pos.last].get_opponent_king_position == end_pos
    end 

    def king_at_original_square?(color, start_pos)
        if color == :white 
            return true if start_pos == [7, 4]
        else   
            return true if start_pos == [0, 4]
        end 
        false 
    end 

    def king_under_attack?(king)
        any_pieces_attacking?(king.position, king.opponent_color)
    end 

    def king_in_adjacent_square?(position, color)
        adjacent_squares = get_adjacent_squares(position)

        adjacent_squares.each do |adjacent_square| 
            piece = self[adjacent_square.first, adjacent_square.last]
            return true if piece.class == King && piece.color == color 
        end 
        
        false 
    end 

    def move_rook_if_castling(king_color, end_pos)
        if king_color == :white 
            move_piece!([7, 7], [7, 5]) if end_pos == [7, 6]
            move_piece!([7, 0], [7, 3]) if end_pos == [7, 2]
        else 
            move_piece!([0, 7], [0, 5]) if end_pos == [0, 6]
            move_piece!([0, 0], [0, 3]) if end_pos == [0, 2]
        end 
    end 

    def evaluate_for_castling(start_pos, end_pos)
        starting_piece = self[start_pos.first, start_pos.last]
        move_rook_if_castling(starting_piece.color, end_pos) if starting_piece.class == King && king_at_original_square?(starting_piece.color, start_pos)
    end 

    def legal_move?(start_pos, end_pos)
        if self[start_pos.first, start_pos.last].valid_moves.include?(end_pos)
            true 
        else 
            false 
        end 
    end 

    def reset_white_piece_ct_and_black_piece_ct
        @white_piece_ct = Hash.new { |hash, key| hash[key] = 0 }
        @black_piece_ct = Hash.new { |hash, key| hash[key] = 0 }
    end 

    def count_pieces(color, color_piece_ct)
        rows.each do |row|
            row.each do |piece| 
                if piece.class != NullPiece && piece.color == color 
                    color_piece_ct[piece.class.to_s] += 1 
                end 
            end  
        end 
    end 

    def piece_ct_calculation
        reset_white_piece_ct_and_black_piece_ct
        count_pieces(:white, white_piece_ct)
        count_pieces(:black, black_piece_ct)
    end 

    def get_adjacent_squares(position)
        adjacent_squares = []
        row, column = position.first, position.last 

        #squares above position
        new_row = row - 1 
        col = column - 1 
        col.upto(col + 2) do |new_col| 
            adjacent_squares << [new_row, new_col] if Board.valid_position?([new_row, new_col])
        end 

        #squares beside position 
        col.upto(col + 2) do |new_col| 
            adjacent_squares << [row, new_col] if Board.valid_position?([row, new_col]) && new_col != column
        end 

        #square below position 
        new_row = row + 1 
        col.upto(col + 2) do |new_col| 
            adjacent_squares << [new_row, new_col] if Board.valid_position?([new_row, new_col])
        end 

        adjacent_squares
    end 

    def king_against_king?
        white_piece_ct['Pawn'] == 0 && 
        white_piece_ct['Rook'] == 0 && 
        white_piece_ct['Knight'] == 0 && 
        white_piece_ct['Bishop'] == 0 && 
        white_piece_ct['Queen'] == 0 && 
        white_piece_ct['King'] == 1 &&

        black_piece_ct['Pawn'] == 0 && 
        black_piece_ct['Rook'] == 0 && 
        black_piece_ct['Knight'] == 0 && 
        black_piece_ct['Bishop'] == 0 && 
        black_piece_ct['Queen'] == 0 && 
        black_piece_ct['King'] == 1
    end 

    def king_against_king_and_bishop? 
        #checks for white king against black king and black bishop 
        white_piece_ct['Pawn'] == 0 && 
        white_piece_ct['Rook'] == 0 && 
        white_piece_ct['Knight'] == 0 && 
        white_piece_ct['Bishop'] == 0 && 
        white_piece_ct['Queen'] == 0 && 
        white_piece_ct['King'] == 1 &&

        black_piece_ct['Pawn'] == 0 && 
        black_piece_ct['Rook'] == 0 && 
        black_piece_ct['Knight'] == 0 && 
        black_piece_ct['Bishop'] == 1 && 
        black_piece_ct['Queen'] == 0 && 
        black_piece_ct['King'] == 1 ||

        #checks for white king and bishop againt black king 
        white_piece_ct['Pawn'] == 0 && 
        white_piece_ct['Rook'] == 0 && 
        white_piece_ct['Knight'] == 0 && 
        white_piece_ct['Bishop'] == 1 && 
        white_piece_ct['Queen'] == 0 && 
        white_piece_ct['King'] == 1 &&

        black_piece_ct['Pawn'] == 0 && 
        black_piece_ct['Rook'] == 0 && 
        black_piece_ct['Knight'] == 0 && 
        black_piece_ct['Bishop'] == 0 && 
        black_piece_ct['Queen'] == 0 && 
        black_piece_ct['King'] == 1
    end 

    def king_against_king_and_knight? 
        #checks for white king against black king and black knight 
        white_piece_ct['Pawn'] == 0 && 
        white_piece_ct['Rook'] == 0 && 
        white_piece_ct['Knight'] == 0 && 
        white_piece_ct['Bishop'] == 0 && 
        white_piece_ct['Queen'] == 0 && 
        white_piece_ct['King'] == 1 &&

        black_piece_ct['Pawn'] == 0 && 
        black_piece_ct['Rook'] == 0 && 
        black_piece_ct['Knight'] == 1 && 
        black_piece_ct['Bishop'] == 0 && 
        black_piece_ct['Queen'] == 0 && 
        black_piece_ct['King'] == 1 ||

        #checks for white king and knight againt black king 
        white_piece_ct['Pawn'] == 0 && 
        white_piece_ct['Rook'] == 0 && 
        white_piece_ct['Knight'] == 1 && 
        white_piece_ct['Bishop'] == 0 && 
        white_piece_ct['Queen'] == 0 && 
        white_piece_ct['King'] == 1 &&

        black_piece_ct['Pawn'] == 0 && 
        black_piece_ct['Rook'] == 0 && 
        black_piece_ct['Knight'] == 0 && 
        black_piece_ct['Bishop'] == 0 && 
        black_piece_ct['Queen'] == 0 && 
        black_piece_ct['King'] == 1
    end 

    def both_players_have_1_king_and_1_bishop? 
        white_piece_ct['Pawn'] == 0 && 
        white_piece_ct['Rook'] == 0 && 
        white_piece_ct['Knight'] == 0 && 
        white_piece_ct['Bishop'] == 1 && 
        white_piece_ct['Queen'] == 0 && 
        white_piece_ct['King'] == 1 &&

        black_piece_ct['Pawn'] == 0 && 
        black_piece_ct['Rook'] == 0 && 
        black_piece_ct['Knight'] == 0 && 
        black_piece_ct['Bishop'] == 1 && 
        black_piece_ct['Queen'] == 0 && 
        black_piece_ct['King'] == 1 
    end 

    def bishops_on_same_color_squares?(bishop_squares)
        bishop_squares.all? { |square| grey_squares.include?(square) } || bishop_squares.all? { |square| red_squares.include?(square) }
    end 

    def both_bishops_are_on_same_color_square? 
        bishop_squares = []

        rows.each do |row|
            row.each { |piece| bishop_squares << piece.position if piece.class == Bishop } 
        end 

        bishops_on_same_color_squares?(bishop_squares)  
    end 

    def king_and_bishop_against_king_and_bishop_where_both_bishops_are_on_same_color_square?
        both_players_have_1_king_and_1_bishop? && both_bishops_are_on_same_color_square?
    end 

end 





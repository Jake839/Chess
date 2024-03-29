require_relative 'board'
require_relative 'cursor'
require 'colorize'

class Display 

    attr_reader :board, :cursor, :debug, :letter_hash

    def initialize(board)
        @board = board 
        @cursor = Cursor.new([7,0], board) 
        @letter_hash = { 0 => 'a', 1 => 'b', 2 => 'c', 3 => 'd', 4 => 'e', 5 => 'f', 6 => 'g', 7 => 'h' }
        @debug = false 
    end 

    def move_cursor 
        selected_position = cursor.get_input 
        selected_position
    end 

    def render 
        chess_board = []

        #build 2D array of chess piece symbols 
        board.rows.each_with_index do |row, row_idx| 
            chess_row = []
            row.each_with_index do |col, col_idx| 
                if cursor.at_position?(row_idx, col_idx)
                    if board.null_piece?(row_idx, col_idx)
                        chess_row << colored_null_piece
                    else 
                        chess_row << colored_symbol(row_idx, col_idx)
                    end 
                else     
                    chess_row << board[row_idx, col_idx].symbol 
                end 
            end 
            chess_board << chess_row
        end 

        draw_board(chess_board) 
        show_info if debug 
    end 

    private 

    #method returns the appropriate symbol color 
    def colored_symbol(row_idx, col_idx)
        if cursor.selected 
            " #{board[row_idx, col_idx].symbol.colorize(:light_cyan)} "
        else 
            " #{board[row_idx, col_idx].symbol.colorize(:light_white)} "
        end 
    end 

    #method returns the appropriate null piece color for moving the cursor through the board
    def colored_null_piece
        if cursor.selected 
            " #{'-'.colorize(:light_cyan)} "
        else 
            " #{'-'.colorize(:light_white)} "
        end 
    end 

    def draw_board(args, boxlen=3)
        #Define box drawing characters
        side = '│'
        topbot = '─'
        tl = ' ┌'
        tr = '┐'
        bl = ' └'
        br = '┘'
        lc = ' ├'
        rc = '┤'
        tc = '┬'
        bc = '┴'
        crs = '┼'
        ##############################
        board_row_idx = 0 
        draw = [] 
        background_color = :light_black

        args.each_with_index do |row, rowindex|
            # TOP OF ROW Upper borders
            row.each_with_index do |col, colindex|
                if rowindex == 0
                    colindex == 0 ? start = tl : start = tc
                    draw << start + (topbot*boxlen)
                    colindex == row.length - 1 ? draw << tr : ""
                end
            end
            draw << "\n" if rowindex == 0

            # MIDDLE OF ROW: DATA
            row.each_with_index do |col, index|
                if index == 0 
                    draw << letter_hash[board_row_idx]
                end 
                draw << side + col.to_s.center(boxlen).colorize(:background => background_color)
                background_color = background_color == :light_black ? :red : :light_black
            end
            draw << side + "\n"
            background_color = background_color == :red ? :light_black : :red 

            # END OF ROW
            row.each_with_index do |col, colindex|
                if colindex == 0
                    rowindex == args.length - 1 ? draw << bl : draw << lc
                    draw << (topbot*boxlen)
                else
                    rowindex == args.length - 1 ? draw << bc : draw << crs
                    draw << (topbot*boxlen)
                end
                endchar = rowindex == args.length - 1 ? br : rc

                #Overhang elimination if the next row is shorter
                if args[rowindex+1]
                    if args[rowindex+1].length < args[rowindex].length
                    endchar = br
                    end
                end
                colindex == row.length - 1 ? draw << endchar : ""
            end

            draw << "\n"
            board_row_idx += 1 
        end

        puts "CHESS\n".rjust(21)
        (0..7).each { |i| print "   #{i}" } 
        puts "\n"
        draw.each { |char| print "#{char}" } 

        true
    end 

    def show_info
        cursor_pos = cursor.cursor_pos 
        selected_piece = board[cursor_pos.first, cursor_pos.last]
        unless selected_piece.class == NullPiece
            puts "#{selected_piece.color.capitalize.upcase} #{selected_piece.class} #{letter_hash[cursor_pos.first]}#{cursor_pos.last}" 
            puts "Valid Moves - #{selected_piece.valid_moves}" 
            puts "Check = #{board.in_check?(selected_piece.color)}"
            puts "Checkmate = #{board.checkmate?(selected_piece.color)}"
        end 
    end 

end 
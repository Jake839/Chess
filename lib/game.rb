require_relative 'display'
require_relative 'human_player'

class Game 

    attr_reader :board, :captured_piece, :display, :player1, :player2
    attr_accessor :castle_move, :current_player, :en_passant_move, :illegal_move, :last_piece_moved, :last_start_position, :last_end_position, :pawn_promotion_move, :starting_piece 

    def self.start 
        introduction
        name1 = get_player_name("Player 1")
        name2 = get_player_name("Player 2")
        Game.new(name1, name2)
    end 

    def self.introduction 
        puts "Welcome to Chess!"
        puts "For chess instructions, please visit https://en.wikipedia.org/wiki/Rules_of_chess"
        puts "Use space or enter to select pieces and squares."
        puts "Press return/enter to begin."
        gets 
    end 

    def self.get_player_name(player)
        clear 
        print "#{player}, enter your name: "
        name = gets.chomp 
    end 

    def self.clear 
        system("clear")
    end 
    
    def initialize(name1, name2) 
        @board = Board.new
        @display = Display.new(board)
        @starting_piece = nil
        @last_start_position = nil 
        @last_end_position = nil 
        reset_illegal_move
        reset_last_piece_moved
        reset_captured_piece
        reset_castle_move 
        reset_en_passant_move 
        reset_pawn_promotion_move
        @player1 = HumanPlayer.new(name1, :white)
        @player2 = HumanPlayer.new(name2, :black) 
        @current_player = player1 
        play 
    end 

    def play 
        while !game_over? 
            move_complete = false 
            while !move_complete 
                start_position = get_start_position 
                @starting_piece = board[start_position.first, start_position.last] 
                end_position = get_cursor_selection(select_position_prompt)
                next if end_position == start_position
                reset_castle_move 
                reset_en_passant_move 
                reset_pawn_promotion_move
                evaluate_for_captured_piece(start_position, end_position) 
                remove_opponent_pawn_if_en_passant_move(starting_piece, start_position, end_position)
                set_message_allowed_to_true 
                if board.move_piece(start_position, end_position) 
                    move_complete = true                          
                    @castle_move = true if castling?(start_position, end_position)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
                    @last_start_position = start_position
                    @last_end_position = end_position
                    board.last_piece_moved = starting_piece 
                    starting_piece.increase_move_ct 
                    @pawn_promotion_move = true if pawn_promotion?(starting_piece, end_position)  
                end 
                reset_illegal_move
                reset_message_allowed
            end 
            check_prompt
            swap_turn
        end 
        result
    end 

    def game_over?
        return true if draw? 
        return false if board.any_moves?(current_player.color)
        checkmate? || stalemate? 
    end 

    private 

    def select_piece_prompt 
        "#{current_player.name}, select a piece."
    end 

    def select_position_prompt
        "#{current_player.name}, select a square to move the #{starting_piece.color.capitalize} #{starting_piece.class}."
    end 

    def pawn_promotion_prompt
        puts "#{current_player.name}, choose a piece to replace your pawn. Enter Q, B, K, or R"
        puts "Q - Queen"
        puts "B - Bishop"
        puts "K - Knight"
        puts "R - Rook"
    end 

    def draw_prompt 
        puts "Checkmate can't be achieved with the remaining pieces. The game has ended in a draw. Game over."
    end 

    def check_prompt
        puts "#{current_player.color.capitalize} is in check." if board.in_check?(current_player.color)
    end 

    #method lets player move cursor through board until they hit enter or space 
    def get_cursor_selection(prompt)
        valid_cursor_selection = false
    
        while !valid_cursor_selection
            print_board
            check_prompt
            puts prompt
            cursor_selection = current_player.make_move(display) 
            valid_cursor_selection = true if cursor_selection.is_a?(Array)
        end 

        cursor_selection
    end 

    #method returns the starting position of a piece 
    def get_start_position  
        valid_start = false 
 
        while !valid_start
            start_position = get_cursor_selection(select_piece_prompt)

            if board.null_piece?(start_position.first, start_position.last)
                puts "That is not a piece."
                display.cursor.toggle_selected
                board.prompt_to_continue_move
            elsif board.piece_color(start_position) != current_player.color
                puts "That isn't your color. Please select a #{current_player.color.capitalize} piece."
                display.cursor.toggle_selected
                board.prompt_to_continue_move
            else 
                valid_start = true   
            end 
    
        end 

        start_position
    end

    def other_player(player)
        player == player1 ? player2 : player1 
    end 

    def other_color(color)
        color == 'White' ? 'Black' : 'White'
    end 

    def eval_opponent_at_end_position(board_copy, end_position)
        board_copy[end_position.first, end_position.last].class != NullPiece 
    end 

    def swap_turn 
        @current_player = other_player(current_player)
    end 

    def checkmate? 
        board.checkmate?(current_player.color)
    end 

    def stalemate?
        board.stalemate?(current_player.color)
    end 

    def draw? 
        board.draw? 
    end 

    def result 
        print_board
        if draw? 
            draw_prompt
        elsif checkmate?   
            winner = other_player(current_player)
            loser = current_player 
            puts "#{loser.color.capitalize} is in checkmate. #{winner.name} wins. #{loser.name} loses."
        elsif stalemate?
            puts "#{current_player.color.capitalize} has no moves but isn't in check. This is a stalemate. "
            draw_prompt
        end 
    end 

    def set_message_allowed_to_true
        board.message_allowed = true 
    end 

    def reset_illegal_move
        @illegal_move = false 
    end 

    def reset_captured_piece 
        @captured_piece = nil 
    end 

    def reset_last_piece_moved 
        board.last_piece_moved = nil 
    end 

    def reset_castle_move
        @castle_move = false  
    end 

    def reset_en_passant_move
        @en_passant_move = false 
    end 

    def reset_pawn_promotion_move
        @pawn_promotion_move = false 
    end 

    def reset_message_allowed
        board.message_allowed = false 
    end 

    def evaluate_for_captured_piece(start_position, end_position)
        board_copy = board.duplicate 
        board_copy.last_piece_moved = board.last_piece_moved
        opponent_at_end_position = eval_opponent_at_end_position(board_copy, end_position)
        potential_captured_piece = board_copy[end_position.first, end_position.last] if opponent_at_end_position
        @captured_piece = potential_captured_piece if board_copy.move_piece(start_position, end_position) 
    end 

    def remove_opponent_pawn_if_en_passant_move(starting_piece, start_position, end_position)
        if starting_piece.class == Pawn && board.en_passant_move(start_position) == end_position
            row, col = board.last_piece_moved.position 
            board[row, col] = board.null_piece
            @en_passant_move = true 
        end 
    end 

    def starting_piece_is_pawn?(piece)
        piece.class == Pawn 
    end 

    def pawn_at_last_row?(end_position, last_row)
        end_position[0] == last_row
    end 

    def exchange_pawn_for_promotion_piece(choice, end_position)
        case choice
        when 'q'
            if current_player.color == :white 
                board[end_position.first, end_position.last] = Queen.new(:white, board.icon(board.unicode('white queen')), end_position, board, 'Queen')
            else 
                board[end_position.first, end_position.last] = Queen.new(:black, board.icon(board.unicode('black queen')), end_position, board, 'Queen')
            end
        when 'b'
            if current_player.color == :white 
                board[end_position.first, end_position.last] = Bishop.new(:white, board.icon(board.unicode('white bishop')), end_position, board, 'Bishop')
            else 
                board[end_position.first, end_position.last] = Bishop.new(:black, board.icon(board.unicode('black bishop')), end_position, board, 'Bishop')
            end 
        when 'k'
            if current_player.color == :white 
                board[end_position.first, end_position.last] = Knight.new(:white, board.icon(board.unicode('white knight')), end_position, board, 'Knight')
            else 
                board[end_position.first, end_position.last] = Knight.new(:black, board.icon(board.unicode('black knight')), end_position, board, 'Knight')
            end 
        when 'r'
            if current_player.color == :white 
                board[end_position.first, end_position.last] = Rook.new(:white, board.icon(board.unicode('white rook')), end_position, board, 'Rook')
            else 
                board[end_position.first, end_position.last] = Rook.new(:black, board.icon(board.unicode('black rook')), end_position, board, 'Rook')
            end 
        end 
    end 

    def valid_promotion_choice?(choice)
        ['q', 'b', 'k', 'r'].include?(choice)
    end 

    def do_pawn_promotion(end_position)
        valid_choice = false 

        while !valid_choice 
            print_board
            pawn_promotion_prompt 
            user_choice = gets.chomp.downcase 
            if valid_promotion_choice?(user_choice)
                valid_choice = true 
                exchange_pawn_for_promotion_piece(user_choice, end_position)
            else    
                board.cant_move_message("Invalid selection. Please choose Q, B, K, or R.")
            end 
        end 

        true 
    end 

    def pawn_promotion?(starting_piece, end_position) 
        if starting_piece_is_pawn?(starting_piece)
            if starting_piece.color == :white
                do_pawn_promotion(end_position) if pawn_at_last_row?(end_position, 0)    
            else    
                do_pawn_promotion(end_position) if pawn_at_last_row?(end_position, 7)
            end 
        else 
            false
        end  
    end 

    def king_castling_move?(king_castle_moves, end_position)
        king_castle_moves.include?(end_position)
    end 

    def castling?(start_position, end_position) 
        if start_position == [7, 4]
            return true if king_castling_move?([[7, 6], [7, 2]], end_position)
        elsif start_position == [0, 4]
            return true if king_castling_move?([[0, 6], [0, 2]], end_position)
        end 
        false 
    end 

    def last_move_message(color)
        print "#{color} moved their #{board.last_piece_moved.name} from #{display.letter_hash[last_start_position.first]}#{last_start_position.last} to #{display.letter_hash[last_end_position.first]}#{last_end_position.last}.\n\n"
    end 

    def captured_message(color)
        print "#{color} took the #{other_color(color)} #{captured_piece.name} by moving their #{board.last_piece_moved.name} from #{display.letter_hash[last_start_position.first]}#{last_start_position.last} to #{display.letter_hash[last_end_position.first]}#{last_end_position.last}.\n\n"
    end 

    def en_passant_message(color)
        print "#{color} used en passant to take the #{other_color(color)} Pawn by moving their #{board.last_piece_moved.name} from #{display.letter_hash[last_start_position.first]}#{last_start_position.last} to #{display.letter_hash[last_end_position.first]}#{last_end_position.last}.\n\n"
    end 

    def pawn_promotion_message(color)
        print "Promotion: #{color} replaced their Pawn with a #{board[last_end_position.first, last_end_position.last].class}.\n\n"
    end 

    def castle_message(color)
        if [[7, 6], [0, 6]].include?(last_end_position)
            print "#{color} castled king-side.\n\n"
        else 
            print "#{color} castled queen-side.\n\n"
        end 
    end 

    def print_message(color)
        if captured_piece 
            captured_message(color)
        elsif castle_move 
            castle_message(color)
        elsif en_passant_move
            en_passant_message(color)
        else 
            last_move_message(color)
        end 

        pawn_promotion_message(color) if pawn_promotion_move
    end 

    def print_last_move 
        if board.last_piece_moved 
            print "Last move: "
            if board.last_piece_moved.color == :white 
                print_message('White')
            else 
                print_message('Black')
            end 
        end 
    end 

    def print_board 
        Game.clear
        display.render 
        print_last_move 
    end 

end 
 
Game.start 

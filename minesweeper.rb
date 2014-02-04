#!/usr/bin/env ruby

require 'colorize'
require 'yaml'

class Minesweeper
  def initialize
    # Initialize board
    @board = Array.new(9) { Array.new(9) }

    @board.each_with_index do |row, r_idx|
      row.each_with_index do |col, c_idx|
        @board[r_idx][c_idx] = Tile.new(false, false, false, r_idx, c_idx, @board)
      end
    end

    # Randomize bomb
    10.times do
      # Place random bomb
      r_idx = rand(0...9)
      c_idx = rand(0...9)
      until @board[r_idx][c_idx].is_bombed == false
        r_idx = rand(0...9)
        c_idx = rand(0...9)
      end
      @board[r_idx][c_idx].is_bombed = true
    end
  end

  def play
    alive = true
    while alive
      self.print_board
      puts "Enter a location to reveal:"
      input = gets.chomp
      if input == 'save'
        self.save_game
        puts 'Game saved'
      elsif input == 'load'
        self.load_game
      else
        mode = input[0]
        pos = input[1..-1].split(',').map {|num| num.to_i }
        if mode == 'f'
          tile = @board[pos[0]][pos[1]]
          tile.is_flagged = true
        else
          alive = self.reveal(pos)
          if self.win?
            puts "You've won!"
            break
          end
        end
      end
    end
    # Print out revealed board
  end

  def save_game
    File.open('saved_game.yaml', 'w') do |f|
      f.puts @board.to_yaml
    end
  end

  def load_game(filename='saved_game.yaml')
    f = File.open(filename)
    @board = YAML::load(f)

    @board.print_board
  end

  def neighbor(pos)
    row = pos[0]
    col = pos[1]
    tile = @board[row][col]
    tile.neighbors
  end

  def print_board
    puts '  0 1 2 3 4 5 6 7 8'.blue
    @board.each_with_index do |rows, r_idx|
      str = "#{r_idx} ".blue
      rows.each do |tile|
        if tile.is_flagged
          str += 'F '.red
        elsif tile.is_revealed
          if tile.is_bombed
            str += 'B '.red
          else
            if tile.bomb_count == 0
              str += "#{tile.bomb_count} ".black
            else
              str += "#{tile.bomb_count} "
            end
          end
        else
          str += '- '
        end
      end
      puts str
    end
  end

  def reveal(pos)
    row = pos[0]
    col = pos[1]

    tile = @board[row][col]
    tile.reveal
    if tile.is_bombed
      # YOU LOSE!
      p "BOOOOOOM! GAME OVER!"
      self.game_over
      return false
    end
    true
  end

  def game_over
    @board.each_with_index do |row, r_idx|
      row.each_with_index do |col, c_idx|
        tile = @board[r_idx][c_idx]
        tile.reveal unless tile.is_revealed
      end
    end
  end

  def win?
    hidden_count = 0
    @board.each do |row|
      row.each do |tile|
        hidden_count += 1 unless tile.is_revealed
      end
    end
    return true if hidden_count == 10 # Bomb count
    false
  end
end

class Tile
  attr_accessor :is_flagged, :r_idx, :c_idx, :is_bombed, :is_revealed, :board, :bomb_count

  def initialize(is_bombed, is_flagged, is_revealed, r_idx, c_idx, board)
    @is_bombed = is_bombed
    @is_flagged = is_flagged
    @is_revealed = is_revealed
    @r_idx = r_idx
    @c_idx = c_idx
    @board = board
  end

  # Mark tile as revealed
  def reveal
    @is_revealed = true
    @bomb_count = self.neighbor_bomb_count
    if @bomb_count == 0
      self.neighbors.each do |neighbor_tile|
        next if self == neighbor_tile
        neighbor_tile.reveal
      end
    end
  end

  # Return array of neighboring tiles
  def neighbors
    neighbors = []
    (-1..1).each do |delta_r|
        (-1..1).each do |delta_c|
            next if delta_r == 0 && delta_c == 0
            new_r_idx = self.r_idx+delta_r
            new_c_idx = self.c_idx+delta_c
            next if new_r_idx < 0 || new_r_idx > 8
            next if new_c_idx < 0 || new_r_idx > 8
            neighbor_tile = @board[new_r_idx][new_c_idx]
            next if neighbor_tile.nil? || neighbor_tile.is_revealed
            neighbors << neighbor_tile
        end
    end
    neighbors
  end

  def neighbor_bomb_count
    bombs = 0
    self.neighbors.each do |neighbor_tile|
      bombs += 1 if neighbor_tile.is_bombed
    end
    bombs
  end

  # def inspect
  #   return 'F' if self.is_bombed
  #   '_'
  # end

end

if $PROGRAM_NAME == __FILE__
  g = Minesweeper.new
  g.play
end



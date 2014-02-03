
#!/usr/bin/env ruby

class Minesweeper
  def initialize
    # Initialize board
    @board = Array.new(9) { Array.new(9) }

    # Randomize bomb
    10.times do
      # Place random bomb
      r_idx = rand(0...10)
      c_idx = rand(0...10)
      p @board[r_idx][c_idx]
      until @board[r_idx][c_idx].nil?
        r_idx = rand(0...10)
        c_idx = rand(0...10)
      end
      @board[r_idx][c_idx] = Tile.new(true, false, false, r_idx, c_idx, @board)
    end
  end

  def print_board
    @board.each do |rows|
      str = ''
      rows.each do |tile|
        if tile.is_bombed
          str += 'F'
        else
          str += '_'
        end
      end
      p str
    end
  end
end

class Tile
  attr_reader :is_bombed, :is_revealed, :board
  attr_accessor :is_flagged, :r_idx, :c_idx
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
  end

  # Return array of neighboring tiles
  def neighbors
    neighbors = []
    (-1..1).each do |delta_r|
        (-1..1).each do |delta_c|
            next if delta_r == 0 && delta_c == 0
            new_r_idx = self.r_idx+delta_r
            new_c_idx = self.c_idx+delta_c
            next if new_r_idx < 0 || new_r_idx > 9
            next if new_c_idx < 0 || new_r_idx > 9
            neighbor_tile = @board[new_r_idx][new_c_idx]
            neighbors << neighbor_tile
        end
    end
    neighbors
  end

  # def inspect
  #   return 'F' if self.is_bombed
  #   '_'
  # end

end

if $PROGRAM_NAME == __FILE__
  g = Minesweeper.new
  g.print_board
end



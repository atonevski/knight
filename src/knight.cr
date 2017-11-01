require "./knight/*"

module Knight
  # TODO Put your code here

  def self.print_syntax_and_exit
    puts <<-EOS
      usage knight [[size] col row]
      \twhere:
      \t\tcol/row start position: col: A|B|C..., row 1|2|3...
    EOS
    exit 1
  end

  class Board
    MAX = 10
    @@alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    @@diffs = [
      { x: -1, y: -2 },
      { x:  1, y: -2 },
      { x:  2, y: -1 },
      { x:  2, y:  1 },
      { x:  1, y:  2 },
      { x: -1, y:  2 },
      { x: -2, y: -1 },
      { x: -2, y:  1 },
    ]

    @one_halve : Int32
    @two_thirds : Int32
    @three_fourths : Int32

    def initialize(@size : Int32, x, y : Int32)
      raise "Size #{ @size } too big" if @size > MAX
      if x < 0 || y < 0 || x >= @size || y >= @size
        raise "Invalid start position (#{x}, #{y})"
      end

      @table = [] of Array(Int32)
      @size.times {|i| @table << Array.new(@size, 0)}
      @table[x][y] = 1

      @one_halve = @size*@size/2
      @two_thirds = @size*@size*2/3
      @three_fourths = @size*@size*3/4
    end

    def try(level, x, y) : Bool
      if level == @size * @size
        return true
      end

      # at this depth we check if some positions 
      # are unreachable
      if level == @two_thirds || level == @three_fourths ||
         level == @one_halve
        @size.times do |r|
          @size.times do |c|
            if @table[r][c] == 0
              return false unless is_reachable? r, c
            end
          end
        end
      end

      @@diffs.each do |d|
        xdx = x + d[:x]
        ydy = y + d[:y]
        if xdx >= 0 && xdx < @size &&
           ydy >= 0 && ydy < @size &&
           @table[xdx][ydy] == 0

          # set this position to next level
          # and try again
          @table[xdx][ydy] = level + 1
          return true if self.try(level+1, xdx, ydy)
          @table[xdx][ydy] = 0
        end
      end
      false
    end

    def is_reachable?(x, y)
      return true if @table[x][y] != 0

      @@diffs.each do |d|
        xdx = x + d[:x]
        ydy = y + d[:y]
        if xdx >= 0 && xdx < @size &&
           ydy >= 0 && ydy < @size &&
           @table[xdx][ydy] == 0

          return true
        end
      end
      false
    end

    # prints the arbitrary chess board
    def print 
      print "r\\c"
      @size.times {|c| printf "  %s", @@alpha[c]}
      print "\n"

      @size.times do |r|
        printf "%-3d", r + 1
        @size.times do |c|
          printf "%3d", @table[r][c]
        end
        print "\n"
      end
    end
  end

  # default board size and knight's start position
  x = 6
  y = 6
  n = 8
  case ARGV.size
    when 0
    when 2
      raise "Columns must be letters A|B|..." unless ('A'..'H').includes? ARGV[0][0].upcase
      y = ARGV[0][0].upcase.ord - 'A'.ord
      x = ARGV[1].to_i - 1
      raise "Invalid row #{x}" unless (0..n-1).includes? x
    when 3
      n = ARGV[0].to_i
      raise "Board size must be between 5..10" unless (5..10).includes? n
      raise "Columns must be letters A|B|..." unless ('A'..'H').includes? ARGV[1][0].upcase
      y = ARGV[1][0].upcase.ord - 'A'.ord
      x = ARGV[2].to_i - 1
      raise "Invalid row #{x}" unless (0..n-1).includes? x
    else
      print_syntax_and_exit
  end
  start = Time.new
  board = Board.new n, x, y
  board.try 1, x, y
  board.print
  puts "elapsed time: #{ Time.now - start }"
end

# nn: nn sec, nm: n min, nM: n0 min, nh: n hour, nH: n0 hours
#
#  r\c  A  B  C  D  E  F  G  H
#  1           
#  2    6     1m    2    22 
#  3         27          12
#  4                  12m21
#  5   
#  6    4
#  7       3m             1
#  8   

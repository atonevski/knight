require "./knight/*"

module Knight
  # TODO Put your code here

  def self.print_syntax_and_exit
    puts <<-EOS
      usage knight [[size] col row] [N|R|V|H|C]
      where: col/row start position, col: A|B|C..., row 1|2|3...
    EOS
    exit 1
  end

  class Board
    MAX = 10
    @@alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    #   x  
    #  .->   . o . o .    . 1 . 2 .
    # y|     o . . . o    8 . . . 3
    #  V     . . x . .    . . x . .
    #        o . . . o    7 . . . 4
    #        . o . o .    . 6 . 5 .
    #     
    @@diffs = [
      { x: -1, y: -2 }, # 1
      { x:  1, y: -2 }, # 2
      { x:  2, y: -1 }, # 3
      { x:  2, y:  1 }, # 4
      { x:  1, y:  2 }, # 5
      { x: -1, y:  2 }, # 6
      { x: -2, y:  1 }, # 7
      { x: -2, y: -1 }, # 8
    ]
    # rotate 1 click clock-wise: 1=>8, 2=>1, 3=>2,... 7=>6, 8=>7
    # vertical reflection: 1=>2, 2=>1, 3=>8, 4=>7, 5=>6, 6=>5, 7=>4, 8=>3
    # horizontal reflection: 1=>6, 2=>5, 3=>4, 4=>3, 5=>2, 6=>1, 7=>8, 8=>7
    # central reflection: 1=>5, 2=>6, 3=>7, 4=>8, 5=>1, 6=>2, 7=>3, 8=>4
    def diffs_rot()
      return [ 
        @@diffs[7], @@diffs[0], @@diffs[1], @@diffs[2],
        @@diffs[3], @@diffs[4], @@diffs[5], @@diffs[6],
      ]
    end
    def diffs_vert()
      return [ 
        @@diffs[1], @@diffs[0], @@diffs[7], @@diffs[6],
        @@diffs[5], @@diffs[4], @@diffs[3], @@diffs[2],
      ]
    end
    def diffs_hor()
      return [ 
        @@diffs[5], @@diffs[4], @@diffs[3], @@diffs[2],
        @@diffs[1], @@diffs[0], @@diffs[7], @@diffs[6],
      ]
    end
    def diffs_cent()
      return [ 
        @@diffs[4], @@diffs[5], @@diffs[6], @@diffs[7],
        @@diffs[0], @@diffs[1], @@diffs[2], @@diffs[3],
      ]
    end

    @one_halve : Int32
    @two_thirds : Int32
    @three_fourths : Int32
    @diffs : Array(NamedTuple(x: Int32, y: Int32))

    def initialize(@size : Int32, x, y : Int32, diffs = 'N')
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
      @diffs = case diffs
               when 'N' then @@diffs
               when 'R' then diffs_rot
               when 'V' then diffs_vert
               when 'H' then diffs_hor
               when 'C' then diffs_cent
               else [ ] of NamedTuple(x: Int32, y: Int32)
               end
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

      @diffs.each do |d|
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

      @diffs.each do |d|
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
  d = 'N'
  d = (ARGV.pop)[0].upcase if ARGV[-1] =~ /N|R|V|H|C/i
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
  board = Board.new n, x, y, d
  board.try 1, x, y
  board.print
  puts "elapsed time: #{ Time.now - start }"
end

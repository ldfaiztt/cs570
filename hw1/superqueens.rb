class SuperQueens
  attr_reader :start, :goal

  def initialize(size, goal)
    @size = size
    @columns = [nil]*size
    @start = State.new(size**2, size, size, SearchNode.new(@columns))
    @goal = State.new(goal, 0, 0) # if size > 4
  end

  def self.collisions(x1, y1, x2, y2)
    # puts "x1: #{x1} y1: #{y1} x2: #{x2} y2: #{y2}"
    c = 0
    c += 1 if (x1 == x2)
    c += 1 if (y1 == y2) 
    c += 1 if (x1-x2).abs == (y1-y2).abs
    c += 1 if [(x1-x2).abs, (y1-y2).abs] == [1, 2]
    c += 1 if [(x1-x2).abs, (y1-y2).abs] == [2, 1]
    c
    # (x1 == x2) or 
    # (y1 == y2) or 
    # (x1-x2).abs == (y1-y2).abs or
    # [(x1-x2).abs, (y1-y2).abs] == [1, 2] or
    # [(x1-x2).abs, (y1-y2).abs] == [2, 1]
  end

  class State
    attr_reader :attacks, :empty_cols, :empty_rows, :node

    # number of attacking pairs
    def initialize(attacks, empty_cols, empty_rows, node=nil)
      @attacks = attacks
      @empty_cols = empty_cols
      @empty_rows = empty_rows
      @node = node
    end

    def ==(obj)
      obj.class == self.class && 
      obj.attacks == attacks && 
      obj.empty_cols == empty_cols &&
      obj.empty_rows == empty_rows
    end
    alias_method :eql?, :==

    def hash
      node.hash
    end

    def neighbors
      node.neighbors
    end

    def to_s
      "#{@node}"
    end
  end

  class SearchNode
    def initialize(columns)
      @columns = columns
      @size = @columns.size
      @empty = @columns.find_index nil
    end

    def to_s
      str = ""
      (0..@size-1).each do |row|
        cols = @columns.each_index.select { |i| @columns[i]==row}
        r = [0]*@size
        cols.each { |i| r[i] = 1 }
        str += r.join(" ") + "\n"
      end
      str
    end

    def [](x)
      @columns[x]
    end

    def neighbors
      return [] unless @empty
      @neighbors ||= valid_moves.map do |x|
        st = deep_copy(@columns)
        st[@empty] = x
        sn = SearchNode.new(st)
        empty_cols = @size-(@empty+1)
        empty_rows = @size - @columns.uniq.size
        st = State.new(sn.heuristic, empty_cols, empty_rows, sn)
      end
    end

    def valid_moves
      # puts "checking valid moves"
      possible = []
      (0..@size-1).each do |row|
        next if on_occupied_space(row, @empty)
        possible << row
      end
      possible
    end

    def on_occupied_space(x, y)
      (0..@empty-1).each do |col|
        row = @columns[col]
        # puts collision(row, col, x, y)
        return true if row == x or col == y or (row-x).abs == (col-y).abs
        # return true if SuperQueens.collision(row, col, x, y)
      end
      return false
    end

    def deep_copy(obj)
      Marshal.load(Marshal.dump(obj))
    end

    def heuristic(state=@columns, goal=0)
      # puts "\n" * 3
      # puts "state: #{state}"
      state = state.node if state.respond_to? :node
      attacking_pairs = 0
      # (0..@size-2).each do |col1|
      (0..@size-2).each do |col1|
        row1 = state[col1]
        (col1+1..@size-1).each do |col2|
          row2 = state[col2]
          next if [row1, col1, row2, col2].include? nil
          attacking_pairs += SuperQueens.collisions(row1, col1, row2, col2)
          # attacking_pairs += 1 if SuperQueens.collisions(row1, col1, row2, col2)
        end
      end
      attacking_pairs
      # (attacking_pairs / 2.0).ceil + 1 # avoid double-counting
    end



    # todo: add method for printing board
  end
end


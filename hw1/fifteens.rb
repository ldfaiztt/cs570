class Fifteens
  attr_reader :start, :goal

  ROWS = 4
  COLS = 4
  GOAL = [[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12], [13, 14, 15, 0]]

  def initialize(board)
    raise "incorrect dimensions for board" unless board.size==ROWS and board.first.size==COLS
    @start = SearchNode.new(board)
    @goal  = SearchNode.new(GOAL)
  end

  def to_s
    "#{@start}"
  end

  def heuristic(node, goal=@goal)
    # manhattan distance for now
    dist = 0
    # todo: add data on knights' moves later 
    # this is important so that h is admissable
    goal.state.each_with_index do |row, row_ix|
      row.each_with_index do |cell, col_ix|
        current_row, current_col = Fifteens.find_position(cell, node.state)
        dist += (row_ix - current_row).abs + (col_ix-current_col).abs # min of this or knight moves
      end
    end
    dist
  end

  def self.find_position(item, board)
    row = board.find_index { |row| row.include? item }
    col = board[row].find_index(item)
    [row, col]
  end

  class SearchNode

    attr_reader :state
    
    def initialize(state)
      @state = state      
    end

    def to_s
      "#{@state}"
    end

    def ==(obj)
      obj.class == self.class && obj.state == state
    end
    alias_method :eql?, :==

    def hash
      @state.hash
    end

    def neighbors
      return @neighbors if @neighbors
      empty_row, empty_col = Fifteens.find_position(0, @state) 
      @neighbors = moves(empty_row, empty_col).compact.map { |st| SearchNode.new(st) }
    end

    def moves(empty_row, empty_col)
      [
        switch(empty_row, empty_col, empty_row, empty_col-1),
        switch(empty_row, empty_col, empty_row, empty_col+1),
        switch(empty_row, empty_col, empty_row+1, empty_col),
        switch(empty_row, empty_col, empty_row-1, empty_col),
        switch(empty_row, empty_col, empty_row-1, empty_col+2),
        switch(empty_row, empty_col, empty_row-1, empty_col-2),
        switch(empty_row, empty_col, empty_row+1, empty_col+2),
        switch(empty_row, empty_col, empty_row+1, empty_col-2),
        switch(empty_row, empty_col, empty_row-2, empty_col+1),
        switch(empty_row, empty_col, empty_row-2, empty_col-1),
        switch(empty_row, empty_col, empty_row+2, empty_col+1),
        switch(empty_row, empty_col, empty_row+2, empty_col-1),
      ]
    end

    def switch(row1, col1, row2, col2)
      return nil if out_of_bounds(row1, col1) or out_of_bounds(row2, col2)
      st = deep_copy(@state)
      st[row1][col1], st[row2][col2] = st[row2][col2], st[row1][col1]
      return st
    end

    def out_of_bounds(row, col)
      (row < 0 or row > Fifteens::ROWS-1) or (col < 0 or col > Fifteens::COLS-1)
    end

    def deep_copy(obj)
      Marshal.load(Marshal.dump(obj))
    end
  end



end

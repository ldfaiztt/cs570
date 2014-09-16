class Astar

  def initialize(start, goal, heuristic)
    raise "Start node does not have neighbors" unless start.respond_to?(:neighbors)
    @start = start
    @goal  = goal
    self.class.send(:define_method, :heuristic_cost, heuristic)
    # raise "Start node does not have a distance_to function" unless start.respond_to?(:distance_to)
  end

  def search(start=@start, goal=@goal)
    visited = []
    to_visit = [start]

    path_so_far = {}
    cost = {start => 0}
    estimated_cost = { start => cost[start]+ heuristic_cost(start, goal) }

    until to_visit.empty? do
      current = to_visit.sort_by { |node| estimated_cost[node] }.first
      # puts "current: #{current.class}"
      # puts "goal:    #{goal.class}"
      # puts current == goal
      return path_from(path_so_far, goal) if current == goal

      to_visit.delete(current)
      visited << current
      current.neighbors.each do |neighbor|
        next if visited.include? neighbor

        tentative_cost = cost[current] + 1 # 1=current.distance_to(neighbor)

        if (!to_visit.include?(neighbor)) || (tentative_cost < cost[neighbor])
          path_so_far[neighbor.to_s] = current
          cost[neighbor] = tentative_cost
          estimated_cost[neighbor] = tentative_cost + heuristic_cost(neighbor, goal)
          to_visit << neighbor unless to_visit.include?(neighbor) # could maybe use an elsif to avoid this
        end 
      end # neighbors
    end # until

    return :failure
  end # search

  def path_from(path_so_far, current)
    # puts path_so_far.keys
    if path_so_far.keys.include? current.to_s
      path = path_from(path_so_far, path_so_far[current.to_s])
      path << current
      return path
    else
      return [current]
    end
  end # path_from
end # Astar
# app/services/maze_solver.rb
class MazeSolver
  attr_reader :grid, :start_pos, :end_pos, :path, :solution_length

  def initialize(grid, start_pos, end_pos)
    @grid = grid
    @start_pos = start_pos
    @end_pos = end_pos
    @path = []
    @visited = Array.new(grid.size) { Array.new(grid[0].size, false) }
    @solution_length = nil
  end

  def solve
    # Lösche den bisherigen Pfad
    @path = []
    @visited = Array.new(@grid.size) { Array.new(@grid[0].size, false) }
    
    # Starte die rekursive Suche
    result = find_path(@start_pos[0], @start_pos[1])
    
    # Setze Pfadlänge, wenn ein Pfad gefunden wurde
    @solution_length = @path.size - 1 if result
    
    result
  end

  private

  def find_path(y, x)
    # Prüfe, ob Position gültig ist
    return false if !valid_position?(y, x)
    
    # Prüfe, ob wir das Ziel erreicht haben
    if [y, x] == @end_pos
      @path << [y, x]
      return true
    end
    
    # Markiere diese Position als besucht
    @visited[y][x] = true
    @path << [y, x]
    
    # Versuche alle vier Richtungen (oben, rechts, unten, links)
    directions = [[-1, 0], [0, 1], [1, 0], [0, -1]]
    directions.each do |dy, dx|
      new_y, new_x = y + dy, x + dx
      
      if valid_position?(new_y, new_x) && !@visited[new_y][new_x] && @grid[new_y][new_x] != '#'
        if find_path(new_y, new_x)
          return true
        end
      end
    end
    
    # Backtracking: Entferne die aktuelle Position vom Pfad
    @path.pop
    false
  end

  def valid_position?(y, x)
    y >= 0 && y < @grid.size && x >= 0 && x < @grid[0].size
  end
end

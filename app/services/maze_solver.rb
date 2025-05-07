# app/services/maze_solver.rb
class MazeSolver
  attr_reader :path, :solution_length

  def initialize(maze_data, start_pos = nil, end_pos = nil)
    @maze = parse_maze(maze_data)
    @rows = @maze.size
    @cols = @maze.first.size
    @visited = Array.new(@rows) { Array.new(@cols, false) }
    @path = []
    @found = false
    @start_pos = start_pos
    @end_pos = end_pos
  end

  def solve
    y, x = @start_pos || find_cell('S')
    return { success: false, message: "Startpunkt nicht gefunden" } unless y

    @end_pos ||= find_cell('E')
    return { success: false, message: "Endpunkt nicht gefunden" } unless @end_pos

    backtrack(y, x)

    if @found
      {
        success: true,
        path: @path,
        solution_length: @path.length
      }
    else
      {
        success: false,
        message: "Keine Lösung gefunden"
      }
    end
  end

  private

  def parse_maze(data)
    # Debugging: Überprüfe den Inhalt von data
    puts "Daten vor der Verarbeitung: #{data.inspect}"
    data.map { |line| line.to_s.chars }
  end
  
  def find_cell(symbol)
    @maze.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        return [y, x] if cell == symbol
      end
    end
    nil
  end

  def backtrack(y, x)
    return false if out_of_bounds?(y, x)
    return false if @visited[y][x]
    return false if @maze[y][x] == '#'

    @visited[y][x] = true
    @path << [y, x]

    if [y, x] == @end_pos
      @found = true
      return true
    end

    directions = [[0,1], [1,0], [0,-1], [-1,0]]

    directions.each do |dy, dx|
      new_y, new_x = y + dy, x + dx
      return true if backtrack(new_y, new_x)
    end

    @path.pop
    false
  end

  def out_of_bounds?(y, x)
    y < 0 || y >= @rows || x < 0 || x >= @cols
  end
end

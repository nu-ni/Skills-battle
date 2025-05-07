class MazesController < ApplicationController
  def index
    @mazes = Maze.all
  end

  def new
    @maze = Maze.new
  end

  def create
    uploaded_file = params[:maze_file]
    return redirect_to new_maze_path, alert: "Bitte wähle eine Datei." unless uploaded_file
  
    raw_text = uploaded_file.read
  
    parser = MazeParser.new(raw_text)
    unless parser.parse_and_validate
      return redirect_to new_maze_path, alert: "Maze ungültig: #{parser.error_message}"
    end
  
    grid = parser.grid
    grid_size = grid.size
    creator_name = session[:creator_name]
  
    @maze = Maze.new(
      name: params[:maze][:name],
      creator: creator_name,
      data: raw_text,
      size: grid_size,
      difficulty: params[:maze][:difficulty],
      remark: params[:maze][:remark],
      solution: "PLACEHOLDER",
      solution_length: 1
    )
  
    if @maze.save
      redirect_to mazes_path, notice: "Maze erfolgreich gespeichert."
    else
      render :new
    end
  end  
end

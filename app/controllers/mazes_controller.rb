class MazesController < ApplicationController
  def index
    @mazes = Maze.all
  end

  def new
    @maze = Maze.new
  end

  def create
    uploaded_file = params[:maze_file]
    if uploaded_file.nil?
      flash[:error] = "Bitte eine Maze-Datei auswählen."
      return redirect_to new_maze_path
    end
  
    begin
      maze_data = uploaded_file.read.strip
      grid_size = maze_data.lines.size
  
      @maze = Maze.new(
        name: params[:maze][:name],
        creator: session[:creator_name],
        data: maze_data,
        size: grid_size,
        difficulty: params[:maze][:difficulty],
        remark: params[:maze][:remark],
        solution: "PLACEHOLDER",          # kommt später
        solution_length: 1                # kommt später
      )
  
      if @maze.save
        redirect_to mazes_path, notice: "Maze erfolgreich gespeichert."
      else
        render :new
      end
  
    rescue => e
      flash[:error] = "Fehler beim Verarbeiten der Datei: #{e.message}"
      redirect_to new_maze_path
    end
  end  
end

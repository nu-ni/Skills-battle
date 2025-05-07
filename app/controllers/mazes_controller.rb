# app/controllers/mazes_controller.rb
class MazesController < ApplicationController
  before_action :set_maze, only: [:edit, :update, :destroy]

  def index
    @mazes = Maze.all
    
    # Apply filters
    @mazes = @mazes.where(size: params[:size]) if params[:size].present?
    @mazes = @mazes.where(difficulty: params[:difficulty]) if params[:difficulty].present?
    @mazes = @mazes.where("DATE(created_at) = ?", params[:date]) if params[:date].present?
    @mazes = @mazes.where("name ILIKE ?", "%#{params[:name]}%") if params[:name].present?
    
    @mazes = @mazes.order(created_at: :desc)
  end

  def edit
  end

  def update
    if @maze.update(maze_params)
      redirect_to mazes_path, notice: 'Maze wurde erfolgreich aktualisiert.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @maze.destroy
    redirect_to mazes_path, notice: 'Maze wurde erfolgreich gelöscht.'
  end
  
  def new
    @maze = Maze.new
  end

  def create
    uploaded_file = params[:maze_file]
    unless uploaded_file
      flash[:alert] = "Bitte wähle eine Datei."
      return redirect_to new_maze_path
    end

    raw_text = uploaded_file.read
    Rails.logger.debug "RAW TEXT:\n#{raw_text}"

    parser = MazeParser.new(raw_text)
    unless parser.parse_and_validate
      Rails.logger.debug "Parser-Fehler: #{parser.error_message}"
      flash[:alert] = "Maze ungültig: #{parser.error_message}"
      return redirect_to new_maze_path
    end

    Rails.logger.debug "Parser OK. Grid size: #{parser.height}x#{parser.width}"
    Rails.logger.debug "Start: #{parser.start_pos}, End: #{parser.end_pos}"

    # Labyrinth lösen
    solver = MazeSolver.new(parser.grid, parser.start_pos, parser.end_pos)
    if solver.solve
      path_string = solver.path.map { |y, x| "(#{y},#{x})" }.join(" -> ")
      solution_length = solver.solution_length
      Rails.logger.debug "Lösung gefunden mit Länge: #{solution_length}"
    else
      flash[:alert] = "Maze ist unlösbar – kein Pfad von S nach E gefunden."
      return redirect_to new_maze_path
    end

    # Grid als String für die Datenbank aufbereiten
    maze_data = parser.grid.map { |row| row.join }.join("\n")

    @maze = Maze.new(
      name: params[:maze][:name],
      creator: session[:creator_name] || "Unbekannt",
      data: maze_data,
      size: [parser.width, parser.height].max, # Größere Dimension als Größe
      difficulty: params[:maze][:difficulty],
      remark: params[:maze][:remark],
      solution: path_string,
      solution_length: solution_length
    )

    if @maze.save
      redirect_to mazes_path, notice: "Maze erfolgreich gespeichert."
    else
      flash[:alert] = "Fehler beim Speichern: #{@maze.errors.full_messages.join(', ')}"
      render :new
    end
  end

  private

  def set_maze
    @maze = Maze.find(params[:id])
  end

  def maze_params
    params.require(:maze).permit(:name, :size, :difficulty)
  end
end

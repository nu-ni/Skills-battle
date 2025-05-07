# app/controllers/mazes_controller.rb
class MazesController < ApplicationController
  def index
    @mazes = Maze.all
  end

  def new
    @maze = Maze.new
  end
  
  def show
    @maze = Maze.find(params[:id])
  end
  
  def play
    @maze = Maze.find(params[:id])
    @grid = @maze.data.split("\n").map(&:chars)
    puts @grid.inspect # Debug
  end

  def solve
    begin
      maze = Maze.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      return render json: { success: false, message: "Maze nicht gefunden" }, status: :not_found
    end

    data = maze.data
  
    # Überprüfen, ob der Body der Anfrage korrekt empfangen wird
    body = request.body.read
    Rails.logger.debug "Empfangener Body: #{body.inspect}"  # Überprüfe den gesamten Body
  
    if body.blank?
      return render json: { success: false, message: "Leere Anfrage empfangen" }, status: :unprocessable_entity
    end
    
    # Versuche, die JSON-Daten zu parsen
    begin
      json_params = JSON.parse(body)
      Rails.logger.debug "Parsed JSON: #{json_params.inspect}"  # Debugging-Ausgabe
    rescue JSON::ParserError => e
      return render json: { success: false, message: "Fehler beim Parsen der Anfrage: #{e.message}" }, status: :unprocessable_entity
    end
  
    start = json_params["start"]
    end_pos = json_params["end"]
    Rails.logger.debug "Start: #{start}, End: #{end_pos}"
    
    unless start && end_pos
      return render json: { success: false, message: "Start- und Endpunkt müssen angegeben werden" }, status: :unprocessable_entity
    end    
  
    solver = MazeSolver.new(data, start, end_pos)
    result = solver.solve
  
    if result[:success]
      render json: {
        success: true,
        path: result[:path],
        solution_length: result[:solution_length]
      }
    else
      render json: {
        success: false,
        message: result[:message]
      }
    end
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
    result = solver.solve
    
    if result[:success]
      path_string = result[:path].map { |y, x| "(#{y},#{x})" }.join(" -> ")
      solution_length = result[:solution_length]
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
  
  def destroy
    @maze = Maze.find(params[:id])
    
    if @maze.creator == session[:creator_name]
      @maze.destroy
      redirect_to mazes_path, notice: "Maze wurde erfolgreich gelöscht."
    else
      redirect_to mazes_path, alert: "Du darfst nur deine eigenen Mazes löschen."
    end
  end
  
  private
  
  def find_position(grid, char)
    grid.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        return [y, x] if cell == char
      end
    end
    nil
  end
end

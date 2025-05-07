class MazeParser
  ALLOWED_CHARS = ['#', '.', 'S', 'E', ' '].freeze
  MAX_SIZE = 100

  attr_reader :grid, :start_pos, :end_pos, :error_message, :width, :height

  def initialize(text)
    @raw = text.strip
    @grid = []
    @start_pos = nil
    @end_pos = nil
    @error_message = nil
    @width = 0
    @height = 0
  end

  def parse_and_validate
    lines = @raw.lines.map { |l| l.rstrip }
    return error("Labyrinth ist leer.") if lines.empty?
    
    # Bestimme max Breite und Höhe
    @height = lines.size
    @width = lines.map(&:length).max
    
    # Prüfe Größe
    return error("Maximale Größe von 100x100 überschritten.") if @width > MAX_SIZE || @height > MAX_SIZE
    
    # Prüfe auf gültige Zeichen und normalisiere
    @grid = []
    lines.each_with_index do |line, y|
      row = []
      line.chars.each_with_index do |char, x|
        return error("Ungültiges Zeichen '#{char}' an Position #{x},#{y}.") unless ALLOWED_CHARS.include?(char)
        
        # Erkenne Start/Ziel, wenn vorhanden
        @start_pos = [y, x] if char == 'S'
        @end_pos = [y, x] if char == 'E'
        
        row << char
      end
      
      # Fülle Zeile auf die max. Breite auf
      row += Array.new(@width - row.length, ' ')
      @grid << row
    end
    
    # Falls kein Start/Ziel definiert ist, setzen wir Standard-Start/Ziel
    # (oben links/unten rechts)
    if @start_pos.nil?
      # Erster möglicher Startpunkt
      @start_pos = [0, 0]
      @grid[0][0] = 'S'
    end
    
    if @end_pos.nil?
      # Letzter möglicher Endpunkt
      @end_pos = [@height-1, @width-1]
      @grid[@height-1][@width-1] = 'E'
    end
    
    true
  end
  
  private

  def error(msg)
    @error_message = msg
    false
  end
end

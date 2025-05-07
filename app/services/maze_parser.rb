# app/services/maze_parser.rb
class MazeParser
  ALLOWED_CHARS = ['#', '.', 'S', 'E'].freeze
  MAX_SIZE = 30

  attr_reader :grid, :start_pos, :end_pos, :error_message

  def initialize(text)
    @raw = text.strip
    @grid = []
    @start_pos = nil
    @end_pos = nil
    @error_message = nil
  end

  def parse_and_validate
    lines = @raw.lines.map(&:chomp)
    return error("Labyrinth ist leer.") if lines.empty?

    height = lines.size
    width = lines.map(&:length).uniq
    return error("Inkonstante Zeilenlängen im Labyrinth.") if width.size != 1

    size = width.first
    return error("Maximale Größe von 30x30 überschritten.") if size > MAX_SIZE || height > MAX_SIZE

    @grid = lines.map.with_index do |line, y|
      line.chars.map.with_index do |char, x|
        return error("Ungültiges Zeichen '#{char}' an Position #{x},#{y}.") unless ALLOWED_CHARS.include?(char)

        @start_pos = [y, x] if char == 'S'
        @end_pos = [y, x] if char == 'E'
        char
      end
    end

    return error("Startpunkt 'S' fehlt.") unless @start_pos
    return error("Zielpunkt 'E' fehlt.") unless @end_pos

    true
  end

  private

  def error(msg)
    @error_message = msg
    false
  end
end

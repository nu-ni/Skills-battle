# app/helpers/mazes_helper.rb
module MazesHelper
  def cell_class(cell)
    case cell
    when '#'
      'wall'
    when 'S'
      'start'
    when 'E'
      'end'
    else
      'path'
    end
  end
end

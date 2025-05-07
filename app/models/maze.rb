class Maze < ApplicationRecord
  validates :name, presence: true
  validates :creator, presence: true
  validates :data, presence: true
  validates :size, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 100 }
  validates :difficulty, presence: true, inclusion: { in: 1..5 }
  validates :solution_length, presence: true, numericality: { only_integer: true, greater_than: 0 }
end

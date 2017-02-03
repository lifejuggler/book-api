class Book < ApplicationRecord
  def self.read
    IO.foreach("test.csv", "r") do |line|
      Book.create(isbn: line)
    end
  end
end

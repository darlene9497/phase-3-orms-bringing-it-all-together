class Dog
# Readable and writable Dog attributes.
  attr_accessor :id, :name, :breed

# Initialize method which accepts keyword argument value with key-value pairs as an argument(id, name, breed).
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

# Create a table called dogs with the appropriate columns.
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

# Drop the dogs table from the database.
  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

# Calling save will insert a new record into the database and return the instance of a dog.
  def save
    sql = <<-SQL
      INSERT INTO dogs(name, breed)
      values (?, ?)
    SQL
  # insert the dog
    DB[:conn].execute(sql, self.name, self.breed)
  # get the dog ID from the database and save it to the Ruby instance
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  # return the Ruby instance
    self
  end

# This create method will wrap the code we used above to create a new Dog instance and save it.
  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end

# Converts what the database gives us into a new Ruby object. self.new == Dog.new.
  def self.new_from_db(row)
    self.new(id:row[0], name:row[1], breed:row[2])
  end

# Persists data using the database as it should return an array of Dog instances for every record in the dogs table.
  def self.all
    sql = <<-SQL
     SELECT * FROM dogs
    SQL
    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
  end
end

# Include a name in our SQL statement by using a ? where we want the name parameter to be passed in.
  def self.find_by_name(name)
    sql = <<-SQL
     SELECT * FROM dogs
     WHERE name = ?
     LIMIT 1
    SQL
# Include name as the second argument to the execute method.
# The return value of the #map method is an array, and we're simply grabbing the #first element from the returned array using .first.
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
  end.first
end

  def self.find(id)
    sql = <<-SQL
     SELECT * FROM dogs
     WHERE id = ?
     LIMIT 1
    SQL
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
  end.first
end

end
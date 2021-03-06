class Dog
  attr_accessor :name, :breed, :id
  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name,breed) VALUES (?,?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").first.first
      self.id = id
      self
    end
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
  end

  def self.find_by_id(id)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE id = (?)", id).flatten
    new_from_db(row)
  end

  def self.find_or_create_by(name:, breed:)
    dog_from_db = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    unless dog_from_db.empty?
      row = dog_from_db.first
      dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    else
      dog = self.create(name: name, breed: breed)
    end
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = (?)", name).flatten
    new_from_db(row)
  end
end #end of class

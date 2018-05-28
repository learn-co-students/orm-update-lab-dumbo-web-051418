require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade, :id

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql_create_table = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      );
    SQL
    DB[:conn].execute(sql_create_table)
  end

  def self.drop_table
    sql_drop_table = <<-SQL
      DROP TABLE IF EXISTS students;
    SQL
    DB[:conn].execute(sql_drop_table)
  end

  def save
    if self.id
      self.update
    else
      sql_save = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?);
      SQL
      DB[:conn].execute(sql_save, @name, @grade)

      sql_id = <<-SQL
        SELECT last_insert_rowid() FROM students;
      SQL
      @id = DB[:conn].execute(sql_id)[0][0]
    end
  end

  def self.create(name, grade)
    s = Student.new(name, grade)
    s.save
    s
  end

  def self.new_from_db(row)
    s = Student.create(row[1], row[2])
    s.id = row[0]
    s
  end

  def self.find_by_name(name)
    sql_name = <<-SQL
      SELECT * FROM students WHERE name = ?;
    SQL
    row = DB[:conn].execute(sql_name, name).first
    self.new_from_db(row)
  end

  def update
    sql_update = <<-SQL
      UPDATE students SET name = ?, grade = ? WHERE id = ?;
    SQL
    DB[:conn].execute(sql_update, @name, @grade, @id)
  end


end

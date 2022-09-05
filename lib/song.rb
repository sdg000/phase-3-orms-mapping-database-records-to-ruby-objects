class Song

  attr_accessor :name, :album, :id

  def initialize(name:, album:, id: nil)
    @id = id
    @name = name
    @album = album
  end

  # class method to create a table (with matching column_names to Class attributes) and establish connection to Database
  def self.create_table
    sql = %Q(
      CREATE TABLE IF NOT EXISTS songs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        album TEXT
      )
      )
      DB[:conn].execute(sql)
  end

  # instance method that saves attributes of Song Instances to Database.

  def save 
    sql = %Q(
    INSERT INTO songs (name, album)
    VALUES (?, ?)
    )
    DB[:conn].execute(sql, self.name, self.album)

    # get the song ID from the database and save it to the Ruby instance
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]

    # return the Ruby instance (object)
    self
  end

  def self.create(name:, album:)
    song = Song.new(name: name, album: album)
    song.save
  end

    #TRANSFORMING DATABASE RECORDS INTO RUBY OBJECTS:

  # Takes a row (array of data) from database
  # Creates a temporal storage by creating an instance of Song Class
  # with data from row.

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], album: row[2])
  end



  # returning all rows from database

  #this method DB[:conn] to execute sql script to return all data or rows from database.
  #maps through the returning data , and passes each row returned to 
  #self.new_from_db method, which creates an OBJECT OF SONG CLASS with the data in the row.
  # =>therefore, SUCCESFULLY MAPPING OR TRANSFORMING DATABASE RECORDS TO RUBY OBJECT
  
  def self.all
    sql = %Q(
      select * from songs
    )
    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end
  end



  # this method takes parameter of name, 
  # uses DB[:conn] to execute an sql script (use bounded parameter to insert value of parameter)
  # map through returned results of sql (arrays), 
  # pass each array to #self.new_from_db method to create
  # an OBJECT OF SONG CLASS, and return first Object created.
  # =>therefore, SUCCESFULLY MAPPING OR TRANSFORMING DATABASE RECORDS TO RUBY OBJECT

  def self.find_by_name(name)
    sql = %Q(
      select * from songs where name = ?
    )
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

end

# STEPS:How a new Song Instance (object) is created and persisted into songs database.

# 1. Class Method #self.create invokes, init_method (def_initialize) to create new Song Instance or Object.
# 2. Class Method #self.create invokes class method #save which does the ff;
# -uses heredoc script to insert attributes of new Song Instance (Object) into songs database
# -returns database id of Song Object and save it as the Object's id, to enable consistent Object id and table_id
# -returns object (self)

# ** DRY NOTICE (EFFICIENCY)
# it's better to utilze the #self.create Method to instantiate and persist new objects to database
# RATHER THAN
# uSE #initialise_method // #save_method to instantiate and persist new objects to db

# self.create abstracts both #initialize and #save methods into one method

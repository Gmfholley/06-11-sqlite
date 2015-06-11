require 'sqlite3'
require 'active_support'
require 'active_support/core_ext/string/filters.rb'

#Module DatabaseConnector
  # connects to the database
  #
  # database_name    - String representing the database name (and relative path)
  #
  # returns Object representing the database connection 
  def connection_to_database(database_name)
    connection = SQLite3::Database.new(database_name)
    connection.results_as_hash = true
    connection
  end


  # creates a table with field names and types as provided
  #
  # db_connection           - Object of the database's connection
  # table                   - String of the table name
  # field_names_and_types   - Array of Arrays of field names and their types - first Array assumed to be Primary key
  #
  # returns nothing
  def create_table(db_connection: db_connection, table: table, field_names_and_types: field_names_and_types)
    stringify_field_names_and_types = create_string_of_field_names_and_types(field_names_and_types)
    binding.pry
    db_connection.execute("CREATE TABLE #{table} (#{stringify_field_names_and_types});")
  end
  
  # returns a stringified version of this table, optimizied for SQL statements
  #
  # Example: 
  #           [["id", "integer"], ["name", "text"], ["grade", "integer"]]
  #        => "id INTEGER PRIMARY KEY, name TEXT, grade INTEGER" 
  #
  # field_names_and_types     - Array of Arrays of field names and their types - first Array assumed to be Primary key
  #
  # returns String
  def create_string_of_field_names_and_types(field_names_and_types)
    field_names_and_types.each do |array|
      array[1] = array[1].upcase + ","
    end
    field_names_and_types.last[1] = field_names_and_types.last[1].remove(/,/)
    if !field_names_and_types.first[1].include?("PRIMARY KEY")
      field_names_and_types.first[1] = field_names_and_types.first[1].remove(/,/) + " PRIMARY KEY,"
    end
    field_names_and_types.join(" ")
  end
  
  # creates a new record in the table
  #
  # db_connection           - Object of the database's connection
  # table                   -  String of the table name
  # column_names_and_values - multi-dimensional Array of column names (row 0) and values(rows 1-...)
  #
  # returns nothing
  def create_new_records(db_connection: db_connection, table: table, column_names_and_values: column_names_and_values)
  ####
    col_names = column_names_and_values[0].join(", ")
    (1..column_names_and_values.length - 1).each do |x|
      col_values = add_quotes_to_string(column_names_and_values[x].join("', '"))
      db_connection.execute("INSERT INTO #{table} (#{col_names}) VALUES (#{col_values});")
    end
  end

  # deletes the record matching the primary key
  #
  # db_connection           - Object of the database's connection
  # table                   - String of the table name
  # primary_key_field       - String of the primary field key
  # primary_key             - String of the value of the record you want to delete
  #
  # returns nothings
  def delete_record(db_connection: db_connection, table: table, primary_key_field: primary_key_field, primary_key: primary_key)
    if primary_key.is_a? String
      primary_key = add_quotes_to_string(primary_key)
    end
    db_connection.execute("DELETE FROM #{table} WHERE #{primary_key_field} = #{primary_key};")
  end
  # ####
  # CONNECTION.execute("DELETE FROM test_vals WHERE id = 4;")
  # puts "\nDeleting the fourth record."
  # puts CONNECTION.execute("SELECT * FROM test_vals;")


  # updates the field of one column if records meet criteria
  #
  # db_connection           - Object of the database's connection
  # table                   - String of the table name
  # look_up_field           - String of the criteria field
  # look_up_value           - String of the value in the criteria field
  # change_field            - String of the change field
  # change_value            - String of the value to change in the change field
  #
  # returns nothing
  def update_records(db_connection: db_connection, table: table, look_up_field: look_up_field, look_up_value: look_up_value, change_field: change_field, change_value: change_value)
    db_connection.execute("UPDATE #{table} SET #{change_field} = '#{change_value}' WHERE #{look_up_field} = #{look_up_value};")
  end

  
  # returns the result of an array from all these field names
  #
  # db_connection           - Object of the database's connection
  # table                   - String of the table name
  # field_names             - Array containing a string of the column names you want to look at
  #
  # returns Array of a Hash of the resulting records
  def select_records(db_connection: db_connection, table: table, field_names: field_names="*")
    if field_names.length > 1
      field_names = field_names.join(", ")
    end
    db_connection.execute("SELECT #{field_names} FROM #{table};")
  end
  
  #def return_records_as_string(array)
    
  #end  
  
  # adds '' quotes around a string for SQL statement
  #
  # Example: 
  #
  #        text
  #     => 'text'
  # 
  # string  - String
  #
  # returns a String
  def add_quotes_to_string(string)
    string = "'#{string}'"
  end

#end


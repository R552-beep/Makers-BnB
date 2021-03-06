require 'bcrypt'

class User
  attr_reader :id, :username, :email, :password

  def initialize(id:, username:, email:, password:)
    @id = id
    @username = username
    @email = email
    @password = password
  end

  def self.create(username:, email:, password:)
    encrypted_password = BCrypt::Password.create(password)
    result = DatabaseConnection.query("INSERT INTO users(username, email, password) 
                                      VALUES($1, $2, $3) RETURNING id, username, email, password;", 
                                      [username, email, encrypted_password])
    User.new(id: result[0]['id'], username: result[0]['username'], 
             email: result[0]['email'], password: result[0]['password'])
  end

  def self.authenticate(username:, password:)
    result = DatabaseConnection.query("SELECT * FROM users WHERE username = $1;", [username])
    return unless result.any?
    return unless BCrypt::Password.new(result[0]['password']) == password
    User.new(id: result[0]['id'], username: result[0]['username'], 
             email: result[0]['email'], password: result[0]['password'])
  end

  def self.find(id = nil)
    result = DatabaseConnection.query("SELECT * FROM users WHERE id = $1;", [id])
    return unless result.any?
    User.new(id: result[0]['id'], username: result[0]['username'], 
             email: result[0]['email'], password: result[0]['password'])
  end
end

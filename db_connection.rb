# frozen_string_literal: true

require 'pg'

module DBConnection
  def self.conn
    @conn ||= PG.connect(
      dbname: ENV['POSTGRESQL_DATABASE'],
      user: ENV['POSTGRESQL_USER'],
      password: ENV['POSTGRESQL_PASSWORD'],
      host: 'localhost'
    )
  end
end

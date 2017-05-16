class Kele
  require 'httparty'
  require 'json'
  include HTTParty


  def get_me
    response = self.class.get("/users/me", { "headers": { "authorization" => @auth_token }})
    JSON.parse(response.body)
  end

  def initialize(email, password)
      @base_uri = "https://www.bloc.io/api/v1"
      self.class.base_uri @base_uri
      body = {
        "email": email,
        "password": password
      }
      response = self.class.post("/sessions", { "body": body})

      raise response.message or 'Login Failed' if response.code == 401
      raise response.message or 'Page not found' if response.code == 404
      raise response.message or 'Connection failed' unless response.code == 200

      @auth_token = response.parsed_response["auth_token"]
    end
end

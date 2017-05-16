class Kele
  require 'httparty'
  require 'json'
  require './lib/roadmap'
  include Roadmap
  include HTTParty


  def get_me
    headers = {"authorization" => @auth_token}
    response = self.class.get("/users/me", { "headers": headers})
    me = JSON.parse(response.body)
    @mentor_id = me["current_enrollment"]["mentor_id"]
    @roadmap_id = me["current_enrollment"]["roadmap_id"]
    me
  end

  def get_mentor_availability
    raise 'mentor ID required' if @mentor_id.nil?
    headers = {"authorization" => @auth_token}
    response = self.class.get("/mentors/#{@mentor_id}/student_availability", { "headers": headers})
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
      get_me
    end
end

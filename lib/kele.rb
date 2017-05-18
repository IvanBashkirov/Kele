class Kele
  require './lib/roadmap'
  require 'httparty'
  include Roadmap
  include HTTParty


  def get_mentor_availability
    mentor_id = get_me["current_enrollment"]["mentor_id"]
    raise 'mentor ID required' if mentor_id.nil?
    headers = {"authorization" => @auth_token}
    response = self.class.get("/mentors/#{mentor_id}/student_availability", { "headers": headers})
    JSON.parse(response.body)
  end

  def get_messages(page=1)
    headers = {"authorization" => @auth_token}
    body = {"page" => page}
    response = self.class.get("/message_threads", {"headers": headers, "body": body})
    page = JSON.parse(response.body)
    messages = page["items"]
  end

  def create_submission(assignment_branch: "master", assignment_commit_link:, checkpoint_id:, comment:, enrollment_id: get_me["current_enrollment"]["id"]  )
    headers = {"authorization" => @auth_token}
    body = {
      "assignment_branch": assignment_branch,
      "assignment_commit_link": assignment_commit_link,
      "checkpoint_id": checkpoint_id,
      "comment": comment,
      "enrollment_id": enrollment_id
    }
    response = self.class.post("/checkpoint_submissions", {"headers": headers, "body": body})
    JSON.parse(response.body)
  end


  def create_message(sender: get_me["email"], recipient_id:, token: nil, stripped_text:, subject: "No Subject")
    headers = {"authorization" => @auth_token}
    body = {
      "sender" => sender,
      "recipient_id" => recipient_id,
      "subject" => subject,
      "stripped-text" => stripped_text
    }
    body["token"] = token unless token.nil?
    puts body
    response = self.class.post("/messages", {headers: headers, body: body})
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

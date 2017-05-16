module Roadmap
  def get_roadmap
    raise 'Roadmap ID required' if @roadmap_id.nil?
    headers = {"authorization" => @auth_token}
    body = {"id": @roadmap_id}
    response = self.class.get("/roadmaps/#{@roadmap_id}", {headers: headers, body: body})
    JSON.parse(response.body)
  end

  def get_checkpoint(section_number,checkpoint_number)
    raise "Please provide a checkpoint number" if checkpoint_number.nil?
    raise "Please provide a section number" if section_number.nil?
    raise "Invalid section or checkpoint index" if (section_number < 1 or checkpoint_number < 1)

    roadmap = get_roadmap
    section = roadmap["sections"][section_number-1]
    raise "Section does not exist" if section.nil?
    checkpoint = section["checkpoints"][checkpoint_number-1]
    raise "Checkpoint does not exist" if checkpoint.nil?
    checkpoint_id = checkpoint["id"]
    puts checkpoint_id
    headers = {"authorization" => @auth_token}
    response = self.class.get("/checkpoints/#{checkpoint_id}", {headers: headers})
    raise "Couldn't retrieve the checkpoint" unless response.code == 200
    JSON.parse(response.body)
  end
end

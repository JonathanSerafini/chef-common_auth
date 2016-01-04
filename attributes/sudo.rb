
default[:authorization][:sudo].tap do |config|
  config[:groups] = Array.new
  config[:agent_forwarding] = true
  config[:include_sudoers_d] = true
end


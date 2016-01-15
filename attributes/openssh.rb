
default[:openssh][:server].tap do |server|
  server[:port] = 22
  server[:protocol] = 2
  server[:syslog_facility] = "AUTH"
  server[:log_level] = "INFO"
  server[:login_grace_time] = 10
  server[:r_s_a_authentication] = "yes"
  server[:pubkey_authentication] = "yes"
  server[:password_authentication] = "no"
  server[:challenge_response_authentication] = "no"
  server[:permit_empty_passwords] = "no"
  server[:permit_root_login] = "no"
  server[:ignore_rhosts] = "yes"
  server[:strict_modes] = "yes"
  server[:allow_tcp_forwarding] = "no"
  server[:allow_agent_forwarding] = "yes"
  server[:x11_forwarding] = "no"
  server[:subsystem] = "sftp /usr/lib/openssh/sftp-server"
  server[:allow_groups] = Array.new
end

default[:openssh][:client].tap do |client|
  client.delete(:host)
  # OpenSSH CVE-2016-0777
  client["*"][:use_roaming] = "no"
end


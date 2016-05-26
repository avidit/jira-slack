require 'uri'
require 'net/http'
require 'net/https'
require 'json'
require 'base64'

def get_jira_details(id)
  uri = URI("#{ENV['JIRA_URL']}/rest/api/2/issue/#{id}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  req = Net::HTTP::Get.new(uri)
  auth = Base64.strict_encode64("#{ENV['JIRA_USERNAME']}:#{ENV['JIRA_PASSWORD']}")
  req.add_field 'Authorization', "Basic #{auth}"
  res = http.request(req)
  jira = Hash.new
  if res.code == '200'
    json = JSON.parse(res.body)
    jira[:key] = json['key']
    jira[:summary] = json['fields']['summary']
    jira[:description] = json['fields']['description']
    jira[:creator_name] = json['fields']['reporter']['displayName']
  end
  jira
end

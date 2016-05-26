require 'json'
require 'sinatra'

Dir["#{__dir__}/lib/*.rb"].each { |file| load file }

not_found do
  status 404
  'Seems like you are lost'
end

get '/' do
  status 200
  'Running OK'
end

post '/' do

  return 401 unless request[:token] == ENV['SLACK_TOKEN']
  status 200
  content_type 'application/json'

  text = request[:text].strip
  channel = request[:channel_name]

  if text.empty?
    {text: 'Please provide jira ID'}
  else
    jira = get_jira_details(text)
    if jira.empty?
      {text: "Something went wrong. Please try: #{ENV['JIRA_URL']}/browse/#{text}"}
    else
      data = build_slack_message('in_channel', 'jira_bot', "##{channel}", nil, ':jira:', '')
      data['attachments'] = [{
                                 color: '#203d70',
                                 fallback: 'Oops!, something went wrong',
                                 title: jira[:summary],
                                 title_link: "#{ENV['JIRA_URL']}/browse/#{text}",
                                 fields: [
                                     {
                                         title: 'Issue Key',
                                         value: "#{jira[:key]}",
                                         short: true
                                     },
                                     {
                                         title: 'Creator',
                                         value: "#{jira[:creator_name]}",
                                         short: true
                                     },
                                     {
                                         title: 'Description',
                                         value: "#{jira[:description]}",
                                         short: false
                                     }
                                 ]
                             }]
      data
    end
  end.to_json

end

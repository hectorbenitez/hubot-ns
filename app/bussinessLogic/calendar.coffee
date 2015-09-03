request = require('request')
_ = require('_')

calendar = (apiKey) ->
  host = 'https://slack.com/api';

  add = data, (cb) ->
    url = "#{host}/api/meeting"

    requestInfo = {
      url: url,
      form: data
    }

    request.post requestInfo, (error, response, body) ->
      if(error){
        cb error
      }

      response = JSON.parse(body)
      cb response

module.exports = calendar()

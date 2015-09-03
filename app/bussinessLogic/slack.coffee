request = require('request')
_ = require('_')

slackService = (apiKey) ->
  host = 'https://slack.com/api';

  getAll = (cb) ->
    url = "#{host}/users.list?token=#{apiKey}"
    request.get url, (error, response, body) ->
      if(error){
        cb error
      }

      response = JSON.parse(body)
      cb response.members

  getByEmail = (email, cb) ->
    this.getAll (users) ->
      user = _.filter users, (user) ->
        user.profile.email == email

      if user.length > 0
        cb user[0]
      else
        cb null

  return {
    getAll: getAll
    getByEmail
  }

module.exports = slackService

request = require('request')
_ = require('underscore')

slackService = (apiKey) ->
  host = 'https://slack.com/api';

  getAll = (cb) ->
    url = "#{host}/users.list?token=#{apiKey}"
    request.get url, (error, response, body) ->
      if error
        cb error

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

  getById = (id, cb) ->
    url = "#{host}/users.info?user=#{id}&token=#{apiKey}"
    request.get url, (error, response, body) ->
      if error
        cb error

      response = JSON.parse(body)
      cb response.user

  return {
    getAll: getAll
    getByEmail: getByEmail
    getById: getById
  }

module.exports = slackService

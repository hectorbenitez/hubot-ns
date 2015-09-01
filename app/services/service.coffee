
service = () ->
  host = process.env.PEOPLE_API_HOST || "http://localhost:8000"
  peopleApiAuth = require('../config/people_api.json')
  scopedCredentials = success: false
  MAX_RETRIES = 3

  sendRequest = (robot, url, cb) ->
    today = new Date
    dd = today.getDate()
    retry = 0

    if !scopedCredentials.success || dd > scopedCredentials.expirationDate
      if(retry == MAX_RETRIES)
        return

      authenticationUrl = "#{host}/api/user/authenticate?user=#{peopleApiAuth.username}&clientId=#{peopleApiAuth.clientId}&secret=#{peopleApiAuth.secret}"

      sendHttpRequest robot, authenticationUrl, {}, (credentials) ->
        retry += 1
        scopedCredentials = credentials
        sendHttpRequest robot, url, {'x-access-token': credentials.token}, (result) ->
          cb result
      return

    sendHttpRequest robot, url, {'x-access-token': scopedCredentials.token}, (result) ->
      cb result

  sendHttpRequest = (robot, url, headers, cb) ->
    robot.http(url)
      .headers(headers)
      .get() (err, res, body) ->
          console.log(err)
          if !res || res.statusCode != 200
            statusCode = if res then res.statusCode else 503
            switch statusCode
              when 404 then robot.send "404 - Failed to find what you were looking for."
              when 403
                console.log("Sorry my credentials expired")
                scopedCredentials = success: false
                sendRequest robot, url
              else robot.send "Something happened while i was asleep, try again later. :(. ErrorCode: #{statusCode}"
            return
          if body == ""
            cb body
          else
            cb JSON.parse(body)

  return {
    sendRequest: sendRequest
  }


module.exports = service()

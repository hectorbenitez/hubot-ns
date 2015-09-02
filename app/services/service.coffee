service = () ->
  host = process.env.PEOPLE_API_HOST || "http://localhost:8000"
  peopleApiAuth = require('../config/people_api.json')
  scopedCredentials = success: false
  MAX_RETRIES = 3


  get = (robot, url, cb) ->
    authenticate robot, url, (header) ->
      getRequest robot, url, header, (result) ->
        cb result

  post = (robot, url, data, cb) ->
    authenticate robot, url, cb, (header) ->
      postRequest robot, url, header, data, (result) ->
        cb result

  authenticate = (robot, url, cb) ->
    today = new Date
    dd = today.getDate()

    if !scopedCredentials.success || dd > scopedCredentials.expirationDate

      authenticationUrl = "#{host}/api/user/authenticate?user=#{peopleApiAuth.username}&clientId=#{peopleApiAuth.clientId}&secret=#{peopleApiAuth.secret}"

      getRequest robot, authenticationUrl, {}, (credentials) ->
        scopedCredentials = credentials
        cb {'x-access-token': scopedCredentials.token}
        return

    cb {'x-access-token': scopedCredentials.token}

  getRequest = (robot, url, headers, cb) ->
    robot.http(url)
      .headers(headers)
      .get() (err, res, body) ->
        result = parseResult(err, res, body, robot)
        if(result)
          cb result

  postRequest = (robot, url, headers, data, cb) ->
    robot.http(url)
      .headers(headers)
      .post(data) (err, res, body) ->
        result = parseResult(err, res, body, robot)
        if(result)
          cb result

  parseResult = (err, res, body, robot) ->
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
      return body
    else
      return JSON.parse(body)

  return {
    get: get
    post: post
  }


module.exports = service()

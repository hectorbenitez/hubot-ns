slack = require("./bussinessLogic/slack.js")(process.env.SLACK_API_KEY)
calendar = require("./bussinessLogic/calendar.js")
moment = require("moment")

meetingRooms = (cb) ->
  add = (organizer, startTime, endTime, attendees, cb) ->
    user = slack.getByEmail organizer, (user) ->
      timezone = user.tz ? user.tz : 'UTC'
      calendar.add organizer, startTime, attendees, timezone, (result) ->
        cb result

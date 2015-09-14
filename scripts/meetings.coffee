# Description
#   An integration with nearsoft contact information API / meeting rooms
#
# Dependencies:
#   none
#
#
# Commands:
#   bot rooms - A list of all meeting rooms
#   bot rooms in <location> -  Meeting rooms in a specific location
#   bot organize a meeting in <room_name> from <time> to <time>
#   bot is <room_name> available at <time>?
#
#Notes:
#   None
#
# Author:
#   luis-montealegre
host = process.env.PEOPLE_API_HOST || "http://localhost:8000"
slackApiKey = process.env.SLACK_API_KEY || "<your_api_key_here>";

service = require('../app/services/service.coffee')
slack = require('../app/bussinessLogic/slack.coffee')(slackApiKey)
time = require('../app/utils/time.coffee')
moment = require('moment-timezone')

module.exports = (robot) ->
    robot.respond /rooms( in (.*))?$/, (robot) ->
        location = robot.match[2];
        url = "#{host}/api/meeting/rooms"
        if(location)
          url = "#{url}/#{location}"


        service.get robot, url, (rooms) ->
          message = ""

          if rooms.length == 0
            message = "I was not able to find any meeting rooms"
            if(location)
              message = "#{message} at #{location}"
            robot.send "#{message}. :("
            return


          for index, room of rooms
              message += "#{room.name} at #{room.location}. \n"

          robot.send message

    robot.respond /organize a meeting in ([-_0-9a-zA-Z\.]+) at (([01]?[0-9]|2[0-3]):[0-5][0-9]) to (([01]?[0-9]|2[0-3]):[0-5][0-9]) about (.*)/i, (robot) ->
        location = robot.match[1]
        startTime = robot.match[2]
        endTime = robot.match[3]
        summary = robot.match[4]

        slack.getById robot.message.user.id, (user) ->
          if !user
            robot.send "I wasn't able to find you! Please help!"
            return

          startTime = time.setWithToday(startTime, user.tz)
          endTime = time.setWithToday(endTime, user.tz)
          date = moment.tz(user.tz).format()

          if startTime
            robot.send "Sorry, your meeting start time seems to be invalid"
            return

          if endTime
            robot.send "Sorry, your ending time seems to be invalid"
            return

          if moment(startTime).isAfter(date)
            robot.send "Sorry, start time of the meeting cannot be less than the ending time"
            return

          if  moment(endTime).isAfter(date)
            robot.send "Sorry, end time of a meeting cannot be less than today's date"
            return


          url = "#{host}/api/meeting"

          data = {
            organizer: robot.message.user.email
            startTime: startTime
            endTime: endTime
            summary: summary
          }

          service.post robot, url, data, (meeting) ->
            if meeting
              robot.send "I was not able to schedule your meeting in #{location}. :("
              return

            robot.send "Done!! Your meeting is setup!"

    robot.respond /is ([-_0-9a-zA-Z\.]+) available at (([01]?[0-9]|2[0-3]):[0-5][0-9])/i, (robot) ->
        room = robot.match[1]
        startTime = robot.match[2]

        slack.getById robot.message.user.id, (user) ->
          if !user
            robot.send "Sorry, I was not able to find you in the slack directory. :("
            return

          formattedISOTime = time.setWithToday(startTime, user.tz)

          data = {
            startTime: formattedISOTime,
          }

          if !moment(formattedISOTime).isValid()
            robot.send "Sorry, I'm not able to handle that date. Try with 3:00, 3pm, 4:00 or a complicated ISO date"
            return

          url = "#{host}/api/meeting/rooms/#{room}/available?startTime=#{formattedISOTime}"

          service.get robot, url, (event) ->
            if event.isBusy
              robot.send "Hey, that room is busy at that time. You might want to use later"
              return

            robot.send "#{room} is free at #{startTime}. Schedule a meeting before they take it!"

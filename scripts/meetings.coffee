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
#   bot organize a meeting in <room_name> at <time>
#   bot organize a meeting in <room_name> at <date> <time>
#   bot is <room_name> available at <time>?
#   bot is <room_name> avialable at <date> <time>?
#   bot is <room_name> available from <date> to <date>?
#
#Notes:
#   None
#
# Author:
#   luis-montealegre
host = process.env.PEOPLE_API_HOST || "http://localhost:8000"
service = require('../app/services/service.coffee')

module.exports = (robot) ->
    robot.respond /rooms( in (.*))?$/, (robot) ->
        location = robot.match[2];
        url = "#{host}/api/meeting/rooms"
        console.log("location:", robot.match)
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

    robot.respond /organize a meeting in ([-_0-9a-zA-Z\.]+) at (([01]?[0-9]|2[0-3]):[0-5][0-9])/i, (robot) ->
        location = robot.match[1]
        url = "#{host}/api/meeting"
        data = {

        }

        service.post robot, url, data (meeting) ->
          if meeting
            robot.send "I was not able to schedule your meeting in #{location}. :("
            return

          robot.send "done!!"

    robot.respond /organize a meeting in ([-_0-9a-zA-Z\.]+) at (\d{4})-(\d{2})-(\d{2}) (([01]?[0-9]|2[0-3]):[0-5][0-9])\?/i, (robot) ->
        location = robot.match[1]
        url = "#{host}/api/rooms/#{location}"

        service.post robot, url, (rooms) ->
          if rooms.length == 0
            robot.send "I was not able to find any meeting rooms in #{location}. :("
            return

          message = ""
          for index, room of rooms
              message += "#{room.name}. \n"

          robot.send message

    robot.respond /is ([-_0-9a-zA-Z\.]+) available at (([01]?[0-9]|2[0-3]):[0-5][0-9])\?/i, (robot) ->
        location = robot.match[1]
        url = "#{host}/api/rooms/#{location}"

        service.post robot, url, (rooms) ->
          if rooms.length == 0
            robot.send "I was not able to find any meeting rooms in #{location}. :("
            return

          message = ""
          for index, room of rooms
              message += "#{room.name}. \n"

          robot.send message

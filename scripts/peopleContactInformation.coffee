# Description
#   An integration with nearsoft contact information API
#
# Dependencies:
#   none
#
#
# Commands:
#   bot who work's at nearsoft? - Returns all the people who work at nearsoft
#   bot who's in <team_name>? - Returns a list of the people working at the specified team
#   bot who's at <place>? - Returns a list of
#   bot tell me about <name> <last_name> - A long story about the person you are looking for
#   bot find <email/skype/name> - Search by name, skype or email
#   bot who works with <skill>? - Returns a list of people with the specified skill
#   bot who works with <skill> at <location>? - Returns a list of people with the specified skill in a certain location
#   bot who works with <skill> at <location> in <team>? - Returns a list of people with the specified skill in a certain location and team
#
# Notes:
#   None
#
# Author:
#   luis-montealegre

host = process.env.PEOPLE_API_HOST || "http://localhost:8000"

module.exports = (robot) ->


    robot.respond /who works at nearsoft\?/i, (robot) ->
        url = "#{host}/api/people"

        sendRequest robot, url, (people) ->
          if people.length == 0
            robot.send "I was not able to find any people working at nearsoft. :("
            return

          message = ""
          for index, person of people
              message += "#{person.name} #{person.lastName} \n"

          robot.send message

    robot.respond /who works with ([-_0-9a-zA-Z\.]+)\?/i, (robot) ->
      skill = robot.match[1]

      url = "#{host}/api/people/#{skill}"

      sendRequest robot, url, (people) ->
        if people.length == 0
          robot.send "I wasn't able to find people with #{skill} skill. :("
          return

        message = ""
        for index, person of people
            message += "#{person.name} #{person.lastName} in #{person.location} \n"

        robot.send message

    robot.respond /who works with ([-_0-9a-zA-Z\.]+) at ([-_0-9a-zA-Z\.]+)\?/i, (robot) ->
      skill = robot.match[1]
      location = robot.match[2]

      url = "#{host}/api/people/#{skill}?location=#{location}"

      sendRequest robot, url, (people) ->
        if people.length == 0
          robot.send "I wasn't able to find people with #{skill} skill at #{location}. :("
          return

        message = ""
        for index, person of people
            message += "#{person.name} #{person.lastName}. Email: #{person.workEmail}. Skype: #{person.skype} <skype:#{person.skype}?chat>.\n"

        robot.send message

    robot.respond /who works with ([-_0-9a-zA-Z\.]+) at ([-_0-9a-zA-Z\.]+) in ([-_0-9a-zA-Z\.]+)\?/i, (robot) ->
      skill = robot.match[1]
      location = robot.match[2]
      team = robot.match[3]

      url = "#{host}/api/people/#{robot.match[1]}?location=#{robot.match[2]}&team=#{robot.match[3]}"

      sendRequest robot, url, (people) ->
        if people.length == 0
          robot.send "I wasn't able to find people with #{skill} skill at #{location} in #{team}. :("
          return

        message = ""
        for index, person of people
            message += "#{person.name} #{person.lastName}. Email: #{person.workEmail}. Skype: #{person.skype} <skype:#{person.skype}?chat>.\n"

        robot.send message

    robot.respond /Who's in (.*)\?/i, (robot) ->
        team = (robot.match[1].split(' ').map (word) -> word[0].toUpperCase() + word[1..-1].toLowerCase()).join ' '

        url = "#{host}/api/team/#{team}"

        sendRequest robot, url, (people) ->
          if people.length == 0
            robot.send "Couldn't find a team with the name \"#{team}\"."
            return

          message = ""
          for index, person of people
            message += "#{person.name} #{person.lastName} \n"

          robot.send message

    robot.respond /tell me about (.*)/i, (robot) ->
        personName = (robot.match[1].split(' ').map (word) -> word[0].toUpperCase() + word[1..-1].toLowerCase()).join ' '

        [first, last] = personName.split(" ")

        baseUrl = "#{host}/api/person/#{first}"
        url = if last then "#{baseUrl}/#{last}" else baseUrl

        sendRequest robot, url, (person) ->
            if person == ""
              robot.send "I couldn't find \"#{personName}\". Maybe I forgot where to find him/her."
              return

            location = ""

            switch person.location
              when "HMO" then location = "Hermosillo, Sonora"
              when "CUU" then location = "Chihuahua, Chihuahua"
              when "DF" then  location = "DF"
              else  location = "somewhere in the earth."

            message = "His/her fullname is: #{person.name} #{person.lastName}. \n"

            message += "Email: #{person.workEmail}. Skype: #{person.skype} <skype:#{person.skype}?chat>. \n"

            switch person.role
              when "Developer" then message += "Likes to code in #{location}."
              when "IT Support" then message += "Enjoys denying pretty things to people in #{location}."
              when "Intern" then message += "Likes to be called an \"Intern\". ¯\\_(ツ)_/¯"
              when person.role.toLowerCase().indexOf("test") > -1 then  message += "Likes to test and break things developer do (or not)."
              else  message += "Saves the world in their free time and read some books."

            robot.send message

    robot.respond /find (.*)/i, (robot) ->
        searchTerm = robot.match[1]
        url = "#{host}/api/people/search?query=#{searchTerm}"

        sendRequest robot, url, (people) ->
          if people.length == 0
            robot.send "I was not able to find \"#(searchTerm)\" :("
            return

          message = "I found #{people.length} people: \n"

          for index, person of people
            message += "#{person.role}: #{person.name} #{person.lastName}. Working at #{person.location}. His/her email is #{person.workEmail} and skype is #{person.skype} <skype:#{person.skype}?chat>.\n"

          robot.send message

    robot.respond /who's at (.*)\?/i, (robot) ->
        my_place = robot.match[1];
        place = my_place
        switch my_place.toLowerCase()
          when "someplace" || "otro" then place = "Other"
          when "DF" then place = "DF"
          when "hermosillo" then place = "HMO"
          when "chihuahua" then place = "CUU"

        url = "#{host}/api/location/#{place}"

        sendRequest robot, url, (people) ->
          if people.length == 0
            robot.send "I was not able to find people working at #{place} :("
            return

          message = "Found #{people.length} people in #{my_place}: \n"

          for index, person of people
            message += "#{person.name} #{person.lastName}. His/her email is #{person.workEmail} and skype is #{person.skype} <skype:#{person.skype}?chat>.  \n"

          robot.send message


scopedCredentials = success: false
MAX_RETRIES = 3

sendRequest = (robot, url, cb) ->
  today = new Date
  dd = today.getDate()
  retry = 0

  if !scopedCredentials.success || dd > scopedCredentials.expirationDate
    if(retry == MAX_RETRIES)
      return

    peopleApiAuth = require('./config/people_api.json')

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
        if !res || res.statusCode != 200
          statusCode = if res then res.statusCode else 503
          switch statusCode
            when 404 then robot.send "404 - Failed to find what you were looking for."
            when 403
              console.log("Sorry my credentials expired, find the developer and yell at him/her")
              scopedCredentials = success: false
              sendRequest robot, url
            else robot.send "Something happened while i was asleep, try again later. :(. ErrorCode: #{statusCode}"
          return
        if body == ""
          cb body
        else
          cb JSON.parse(body)

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
#   bot who's at <location> and is a <role>? - Returns a list of people in a certain location with the specified role
#   bot who's at <location> in <team>? - Returns a list of people in a certain location with the specified team
#
# Notes:
#   None
#
# Author:
#   luis-montealegre

host = process.env.PEOPLE_API_HOST || "http://localhost:8000"
service = require('../app/services/service.coffee')

module.exports = (robot) ->

    robot.respond /who works at nearsoft\?/i, (robot) ->
        url = "#{host}/api/people"

        service.get robot, url, (people) ->
          if people.length == 0
            robot.send "I was not able to find any people working at nearsoft. :("
            return

          message = ""
          for index, person of people
              message += "#{person.name} #{person.lastName} \n"

          robot.send message

    robot.respond /who works with ([-_0-9a-zA-Z\.\#\+]+)\?/i, (robot) ->
      skill = robot.match[1]

      url = "#{host}/api/people/#{skill}"

      service.get robot, url, (people) ->
        if !people || people.length == 0
          robot.send "I wasn't able to find people with #{skill} skill. :("
          return

        message = ""
        for index, person of people
            message += "#{person.name} #{person.lastName} in #{person.location} \n"

        robot.send message

    robot.respond /who works with ([-_0-9a-zA-Z\.#]+) at ([-_0-9a-zA-Z\.]+)\?/i, (robot) ->
      skill = robot.match[1]
      location = robot.match[2]

      url = "#{host}/api/people/#{skill}?location=#{location}"

      service.get robot, url, (people) ->
        if !people || people.length == 0
          robot.send "I wasn't able to find people with #{skill} skill at #{location}. :("
          return

        message = ""
        for index, person of people
            message += "#{person.name} #{person.lastName}. Email: #{person.workEmail}. Skype: #{person.skype} <skype:#{person.skype}?chat>.\n"

        robot.send message

    robot.respond /who works with ([-_0-9a-zA-Z\.#]+) at ([-_0-9a-zA-Z\.]+) in ([-_0-9a-zA-Z\.]+)\?/i, (robot) ->
      skill = robot.match[1]
      location = robot.match[2]
      team = robot.match[3]

      url = "#{host}/api/people/#{skill}?location=#{location}&team=#{team}"

      service.get robot, url, (people) ->
        if !people || people.length == 0
          robot.send "I wasn't able to find people with #{skill} skill at #{location} in #{team}. :("
          return

        message = ""
        for index, person of people
            message += "#{person.name} #{person.lastName}. Email: #{person.workEmail}. Skype: #{person.skype} <skype:#{person.skype}?chat>.\n"

        robot.send message

    robot.respond /who(\’|\')s in (.*)\?/i, (robot) ->
        team = robot.match[2]

        url = "#{host}/api/team/#{team}"

        service.get robot, url, (people) ->
          if people.length == 0
            robot.send "Couldn't find a team with the name \"#{team}\"."
            return

          message = ""
          for index, person of people
            message += "#{person.name} #{person.lastName} \n"

          robot.send message

    robot.respond /who(\’|\')s a (.*)\?/i, (robot) ->
      role = robot.match[2]

      url = "#{host}/api/people?role=#{role}"

      service.get robot, url, (people) ->
        if people.length == 0
          robot.send "I wasn't able to find people with #{role} role. :("
          return

        message = ""
        for index, person of people
            message += "#{person.name} #{person.lastName}. Email: #{person.workEmail}. Skype: #{person.skype} <skype:#{person.skype}?chat>.\n"

        robot.send message

    robot.respond /who(\’|\')s at ([-_0-9a-zA-Z\.]+) and is a (.*)\?/i, (robot) ->
      location = robot.match[2]
      role = robot.match[3]

      url = "#{host}/api/people?location=#{location}&role=#{role}"

      service.get robot, url, (people) ->
        if people.length == 0
          robot.send "I wasn't able to find people in #{location} with #{role} role. :("
          return

        message = ""
        for index, person of people
            message += "#{person.name} #{person.lastName}. Email: #{person.workEmail}. Skype: #{person.skype} <skype:#{person.skype}?chat>.\n"

        robot.send message

    robot.respond /who(\’|\')s at ([-_0-9a-zA-Z\.]+) and is a (.*)\?/i, (robot) ->
      location = robot.match[2]
      role = robot.match[3]

      url = "#{host}/api/people?location=#{location}&role=#{role}"

      service.get robot, url, (people) ->
        if people.length == 0
          robot.send "I wasn't able to find people in #{location} who are #{role}. :("
          return

        message = ""
        for index, person of people
            message += "#{person.name} #{person.lastName}. Email: #{person.workEmail}. Skype: #{person.skype} <skype:#{person.skype}?chat>.\n"

        robot.send message

    robot.respond /who(\’|\')s at ([-_0-9a-zA-Z\.]+) in (.*)\?/i, (robot) ->
      location = robot.match[2]
      team = robot.match[3]

      url = "#{host}/api/people?location=#{location}&team=#{team}"

      service.get robot, url, (people) ->
        if people.length == 0
          robot.send "I wasn't able to find people in #{location} in #{team}. :("
          return

        message = ""
        for index, person of people
            message += "#{person.name} #{person.lastName}. Email: #{person.workEmail}. Skype: #{person.skype} <skype:#{person.skype}?chat>.\n"

        robot.send message

    robot.respond /tell me about (.*)/i, (robot) ->
        personName = robot.match[1]

        [first, last] = personName.split(" ")

        baseUrl = "#{host}/api/person/#{first}"
        url = if last then "#{baseUrl}/#{last}" else baseUrl

        service.get robot, url, (person) ->

            if person == ""
              robot.send "I couldn't find #{personName}."
              return

            location = ""

            switch person.location
              when "HMO" then location = "Hermosillo, Sonora"
              when "CUU" then location = "Chihuahua, Chihuahua"
              when "DF" then  location = "DF"
              else  location = "somewhere in the earth."

            message = "Fullname is: #{person.name} #{person.lastName}. \n"

            message += "Email: #{person.workEmail}. Skype: #{person.skype} <skype:#{person.skype}?chat>. \n"

            message += "Location: #{location}. \n"

            if person.skills
              message += "Skills: " + person.skills.join(", ")

            # switch person.role
            #   when "Developer" then message += "Likes to code in #{location}."
            #   when "IT Support" then message += "Enjoys denying pretty things to people in #{location}."
            #   when "Intern" then message += "Likes to be called an \"Intern\". ¯\\_(ツ)_/¯"
            #   when person.role.toLowerCase().indexOf("test") > -1 then  message += "Likes to test and break things developer do (or not)."
            #   else  message += "Saves the world in their free time and read some books."

            robot.send message

    robot.respond /find (.*)/i, (robot) ->
        searchTerm = robot.match[1]
        url = "#{host}/api/people/search?query=#{searchTerm}"

        service.get robot, url, (people) ->
          if people.length == 0
            robot.send "I was not able to find \"#{searchTerm}\" :("
            return

          if people.length == 1
            message = "I found one person that matched #{searchTerm}: \n"
          else
            message = "I found #{people.length} people: \n"

          for index, person of people
            message += "#{person.role}: #{person.name} #{person.lastName}.\n Team: #{person.team}. Working at #{person.location}.\n Email: #{person.workEmail}. Skype: #{person.skype} <skype:#{person.skype}?chat>. \n ___________________ \n"

          robot.send message



    robot.respond /who(\’|\')s at ([-_0-9a-zA-Z\.]+)\?/i, (robot) ->
        my_place = robot.match[2];
        place = my_place
        switch my_place.toLowerCase()
          when "someplace" || "otro" then place = "Other"
          when "DF" then place = "DF"
          when "hermosillo" then place = "HMO"
          when "chihuahua" then place = "CUU"

        url = "#{host}/api/location/#{place}"

        service.get robot, url, (people) ->
          if people.length == 0
            robot.send "I was not able to find people working at #{place} :("
            return

          message = "Found #{people.length} people in #{my_place}: \n"

          for index, person of people
            message += "#{person.name} #{person.lastName}. His/her email is #{person.workEmail} and skype is #{person.skype} <skype:#{person.skype}?chat>.  \n"

          robot.send message

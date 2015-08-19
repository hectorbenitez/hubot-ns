# Description
#   An integration with nearsoft contact information API
#
# Dependencies:
#   none
#
#
# Commands:
#   bot quienes chambean en nearsoft - Te regresa una lista de todas las personas de Nearsoft
#   bot quienes estan en <nombre_del_equipo> - Te regresa una lista de todas las personas del equipo especificado
#   bot cuentame acerca de <nombre> <apellido_paterno> - Una historia larga sobre la persona que buscaste
#   bot busca <algo> - Busca por nombre, email y skype dentro del directorio de personas de Nearsoft
#
# Notes:
#   None
#
# Author:
#   luis-montealegre

host = process.env.PEOPLE_API_HOST || "http://localhost:8000"

module.exports = (robot) ->


    robot.respond /quienes chambean en nearsoft/i, (robot) ->
        url = "#{host}/api/people"

        sendRequest robot, url, (people) ->
          if people.length == 0
            robot.send "No encontré a nadie :("
            return

          message = ""
          for index, person of people
              message += "#{person.name} #{person.lastName} \n"

          robot.send message

    robot.respond /quienes estan en (.*)/i, (robot) ->
        team = (robot.match[1].split(' ').map (word) -> word[0].toUpperCase() + word[1..-1].toLowerCase()).join ' '

        url = "#{host}/api/team/#{team}"

        sendRequest robot, url, (people) ->
          if people.length == 0
            robot.send "No encontré a nadie en el equipo de #{team}"
            return

          message = ""
          for index, person of people
            message += "#{person.name} #{person.lastName} \n"

          robot.send message

    robot.respond /cuentame acerca de (.*)/i, (robot) ->
        person = (robot.match[1].split(' ').map (word) -> word[0].toUpperCase() + word[1..-1].toLowerCase()).join ' '

        [first, last] = person.split(" ")

        baseUrl = "#{host}/api/person/#{first}"
        url = if last then "#{baseUrl}/#{last}" else baseUrl

        sendRequest robot, url, (persona) ->
            if persona == ""
              robot.send "No encontré a nadie con el nombre de #{person}"
              return

            location = ""

            switch persona.location
              when "HMO" then location = "Hermosillo, Sonora"
              when "CUU" then location = "Chihuahua, Chihuahua"
              when "DF" then  location = "DF"
              else  location = "algun lugar en el planeta tierra"

            message = "Su nombre completo es: #{persona.name} #{persona.lastName}. \n"

            message += "Su correo es: #{persona.workEmail}. Su skype es #{person.skype} <skype:#{person.skype}?chat>. \n"

            switch persona.role
              when "Developer" then message += "Le gusta tirar codigo en la frescas mañanas de #{location}."
              when "IT Support" then message += "Atraer la atencion negandole cosas a la gente de Nearsoft."
              when "Intern" then message += "Le gusta que le digan Intern. ¯\\_(ツ)_/¯"
              when persona.role.toLowerCase().indexOf("test") > -1 then  message += "Prueba en las mañanas, tardes y ocasionalmente en las noches."
              else  message += "Salvar el mundo en sus tiempos libros y tomar cafe."

            robot.send message

    robot.respond /busca (.*)/i, (robot) ->
        searchTerm = robot.match[1]
        url = "#{host}/api/people/search?query=#{searchTerm}"

        sendRequest robot, url, (people) ->
          if people.length == 0
            robot.send "No encontré lo que buscabas :("
            return

          message = "Encontré #{people.length} personas: \n"

          for index, person of people
            message += "#{person.role}: #{person.name} #{person.lastName}. Se encuentra en #{person.location}. Su correo es #{person.workEmail} y su Skype es #{person.skype} <skype:#{person.skype}?chat>.\n"

          robot.send message

    robot.respond /quienes se encuentran en (.*)/i, (robot) ->
        my_place = robot.match[1];
        place = my_place
        switch my_place.toLowerCase()
          when "otro lugar" || "otro" then place = "Other"
          when "el df" then place = "DF"
          when "hermosillo" then place = "HMO"
          when "chihuahua" then place = "CUU"

        url = "#{host}/api/location/#{place}"

        sendRequest robot, url, (people) ->
          if people.length == 0
            robot.send "No encontré personas en #{place} :("
            return

          message = "Encontré #{people.length} personas en #{my_place}: \n"

          for index, person of people
            message += "#{person.name} #{person.lastName}. Su correo es #{person.workEmail} y su Skype es #{person.skype} <skype:#{person.skype}?chat>.  \n"

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
            when 404 then robot.send "404 - No encontré lo buscabas"
            when 403
              console.log("credentials expired")
              scopedCredentials = success: false
              sendRequest robot, url
            else robot.send "Algo paso mientras dormia, no puedo contestarte en este momento. :("
          return
        if body == ""
          cb body
        else
          cb JSON.parse(body)

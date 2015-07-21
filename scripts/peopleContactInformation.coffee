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
            robot.send "No encontre a nadie :("
            return

          message = ""
          for index, person of people
              message += "#{person.name} #{person.lastName} \n"

          robot.send message

    robot.respond /quienes estan en (.*)/i, (robot) ->
        url = "#{host}/api/team/#{team}"

        team = robot.match[1]
        sendRequest robot, url, (people) ->
          if people.length == 0
            robot.send "No encontre a nadie en el equipo de #{team}"
            return

          message = ""
          for index, person of people
            message += "#{person.name} #{person.lastName} \n"

          robot.send message

    robot.respond /cuentame acerca de (.*)/i, (robot) ->
        url = "#{host}/api/person/#{first}/#{last}"

        person = robot.match[1]
        [first, last] = person.split(" ")

        sendRequest robot, url, (persona) ->
            if persona == ""
              robot.send "No encontre a nadie con el nombre de #{first} #{last}"
              return

            location = ""

            switch persona.location
              when "HMO" then location = "Hermosillo, Sonora"
              when "CUU" then location = "Chihuahua, Chihuahua"
              when "DF" then  location = "DF"
              else  location = "algun lugar en el planeta tierra"

            message = "Su nombre completo es: #{persona.name} #{persona.lastName}. \n"

            message += "Su correo es: #{persona.workEmail}. Su skype es #{persona.skype}. \n"

            switch persona.role
              when "Developer" then message += "Le gusta tirar codigo en la frescas mañanas de #{location}."
              when "IT Support" then message += "Atraer la atencion negandole cosas a la gente de Nearsoft."
              when "Intern" then message += "Le gusta que le digan Intern. ¯\\_(ツ)_/¯"
              when persona.role.toLowerCase().indexOf("test") > -1 then  message += "Prueba en las mañanas, tardes y ocasionalmente en las noches."
              else  message += "Salvar el mundo en sus tiempos libros y tomar cafe."

            robot.send message

    robot.respond /busca (.*)/i, (robot) ->
        url = "#{host}/api/people/search?query=#{searchTerm}"
        searchTerm = robot.match[1]

        sendRequest robot, url, (people) ->
          if people.length == 0
            robot.send "No encontre lo que buscabas :("
            return

          robot.send "Encontre " + people.length + " personas:"
          message = for index, person of people
            "#{person.role}: #{person.name} #{person.lastName}. Se encuentra en #{person.location}. Su correo es #{person.workEmail} y su Skype es #{person.skype}.  \n"
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

    peopleApiAuth = require('../config/people-api.json')

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
            when 404 then robot.send "404 - No encontre lo buscabas"
            when 403
              console.log("credentials expired")
              scopedCredentials = success: false
              sendRequest robot, url
            else robot.send "Algo paso mientras dormia, no puedo contestarte en este momento. :("
          return
        cb JSON.parse(body)

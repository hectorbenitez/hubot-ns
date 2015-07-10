module.exports = (robot) ->
    answer = 42
    host = "https://boiling-dawn-2781.herokuapp.com"

    robot.respond /cual es la respuesta a la vida, el universo y todo lo demas/, (res) ->
      unless answer?
        res.send "Missing HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING in environment: please set and try again"
        returnbog s
      res.send "#{answer}, pero cual es la pregunta?"

    robot.hear /bot ns help/i, (msg) ->
      help = "Comandos: \n"
      help += "\t quienes chambean en nearsoft - Una lista de la gente parte del equipo de Nearsoft\n"
      help += "\t quienes estan en <nombre_del_equipo> - Una lista del equipo \n"
      help += "\t cuenta acerca de <nombre> <apellido_paterno> - Una historia large sobre la persona que buscaste \n"
      help += "\t encontrame <lo_que_quieras_encontrar> - Encuentra personas por su mail, nombre, apellido, etc \n"
      msg.send help

    robot.respond /quienes chambean en nearsoft/i, (msg) ->
        msg.http("#{host}/api/people")
            .get() (err, res, body) ->
              # pretend there's error checking code here
                switch res.statusCode
                  when 404 then msg.send "404 - Service got lost in time and space"
                  else msg.send "Unable to process your request and we're not sure why :("

                people = JSON.parse(body)

                message = for index, person of people
                  "#{person.name} #{person.lastname} \n"
                msg.send message

    robot.respond /quienes estan en {.*}/i, (msg) ->
        team = msg.match[1]

        msg.http("#{host}/api/team/#{team}")
            .get() (err, res, body) ->
              # pretend there's error checking code here
                switch res.statusCode
                  when 404 then msg.send "404 - Service got lost in time and space"
                  else msg.send "Unable to process your request and we're not sure why :("

                people = JSON.parse(body)

                if body = ""
                  msg.send "No encontre a nadie en el equipo de #{team}"
                  return

                message = for index, person of people
                  "#{person.name} #{person.lastname} \n"
                msg.send message

    robot.respond /cuentame acerca de (.*)/i, (msg) ->
        person = msg.match[1]

        [first, last] = person.split(" ")

        msg.http("#{host}/api/person/#{first}/#{last}")
            .get() (err, res, body) ->
              # pretend there's error checking code here
                if res.statusCode != 200
                  switch res.statusCode
                    when 404 then msg.send "404 - Service got lost in time and space"
                    else msg.send "Unable to process your request and we're not sure why :("
                  return

                person = JSON.parse(body)

                if person = ""
                  msg.send "No encontre a  alguien con el nombre #{first} #{last}"
                  return

                location = ""
                switch person.location
                  when "HMO" then location = "Hermosillo, Sonora"
                  when "CUU" then location = "Chihuahua, Chihuahua"
                  when "DF" then  location = "DF"
                  else  location = "algun lugar en el planeta tierra"

                message = "Su nombre completo es: #{person.name} #{person.lastname}. \n"

                switch person.role
                  when "Developer" then message += "Le gusta hechar codigo en la frescas mañanas de #{location}."
                  when "IT Support" then message += "Atraer la atencion negandole cosas a la gente de Nearsoft."
                  when "Intern" then message += "Le gusta que le digan Intern. ¯\\_(ツ)_/¯"
                  when person.role.test("Test") then  message += "Prueba en las mañanas, tardes y ocasionalmente en las noches."
                  else  message += "Salvar el mundo en sus tiempos libros y tomar cafe."

                msg.send message

    robot.respond /encuentrame (.*)/i, (msg) ->
        searchTerm = msg.match[1]

        msg.http("#{host}/api/search/searchTerm")
            .get() (err, res, body) ->
              # pretend there's error checking code here
                if res.statusCode != 200
                  switch res.statusCode
                    when 404 then msg.send "404 - Service got lost in time and space"
                    else msg.send "Unable to process your request and we're not sure why :("
                  return

                people = JSON.parse(body)

                if people.length > 0
                  msg.send "Encontre " + people.length + " personas:"
                  message = for index, person of people
                    "#{person.role}: #{person.name} #{person.lastname}. Se encuentra en #{person.location}. Su correo es #{person.workEmail} y su Skype es #{person.skype}.  \n"
                  msg.send message
                  return

                msg.send "No encontre lo que buscabas :("

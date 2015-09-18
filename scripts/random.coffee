# Description
#   The answer to life, the universe and everything
#
# Dependencies:
#   none
#
#
# Commands:
#
# Notes:
#   None
#
# Author:
#   luis-montealegre

module.exports = (robot) ->
    answer = 42

    robot.respond /cual es la respuesta a la vida, el universo y todo lo demas|what's the answer to life, the universe and everything/i, (res) ->
      res.send "#{answer}"

    robot.respond /que piensa el mike de (.*)/i, (res) ->
      res.reply "¯\\_(ツ)_/¯"

    robot.hear /por que!\?|why!\?/i, (res) ->
      res.reply "ლ(ಠ_ಠლ)"

    robot.hear /quien es el robot\?/, (res) ->
      res.reply "Yo! ლ(ಠ_ಠლ)! "

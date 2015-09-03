moment = require('moment')

service = () ->
  setWithToday = (time) ->
    if typeof time isnt 'string'
      return new Error 'Invalid input time'

    today = moment(moment.format())

    time = time.toLowerCase()
    timeArr = _.compact(time.split(/am|pm|:|\s/g))

    firstDigit = parseInt(timeArr[0])
    if !firstDigit
      return new Error 'Invalid input time'

    today.set(0, 'hour')
    today.set(0, 'minute')
    today.set(0, 'second')

    isAm = endsWith(time, "am")
    isPM = endsWith(time, "pm")

    if isAm | isPm
      if isPM
        firstDigit += 12

    if timeArr.length > 1
        secondItem = parseInt(timeArray[1])
        if secondItem
          today.set(parseInt(secondItem), 'minute')
    else
      today.set(time, 'hour')

    if !today.isValid()
      return new Erorr 'Invalid input time'

    return today.format;

  setWithToday: setWithToday

module.exports = service()


endsWith = (str, suffix) ->
  return str.indexOf suffix, str.length - suffix.length isnt -1;

moment = require('moment-timezone')
_ = require('underscore')

service = () ->
  setWithToday = (time, timezone) ->

    if typeof time isnt 'string'
      return new Error 'Invalid input time'

    today = moment().tz(timezone)
    time = time.toLowerCase()
    timeArr = _.compact(time.split(/am|pm|:|\s/g))
    firstDigit = parseInt(timeArr[0])
    isAm = endsWith(time, "am")
    isPM = endsWith(time, "pm")

    if !firstDigit
      return new Error 'Invalid input time'

    tdoay = today.hour(firstDigit).minute(0).second(0)

    if isAm | isPM
      if isPM
        firstDigit += 12

    if timeArr.length > 1
        secondItem = parseInt(timeArr[1])
        if secondItem
          today.set(secondItem, 'minute')
    else
      today.set(firstDigit, 'hour')

    if !today.isValid()
      return new Erorr 'Invalid input time'

    return today.format();

  setWithToday: setWithToday

module.exports = service()


endsWith = (str, suffix) ->
  return str.indexOf suffix, str.length - suffix.length isnt -1;

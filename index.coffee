express = require('express')
request = require('request')
ical = require('icalendar')
S = require('string')

app = express()

app.get '/venue/:id', (req, res) ->
  TM_URL = 'http://www.ticketmaster.co.uk'
  request "#{TM_URL}/json/search/event?vid=#{req.params.id}", (error, response, body) ->
    if error or response.statusCode is not 200
      res.sendStatus(500)
      return
    cal = new ical.iCalendar()
    JSON.parse(body)?.response?.docs?.forEach (i) ->
      event = new ical.VEvent()
      event.setDate i.EventDate
      event.setDescription S(i['search-en']).decodeHTMLEntities().s
      event.setLocation i.VenueName
      event.setSummary S(i.EventName).decodeHTMLEntities().s
      event.addProperty 'GEO', i.VenueLatLong
      event.addProperty 'URL', "#{TM_URL}#{i.AttractionSEOLink}"
      cal.addComponent event
    res.contentType 'ics'
    res.send cal.toString()

server = app.listen process.env.PORT || 8080, process.env.IP || '127.0.0.1', ->
  host = server.address().address
  port = server.address().port
  console.log 'Listening at http://%s:%s', host, port

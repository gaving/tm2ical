request = require("request")
icalendar = require("icalendar")
express = require("express")
app = express()

TM_URL = "http://www.ticketmaster.co.uk/"

app.get "/venue/:id", (req, res) ->
  request "#{TM_URL}json/search/event?vid=" + req.params.id, (error, response, body) ->
    if not error and response.statusCode is 200
      cal = new icalendar.iCalendar()
      data = JSON.parse(body)
      data.response.docs.forEach (i, e) ->
        event = new icalendar.VEvent()
        event.setSummary i.EventName
        event.setDescription i["search-en"]
        event.setLocation i.VenueName
        event.setDate i.EventDate, i.EventDate
        event.addProperty "GEO", i.VenueLatLong
        event.addProperty "URL", "#{TM_URL}#{i.AttractionSEOLink}"
        cal.addComponent event
      res.contentType "ics"
      res.send cal.toString()
      res.end()

server = app.listen process.env.OPENSHIFT_NODEJS_PORT || 8080, process.env.OPENSHIFT_NODEJS_IP || "127.0.0.1", ->
  host = server.address().address
  port = server.address().port
  console.log "Listening at http://%s:%s", host, port

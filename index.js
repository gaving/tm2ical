import express from "express";
import ical from "icalendar";
import morgan from "morgan";
import request from "request";
import S from "string";

const TM_URL = "http://www.ticketmaster.co.uk";

const app = express();

app.use(morgan("combined"));

const get = request.defaults({
  headers: {
    "User-Agent":
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36",
  },
});

app.get("/venue/:id", (req, res) => {
  return get(
    `${TM_URL}/json/search/event?vid=${req.params.id}`,
    (error, response, body) => {
      if (error || response.statusCode === !200) {
        res.sendStatus(500);
        return;
      }
      const cal = new ical.iCalendar();
      const { response: resp } = JSON.parse(body);
      for (const i of resp.docs) {
        const event = new ical.VEvent();
        event.setDate(i.EventDate, i.EventDate, true);
        event.setDescription(S(i["search-en"]).decodeHTMLEntities().s);
        event.setLocation(i.VenueName);
        event.setSummary(S(i.EventName).decodeHTMLEntities().s);
        event.addProperty("GEO", i.VenueLatLong);
        event.addProperty("URL", `${TM_URL}${i.AttractionSEOLink}`);
        cal.addComponent(event);
        continue;
      }
      res.contentType("ics");
      return res.send(cal.toString());
    }
  );
});

const server = app.listen(
  process.env.PORT || 8080,
  process.env.IP || "0.0.0.0",
  () => {
    const host = server.address().address;
    const { port } = server.address();
    return console.log("Listening at http://%s:%s", host, port);
  }
);

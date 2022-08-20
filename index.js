require('dotenv').config();
const express = require('express');
const MessagingResponse = require('twilio').twiml.MessagingResponse;
const app = express();
const port = 3000;
const bodyParser = require('body-parser');
const mysql = require('mysql');
const jsonParser = bodyParser.json();
const urlencodedParser = bodyParser.urlencoded({ extended: false });
var con = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_NAME
});

con.connect(function(err) {
    if (err) throw err;
    console.log("Connected to mysql!");
});

const sleep = (milliseconds) => {
    return new Promise(resolve => setTimeout(resolve, milliseconds))
}

const searchDrivers = async (phone, address) => {
    var driverFound = false;
    while (!driverFound) {
        console.log("loop");
        con.query("SELECT * FROM drivers WHERE isdriving IS NULL", function (err, results, fields) {
            if (err) throw err;
            if (results.length > 0) {
                driverFound = true;
                console.log("driver found");
                console.log(results);
                let driver_id = results[0].id;

                con.query(`UPDATE drivers SET isdriving = "${address}" WHERE id = ${driver_id}`, function (err, results, fields) {
                    if (err) throw err;
                });

                

            }
        });
        await sleep(2000);
    }
}

app.get('/', (req, res) => {
  res.send('Hello World!');
});

// webhook for Twilio
app.post('/sms', urlencodedParser, (req, res) => {
    const phone = req.body.From;
    const address = req.body.Body;

    const twiml = new MessagingResponse();
    twiml.message('Thank you for your message! Looking for drivers...');

    searchDrivers(phone, address);

    res.writeHead(200, {'Content-Type': 'text/xml'});
    res.end(twiml.toString());
});

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`);
});
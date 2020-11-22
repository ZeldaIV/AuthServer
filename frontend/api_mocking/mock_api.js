
const https = require('https');
const fs = require('fs');
const responses = require('./api_responses');

const options = {
    key: fs.readFileSync('../Certificates/nginx-selfsigned.key'),
    cert: fs.readFileSync('../Certificates/nginx-selfsigned.crt')
};



https.createServer(options, (req, res) => {
    console.log('Request: ');
    console.log('\tUrl: ', req.url);
    console.log('\tMethod: ', req.method);
    res.setHeader('Access-Control-Allow-Origin', 'https://127.0.0.1:3001');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
    res.setHeader('Access-Control-Allow-Headers', 'X-Requested-With,content-type');

    responses.maybeLoginRequest(req, res);

    responses.maybeGetUserRequest(req, res);

    responses.maybeGetApiResourceRequest(req, res);
    
    console.log('Rsponding with: ')
    console.log('\tstatusCode:', res.statusCode);
    console.log('\theaders:', res.headers);
    console.log('\tbody:', res.body);
    
    if (req.method === 'OPTIONS') {
        console.log('Responding with OK to Options')
        res.writeHead(200);
        res.end();
    }
    
}).listen(3001);


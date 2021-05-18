
exports.maybeLoginRequest = function (req, res) {
    if (req.method === 'POST' && req.url === "/Account") {
        res.writeHead(200, {'Content-Type': 'application/json'});
        res.end();
    }
}

exports.maybeGetUserRequest = function (req, res) {
    if (req.method === 'GET' && req.url === '/Account/user') {
        res.writeHead(200, {'Content-Type': 'text/plain'});
        res.write(JSON.stringify(user));
        res.end();
    }
}

exports.maybeGetApiResourceRequest = function (req, res) {
    if (req.method === "GET" && req.url === "/ApiResource") {
        res.writeHead(200, {'Content-Type': 'application/json'});
        res.write(JSON.stringify(apiResources))
        //res.body = JSON.stringify(apiResources)
        res.end();
    }
}

exports.maybeIsSignedIn = function (req, res) {
    if (req.method === "GET" && req.url === "/Account/isSignedIn") {
        res.writeHead(200, {'Content-Type': 'application/json'});
        //res.write(true)
        res.body = true;
        res.end();
    }
}

const user = {
    userName: "Auser",
    email: "auser@email.com"
}

const apiResources = [
    {
        id: "8880A722-0FF9-4EDB-8ED8-68DC8F29EFD8",
        enabled : true,
        name : "FakeApi",
        displayName : "This is a fake api",
        description : "You cannot use this api for anything",
        apiSecrets : ["a secret"],
        scopes : null,
    },
    {
        id: "AE696620-0738-4CC7-86F0-A1471BC7ABE3",
        enabled : true,
        name : "AnotherFakeApi",
        displayName : "This is yet another fake api",
        description : "You cannot use this api for anything either",
        apiSecrets : null, 
        scopes : ["Ascope"],
    }
]
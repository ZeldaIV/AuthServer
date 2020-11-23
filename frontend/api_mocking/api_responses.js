
exports.maybeLoginRequest = function (req, res) {
    if (req.method === 'POST' && req.url === "/Account") {
        res.writeHead(200, {'Content-Type': 'application/json'});
        res.end();
    }
}

exports.maybeGetUserRequest = function (req, res) {
    if (req.method === 'GET' && req.url === '/Account/user') {
        res.writeHead(200, {'Content-Type': 'text/plain'});
        res.end('\"Auser\"');
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



const apiResources = [
    {
        id: 1,
        enabled : true,
        name : "FakeApi",
        displayName : "This is a fake api",
        description : "You cannot use this api for anything",
        allowedAccessTokenSigningAlgorithms : "unknown",
        showInDiscoveryDocument : true,
        secrets : null, //(Maybe (List ApiResourceSecret)),
        scopes : null, //(Maybe (List ApiResourceScope))
        userClaims : null, // (Maybe (List ApiResourceClaim))
        properties : null, // (Maybe (List ApiResourceProperty))
        created : null, //Maybe (DateTime)
        updated : null, //(Maybe DateTime)
        lastAccessed : null, // (Maybe DateTime)
        nonEditable : false//Maybe (Bool)
    },
    {
        id: 2,
        enabled : true,
        name : "AnotherFakeApi",
        displayName : "This is yet another fake api",
        description : "You cannot use this api for anything either",
        allowedAccessTokenSigningAlgorithms : "unknown",
        showInDiscoveryDocument : true,
        secrets : null, //(Maybe (List ApiResourceSecret)),
        scopes : null, //(Maybe (List ApiResourceScope))
        userClaims : null, // (Maybe (List ApiResourceClaim))
        properties : null, // (Maybe (List ApiResourceProperty))
        created : null, //Maybe (DateTime)
        updated : null, //(Maybe DateTime)
        lastAccessed : null, // (Maybe DateTime)
        nonEditable : false//Maybe (Bool)
    }
]
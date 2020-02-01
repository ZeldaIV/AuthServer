module Login exposing (State, UserInfo, login)


type State
    = Failure
    | Loading
    | Success


type alias UserInfo =
    { userName : String, password : String }


login : UserInfo -> State
login u =
    if u.password == "thingy" then
        Success

    else if u.password == "fail" then
        Failure

    else if u.password == "load" then
        Loading

    else
        Failure

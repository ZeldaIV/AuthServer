module Domain.User exposing (User, decoder, encode)

import Json.Decode as Json
import Json.Encode as Encode


type alias User =
    { name : String
    , email: String
    }


decoder : Json.Decoder User
decoder =
    Json.map2 User
        (Json.field "name" Json.string)
        (Json.field "email" Json.string)


encode : User -> Json.Value
encode user =
    Encode.object
        [ ( "name", Encode.string user.name),
          ("email", Encode.string user.email)
        ]
port module Storage exposing
    ( Storage
    , fromJson
    , load
    , signIn
    , signOut
    )

import Domain.User as User exposing (User)
import Json.Decode as Json
import Json.Encode as Encode


type alias Storage =
    { user : Maybe User }



-- Convert from json


fromJson : Json.Value -> Storage
fromJson value =
    value
        |> Json.decodeValue decoder
        |> Result.withDefault init


decoder : Json.Decoder Storage
decoder =
    Json.map Storage
        (Json.field "storage" (Json.field "user" (Json.maybe User.decoder)))


init : Storage
init =
    { user = Nothing
    }


save : Storage -> Json.Value
save storage =
    Encode.object
        [ ( "user"
          , storage.user
                |> Maybe.map User.encode
                |> Maybe.withDefault Encode.null
          )
        ]



-- UPDATING STORAGE


signIn : User -> Storage -> Cmd msg
signIn user storage =
    saveToLocalStorage { storage | user = Just user }


signOut : Storage -> Cmd msg
signOut storage =
    saveToLocalStorage { storage | user = Nothing }



-- PORTS


saveToLocalStorage : Storage -> Cmd msg
saveToLocalStorage =
    save >> save_


port save_ : Json.Value -> Cmd msg


load : (Storage -> msg) -> Sub msg
load fromStorage =
    load_ (fromJson >> fromStorage)


port load_ : (Json.Value -> msg) -> Sub msg

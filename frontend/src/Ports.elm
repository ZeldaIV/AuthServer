port module Ports exposing (saveUser)

import Json.Decode as Json
import Json.Encode as Encode
import Shared exposing (User)

port outgoing : { action: String, data: Json.Value } -> Cmd msg


saveUser: User -> Cmd msg
saveUser user =
    { action= "save", data= encodeModel user} |> outgoing


encodeModel: User -> Encode.Value
encodeModel user =
    Encode.object [("username", Encode.string user.username)]
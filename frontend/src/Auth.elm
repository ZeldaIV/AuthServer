module Auth exposing
    ( User
    , beforeProtectedInit
    )

{-|

@docs User
@docs beforeProtectedInit

-}

import Domain.User
import ElmSpa.Page as ElmSpa
import Gen.Route exposing (Route)
import Request exposing (Request)
import Shared


type alias User =
    Domain.User.User


beforeProtectedInit : Shared.Model -> Request -> ElmSpa.Protected User Route
beforeProtectedInit { storage } req =
    case storage.user of
        Just user ->
            let
                r =
                    Debug.log "user" user.name
            in
            ElmSpa.Provide user

        Nothing ->
            ElmSpa.RedirectTo Gen.Route.Login

{-
   AuthServer API
   AuthServer Idp

   The version of the OpenAPI document: v1

   NOTE: This file is auto generated by the openapi-generator.
   https://github.com/openapitools/openapi-generator.git
   Do not edit this file manually.
-}


module Request.Account exposing (accountIsSignedInGet, accountLogoutPost, accountPost, accountUserGet)

import Data.UserDto as UserDto exposing (UserDto)
import Data.LoginRequest as LoginRequest exposing (LoginRequest)
import Data.LogoutInputModel as LogoutInputModel exposing (LogoutInputModel)
import Dict
import Http
import Json.Decode as Decode
import Url.Builder as Url




basePath : String
basePath =
    "https://localhost/api"


accountIsSignedInGet :
    { onSend : Result Http.Error Bool -> msg





    }
    -> Cmd msg
accountIsSignedInGet params =
    Http.request
        { method = "GET"
        , headers = List.filterMap identity []
        , url = Url.crossOrigin basePath
            ["Account", "isSignedIn"]
            (List.filterMap identity [])
        , body = Http.emptyBody
        , expect = Http.expectJson params.onSend Decode.bool
        , timeout = Just 30000
        , tracker = Nothing
        }


accountLogoutPost :
    { onSend : Result Http.Error () -> msg


    , body : Maybe LogoutInputModel


    }
    -> Cmd msg
accountLogoutPost params =
    Http.request
        { method = "POST"
        , headers = List.filterMap identity []
        , url = Url.crossOrigin basePath
            ["Account", "logout"]
            (List.filterMap identity [])
        , body = Maybe.withDefault Http.emptyBody <| Maybe.map (Http.jsonBody << LogoutInputModel.encode) params.body
        , expect = Http.expectWhatever params.onSend
        , timeout = Just 30000
        , tracker = Nothing
        }


accountPost :
    { onSend : Result Http.Error () -> msg


    , body : Maybe LoginRequest


    }
    -> Cmd msg
accountPost params =
    Http.request
        { method = "POST"
        , headers = List.filterMap identity []
        , url = Url.crossOrigin basePath
            ["Account"]
            (List.filterMap identity [])
        , body = Maybe.withDefault Http.emptyBody <| Maybe.map (Http.jsonBody << LoginRequest.encode) params.body
        , expect = Http.expectWhatever params.onSend
        , timeout = Just 30000
        , tracker = Nothing
        }


accountUserGet :
    { onSend : Result Http.Error UserDto -> msg





    }
    -> Cmd msg
accountUserGet params =
    Http.request
        { method = "GET"
        , headers = List.filterMap identity []
        , url = Url.crossOrigin basePath
            ["Account", "user"]
            (List.filterMap identity [])
        , body = Http.emptyBody
        , expect = Http.expectJson params.onSend UserDto.decoder
        , timeout = Just 30000
        , tracker = Nothing
        }

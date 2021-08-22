{-
   AuthServer API
   AuthServer Idp

   The version of the OpenAPI document: v1

   NOTE: This file is auto generated by the openapi-generator.
   https://github.com/openapitools/openapi-generator.git
   Do not edit this file manually.
-}


module Request.Clients exposing (clientsGet, clientsPatch, clientsPut)

import Data.ClientDto as ClientDto exposing (ClientDto)
import Dict
import Http
import Json.Decode as Decode
import Url.Builder as Url




basePath : String
basePath =
    "https://localhost/api"


clientsGet :
    { onSend : Result Http.Error (List ClientDto) -> msg





    }
    -> Cmd msg
clientsGet params =
    Http.request
        { method = "GET"
        , headers = List.filterMap identity []
        , url = Url.crossOrigin basePath
            ["Clients"]
            (List.filterMap identity [])
        , body = Http.emptyBody
        , expect = Http.expectJson params.onSend (Decode.list ClientDto.decoder)
        , timeout = Just 30000
        , tracker = Nothing
        }


clientsPatch :
    { onSend : Result Http.Error () -> msg


    , body : Maybe ClientDto


    }
    -> Cmd msg
clientsPatch params =
    Http.request
        { method = "PATCH"
        , headers = List.filterMap identity []
        , url = Url.crossOrigin basePath
            ["Clients"]
            (List.filterMap identity [])
        , body = Maybe.withDefault Http.emptyBody <| Maybe.map (Http.jsonBody << ClientDto.encode) params.body
        , expect = Http.expectWhatever params.onSend
        , timeout = Just 30000
        , tracker = Nothing
        }


clientsPut :
    { onSend : Result Http.Error () -> msg


    , body : Maybe ClientDto


    }
    -> Cmd msg
clientsPut params =
    Http.request
        { method = "PUT"
        , headers = List.filterMap identity []
        , url = Url.crossOrigin basePath
            ["Clients"]
            (List.filterMap identity [])
        , body = Maybe.withDefault Http.emptyBody <| Maybe.map (Http.jsonBody << ClientDto.encode) params.body
        , expect = Http.expectWhatever params.onSend
        , timeout = Just 30000
        , tracker = Nothing
        }

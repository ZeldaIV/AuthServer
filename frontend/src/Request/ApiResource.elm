{-
   AuthServer API
   AuthServer Idp

   The version of the OpenAPI document: v1

   NOTE: This file is auto generated by the openapi-generator.
   https://github.com/openapitools/openapi-generator.git
   Do not edit this file manually.
-}


module Request.ApiResource exposing (apiResourceGet, apiResourcePost)

import Data.ApiResourceDto as ApiResourceDto exposing (ApiResourceDto)
import Dict
import Http
import Json.Decode as Decode
import Url.Builder as Url




basePath : String
basePath =
    "https://localhost:3001"


apiResourceGet :
    { onSend : Result Http.Error (List ApiResourceDto) -> msg





    }
    -> Cmd msg
apiResourceGet params =
    Http.request
        { method = "GET"
        , headers = List.filterMap identity []
        , url = Url.crossOrigin basePath
            ["ApiResource"]
            (List.filterMap identity [])
        , body = Http.emptyBody
        , expect = Http.expectJson params.onSend (Decode.list ApiResourceDto.decoder)
        , timeout = Just 30000
        , tracker = Nothing
        }


apiResourcePost :
    { onSend : Result Http.Error () -> msg


    , body : Maybe ApiResourceDto


    }
    -> Cmd msg
apiResourcePost params =
    Http.request
        { method = "POST"
        , headers = List.filterMap identity []
        , url = Url.crossOrigin basePath
            ["ApiResource"]
            (List.filterMap identity [])
        , body = Maybe.withDefault Http.emptyBody <| Maybe.map (Http.jsonBody << ApiResourceDto.encode) params.body
        , expect = Http.expectWhatever params.onSend
        , timeout = Just 30000
        , tracker = Nothing
        }

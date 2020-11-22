{-
   AuthServer API
   AuthServer Idp

   The version of the OpenAPI document: v1

   NOTE: This file is auto generated by the openapi-generator.
   https://github.com/openapitools/openapi-generator.git
   Do not edit this file manually.
-}


module Data.ApiResourceScope exposing (ApiResourceScope, decoder, encode, encodeWithTag, toString)

import Data.ApiResource as ApiResource exposing (ApiResource)
import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode


type alias ApiResourceScope =
    { id : Maybe (Int)
    , scope : (Maybe String)
    , apiResourceId : Maybe (Int)
    , apiResource : Maybe (ApiResource)
    }


decoder : Decoder ApiResourceScope
decoder =
    Decode.succeed ApiResourceScope
        |> optional "id" (Decode.nullable Decode.int) Nothing
        |> optional "scope" (Decode.nullable Decode.string) Nothing
        |> optional "apiResourceId" (Decode.nullable Decode.int) Nothing
        |> optional "apiResource" (Decode.nullable ApiResource.decoder) Nothing



encode : ApiResourceScope -> Encode.Value
encode =
    Encode.object << encodePairs


encodeWithTag : ( String, String ) -> ApiResourceScope -> Encode.Value
encodeWithTag (tagField, tag) model =
    Encode.object <| encodePairs model ++ [ ( tagField, Encode.string tag ) ]


encodePairs : ApiResourceScope -> List (String, Encode.Value)
encodePairs model =
    [ ( "id", Maybe.withDefault Encode.null (Maybe.map Encode.int model.id) )
    , ( "scope", Maybe.withDefault Encode.null (Maybe.map Encode.string model.scope) )
    , ( "apiResourceId", Maybe.withDefault Encode.null (Maybe.map Encode.int model.apiResourceId) )
    , ( "apiResource", Maybe.withDefault Encode.null (Maybe.map ApiResource.encode model.apiResource) )
    ]



toString : ApiResourceScope -> String
toString =
    Encode.encode 0 << encode





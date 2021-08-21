{-
   AuthServer API
   AuthServer Idp

   The version of the OpenAPI document: v1

   NOTE: This file is auto generated by the openapi-generator.
   https://github.com/openapitools/openapi-generator.git
   Do not edit this file manually.
-}


module Data.ApiResourceDto exposing (ApiResourceDto, decoder, encode, encodeWithTag, toString)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode


type alias ApiResourceDto =
    { id : Maybe Int
    , enabled : Maybe Bool
    , name : Maybe String
    , displayName : Maybe String
    , description : Maybe String
    , apiSecrets : Maybe (List String)
    , scopes : Maybe (List String)
    }


decoder : Decoder ApiResourceDto
decoder =
    Decode.succeed ApiResourceDto
        |> optional "id" (Decode.nullable Decode.int) Nothing
        |> optional "enabled" (Decode.nullable Decode.bool) Nothing
        |> optional "name" (Decode.nullable Decode.string) Nothing
        |> optional "displayName" (Decode.nullable Decode.string) Nothing
        |> optional "description" (Decode.nullable Decode.string) Nothing
        |> optional "apiSecrets" (Decode.nullable (Decode.list Decode.string)) Nothing
        |> optional "scopes" (Decode.nullable (Decode.list Decode.string)) Nothing


encode : ApiResourceDto -> Encode.Value
encode =
    Encode.object << encodePairs


encodeWithTag : ( String, String ) -> ApiResourceDto -> Encode.Value
encodeWithTag ( tagField, tag ) model =
    Encode.object <| encodePairs model ++ [ ( tagField, Encode.string tag ) ]


encodePairs : ApiResourceDto -> List ( String, Encode.Value )
encodePairs model =
    [ ( "id", Maybe.withDefault Encode.null (Maybe.map Encode.int model.id) )
    , ( "enabled", Maybe.withDefault Encode.null (Maybe.map Encode.bool model.enabled) )
    , ( "name", Maybe.withDefault Encode.null (Maybe.map Encode.string model.name) )
    , ( "displayName", Maybe.withDefault Encode.null (Maybe.map Encode.string model.displayName) )
    , ( "description", Maybe.withDefault Encode.null (Maybe.map Encode.string model.description) )
    , ( "apiSecrets", Maybe.withDefault Encode.null (Maybe.map (Encode.list Encode.string) model.apiSecrets) )
    , ( "scopes", Maybe.withDefault Encode.null (Maybe.map (Encode.list Encode.string) model.scopes) )
    ]


toString : ApiResourceDto -> String
toString =
    Encode.encode 0 << encode

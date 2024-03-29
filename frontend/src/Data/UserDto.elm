{-
   AuthServer API
   AuthServer Idp

   The version of the OpenAPI document: v1

   NOTE: This file is auto generated by the openapi-generator.
   https://github.com/openapitools/openapi-generator.git
   Do not edit this file manually.
-}


module Data.UserDto exposing (UserDto, decoder, encode, encodeWithTag, toString)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode


type alias UserDto =
    { id : (Maybe String)
    , userName : (Maybe String)
    , email : (Maybe String)
    , emailConfirmed : Maybe (Bool)
    , phoneNumber : (Maybe String)
    , phoneNumberConfirmed : Maybe (Bool)
    , twoFactorEnabled : Maybe (Bool)
    }


decoder : Decoder UserDto
decoder =
    Decode.succeed UserDto
        |> optional "id" (Decode.nullable Decode.string) Nothing
        |> optional "userName" (Decode.nullable Decode.string) Nothing
        |> optional "email" (Decode.nullable Decode.string) Nothing
        |> optional "emailConfirmed" (Decode.nullable Decode.bool) Nothing
        |> optional "phoneNumber" (Decode.nullable Decode.string) Nothing
        |> optional "phoneNumberConfirmed" (Decode.nullable Decode.bool) Nothing
        |> optional "twoFactorEnabled" (Decode.nullable Decode.bool) Nothing



encode : UserDto -> Encode.Value
encode =
    Encode.object << encodePairs


encodeWithTag : ( String, String ) -> UserDto -> Encode.Value
encodeWithTag (tagField, tag) model =
    Encode.object <| encodePairs model ++ [ ( tagField, Encode.string tag ) ]


encodePairs : UserDto -> List (String, Encode.Value)
encodePairs model =
    [ ( "id", Maybe.withDefault Encode.null (Maybe.map Encode.string model.id) )
    , ( "userName", Maybe.withDefault Encode.null (Maybe.map Encode.string model.userName) )
    , ( "email", Maybe.withDefault Encode.null (Maybe.map Encode.string model.email) )
    , ( "emailConfirmed", Maybe.withDefault Encode.null (Maybe.map Encode.bool model.emailConfirmed) )
    , ( "phoneNumber", Maybe.withDefault Encode.null (Maybe.map Encode.string model.phoneNumber) )
    , ( "phoneNumberConfirmed", Maybe.withDefault Encode.null (Maybe.map Encode.bool model.phoneNumberConfirmed) )
    , ( "twoFactorEnabled", Maybe.withDefault Encode.null (Maybe.map Encode.bool model.twoFactorEnabled) )
    ]



toString : UserDto -> String
toString =
    Encode.encode 0 << encode





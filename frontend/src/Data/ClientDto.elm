{-
   AuthServer API
   AuthServer Idp

   The version of the OpenAPI document: v1

   NOTE: This file is auto generated by the openapi-generator.
   https://github.com/openapitools/openapi-generator.git
   Do not edit this file manually.
-}


module Data.ClientDto exposing (ClientDto, AllowedGrantTypes(..), decoder, encode, encodeWithTag, toString)

import DateTime exposing (DateTime)
import DateTime exposing (DateTime)
import DateTime exposing (DateTime)
import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode


type alias ClientDto =
    { id : (Maybe Int)
    , clientId : (Maybe String)
    , enabled : Maybe (Bool)
    , clientName : (Maybe String)
    , description : (Maybe String)
    , clientUri : (Maybe String)
    , logoUri : (Maybe String)
    , clientSecrets : (Maybe (List String))
    , allowedGrantTypes : (Maybe (List AllowedGrantTypes))
    , redirectUris : (Maybe (List String))
    , allowedScopes : (Maybe (List String))
    , postLogoutRedirectUris : (Maybe (List String))
    , created : Maybe (DateTime)
    , updated : (Maybe DateTime)
    , lastAccessed : (Maybe DateTime)
    }


type AllowedGrantTypes
    = NotSet
    | Implicit
    | ImplicitAndClientCredentials
    | Code
    | CodeAndClientCredentials
    | Hybrid
    | HybridAndClientCredentials
    | ClientCredentials
    | ResourceOwnerPassword
    | ResourceOwnerPasswordAndClientCredentials
    | DeviceFlow



decoder : Decoder ClientDto
decoder =
    Decode.succeed ClientDto
        |> optional "id" (Decode.nullable Decode.int) Nothing
        |> optional "clientId" (Decode.nullable Decode.string) Nothing
        |> optional "enabled" (Decode.nullable Decode.bool) Nothing
        |> optional "clientName" (Decode.nullable Decode.string) Nothing
        |> optional "description" (Decode.nullable Decode.string) Nothing
        |> optional "clientUri" (Decode.nullable Decode.string) Nothing
        |> optional "logoUri" (Decode.nullable Decode.string) Nothing
        |> optional "clientSecrets" (Decode.nullable (Decode.list Decode.string)) Nothing
        |> optional "allowedGrantTypes" (Decode.nullable (Decode.list allowedGrantTypesDecoder)) Nothing
        |> optional "redirectUris" (Decode.nullable (Decode.list Decode.string)) Nothing
        |> optional "allowedScopes" (Decode.nullable (Decode.list Decode.string)) Nothing
        |> optional "postLogoutRedirectUris" (Decode.nullable (Decode.list Decode.string)) Nothing
        |> optional "created" (Decode.nullable DateTime.decoder) Nothing
        |> optional "updated" (Decode.nullable DateTime.decoder) Nothing
        |> optional "lastAccessed" (Decode.nullable DateTime.decoder) Nothing



encode : ClientDto -> Encode.Value
encode =
    Encode.object << encodePairs


encodeWithTag : ( String, String ) -> ClientDto -> Encode.Value
encodeWithTag (tagField, tag) model =
    Encode.object <| encodePairs model ++ [ ( tagField, Encode.string tag ) ]


encodePairs : ClientDto -> List (String, Encode.Value)
encodePairs model =
    [ ( "id", Maybe.withDefault Encode.null (Maybe.map Encode.int model.id) )
    , ( "clientId", Maybe.withDefault Encode.null (Maybe.map Encode.string model.clientId) )
    , ( "enabled", Maybe.withDefault Encode.null (Maybe.map Encode.bool model.enabled) )
    , ( "clientName", Maybe.withDefault Encode.null (Maybe.map Encode.string model.clientName) )
    , ( "description", Maybe.withDefault Encode.null (Maybe.map Encode.string model.description) )
    , ( "clientUri", Maybe.withDefault Encode.null (Maybe.map Encode.string model.clientUri) )
    , ( "logoUri", Maybe.withDefault Encode.null (Maybe.map Encode.string model.logoUri) )
    , ( "clientSecrets", Maybe.withDefault Encode.null (Maybe.map (Encode.list Encode.string) model.clientSecrets) )
    , ( "allowedGrantTypes", Maybe.withDefault Encode.null (Maybe.map (Encode.list encodeAllowedGrantTypes) model.allowedGrantTypes) )
    , ( "redirectUris", Maybe.withDefault Encode.null (Maybe.map (Encode.list Encode.string) model.redirectUris) )
    , ( "allowedScopes", Maybe.withDefault Encode.null (Maybe.map (Encode.list Encode.string) model.allowedScopes) )
    , ( "postLogoutRedirectUris", Maybe.withDefault Encode.null (Maybe.map (Encode.list Encode.string) model.postLogoutRedirectUris) )
    , ( "created", Maybe.withDefault Encode.null (Maybe.map DateTime.encode model.created) )
    , ( "updated", Maybe.withDefault Encode.null (Maybe.map DateTime.encode model.updated) )
    , ( "lastAccessed", Maybe.withDefault Encode.null (Maybe.map DateTime.encode model.lastAccessed) )
    ]



toString : ClientDto -> String
toString =
    Encode.encode 0 << encode




allowedGrantTypesDecoder : Decoder AllowedGrantTypes
allowedGrantTypesDecoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "NotSet" ->
                        Decode.succeed NotSet

                    "Implicit" ->
                        Decode.succeed Implicit

                    "ImplicitAndClientCredentials" ->
                        Decode.succeed ImplicitAndClientCredentials

                    "Code" ->
                        Decode.succeed Code

                    "CodeAndClientCredentials" ->
                        Decode.succeed CodeAndClientCredentials

                    "Hybrid" ->
                        Decode.succeed Hybrid

                    "HybridAndClientCredentials" ->
                        Decode.succeed HybridAndClientCredentials

                    "ClientCredentials" ->
                        Decode.succeed ClientCredentials

                    "ResourceOwnerPassword" ->
                        Decode.succeed ResourceOwnerPassword

                    "ResourceOwnerPasswordAndClientCredentials" ->
                        Decode.succeed ResourceOwnerPasswordAndClientCredentials

                    "DeviceFlow" ->
                        Decode.succeed DeviceFlow

                    other ->
                        Decode.fail <| "Unknown type: " ++ other
            )



encodeAllowedGrantTypes : AllowedGrantTypes -> Encode.Value
encodeAllowedGrantTypes model =
    case model of
        NotSet ->
            Encode.string "NotSet"

        Implicit ->
            Encode.string "Implicit"

        ImplicitAndClientCredentials ->
            Encode.string "ImplicitAndClientCredentials"

        Code ->
            Encode.string "Code"

        CodeAndClientCredentials ->
            Encode.string "CodeAndClientCredentials"

        Hybrid ->
            Encode.string "Hybrid"

        HybridAndClientCredentials ->
            Encode.string "HybridAndClientCredentials"

        ClientCredentials ->
            Encode.string "ClientCredentials"

        ResourceOwnerPassword ->
            Encode.string "ResourceOwnerPassword"

        ResourceOwnerPasswordAndClientCredentials ->
            Encode.string "ResourceOwnerPasswordAndClientCredentials"

        DeviceFlow ->
            Encode.string "DeviceFlow"





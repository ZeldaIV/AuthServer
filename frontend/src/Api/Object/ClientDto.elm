-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.Object.ClientDto exposing (..)

import Api.InputObject
import Api.Interface
import Api.Object
import Api.Scalar
import Api.Union
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode
import ScalarCodecs


{-| -}
id : SelectionSet ScalarCodecs.Uuid Api.Object.ClientDto
id =
    Object.selectionForField "ScalarCodecs.Uuid" "id" [] (ScalarCodecs.codecs |> Api.Scalar.unwrapCodecs |> .codecUuid |> .decoder)


{-| -}
clientId : SelectionSet String Api.Object.ClientDto
clientId =
    Object.selectionForField "String" "clientId" [] Decode.string


{-| -}
clientSecret : SelectionSet String Api.Object.ClientDto
clientSecret =
    Object.selectionForField "String" "clientSecret" [] Decode.string


{-| -}
displayName : SelectionSet String Api.Object.ClientDto
displayName =
    Object.selectionForField "String" "displayName" [] Decode.string


{-| -}
displayNames : SelectionSet (Maybe (List String)) Api.Object.ClientDto
displayNames =
    Object.selectionForField "(Maybe (List String))" "displayNames" [] (Decode.string |> Decode.list |> Decode.nullable)


{-| -}
permissions : SelectionSet (List String) Api.Object.ClientDto
permissions =
    Object.selectionForField "(List String)" "permissions" [] (Decode.string |> Decode.list)


{-| -}
postLogoutRedirectUris : SelectionSet (List String) Api.Object.ClientDto
postLogoutRedirectUris =
    Object.selectionForField "(List String)" "postLogoutRedirectUris" [] (Decode.string |> Decode.list)


{-| -}
redirectUris : SelectionSet (List String) Api.Object.ClientDto
redirectUris =
    Object.selectionForField "(List String)" "redirectUris" [] (Decode.string |> Decode.list)


{-| -}
type_ : SelectionSet String Api.Object.ClientDto
type_ =
    Object.selectionForField "String" "type" [] Decode.string


{-| -}
requirePkce : SelectionSet Bool Api.Object.ClientDto
requirePkce =
    Object.selectionForField "Bool" "requirePkce" [] Decode.bool


{-| -}
requireConsent : SelectionSet Bool Api.Object.ClientDto
requireConsent =
    Object.selectionForField "Bool" "requireConsent" [] Decode.bool

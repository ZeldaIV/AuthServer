-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.Object.ScopeDto exposing (..)

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


id : SelectionSet ScalarCodecs.Uuid Api.Object.ScopeDto
id =
    Object.selectionForField "ScalarCodecs.Uuid" "id" [] (ScalarCodecs.codecs |> Api.Scalar.unwrapCodecs |> .codecUuid |> .decoder)


{-| -}
name : SelectionSet String Api.Object.ScopeDto
name =
    Object.selectionForField "String" "name" [] Decode.string


{-| -}
displayName : SelectionSet String Api.Object.ScopeDto
displayName =
    Object.selectionForField "String" "displayName" [] Decode.string


description : SelectionSet String Api.Object.ScopeDto
description =
    Object.selectionForField "String" "description" [] Decode.string


{-| -}
resources : SelectionSet (List String) Api.Object.ScopeDto
resources =
    Object.selectionForField "(List String)" "resources" [] (Decode.string |> Decode.list)
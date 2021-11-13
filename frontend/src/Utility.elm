module Utility exposing (..)

import Api.Scalar exposing (DateTime, Uuid(..))
import Graphql.Http
import Graphql.Http.GraphqlError exposing (GraphqlError)
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet exposing (SelectionSet)
import Http exposing (Error(..))
import Random
import RemoteData exposing (RemoteData(..))
import Uuid



--toStringDateTime:  DateTime -> String
--toStringDateTime d =
--       case d of
--           DateTime string ->
--               string
--
--toStringFromMaybeDateTime: Maybe DateTime -> String
--toStringFromMaybeDateTime d =
--    case d of
--        Just a ->
--            toStringDateTime a
--
--        Nothing ->
--            ""


graphqlErrorToString : GraphqlError -> String
graphqlErrorToString err =
    err.message


type RequestState a
    = RequestSuccess a
    | State String
    | RequestError String


response : RemoteData (Graphql.Http.RawError a Http.Error) a -> RequestState a
response result =
    case result of
        NotAsked ->
            State "Waiting"

        Loading ->
            State "Loading"

        Failure e ->
            case e of
                Graphql.Http.GraphqlError _ graphqlErrors ->
                    RequestError (List.foldr (++) "" (List.map graphqlErrorToString graphqlErrors))

                Graphql.Http.HttpError httpError ->
                    case httpError of
                        BadUrl string ->
                            RequestError string

                        Timeout ->
                            RequestError "Timeout"

                        NetworkError ->
                            RequestError "Network error"

                        BadStatus int ->
                            RequestError ("Bad status: " ++ String.fromInt int)

                        BadBody string ->
                            RequestError ("Bad body: " ++ string)

        Success a ->
            RequestSuccess a


uuidToString : Uuid -> String
uuidToString u =
    case u of
        Uuid string ->
            string


graphQLUrl : String
graphQLUrl =
    "https://localhost/graphql"


makeGraphQLMutation : SelectionSet decodesTo RootMutation -> (Result (Graphql.Http.Error decodesTo) decodesTo -> msg) -> Cmd msg
makeGraphQLMutation mutation decodesTo =
    mutation
        |> Graphql.Http.mutationRequest graphQLUrl
        |> Graphql.Http.send decodesTo


makeGraphQLQuery : SelectionSet decodesTo RootQuery -> (Result (Graphql.Http.Error decodesTo) decodesTo -> msg) -> Cmd msg
makeGraphQLQuery query decodesTo =
    query
        |> Graphql.Http.queryRequest graphQLUrl
        |> Graphql.Http.send decodesTo

module Utility exposing (..)

import Api.Scalar
import Graphql.Http
import Graphql.Http.GraphqlError exposing (GraphqlError)
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Http exposing (Error(..))
import RemoteData exposing (RemoteData(..))
import ScalarCodecs exposing (DateTime)
import Uuid exposing (Uuid)


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


uuidToString : ScalarCodecs.Uuid -> String
uuidToString (Api.Scalar.Uuid u) =
    u


uuidToApiUuid : Uuid -> ScalarCodecs.Uuid
uuidToApiUuid uuid =
    Api.Scalar.Uuid (Uuid.toString uuid)


optionalList : List a -> OptionalArgument (List a)
optionalList resources =
    case resources of
        [] ->
            Absent

        _ ->
            Present resources


optionalString : String -> OptionalArgument String
optionalString s =
    let
        str =
            String.trim s
    in
    case str of
        "" ->
            Absent

        _ ->
            Present s


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

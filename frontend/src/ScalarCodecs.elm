module ScalarCodecs exposing (..)

import Api.Scalar exposing (DateTime(..), EmailAddress)
import Graphql.Internal.Builder.Object as Object
import Json.Decode as Decode
import Json.Encode as Encode


type alias DateTime =
    Api.Scalar.DateTime


type alias Uuid =
    String


type alias Port =
    Int


type alias EmailAddress =
    String


codecs : Api.Scalar.Codecs DateTime EmailAddress Int String
codecs =
    Api.Scalar.defineCodecs
        { codecDateTime =
            { encoder = \(DateTime raw) -> Encode.string raw
            , decoder = Object.scalarDecoder |> Decode.map DateTime
            }
        , codecUuid =
            { encoder = \uuid -> uuid |> Encode.string
            , decoder = Decode.string
            }
        , codecPort =
            { encoder = \raw -> String.fromInt raw |> Encode.string
            , decoder =
                Decode.string
                    |> Decode.map String.toInt
                    |> Decode.andThen
                        (\maybeParsedPort ->
                            case maybeParsedPort of
                                Just parsedPort ->
                                    Decode.succeed parsedPort

                                Nothing ->
                                    Decode.fail "Could not parse Port as an Int."
                        )
            }
        , codecEmailAddress =
            { encoder = \email -> email |> Encode.string
            , decoder = Decode.string
            }
        }

module ScalarCodecs exposing (..)

import Api.Scalar exposing (DateTime(..), Uuid(..))
import Graphql.Internal.Builder.Object as Object
import Json.Decode as Decode
import Json.Encode as Encode


type alias DateTime =
    Api.Scalar.DateTime


type alias Uuid =
    String


codecs : Api.Scalar.Codecs DateTime Uuid
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
        }

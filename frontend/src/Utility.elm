module Utility exposing (fromMaybe)


fromMaybe : Maybe a -> a -> a
fromMaybe value defaultValue =
    case value of
        Just a ->
            a

        Nothing ->
            defaultValue

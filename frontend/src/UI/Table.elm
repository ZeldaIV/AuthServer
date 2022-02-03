module UI.Table exposing (..)

import Element exposing (Attribute, fill, height, maximum, padding, px, spacing, width)
import Element.Border as Border
import Element.Font as Font
import UI.Color exposing (color)


columnAttributes : List (Attribute msg)
columnAttributes =
    [ width <| maximum 1000 fill
    , height <| px 300
    , spacing 10
    , padding 1
    , Border.width 2
    , Border.rounded 3
    , Border.color color.black
    ]


headerAttributes : List (Attribute msg)
headerAttributes =
    [ Font.bold
    , Font.color color.black
    , Border.widthEach { bottom = 2, top = 0, left = 0, right = 0 }
    ]

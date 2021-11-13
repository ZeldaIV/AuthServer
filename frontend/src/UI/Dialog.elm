module UI.Dialog exposing (..)

import Element exposing (Element, centerX, centerY, column, fill, height, px, width)
import Element.Background as Background
import Element.Border as Border
import UI.Color exposing (color)


view : List (Element msg) -> Element msg
view elements =
    let
        dialogAttrs =
            [ Background.color color.white
            , Border.width 1
            , Border.color color.black
            , width <| px 500
            , height <| px 500
            , centerY
            , centerX
            ]

        background =
            column [ width fill, height fill, Background.color color.lightGreyOpaq ]
    in
    background
        [ column dialogAttrs
            elements
        ]

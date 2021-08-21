module UI.Button exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import UI.Color exposing (color)


button : { msg : msg, textContent : String, enabled : Bool } -> Element msg
button { msg, textContent, enabled } =
    let
        theMsg =
            if enabled then
                Just msg

            else
                Nothing

        mouseDownAttrs =
            if enabled then
                [ Background.color color.blue
                , Border.color color.blue
                , Font.color color.white
                ]

            else
                []

        mouseOverAttrs =
            if enabled then
                [ Background.color color.white
                , Border.color color.lightGrey
                ]

            else
                []

        backgroundColor =
            if enabled then
                color.lightBlue

            else
                color.white

        borderColor =
            if enabled then
                color.blue

            else
                color.white
    in
    Input.button
        [ padding 10
        , Border.width 3
        , Border.rounded 5
        , Border.color borderColor
        , Background.color backgroundColor
        , mouseDown mouseDownAttrs
        , mouseOver mouseOverAttrs
        ]
        { onPress = theMsg
        , label = text textContent
        }

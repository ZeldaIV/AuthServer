module UI.Button exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import UI.Color exposing (color)


confirmButton : { msg : msg, label : String, enabled : Bool } -> Element msg
confirmButton { msg, label, enabled } =
    let
        theMsg =
            if enabled then
                Just msg

            else
                Nothing

        mouseDownAttrs =
            if enabled then
                [ Background.color color.blue
                ]

            else
                []

        mouseOverAttrs =
            if enabled then
                [ --Background.color color.lightGrey
                  Border.shadow { offset = ( 1, 1 ), size = 0.5, blur = 10, color = color.black }
                ]

            else
                []

        backgroundColor =
            if enabled then
                color.blue

            else
                color.lightGrey
    in
    Input.button
        [ height <| minimum 40 fill
        , width <| minimum 150 fill
        , padding 3
        , Background.color backgroundColor
        , Font.color color.white
        , Font.center
        , Font.size 14
        , Element.height Element.shrink
        , Element.width Element.shrink
        , Element.paddingXY 16 8
        , Border.rounded 2
        , Border.solid
        , Border.widthXY 1 1
        , Border.color backgroundColor
        , mouseDown mouseDownAttrs
        , mouseOver mouseOverAttrs
        ]
        { onPress = theMsg
        , label = text label
        }


cancelButton : { msg : msg, label : String, enabled : Bool } -> Element msg
cancelButton { msg, label, enabled } =
    let
        theMsg =
            if enabled then
                Just msg

            else
                Nothing

        mouseDownAttrs =
            if enabled then
                [ Background.color color.red
                , Border.color color.red
                ]

            else
                []

        mouseOverAttrs =
            if enabled then
                [ Border.shadow { offset = ( 1, 1 ), size = 0.5, blur = 10, color = color.black }
                , Background.color color.darkRed
                ]

            else
                []

        backgroundColor =
            if enabled then
                color.red

            else
                color.lightGrey
    in
    Input.button
        [ height <| minimum 40 fill
        , width <| minimum 150 fill
        , padding 3
        , Background.color backgroundColor
        , Font.color color.white
        , Font.center
        , Element.height Element.shrink
        , Element.width Element.shrink
        , Element.paddingXY 16 8
        , Border.rounded 2
        , Border.color backgroundColor
        , Border.solid
        , Border.widthXY 1 1
        , mouseDown mouseDownAttrs
        , mouseOver mouseOverAttrs
        ]
        { onPress = theMsg
        , label = text label
        }

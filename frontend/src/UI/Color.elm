module UI.Color exposing (color)

import Element exposing (rgb255, rgba255)


color =
    { blue = rgb255 52 101 164
    , darkBlue = rgb255 0 50 255
    , lightBlue = rgb255 0 141 255
    , lighterGrey = rgb255 219 219 219
    , lightGrey = rgb255 192 192 192
    , lightGreyOpaq = rgba255 192 192 192 0.5
    , grey = rgb255 121 121 121
    , white = rgb255 255 255 255
    , black = rgb255 0 0 0
    , red = rgb255 219 65 63
    , lightRed = rgb255 255 61 0
    , darkRed = rgb255 255 0 0
    }

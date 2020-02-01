module Main exposing (main)

import Bootstrap.Button as Button
import Bootstrap.CDN as CDN
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Form.Input as Input
import Bootstrap.Form.InputGroup as InputGroup
import Bootstrap.Grid as Grid
import Browser
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)



-- MAIN


main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Model =
    { username : String, password : String }


init : Model
init =
    { username = "", password = "" }



-- UPDATE


type Msg
    = Username String
    | Password String


update : Msg -> Model -> Model
update msg model =
    case msg of
        Username name ->
            { model | username = name }

        Password password ->
            { model | password = password }



-- VIEW


view : Model -> Html Msg
view model =
    Grid.container []
        [ CDN.stylesheet -- creates an inline style node with the Bootstrap CSS
        , Grid.row []
            [ Grid.col []
                [ Card.config [ Card.outlinePrimary ]
                    |> Card.headerH4 [] [ text "Log In" ]
                    |> Card.block []
                        [ Block.text [] [ text model.username ]
                        , Block.custom <|
                            InputGroup.view <|
                                InputGroup.config
                                    (InputGroup.text [ Input.placeholder "username", Input.value model.username, Input.onInput Username ])
                        , Block.custom <|
                            InputGroup.view <|
                                InputGroup.config
                                    (InputGroup.password [ Input.placeholder "password" ])
                        , Block.custom <|
                            Button.linkButton
                                [ Button.primary, Button.attrs [ href "#modules" ] ]
                                [ text "Module" ]
                        ]
                    |> Card.view
                ]
            ]
        ]

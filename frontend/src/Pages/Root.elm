module Pages.Root exposing (root)

import Bootstrap.Button as Button
import Bootstrap.CDN as CDN
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Browser.Navigation as Nav
import Html exposing (Html, text)
import Html.Attributes exposing (..)
import Route as Route


init : Nav.Key -> Model
init key =
    { userName = "", password = "", key = key }


type State
    = Failure
    | Loading
    | Success


type alias UserInfo =
    { userName : String, password : String }


login : UserInfo -> State
login u =
    if u.password == "thingy" then
        Success

    else if u.password == "fail" then
        Failure

    else if u.password == "load" then
        Loading

    else
        Failure


stateToString : State -> String
stateToString state =
    case state of
        Failure ->
            "Failure"

        Loading ->
            "Loading"

        Success ->
            "Success"


type alias Model =
    { username : String, password : String, key : Nav.Key }


type Msg
    = Username String
    | Password String
    | Submit


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Username name ->
            ( { model | username = name }, Cmd.none )

        Password password ->
            ( { model | password = password }, Cmd.none )

        Submit ->
            let
                r =
                    login { userName = model.username, password = model.password }
            in
            --Debug.log ("submit was pressed: " ++ stateToString r)
            case r of
                Failure ->
                    Debug.log ("submit was pressed: " ++ stateToString r)
                        ( model, Cmd.none )

                Success ->
                    Debug.log ("submit was pressed: " ++ stateToString r)
                        ( model, Route.replaceUrl model.key Route.Home )

                Loading ->
                    Debug.log ("submit was pressed: " ++ stateToString r)
                        ( model, Cmd.none )


root : Model -> Html Msg
root model =
    Grid.container []
        [ CDN.stylesheet -- creates an inline style node with the Bootstrap CSS
        , Grid.row []
            [ Grid.col []
                [ Card.config [ Card.outlinePrimary ]
                    |> Card.headerH4 [] [ text "Log In" ]
                    |> Card.block []
                        [ Block.text [] [ text model.username ]
                        , Block.custom <|
                            Form.form
                                []
                                [ Form.group []
                                    [ Form.label [ for "myemail" ] [ text "Email address" ]
                                    , Input.email [ Input.id "myemail", Input.value model.username, Input.onInput Username ]
                                    , Input.password [ Input.id "myPass", Input.value model.password, Input.onInput Password ]
                                    , Form.help [] [ text "We'll never share your email with anyone else." ]
                                    , Button.button [ Button.primary, Button.onClick Submit ] [ text "Submit" ]
                                    ]
                                ]
                        ]
                    |> Card.view
                ]
            ]
        ]

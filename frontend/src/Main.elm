module Main exposing (main)

import Bootstrap.Button as Button
import Bootstrap.CDN as CDN
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Form.InputGroup as InputGroup
import Bootstrap.Grid as Grid
import Browser
import Browser.Navigation as Nav
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Login exposing (State, UserInfo, login)
import Url


type State
    = Failure
    | Loading
    | Success


stateToString : State -> String
stateToString state =
    case state of
        Failure ->
            "Failure"

        Loading ->
            "Loading"

        Success ->
            "Success"


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



-- MAIN


main : Program () Model Msg
main =
    Browser.application { init = init, view = view, update = update, subscriptions = subscriptions, onUrlChange = UrlChanged, onUrlRequest = LinkClicked }



-- MODEL


type alias Model =
    { username : String, password : String, key : Nav.Key, url : Url.Url }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( { username = "", password = "", key = key, url = url }, Cmd.none )



-- UPDATE


type Msg
    = Username String
    | Password String
    | Submit State
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Username name ->
            ( { model | username = name }, Cmd.none )

        Password password ->
            ( { model | password = password }, Cmd.none )

        Submit state ->
            Debug.log ("submit was pressed: " ++ stateToString state)
                ( model, Cmd.none )

        --case state of
        --    Failure -> Debug.log "Failed "
        --        ( model, Cmd.none )
        --    Success ->Debug.log "success "
        --        ( model, Cmd.none )
        --    Loading -> Debug.log "loading: "
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            Debug.log (Url.toString url)
                ( { model | url = url }, Cmd.none )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Something"
    , body =
        [ Grid.container []
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
                                        , Button.button [ Button.primary, Button.onClick (Submit (login { userName = model.username, password = model.password })) ] [ text "Submit" ]
                                        ]
                                    ]
                            ]
                        |> Card.view
                    ]
                ]
            ]
        ]
    }

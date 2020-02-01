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
import Pages.Root as Root
import Url



-- MAIN


main : Program () Model Msg
main =
    Browser.application { init = init, view = view, update = update, subscriptions = subscriptions, onUrlChange = UrlChanged, onUrlRequest = LinkClicked }



-- MODEL


type alias Model =
    { key : Nav.Key, url : Url.Url }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( { key = key, url = url }, Cmd.none )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
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
        [ Root.root model.key
        ]
    }

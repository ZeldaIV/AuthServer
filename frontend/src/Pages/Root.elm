module Pages.Root exposing (Msg, init, update, view, Model)

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
import Skeleton


init : Nav.Key -> ( Model, Cmd msg )
init key =
    ( Model "" "" key
    , Cmd.none
    )


type State
    = Failure
    | Loading
    | Success
    

login : Model -> State
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
     {username: String, password: String, key: Nav.Key}

-- UPDATE


type Msg
    = Username String
    | Password String
    | Submit


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Username name ->
            updateForm {model | username = name}

        Password password ->
            updateForm {model | password = password}

        Submit ->
            let
                r =
                    login { username = model.username, password = model.password, key= model.key }
            in
            case r of
                Failure ->
                    Debug.log ("submit was pressed: " ++ stateToString r)
                        ( model, Cmd.none )

                Success ->
                    Debug.log ("submit was pressed: " ++ stateToString r)
                        ( model, Cmd.none )

                Loading ->
                    Debug.log ("submit was pressed: " ++ stateToString r)
                        ( model, Cmd.none )


{-| Helper function for `update`. Updates the form and returns Cmd.none.
Useful for recording form fields!
-}
updateForm : Model -> ( Model, Cmd Msg )
updateForm  model =
    (model , Cmd.none )



-- VIEW


view : Model -> Skeleton.Details Msg
view model =
    { title = "Login"
    , header =" yoyoy"
    , attrs = []
    , kids = [
        viewRoot model
            ]
    }

viewRoot : Model -> Html Msg
viewRoot model =
    Grid.container []
                [ CDN.stylesheet -- creates an inline style node with the Bootstrap CSS
                , Grid.row []
                    [ Grid.col []
                        [ Card.config [ Card.outlinePrimary ]
                            |> Card.headerH4 [] [ text "Log In" ]
                            |> Card.block []
                                [ Block.text [] [ text model.username ]
                                , Block.custom <|
                                    viewForm model
                                ]
                            |> Card.view
                        ]
                    ]
                ]
     


viewForm : Model -> Html Msg
viewForm form =
    Form.form
        []
        [ Form.group []
            [ Form.label [ for "myemail" ] [ text "Email address" ]
            , Input.email [ Input.id "myemail", Input.value form.username, Input.onInput Username ]
            , Input.password [ Input.id "myPass", Input.value form.password, Input.onInput Password ]
            , Form.help [] [ text "We'll never share your email with anyone else." ]
            , Button.button [ Button.primary, Button.onClick Submit ] [ text "Submit" ]
            ]
        ]

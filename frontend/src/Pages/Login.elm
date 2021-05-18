module Pages.Login exposing (Model, Msg, page)
import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Data.LoginRequest exposing (LoginRequest)
import Data.UserDto exposing (UserDto)
import Domain.User exposing (User)
import Gen.Params.Login exposing (Params)
import Gen.Route
import Html exposing (Html, text)
import Html.Attributes exposing (for)
import Http
import Page
import Request exposing (Request)
import Request.Account as Account

import Shared
import Storage exposing (Storage)
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.element
        { init = init
        , update = update shared.storage req
        , view = view
        , subscriptions = subscriptions
        }
        
-- INIT

type alias Model =
    { form: Form
    }
    
type alias Form =
    { username : String
    , password : String
    }
    


init: ( Model, Cmd Msg )
init =
    ( { form = Form "" "" }, Cmd.none )

mapModelToLoginRequest: Form -> LoginRequest
mapModelToLoginRequest login =
    { username= (Just login.username)
    , password= (Just login.password)
    , returnUrl= (Just "")
    }
    
loginCompleted : Result Http.Error () -> Cmd Msg
loginCompleted result =
    case result of
        Ok _ ->
            Account.accountUserGet { onSend = getUserCompleted }
            
        Err _ ->
            Cmd.none
            -- TODO: Handle error

unwrapUser: UserDto -> User
unwrapUser dto =
    User (maybeStringToString dto.userName) (maybeStringToString dto.email)

maybeStringToString: Maybe String -> String
maybeStringToString s =
    case s of
        Just res -> res
        Nothing -> ""

getUserCompleted : Result Http.Error UserDto -> Msg
getUserCompleted result = 
    case result of
        Ok val ->
            GotUser (unwrapUser val)
        Err _ ->
            GotUser (User "" "")

-- UPDATE


type Msg
    = SetUsername String
    | SetPassword String
    | OnLogin Form
    | LoginCompleted (Result Http.Error ())
    | GotUser User


update: Storage -> Request -> Msg -> Model -> ( Model, Cmd Msg )
update storage req msg model =
    case msg of
        SetUsername username ->
            let
                form = model.form
            in
                ({model | form = {form | username = username} }, Cmd.none)
    
        SetPassword password ->
            let
                form = model.form
            in
            ({model | form = { form | password = password }}, Cmd.none)
    
        OnLogin login ->
            (model, Account.accountPost { onSend = LoginCompleted, body = Just (mapModelToLoginRequest login)})
    
        LoginCompleted result ->
            (model, loginCompleted result)

        GotUser user ->
             (model,
             Cmd.batch [
                Storage.signIn {name = user.name, email = user.email} storage,
                Request.replaceRoute Gen.Route.Applications req
                ])


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Login"
    , body = [Grid.container []
                  [ Grid.row []
                      [ Grid.col [Col.xs2]
                          [ Card.config [ Card.outlinePrimary ]
                              |> Card.headerH4 [] [ text "Log In" ]
                              |> Card.block []
                                  [ Block.custom <|
                                      loginForm model.form 
                                  ]
                              |> Card.view
                          ]
                      ]
                  ]]
    }

loginForm : Form -> Html Msg
loginForm form =
    Form.form []
        [ Form.group []
            [ Form.label [ for "email" ] [ text "Email address" ]
            , Input.email [ Input.id "email", Input.value form.username, Input.onInput SetUsername ]
            , Input.password [ Input.id "password", Input.value form.password, Input.onInput SetPassword ]
            , Form.help [] [ text "We'll never share your email with anyone else." ]
            , Button.button [ Button.primary, Button.onClick (OnLogin form)  ] [ text "Submit" ]
            ]
        ]
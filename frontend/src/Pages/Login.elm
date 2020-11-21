module Pages.Login exposing (Params, Model, Msg, page)

import Api exposing (send)
import Api.Data exposing (LoginRequest)
import Api.Request.Account as Account
import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Html exposing (Html, text)
import Html.Attributes exposing (for)
import Http
import Shared exposing (User)
import Spa.Document exposing (Document)
import Spa.Page as Page exposing (Page)
import Spa.Url exposing (Url)


page : Page Params Model Msg
page =
    Page.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , save = save
        , load = load
        }

mapModelToLoginRequest: Form -> LoginRequest
mapModelToLoginRequest login =
    { username= (Just login.username)
    , password= (Just login.password)
    , returnUrl= (Just "")
    }    

performLogin: Maybe Api.Data.LoginRequest -> Api.Request ()
performLogin login =
    Account.accountPost login

loginUser: LoginRequest -> Cmd Msg
loginUser data =
    send LoginCompleted (performLogin <| Just data)
    
getUser: Cmd Msg
getUser =
    send GetUserCompleted Account.accountUserGet
    
loginCompleted : Model -> Result Http.Error () -> (Model, Cmd Msg )
loginCompleted model result =
    case result of
        Ok _ ->
             (model |> Debug.log "User logged in", getUser)
            
        Err _ ->
            ( model |> Debug.log "Could not login", Cmd.none )
            -- TODO: Handle error
            
getUserCompleted : Model -> Result Http.Error String -> (Model, Cmd Msg)
getUserCompleted model result = 
    case result of
        Ok _ ->
            (model, Cmd.none)
            -- TODO: Handle success
        Err _ ->
            ( model|> Debug.log "Error getting user: ", Cmd.none)
            -- TODO: Handle error

-- INIT


type alias Params =
    ()


type alias Model =
    { form: Form,
     user: Maybe User }
    
type alias Form =
    { username : String
    , password : String
    }
    


init : Shared.Model -> Url Params -> ( Model, Cmd Msg )
init shared { params } =
    ( {form = Form "" "", user= shared.user }, Cmd.none )



-- UPDATE


type Msg
    = SetUsername String
    | SetPassword String
    | OnLogin Form
    | LoginCompleted (Result Http.Error ())
    | GetUserCompleted (Result Http.Error String)
    | SaveUser User


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
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
            (model, loginUser <| mapModelToLoginRequest login)
    
        LoginCompleted result ->
            loginCompleted model result
        
        GetUserCompleted result -> 
            getUserCompleted model result
        
        SaveUser user ->
            ( {model | user = Just user} , Cmd.none)


save : Model -> Shared.Model -> Shared.Model
save model shared =
    { shared | user = model.user }


load : Shared.Model -> Model -> ( Model, Cmd Msg )
load shared model =
    ( { model | user = shared.user} , Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Login"
    , body = [Grid.container []
                  [ Grid.row []
                      [ Grid.col []
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
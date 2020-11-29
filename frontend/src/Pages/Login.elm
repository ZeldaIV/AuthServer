module Pages.Login exposing (Params, Model, Msg, page)
import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Browser.Navigation as Nav
import Data.LoginRequest exposing (LoginRequest)
import Html exposing (Html, text)
import Html.Attributes exposing (for)
import Http
import Ports
import Request.Account as Account
import Shared exposing (User)
import Spa.Document exposing (Document)
import Spa.Generated.Route as Route
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
        
-- INIT


type alias Params =
    ()


type alias Model =
    { form: Form
    , user: Maybe User
    , isSignedIn: Bool
    , key: Nav.Key}
    
type alias Form =
    { username : String
    , password : String
    }
    


init : Shared.Model -> Url Params -> ( Model, Cmd Msg )
init shared { params }  =
    ( {form = Form "" "", user= shared.user, isSignedIn = shared.isSignedIn, key = shared.key }, Cmd.none )        
        
save : Model -> Shared.Model -> Shared.Model
save model shared =
    { shared | user = model.user, isSignedIn = model.isSignedIn }


load : Shared.Model -> Model -> ( Model, Cmd Msg )
load shared model =
    ( { model | user = shared.user, isSignedIn = shared.isSignedIn}, Cmd.none )

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
            Account.accountIsSignedInGet { onSend = getUserIsSignedInCompleted }
            
        Err _ ->
            Cmd.none
            -- TODO: Handle error
            
getUserCompleted : Result Http.Error String -> Msg
getUserCompleted result = 
    case result of
        Ok val ->
            GotUser (User val)
        Err _ ->
            GotUser (User "")
            
getUserIsSignedInCompleted : Result Http.Error Bool -> Msg
getUserIsSignedInCompleted result = 
    case result of
        Ok val ->
            IsSignedIn val
        Err _ ->
            IsSignedIn False -- TODO: Handle error

-- UPDATE


type Msg
    = SetUsername String
    | SetPassword String
    | OnLogin Form
    | LoginCompleted (Result Http.Error ())
    | GotUser User
    | IsSignedIn Bool


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
            (model, Account.accountPost { onSend = LoginCompleted, body = Just (mapModelToLoginRequest login)})
    
        LoginCompleted result ->
            (model, loginCompleted result)
            
        IsSignedIn val ->
            ({model | isSignedIn = val}, 
                if (val) then
                    Nav.replaceUrl model.key (Route.toString Route.Applications)
                else
                    Cmd.none)
                
        GotUser user ->
             ({ model | user = Just user }, Cmd.batch 
             [Ports.saveUser user
             , Nav.replaceUrl model.key (Route.toString Route.Applications)])


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
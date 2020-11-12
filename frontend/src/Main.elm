port module Main exposing (..)

import Api exposing (Request)
import Api.Data exposing (LoginRequest)
import Api.Request.Account as Account
import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Navbar as Navbar
import Bootstrap.ButtonGroup as ButtonGroup
import Bootstrap.ListGroup as ListGroup
import Bootstrap.Table as Table
import Browser
import Browser.Navigation as Nav
import Debug exposing (toString)
import Html exposing (Attribute, Html, a, div, h1, h2, h3, p, s, text)
import Html.Attributes exposing (class, for, href, id)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf)

    
main : Program (Decode.Value) Model Msg
main =
    Browser.application { 
    init = init, 
    view = view,
    update = update,
    subscriptions = \_ -> Sub.none, 
    onUrlChange = UrlChanged, 
    onUrlRequest = LinkClicked }      
    
    
init : Decode.Value -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init json url key =
    let
        ( navbarState, navbarCmd ) =
            Navbar.initialState NavMsg
    in
    (initializeModel json navbarState url key, navbarCmd)
    
            
            
initializeModel: Decode.Value -> Navbar.State -> Url.Url -> Nav.Key -> Model
initializeModel json  =
    case Decode.decodeValue modelDecoder json of
        Ok ml ->
            toModel ml
        Err error ->
            Model (Login "" "")  (UserState "" "" False "" LoginPage) (toString error) |> Debug.log "Oh no an error occured, well it does not matter"
             

type alias Login = 
    { userName : String
    , password : String
    }

type alias UserState = 
    { userName: String
    , userId: String
    , loggedIn: Bool
    , url: String
    , page: Page
    }
            
type alias Model =
    { login: Login
    , userState: UserState
    , errorMsg: String
    , navBarState: Navbar.State
    , url: Url.Url
    , key: Nav.Key
    }
            
type Page 
    = LoginPage
    | ClientsPage
    | UsersPage

   
port setStorage : Encode.Value -> Cmd msg

port removeStorage : Encode.Value -> Cmd msg

-- Call Api    
send: (Result Http.Error a -> msg) -> Request a -> Cmd msg
send toMsg request =
    request
        |> Api.withBasePath ""
        |> Api.send toMsg

encodeModel: Model -> Encode.Value
encodeModel model =
    Encode.object [
        ("username", Encode.string model.userState.userName),
        ("userId", Encode.string model.userState.userId),
        ("url", Encode.string model.url.path),
        ("page", Encode.string (pageToString model.userState.page))
    ]

toModel: UserState -> Navbar.State -> Url.Url -> Nav.Key -> Model
toModel ui =
    Model (Login "" "") (UserState ui.userName ui.userId False "" ui.page) ""   


pageToString: Page -> String
pageToString page =
    case page of
        LoginPage ->
            "LoginPage"
        ClientsPage ->
            "ClientsPage"
        UsersPage ->
            "UsersPage"

stringToPage: String -> Decoder Page
stringToPage page =
    case page of
        "LoginPage" ->
            Decode.succeed LoginPage
        "ClientsPage" ->
            Decode.succeed ClientsPage
        "UsersPage" ->
            Decode.succeed UsersPage
        _ ->
            Decode.succeed LoginPage
    
modelDecoder: Decoder UserState
modelDecoder =
    (Decode.map5 UserState
        (field "username" Decode.string)
        (field "userId" Decode.string)
        (field "loggedIn" Decode.bool)
        (field "url" Decode.string)
        (field "page" Decode.string |> andThen stringToPage))
        
        

setStorageHelper : Model -> ( Model, Cmd Msg )
setStorageHelper model =
    ( model, encodeModel model |> setStorage)
    
performLogin: Maybe Api.Data.LoginRequest -> Api.Request ()
performLogin login =
    Account.accountPost login

loginUser: LoginRequest -> Cmd Msg
loginUser data =
    send LoginCompleted (performLogin <| Just data)

getUser: Cmd Msg
getUser =
    send GetUserCompleted Account.accountUserGet
    
loginCompleted : Model -> Result Http.Error () -> ( Model, Cmd Msg )
loginCompleted model result =
    case result of
        Ok _ ->
            let
                login = model.login
                newLogin = { login | password = "", userName = "" }
                userState = model.userState
                newState = { userState | loggedIn = True}
            in
             ({ model | userState = newState, login = newLogin, errorMsg = "" } |> Debug.log "User logged in", getUser)
            
        Err error ->
            let 
                userState = model.userState
                newState = { userState | loggedIn = False}
            in
                ( { model | userState = newState, errorMsg = (toString error) } |> Debug.log "Could not login", Cmd.none )
            
getUserCompleted : Model -> Result Http.Error String -> (Model, Cmd Msg)
getUserCompleted model result = 
    case result of
        Ok userId ->
            let
                userState = model.userState
                newState = { userState | userId = userId}
            in
                setStorageHelper ({ model | userState = newState} |> Debug.log "User is ")
        
        Err error ->
            ({ model | errorMsg = (toString error)} |> Debug.log "Error getting user: ", Cmd.none)
            
--Messages
            
type Msg
    = SetUsername String
    | SetPassword String
    | OnLogin Login
    | LoginCompleted (Result Http.Error ())
    | GetUserCompleted (Result Http.Error String)
    | SaveToCache Model
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | NavMsg Navbar.State
    | ClickMe
    
    
-- Update

update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model |> Debug.log "Internal: ", Nav.pushUrl model.key <| Url.toString url )
        
                Browser.External href ->
                    ( model |> Debug.log "External: ", Nav.load href )
        
        UrlChanged url ->
            urlUpdate url model

        SetUsername username ->
            let
                login = model.login
                newState = { login | userName = username}
            in
            ({model | login = newState}, Cmd.none)

        SetPassword password ->
            let
                login = model.login
                newState = { login | password = password}
            in
            ({model | login = newState}, Cmd.none)

        OnLogin login ->
            (model |> Debug.log "Hello: ", loginUser <| mapModelToLoginRequest login)

        LoginCompleted result ->
            loginCompleted model result
        
        GetUserCompleted result -> 
            getUserCompleted model result
        
        SaveToCache m ->
            (m, setStorage (encodeModel m))
        
        NavMsg state ->
            ( { model | navBarState = state }, Cmd.none )
        
        ClickMe ->
            ( model |> Debug.log "Hello", Cmd.none)

urlUpdate: Url -> Model -> (Model, Cmd Msg)
urlUpdate url model =
    case decode url of
            Nothing ->
                let
                    userState = model.userState
                    newUserState = { userState | page = LoginPage}
                in
                    ({ model | userState = newUserState }, Cmd.none )
    
            Just route ->
                let
                    userState = model.userState
                    newUserState = { userState | page = route}
                in
                    ({ model | userState = newUserState }, Cmd.none )
        
decode: Url -> Maybe Page
decode url =
    { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
        |> Parser.parse routeParser
        
routeParser : Parser (Page -> a) a
routeParser =
    Parser.oneOf
        [ Parser.map LoginPage (Parser.s "login")
        , Parser.map ClientsPage (Parser.s "clients")
        , Parser.map UsersPage (Parser.s "users")
        ]


mapModelToLoginRequest: Login -> LoginRequest
mapModelToLoginRequest login =
    { username= (Just login.userName)
    , password= (Just login.password)
    , returnUrl= (Just "")
    }


-- View          
            
view: Model -> Browser.Document Msg
view model =
    let         
        -- If the user is logged in, show a greeting; if logged out, show the login/register form
        mainView =
            let
                -- If there is an error on authentication, show the error alert
                showError : String
                showError =
                    if String.isEmpty model.errorMsg then
                        "hidden"
                    else
                        ""

                -- Greet a logged in user by username
                greeting : String
                greeting =
                    "Hello, " ++ model.userState.userName ++ "!"
                  
            in
                if model.userState.loggedIn then
                    [menu model,
                    mainContent model]
                else
                    [Grid.container []
                        [ Grid.row []
                            [ Grid.col []
                                [ Card.config [ Card.outlinePrimary ]
                                    |> Card.headerH4 [] [ text "Log In" ]
                                    |> Card.block []
                                        [ Block.custom <|
                                            loginForm model.login
                                        ]
                                    |> Card.view
                                ]
                            ]
                        ] ]
    in
        { title =
              "Main"
          , body = mainView
          }

menu : Model -> Html Msg
menu model =
    Navbar.config NavMsg
        |> Navbar.withAnimation
        |> Navbar.container
        |> Navbar.brand [] [ text "Auth server" ]
        |> Navbar.items
            [ Navbar.itemLink [ href "#clients" ] [ text "Clients" ]
            , Navbar.itemLink [ href "#users" ] [ text "Users" ]
            ]
        |> Navbar.view model.navBarState

mainContent: Model -> Html Msg
mainContent model = 
    Grid.container [] <|
        case model.userState.page of
            LoginPage ->
                [loginForm model.login]

            ClientsPage ->
                clientsView model

            UsersPage ->
                usersView model
        
        
clientsView: Model -> List (Html Msg)
clientsView model =
    [ Grid.container []
        [ h1 [] [ text "Registered clients" ]
        , Table.table 
            { options = [ Table.striped, Table.hover ]
            , thead = Table.simpleThead 
                [ Table.th [] [ text "Col 1" ]
                , Table.th [] [ text "Col 2"]
                ]
            , tbody = 
                Table.tbody [] 
                [ Table.tr [ Table.rowAttr (href "Something") ] 
                  [ Table.td [] [ text "Hello" ]
                  , Table.td [] [ text "Hello" ]
                  , Table.td [] [ text "Hello" ]
                  ]
              , Table.tr []
                  [ Table.td [] [ text "There" ]
                  , Table.td [] [ text "There" ]
                  , Table.td [] [ text "There" ]
                  ]
                ]
            } 
        ]
    ] 
        
clientView: Model -> List (Html Msg)
clientView _ =
    [ h1 [] [text "Clients"]
    , Grid.container []
        [Grid.row []
            [ Grid.col [] 
                [ ListGroup.custom 
                    [ ListGroup.button [] [ text "1 button"] 
                    , ListGroup.button [] [text "2 button"]
                    , ListGroup.button [] [text "3 button"]
                    ]
                ]
            , Grid.col [] [ text "YOYOYO"]
            ]
        ]
    ]
    
usersView: Model -> List (Html Msg)
usersView _ =
    [ h1 [] [ text "Registered users"]
    , Table.table 
        { options = [ Table.striped, Table.hover ]
      , thead = Table.simpleThead 
          [ Table.th [] [ text "Col 1" ]
          , Table.th [] [ text "Col 2"]
          ]
      , tbody = 
          Table.tbody [] 
          [ Table.tr [ Table.rowAttr (onClick ClickMe) ] 
            [ Table.td [] [ text "Hello" ]
            , Table.td [] [ text "Hello" ]
            , Table.td [] [ text "Hello" ]
            ]
        , Table.tr []
            [ Table.td [] [ text "There" ]
            , Table.td [] [ text "There" ]
            , Table.td [] [ text "There" ]
            ]
          ]
      } 
    ]
    
pageUsers: Model -> List (Html Msg)
pageUsers _ =
    [ h1 [] [text "Users"]
     , Grid.container []
       [Grid.row []
           [ Grid.col [] 
               [ ButtonGroup.buttonGroup [ButtonGroup.vertical]
                   [ ButtonGroup.button [Button.primary] [ text "1 button"] 
                   , ButtonGroup.button [Button.primary] [text "2 button"]
                   ]
                    
               ]
           , Grid.col [] [ text "YOYOYO"]
           ]
       ]
     ]


loginForm : Login -> Html Msg
loginForm form =
    Form.form []
        [ Form.group []
            [ Form.label [ for "myemail" ] [ text "Email address" ]
            , Input.email [ Input.id "myemail", Input.value form.userName, Input.onInput SetUsername ]
            , Input.password [ Input.id "myPass", Input.value form.password, Input.onInput SetPassword ]
            , Form.help [] [ text "We'll never share your email with anyone else." ]
            , Button.button [ Button.primary, Button.onClick (OnLogin <| Login form.userName form.password)  ] [ text "Submit" ]
            ]
        ]       
        
        
                 
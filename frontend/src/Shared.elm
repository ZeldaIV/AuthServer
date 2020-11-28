module Shared exposing
    ( Flags
    , Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    , User
    )

import Bootstrap.Navbar as Navbar
import Browser.Navigation as Nav exposing (Key)
import Html exposing (Html, div, text)
import Html.Attributes exposing (class, href)
import Http exposing (Error)
import Json.Decode as Decode exposing (Decoder, field)
import Request.Account as Account
import Spa.Document exposing (Document)
import Spa.Generated.Route as Route
import Url exposing (Url)



-- INIT


type alias Flags =
    Decode.Value

type alias User = 
    { username: String
    }

type alias Model =
    { url : Url
    , key : Key
    , navBarState : Navbar.State
    , user: Maybe User
    , isSignedIn: Bool
    }


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    let
        ( navbarState, navbarCmd ) =
            Navbar.initialState NavMsg
    in
    case Decode.decodeValue userStateDecoder flags of
        Ok value ->
            ( Model url key navbarState (Just value) False
            , navbarCmd
            )            
        
        Err _ ->
            ( Model url key navbarState Nothing False
            , navbarCmd
            )                  
              
userStateDecoder: Decoder User
userStateDecoder =
    (Decode.map User
        (field "username" Decode.string) )
       

signedInResult: Result Error Bool -> Msg
signedInResult result =
    case result of
        Ok value ->
            IsSignedIn value
        Err _ ->
            IsSignedIn False -- TODO: Handle errors 
    

-- UPDATE


type Msg
    = NavMsg Navbar.State
    | OnSignin User
    | OnSignOut
    | IsSignedIn Bool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of    
        NavMsg state ->
            ( { model | navBarState = state }, Account.accountIsSignedInGet { onSend = signedInResult } )

        OnSignin user ->
            ( { model | user = Just user }, Cmd.none )
        OnSignOut ->
            ( { model | user = Nothing }, Cmd.none )

        IsSignedIn signedIn ->
            ( {model | isSignedIn = signedIn}, 
             if signedIn then
                Cmd.none
             else
                (Nav.pushUrl model.key (Route.toString Route.Login))
             )
            
            


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view :
    { page : Document msg, toMsg : Msg -> msg }
    -> Model
    -> Document msg
view { page, toMsg } model =
    { title = page.title
    , body =
        if model.isSignedIn then
            [ Html.map toMsg (menu model)
                , div [ class "page" ] page.body
            ]
        else
            page.body 
    }

menu : Model -> Html Msg
menu model =
    Navbar.config NavMsg
        |> Navbar.withAnimation
        |> Navbar.brand [] [ text "Auth server" ]
        |> Navbar.items
            [ Navbar.itemLink [ href (Route.toString Route.Applications) ] [ text "Applications" ]
            , Navbar.itemLink [ href (Route.toString Route.Users) ] [ text "Users" ]
            ]
        |> Navbar.view model.navBarState


            
module Shared exposing
    ( Flags
    , Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Bootstrap.Navbar as Navbar
import Data.ApiResourceDto exposing (ApiResourceDto)
import Gen.Route
import Html exposing (Html, div, text)
import Html.Attributes exposing (class, href)
import Json.Decode as Decode exposing (Decoder)
import Request exposing (Request)
import Storage exposing (Storage)
import View exposing (View)


-- INIT
type alias Flags =
    Decode.Value

type alias Model =
    { navBarState : Navbar.State
    , storage: Storage
    , apiResources: Maybe (List ApiResourceDto)
    }


init : Request -> Flags -> ( Model, Cmd Msg )
init req flags =
    let
        ( navbarState, navbarCmd ) =
                    Navbar.initialState NavMsg

        model =
            { navBarState = navbarState
            , storage = Storage.fromJson flags
            , apiResources = Nothing
            }
    in
    ( model
    , if model.storage.user /= Nothing && req.route == Gen.Route.Login then
       Request.replaceRoute Gen.Route.Login req
      else
       navbarCmd
     )

-- UPDATE
type Msg
    = NavMsg Navbar.State
    | SignOut
    | StorageUpdated Storage


update : Request -> Msg -> Model -> ( Model, Cmd Msg )
update _ msg model =
    case msg of    
        NavMsg state ->
            ( { model | navBarState = state }, Cmd.none )
        SignOut ->
            ( model, Storage.signOut model.storage )
        StorageUpdated storage ->
            ( {model | storage = storage} , Cmd.none)
            

-- VIEW
view : Request
    -> { page : View msg, toMsg : Msg -> msg }
    -> Model
    -> View msg
view _ { page, toMsg } model =
    { title = page.title
    , body =
        [ Html.map toMsg (menu model)
        , div [ class "page" ] page.body
        ]
        --if model.storage.user /= Nothing then
        --    [ Html.map toMsg (menu model)
        --        , div [ class "page" ] page.body
        --    ]
        --else
        --    page.body
    }

menu : Model -> Html Msg
menu model =
    Navbar.config NavMsg
        |> Navbar.withAnimation
        |> Navbar.brand [] [ text "Auth server" ]
        |> Navbar.items
            [ Navbar.itemLink [ href (Gen.Route.toHref Gen.Route.Applications) ] [ text "Applications" ]
            , Navbar.itemLink [ href (Gen.Route.toHref Gen.Route.Users) ] [ text "Users" ]
            ]
        |> Navbar.view model.navBarState

subscriptions : Request -> Model -> Sub Msg
subscriptions _ _ =
    Storage.load StorageUpdated
module Shared exposing
    ( Flags
    , Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Bootstrap.Button as Button
import Bootstrap.Navbar as Navbar
import Dict
import Gen.Route
import Html exposing (Html, div, text)
import Html.Attributes exposing (class, href)
import Json.Decode as Decode exposing (Decoder)
import Random
import Request exposing (Request)
import Storage exposing (Storage)
import Url exposing (Protocol(..), Url)
import Url.Parser as Parser
import Url.Parser.Query exposing (Parser, map, string)
import Uuid
import View exposing (View)



-- INIT


type alias Flags =
    Decode.Value


type alias Model =
    { navBarState : Navbar.State
    , storage : Storage
    , seed : Random.Seed
    , uuid : String
    , returnUrl : String
    }


redirect_uri : String -> Parser String
redirect_uri s =
    map (Maybe.withDefault "") (string s)


parseQuery : String -> String -> String
parseQuery query what =
    Maybe.withDefault "" (Parser.parse (Parser.query (redirect_uri what)) (toUrl query))


toUrl : String -> Url
toUrl s =
    { path = "/"
    , query = Just s
    , host = "/"
    , protocol = Https
    , port_ = Just 0
    , fragment = Just ""
    }


init : Request -> Flags -> ( Model, Cmd Msg )
init req flags =
    let
        ( navbarState, navbarCmd ) =
            Navbar.initialState NavMsg

        returnUrl =
            case req.url.query of
                Just q ->
                    parseQuery q "ReturnUrl"

                Nothing ->
                    "/applications"

        c =
            Debug.log "==>" returnUrl

        model =
            { navBarState = navbarState
            , storage = Storage.fromJson flags
            , seed = Random.initialSeed 431234234 -- so we dont have to deal with Maybe
            , uuid = ""
            , returnUrl = returnUrl
            }
    in
    ( model
    , if model.storage.user /= Nothing && req.route == Gen.Route.Login then
        Request.replaceRoute Gen.Route.Login req

      else
        Debug.log "Batching"
            Cmd.batch
            [ navbarCmd, Random.generate GenerateNewUuid Random.independentSeed ]
    )



-- UPDATE


type Msg
    = NavMsg Navbar.State
    | SignOut
    | StorageUpdated Storage
    | GenerateNewUuid Random.Seed


update : Request -> Msg -> Model -> ( Model, Cmd Msg )
update _ msg model =
    case msg of
        NavMsg state ->
            ( { model | navBarState = state }, Cmd.none )

        SignOut ->
            ( model, Storage.signOut model.storage )

        StorageUpdated storage ->
            ( { model | storage = storage }, Cmd.none )

        GenerateNewUuid seed ->
            let
                ( newId, newSeed ) =
                    Random.step Uuid.uuidGenerator seed
            in
            ( { model | seed = newSeed, uuid = Uuid.toString newId }, Cmd.none )



-- VIEW


view :
    Request
    -> { page : View msg, toMsg : Msg -> msg }
    -> Model
    -> View msg
view _ { page, toMsg } model =
    { title = page.title
    , body =
        if model.storage.user /= Nothing then
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
            [ Navbar.itemLink [ href (Gen.Route.toHref Gen.Route.Applications) ] [ text "Applications" ]
            , Navbar.itemLink [ href (Gen.Route.toHref Gen.Route.Users) ] [ text "Users" ]
            , Navbar.itemLink [ href (Gen.Route.toHref Gen.Route.Scopes) ] [ text "Scopes" ]
            ]
        |> Navbar.customItems
            [ Navbar.customItem (Button.button [ Button.secondary, Button.onClick SignOut ] [ text "Sign out" ])
            ]
        |> Navbar.view model.navBarState


subscriptions : Request -> Model -> Sub Msg
subscriptions _ _ =
    Storage.load StorageUpdated

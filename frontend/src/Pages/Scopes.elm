module Pages.Scopes exposing (Model, Msg, page)

import Page
import Shared
import View exposing (View)
import Element exposing (..)
import Element.Input as Input
import Html exposing (Html)
import Request exposing (Request)
import UI.Button exposing (button)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Request.Scopes exposing (scopesPut)
import Http exposing (Error)
import Data.ScopeDto exposing (ScopeDto)
import Request.Scopes exposing (scopesGet)
import Utility exposing (fromMaybe)

page : Shared.Model -> Request -> Page.With Model Msg
page _ _ =
    Page.protected.element
        (\_ ->
            { init = init
            , update = update
            , view = view
            , subscriptions = subscriptions
            }
        )



-- INIT

type alias Scope =
    { name : String
    , displayName: String
    }

type alias Model =
    { scope: Scope
    , scopes: (List Scope)
    }


initialScope: Scope
initialScope =
    Scope "" ""

init : ( Model, Cmd Msg )
init =
    ( { scope = initialScope, scopes = []}, scopesGet { onSend = gotScopes } )



-- UPDATE

scopesSent : Result Error Bool -> Msg
scopesSent result =
    case result of
        Ok _ ->
            Success

        Err _ ->
            RequestFailed "An error occured, adding a scope"

fromdtoToModel : ScopeDto -> Scope
fromdtoToModel dto =
    { name = fromMaybe dto.name ""
    , displayName = fromMaybe dto.displayName ""
    }

gotScopes : Result Error (List ScopeDto) -> Msg
gotScopes result =
    case result of
        Ok scopes ->
            GotNewScopes (List.map fromdtoToModel scopes)
        
        Err _ ->
            RequestFailed "An error occured retrieving scopes"


fromModelToDto: Scope -> ScopeDto
fromModelToDto s =
    { name = Just s.name
    , displayName = Just s.displayName
    }

type Msg
    = Update Scope
    | AddScope Scope
    | GotNewScopes (List Scope)
    | Success
    | RequestFailed String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Update scope ->
            ({model | scope = scope}, Cmd.none)
        
        AddScope scope ->
            let
                scopes = model.scopes ++ [scope]
            in
            ({model | scopes = scopes, scope = initialScope }, scopesPut { onSend = scopesSent, body = Just (fromModelToDto scope)})

        Success ->
            (model, scopesGet { onSend = gotScopes })

        RequestFailed _ ->
            (model, Cmd.none)

        GotNewScopes scopes ->
            ({ model | scopes = scopes}, Cmd.none)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


scopeValid: Scope -> Bool
scopeValid scope =
    String.length scope.name > 3


-- VIEW

scopesInputView: Model -> Element Msg
scopesInputView model = 
    let scope = model.scope
    in
    row [ spacing 30, centerX] 
    [ Input.text [ width <| maximum 300 fill ]
        { onChange = \new -> Update {scope | name = new}
        , text = scope.name
        , placeholder= Just <| Input.placeholder [] <| text "Scope name"
        , label = Input.labelHidden "Scope name"
        }
    , Input.text [ width <| maximum 300 fill ]
        { onChange = \new -> Update {scope | displayName = new}
        , text = scope.displayName
        , placeholder= Just <| Input.placeholder [] <| text "Scope display name"
        , label = Input.labelHidden "Scope display name"
        }
    , button { msg = AddScope scope, textContent = "Add", enabled = scopeValid scope }
    ]

scopesTable : Model -> Element msg
scopesTable model =
    let
        headerAttrs =
            [ Font.bold
            , Font.color (rgb255 0x72 0x9F 0xCF)
            , Border.widthEach { bottom = 1, top = 0, left = 0, right = 0 }
            ]
    in
    table [ width <| maximum 1200 <| minimum 1000 fill, spacingXY 0 10 ]
        { data = model.scopes
        , columns =
            [ { header = el headerAttrs <| Element.text "Scope name"
              , width = fill
              , view =
                    \scope ->
                        Element.text scope.name
              }
            , { header = el headerAttrs <| Element.text "Display name"
              , width = fill
              , view =
                    \scope ->
                        Element.text scope.displayName
              }
            ]
        }

scopesView: Model -> List (Html Msg)
scopesView model =
    [layout [ width fill, height fill] <|
        column [width fill, spacing 40 ]
            [ scopesInputView model
            , el [ centerX ] (scopesTable model)
            ]
    ]

view : Model -> View Msg
view model =
    { title = "Scopes"
    , body = scopesView model    
    }

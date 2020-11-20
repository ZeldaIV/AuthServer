module Pages.Users exposing (Params, Model, Msg, page)

import Bootstrap.Button as Button
import Bootstrap.ButtonGroup as ButtonGroup
import Bootstrap.Grid as Grid
import Bootstrap.Table as Table
import Html exposing (Html, h1, text)
import Html.Events exposing (onClick)
import Spa.Document exposing (Document)
import Spa.Page as Page exposing (Page)
import Spa.Url as Url exposing (Url)


page : Page Params Model Msg
page =
    Page.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Params =
    ()


type alias Model =
    {}


init : Url Params -> ( Model, Cmd Msg )
init { params } =
    ( {}, Cmd.none )



-- UPDATE


type Msg
    = ClickMe


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickMe ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Users"
    , body = usersView
    }
    
usersView: List (Html Msg)
usersView =
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
    
pageUsers: List (Html Msg)
pageUsers =
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
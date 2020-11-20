module Pages.Applications exposing (Params, Model, Msg, page)

import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Table as Table
import Html exposing (Html, h1, text)
import Html.Attributes exposing (href)
import Spa.Document exposing (Document)
import Spa.Generated.Route as Route
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
    = ReplaceMe


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReplaceMe ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Applications"
    , body = [applicationsView]
    }
    
applicationsView: Html msg
applicationsView  =
     Grid.container []
        [ Button.linkButton [ Button.primary, Button.block, Button.large, Button.attrs [href (Route.toString Route.ApplicationSelection)] ] [ text "Add new"] , h1 [] [ text "Registered applications" ]
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
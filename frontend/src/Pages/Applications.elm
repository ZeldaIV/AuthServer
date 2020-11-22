module Pages.Applications exposing (Params, Model, Msg, page)

import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Table as Table exposing (Row)
import Data.ApiResource exposing (ApiResource)
import DateTime exposing (DateTime)
import Html exposing (Html, h1, text)
import Html.Attributes exposing (href)
import Http
import Request.ApiResource as ApiResource
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
    { apiResources: List ApiResource
    }


init : Url Params -> ( Model, Cmd Msg )
init { params } =
    ( { apiResources = []}, ApiResource.apiResourceGet { onSend = gotResources} )


gotResources: Result Http.Error (List ApiResource) -> Msg
gotResources result =
    case result of
        Ok value ->
            GotApiResources value

        Err _ ->
            ErrorGettingResources


-- UPDATE


type Msg
    = GotApiResources (List ApiResource)
    | ErrorGettingResources


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotApiResources apiResources ->
            ({ model | apiResources = apiResources}, Cmd.none)

        ErrorGettingResources ->
            (model, Cmd.none)    
        


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Applications"
    , body = [applicationsView model]
    }
    
fromMaybeString: Maybe String -> String
fromMaybeString value = 
    case value of
        Just a ->        
            a
        Nothing ->
            ""
fromMaybeInt: Maybe Int -> String
fromMaybeInt val =
    case val of
        Just a ->     
            String.fromInt a
        Nothing ->
            ""
            
fromMaybeDateTime: Maybe DateTime -> String
fromMaybeDateTime val =
    case val of
        Just a ->
            DateTime.toString a        

        Nothing ->
            ""
            
fromMaybeBool: Maybe Bool -> String
fromMaybeBool val =
    case val of
        Just a ->
            if (a) then "Yes" else "No"            
        Nothing ->
            ""
    
rowView: ApiResource -> Row Msg
rowView resource =
    Table.tr [] 
        [ Table.td [] [text (fromMaybeInt resource.id)]
        , Table.td [] [text (fromMaybeString resource.name)]
        , Table.td [] [text (fromMaybeString resource.displayName)]
        , Table.td [] [text (fromMaybeBool resource.enabled)]
        , Table.td [] [text (fromMaybeDateTime resource.created)]
        ]
        
createRowsView: (List ApiResource) -> List (Row Msg)
createRowsView resources =
     (List.map rowView) resources
    
            
applicationsView: Model -> Html Msg
applicationsView  model =
     Grid.container []
        [ Button.linkButton [ Button.primary, Button.block, Button.large, Button.attrs [href (Route.toString Route.ApplicationSelection)] ] [ text "Add new"] , h1 [] [ text "Registered applications" ]
        , Table.table 
            { options = [ Table.striped, Table.hover ]
            , thead = Table.simpleThead 
                [ Table.th [] [ text "Id" ]
                , Table.th [] [ text "Name"]
                , Table.th [] [ text "DisplayName"]
                , Table.th [] [ text "Enabled"]
                , Table.th [] [ text "Created at"]
                ]
            , tbody = Table.tbody []  (createRowsView model.apiResources)
            } 
        ]
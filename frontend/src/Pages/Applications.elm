module Pages.Applications exposing (Params, Model, Msg, page)

import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Table as Table exposing (Row)
import Browser.Navigation as Nav
import Data.ApiResourceDto exposing (ApiResourceDto)
import DateTime exposing (DateTime)
import Html exposing (Html, h1, text)
import Html.Attributes exposing (href)

import Html.Events exposing (onClick)
import Http exposing (Error)
import Request.ApiResource as ApiResource
import Shared
import Spa.Document exposing (Document)
import Spa.Generated.Route as Route
import Spa.Page as Page exposing (Page)
import Spa.Url as Url exposing (Url)
import Uuid exposing (Uuid)


page : Page Params Model Msg
page =
    Page.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , load = load
        , save = save
        }



-- INIT


type alias Params =
    ()


type alias Model =
    { apiResources: List ApiResourceDto
    , error: String
    , isSignedIn: Bool
    , key: Nav.Key
    }


init : Shared.Model -> Url Params -> ( Model, Cmd Msg )
init shared { params } =
    ( { apiResources = [], error = "", isSignedIn = shared.isSignedIn, key = shared.key }, ApiResource.apiResourceGet { onSend = gotResources} )


gotResources: Result Http.Error (List ApiResourceDto) -> Msg
gotResources result =
    case result of
        Ok value ->
            GotApiResources value

        Err error ->
            ErrorGettingResources error

save : Model -> Shared.Model -> Shared.Model
save model shared =
    { shared | isSignedIn = model.isSignedIn, apiResources = Just model.apiResources }


load : Shared.Model -> Model -> ( Model, Cmd Msg )
load shared model =
    ( { model | isSignedIn = shared.isSignedIn }, Cmd.none )

-- UPDATE


type Msg
    = GotApiResources (List ApiResourceDto)
    | GoToApplication (Maybe String)
    | ErrorGettingResources Error


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotApiResources apiResources ->
            ({ model | apiResources = apiResources}, Cmd.none)

        ErrorGettingResources error ->
            (model, Cmd.none)

        GoToApplication maybeString ->
            (model, case maybeString of
                Just a ->
                    Nav.pushUrl model.key (Route.toString (Route.Applications__Name_String {name = a}))
                Nothing ->
                    Cmd.none
            )
            
                    
            
        


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
fromMaybeUuid: Maybe Uuid -> String
fromMaybeUuid val =
    case val of
        Just a ->     
            Uuid.toString a
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
    
rowView: ApiResourceDto -> Row Msg
rowView resource =
    Table.tr [Table.rowAttr (onClick (GoToApplication resource.name))  ] 
        [ Table.td [] [text (fromMaybeString resource.name)]
        , Table.td [] [text (fromMaybeString resource.displayName)]
        , Table.td [] [text (fromMaybeString resource.description)]
        , Table.td [] [text (fromMaybeBool resource.enabled)]
        ]
        
createRowsView: (List ApiResourceDto) -> List (Row Msg)
createRowsView resources =
     (List.map rowView) resources
    
            
applicationsView: Model -> Html Msg
applicationsView  model =
     Grid.container []
        [ Button.linkButton [ Button.primary, Button.block, Button.large, Button.attrs [href (Route.toString Route.ApplicationSelection)] ] [ text "Add new"] 
        , h1 [] [ text "Registered applications" ]
        , Table.table 
            { options = [ Table.striped, Table.hover ]
            , thead = Table.simpleThead 
                [ Table.th [] [ text "Name"]
                , Table.th [] [ text "DisplayName"]
                , Table.th [] [ text "Description"]
                , Table.th [] [ text "Enabled"]
                ]
            , tbody = Table.tbody []  (createRowsView model.apiResources)
            } 
        ]
module Pages.Applications exposing (Model, Msg, page)

import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Table as Table exposing (Row)
import Data.ApiResourceDto exposing (ApiResourceDto)
import DateTime exposing (DateTime)
import Gen.Route
import Html exposing (Html, h1, text)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)
import Http exposing (Error)
import Page
import Request exposing (Request)
import Request.ApiResource as ApiResource
import Shared
import Utility exposing (fromMaybe)
import Uuid exposing (Uuid)
import View exposing (View)


page : Shared.Model -> Request -> Page.With Model Msg
page _ req =
    Page.protected.element
        (\_ ->
            { init = init
            , update = update req
            , view = view
            , subscriptions = subscriptions
            }
        )



-- INIT


type alias Model =
    { apiResources : List ApiResourceDto
    , error : String
    }


init : ( Model, Cmd Msg )
init =
    ( { apiResources = [], error = "" }, ApiResource.apiResourceGet { onSend = gotResources } )


gotResources : Result Http.Error (List ApiResourceDto) -> Msg
gotResources result =
    case result of
        Ok value ->
            GotApiResources value

        Err error ->
            ErrorGettingResources error



-- UPDATE


type Msg
    = GotApiResources (List ApiResourceDto)
    | GoToApplication (Maybe String)
    | ErrorGettingResources Error


update : Request -> Msg -> Model -> ( Model, Cmd Msg )
update req msg model =
    case msg of
        GotApiResources apiResources ->
            ( { model | apiResources = apiResources }, Cmd.none )

        ErrorGettingResources _ ->
            ( model, Cmd.none )

        GoToApplication maybeString ->
            ( model
            , case maybeString of
                Just a ->
                    Request.replaceRoute (Gen.Route.Appliaction__Name_ { name = a }) req

                Nothing ->
                    Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Applications"
    , body = [ applicationsView model ]
    }


fromMaybeBool : Maybe Bool -> String
fromMaybeBool val =
    case val of
        Just a ->
            if a then
                "Yes"

            else
                "No"

        Nothing ->
            ""


rowView : ApiResourceDto -> Row Msg
rowView resource =
    Table.tr [ Table.rowAttr (onClick (GoToApplication resource.name)) ]
        [ Table.td [] [ text (fromMaybe resource.name "") ]
        , Table.td [] [ text (fromMaybe resource.displayName "") ]
        , Table.td [] [ text (fromMaybe resource.description "") ]
        , Table.td [] [ text (fromMaybeBool resource.enabled) ]
        ]


createRowsView : List ApiResourceDto -> List (Row Msg)
createRowsView resources =
    List.map rowView resources


applicationsView : Model -> Html Msg
applicationsView model =
    Grid.container []
        [ Button.linkButton [ Button.primary, Button.block, Button.large, Button.attrs [ href (Gen.Route.toHref Gen.Route.ApplicationSelection) ] ] [ text "Add new" ]
        , h1 [] [ text "Registered applications" ]
        , Table.table
            { options = [ Table.striped, Table.hover ]
            , thead =
                Table.simpleThead
                    [ Table.th [] [ text "Name" ]
                    , Table.th [] [ text "DisplayName" ]
                    , Table.th [] [ text "Description" ]
                    , Table.th [] [ text "Enabled" ]
                    ]
            , tbody = Table.tbody [] (createRowsView model.apiResources)
            }
        ]

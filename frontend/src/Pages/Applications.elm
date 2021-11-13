module Pages.Applications exposing (Model, Msg, page)

import Api.Object exposing (ClientDto)
import Api.Object.ClientDto as ClientDto
import Api.Query as Query
import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Table as Table exposing (Row)
import Effect exposing (Effect)
import Element exposing (Element, el, fill, maximum, minimum, rgb255, spacingXY, table, width)
import Element.Border as Border
import Element.Font as Font
import Gen.Route
import Graphql.Http
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Html exposing (Html, h1, text)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)
import Http exposing (Error(..))
import Page exposing (Page)
import Random
import RemoteData exposing (RemoteData(..))
import Request exposing (Request)
import Shared
import Utility exposing (RequestState(..), makeGraphQLQuery)
import Uuid
import View exposing (View)


page : Shared.Model -> Request -> Page.With Model Msg
page sharedModel req =
    Page.protected.advanced
        (\_ ->
            { init = init sharedModel
            , update = update req
            , view = view
            , subscriptions = subscriptions
            }
        )


type alias Model =
    { client :
        List Client
    , error : String
    , seed : Random.Seed
    }


type alias Client =
    { id : String
    , displayName : String
    , clientType : String
    }


mapToApiResource : SelectionSet Client ClientDto
mapToApiResource =
    SelectionSet.map3 Client
        (SelectionSet.map Utility.uuidToString ClientDto.id)
        ClientDto.displayName
        ClientDto.type_



-- INIT


init : Shared.Model -> ( Model, Effect Msg )
init sharedModel =
    ( { client =
            []
      , error = ""
      , seed = sharedModel.seed
      }
    , Effect.fromCmd makeRequest
    )


query : SelectionSet (List Client) RootQuery
query =
    Query.clients mapToApiResource


makeRequest : Cmd Msg
makeRequest =
    (Graphql.Http.withSimpleHttpError >> RemoteData.fromResult >> gotResources) |> makeGraphQLQuery query


gotResources : RemoteData (Graphql.Http.RawError (List Client) Http.Error) (List Client) -> Msg
gotResources result =
    case Utility.response result of
        RequestSuccess a ->
            GotApiResources a

        State state ->
            RequestState state

        RequestError err ->
            ErrorGettingResources err



-- UPDATE


type Msg
    = GotApiResources (List Client)
    | GoToApplication String
    | ErrorGettingResources String
    | RequestState String
    | AddNewApplication


update : Request -> Msg -> Model -> ( Model, Effect Msg )
update req msg model =
    case msg of
        GotApiResources client ->
            ( { model
                | client =
                    client
              }
            , Effect.none
            )

        ErrorGettingResources _ ->
            ( model, Effect.none )

        GoToApplication a ->
            ( model, Effect.fromCmd (Request.replaceRoute (Gen.Route.Application__Id___Status_ { id = a, status = "d" }) req) )

        RequestState _ ->
            ( model, Effect.none )

        AddNewApplication ->
            let
                ( newUuid, newSeed ) =
                    Random.step Uuid.uuidGenerator model.seed
            in
            ( model
            , Effect.batch
                [ Effect.fromCmd (Request.replaceRoute (Gen.Route.Application__Id___Status_ { id = Uuid.toString newUuid, status = "new" }) req)
                , Effect.fromShared (Shared.GenerateNewUuid newSeed)
                ]
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


rowView : Client -> Row Msg
rowView client =
    Table.tr [ Table.rowAttr (onClick (GoToApplication client.id)) ]
        [ Table.td [] [ text client.displayName ]
        , Table.td [] [ text client.id ]
        , Table.td [] [ text client.clientType ]
        ]


createRowsView : List Client -> List (Row Msg)
createRowsView resources =
    List.map rowView resources


applicationsView : Model -> Html Msg
applicationsView model =
    Grid.container []
        [ Button.button [ Button.primary, Button.block, Button.large, Button.attrs [ onClick AddNewApplication ] ] [ text "Add new" ]
        , h1 [] [ text "Registered applications" ]
        , Table.table
            { options = [ Table.striped, Table.hover ]
            , thead =
                Table.simpleThead
                    [ Table.th [] [ text "Display name" ]
                    , Table.th [] [ text "Id" ]
                    , Table.th [] [ text "Type" ]
                    ]
            , tbody =
                Table.tbody []
                    (createRowsView model.client)
            }
        ]

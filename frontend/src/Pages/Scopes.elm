module Pages.Scopes exposing (Model, Msg, page)

import Api.InputObject exposing (ScopeInput, ScopeInputRequiredFields, buildScopeInput)
import Api.Mutation exposing (CreateScopeRequiredArguments, DeleteScopeRequiredArguments, createScope, deleteScope)
import Api.Object exposing (CreateScopePayload, DeleteEntityByIdPayload(..), ScopeDto)
import Api.Object.CreateScopePayload as CreateScopePayload
import Api.Object.DeleteEntityByIdPayload as DeleteEntityByIdPayload
import Api.Object.ScopeDto as ScopeDto
import Api.Query as Query
import Api.Scalar as Scalar
import Effect exposing (Effect)
import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Graphql.Http
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Html exposing (Html)
import Http exposing (Error)
import Page
import Random
import RemoteData exposing (RemoteData)
import Request exposing (Request)
import Shared
import UI.Button exposing (confirmButton)
import Utility exposing (RequestState(..), makeGraphQLMutation, makeGraphQLQuery, response)
import Uuid
import View exposing (View)


page : Shared.Model -> Request -> Page.With Model Msg
page sharedModel _ =
    Page.protected.advanced
        (\_ ->
            { init = init sharedModel
            , update = update
            , view = view
            , subscriptions = subscriptions
            }
        )


type alias Scope =
    { id : String
    , name : String
    , displayName : String
    }


selectScope : SelectionSet Scope ScopeDto
selectScope =
    SelectionSet.map3 Scope
        (SelectionSet.map Utility.uuidToString ScopeDto.id)
        ScopeDto.name
        ScopeDto.displayName


type alias Model =
    { scope : Scope
    , scopes : List Scope
    , seed : Random.Seed
    }



-- INIT


initialScope : Scope
initialScope =
    Scope "" "" ""


init : Shared.Model -> ( Model, Effect Msg )
init sharedModel =
    ( { scope = initialScope, scopes = [], seed = sharedModel.seed }, Effect.fromCmd makeRequest )


query : SelectionSet (List Scope) RootQuery
query =
    Query.scopes selectScope


makeRequest : Cmd Msg
makeRequest =
    (Graphql.Http.withSimpleHttpError >> RemoteData.fromResult >> gotScopes) |> makeGraphQLQuery query


gotScopes : RemoteData (Graphql.Http.RawError (List Scope) Http.Error) (List Scope) -> Msg
gotScopes result =
    case response result of
        RequestSuccess a ->
            GotScopes a

        State state ->
            RequestState state

        RequestError err ->
            RequestFailed err



-- MUTATION


insertScopeObject : Scope -> ScopeInput
insertScopeObject scope =
    buildScopeInput (ScopeInput (Scalar.Uuid scope.id) scope.name scope.displayName)


insertArgs : Scope -> CreateScopeRequiredArguments
insertArgs scope =
    CreateScopeRequiredArguments (insertScopeObject scope)


getScopeInsertObject : Scope -> SelectionSet (Maybe Scope) RootMutation
getScopeInsertObject scope =
    createScope (insertArgs scope) mutationResponse


mutationResponse : SelectionSet (Maybe Scope) CreateScopePayload
mutationResponse =
    CreateScopePayload.scope selectScope


deleteArgs : Scalar.Uuid -> DeleteScopeRequiredArguments
deleteArgs id =
    DeleteScopeRequiredArguments id


deletionResponse : SelectionSet Bool Api.Object.DeleteEntityByIdPayload
deletionResponse =
    DeleteEntityByIdPayload.success


getDeletionObject : Scalar.Uuid -> SelectionSet Bool RootMutation
getDeletionObject id =
    deleteScope (deleteArgs id) deletionResponse


makeDeletion : SelectionSet Bool RootMutation -> Cmd Msg
makeDeletion mutation =
    (Graphql.Http.withSimpleHttpError >> RemoteData.fromResult >> deleted) |> makeGraphQLMutation mutation


deleted : RemoteData (Graphql.Http.RawError Bool Http.Error) Bool -> Msg
deleted result =
    case Utility.response result of
        RequestSuccess a ->
            DeleteSuccess a

        State state ->
            RequestState state

        RequestError err ->
            RequestFailed err


makeMutation : SelectionSet (Maybe Scope) RootMutation -> Cmd Msg
makeMutation mutation =
    (Graphql.Http.withSimpleHttpError >> RemoteData.fromResult >> gotScope) |> makeGraphQLMutation mutation


gotScope : RemoteData (Graphql.Http.RawError (Maybe Scope) Http.Error) (Maybe Scope) -> Msg
gotScope result =
    case Utility.response result of
        RequestSuccess a ->
            case a of
                Just scope ->
                    ScopeAddedResponse scope

                Nothing ->
                    CouldNotAddScope

        State state ->
            RequestState state

        RequestError err ->
            RequestFailed err


type Msg
    = Update Scope
    | AddScope Scope
    | GotScopes (List Scope)
    | Success
    | ScopeAddedResponse Scope
    | CouldNotAddScope
    | RequestFailed String
    | RequestState String
    | DeleteScope Scope
    | DeleteSuccess Bool


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        Update scope ->
            ( { model | scope = scope }, Effect.none )

        AddScope scope ->
            let
                ( newUuid, newSeed ) =
                    Random.step Uuid.uuidGenerator model.seed

                mutation =
                    getScopeInsertObject { scope | id = Uuid.toString newUuid }
            in
            ( { model | scope = initialScope }
            , Effect.batch
                [ Effect.fromCmd (makeMutation mutation)
                , Effect.fromShared (Shared.GenerateNewUuid newSeed)
                ]
            )

        Success ->
            ( model, Effect.fromCmd makeRequest )

        RequestFailed _ ->
            ( model, Effect.none )

        GotScopes scopes ->
            ( { model | scopes = scopes }, Effect.none )

        RequestState _ ->
            ( model, Effect.none )

        ScopeAddedResponse scope ->
            ( { model | scopes = scope :: model.scopes }, Effect.none )

        CouldNotAddScope ->
            ( model, Effect.none )

        DeleteScope scope ->
            let
                delete =
                    getDeletionObject (Scalar.Uuid scope.id)
            in
            ( model, Effect.fromCmd (makeDeletion delete) )

        DeleteSuccess _ ->
            ( model, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


scopeValid : Scope -> Bool
scopeValid scope =
    String.length scope.name > 3



-- VIEW


scopesInputView : Model -> Element Msg
scopesInputView model =
    let
        scope =
            model.scope
    in
    row [ spacing 30, centerX ]
        [ Input.text [ width <| maximum 300 fill ]
            { onChange = \new -> Update { scope | name = new }
            , text = scope.name
            , placeholder = Just <| Input.placeholder [] <| text "Scope name"
            , label = Input.labelHidden "Scope name"
            }
        , Input.text [ width <| maximum 300 fill ]
            { onChange = \new -> Update { scope | displayName = new }
            , text = scope.displayName
            , placeholder = Just <| Input.placeholder [] <| text "Scope display name"
            , label = Input.labelHidden "Scope display name"
            }
        , confirmButton { msg = AddScope scope, label = "Add", enabled = scopeValid scope }
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
            [ { header = el headerAttrs <| Element.text "Id"
              , width = fill
              , view =
                    \scope ->
                        Element.text scope.id
              }
            , { header = el headerAttrs <| Element.text "Scope name"
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


scopesView : Model -> List (Html Msg)
scopesView model =
    [ layout [ width fill, height fill ] <|
        column [ width fill, spacing 40 ]
            [ scopesInputView model
            , el [ centerX ] (scopesTable model)
            ]
    ]


view : Model -> View Msg
view model =
    { title = "Scopes"
    , body = scopesView model
    }

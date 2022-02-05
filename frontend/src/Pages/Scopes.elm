module Pages.Scopes exposing (Model, Msg, page)

import Api.InputObject exposing (ScopeInput, ScopeInputOptionalFields, ScopeInputRequiredFields, buildScopeInput)
import Api.Mutation exposing (CreateScopeRequiredArguments, DeleteScopeRequiredArguments, createScope, deleteScope)
import Api.Object exposing (CreateScopePayload, DeleteEntityByIdPayload(..), ScopeDto)
import Api.Object.CreateScopePayload as CreateScopePayload
import Api.Object.DeleteEntityByIdPayload as DeleteEntityByIdPayload
import Api.Object.ScopeDto as ScopeDto
import Api.Query as Query
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
import UI.Color exposing (color)
import UI.Table as UITable
import Utility exposing (RequestState(..), makeGraphQLMutation, makeGraphQLQuery, response)
import Uuid exposing (Uuid)
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
    , description : String
    , resources : List String
    }


selectScope : SelectionSet Scope ScopeDto
selectScope =
    SelectionSet.map5 Scope
        ScopeDto.id
        ScopeDto.name
        ScopeDto.displayName
        ScopeDto.description
        ScopeDto.resources


type alias Model =
    { scope : Scope
    , scopes : List Scope
    , seed : Random.Seed
    , uuidFromShared : Uuid
    }



-- INIT


initialScope : Scope
initialScope =
    { id = ""
    , name = ""
    , displayName = ""
    , description = ""
    , resources = []
    }


predefinedScopes : List String
predefinedScopes =
    [ "profile", "address", "roles", "phone", "email" ]


init : Shared.Model -> ( Model, Effect Msg )
init sharedModel =
    ( { scope = initialScope, scopes = [], seed = sharedModel.seed, uuidFromShared = sharedModel.uuid }, Effect.fromCmd makeRequest )


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
    buildScopeInput
        (ScopeInputRequiredFields scope.id scope.name scope.displayName)
        (\_ ->
            { description = Utility.optionalString scope.description
            , resources = Utility.optionalList scope.resources
            }
        )


insertArgs : Scope -> CreateScopeRequiredArguments
insertArgs scope =
    CreateScopeRequiredArguments (insertScopeObject scope)


getScopeInsertObject : Scope -> SelectionSet (Maybe Scope) RootMutation
getScopeInsertObject scope =
    createScope (insertArgs scope) mutationResponse


mutationResponse : SelectionSet (Maybe Scope) CreateScopePayload
mutationResponse =
    CreateScopePayload.scope selectScope


deleteArgs : String -> DeleteScopeRequiredArguments
deleteArgs id =
    DeleteScopeRequiredArguments id


deletionResponse : SelectionSet Bool Api.Object.DeleteEntityByIdPayload
deletionResponse =
    DeleteEntityByIdPayload.success


getDeletionObject : String -> SelectionSet Bool RootMutation
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
                mutation =
                    getScopeInsertObject { scope | id = Uuid.toString model.uuidFromShared }
            in
            ( { model | scope = initialScope }
            , Effect.batch
                [ Effect.fromCmd (makeMutation mutation)
                , Effect.fromShared (Shared.GenerateNewUuid model.seed)
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
            ( model, Effect.fromCmd (getDeletionObject scope.id |> makeDeletion) )

        DeleteSuccess _ ->
            ( model, Effect.fromCmd makeRequest )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


scopeValid : Scope -> Bool
scopeValid scope =
    String.length scope.name > 3 && not (List.member scope.name predefinedScopes)



-- VIEW


scopeAlreadyAdded : Scope -> List Scope -> Bool
scopeAlreadyAdded scp scopes =
    let
        scps =
            List.map (\s -> String.toLower s.name) scopes
    in
    List.member (String.toLower scp.name) scps


scopesInputView : Model -> Element Msg
scopesInputView model =
    let
        scope =
            model.scope

        inputAttrs =
            [ height shrink
            , paddingXY 4 4
            ]

        scopeExists =
            if scopeAlreadyAdded scope model.scopes then
                text "The scope already exists"

            else
                none
    in
    column [ spacing 20, centerX, width <| maximum 300 fill ]
        [ Input.text inputAttrs
            { onChange = \new -> Update { scope | name = new }
            , text = scope.name
            , placeholder = Nothing
            , label = Input.labelAbove [] <| text "Scope name"
            }
        , Input.text inputAttrs
            { onChange = \new -> Update { scope | displayName = new }
            , text = scope.displayName
            , placeholder = Nothing
            , label = Input.labelAbove [] <| text "Scope display name"
            }
        , Input.multiline
            [ Element.height (Element.shrink |> Element.minimum 50)
            , paddingXY 2 2
            ]
            { onChange = \new -> Update { scope | description = new }
            , text = scope.description
            , placeholder = Nothing
            , label = Input.labelAbove [] <| text "Description"
            , spellcheck = True
            }
        , row []
            [ confirmButton { msg = AddScope scope, label = "Add", enabled = scopeValid scope }
            , scopeExists
            ]
        ]


scopesTable : Model -> Element Msg
scopesTable model =
    let
        headerAttrs =
            [ Font.bold
            , Font.color color.black
            , Border.widthEach { bottom = 2, top = 0, left = 0, right = 0 }
            ]
    in
    column UITable.columnAttributes
        [ row [ width fill ]
            [ el ((width <| fillPortion 2) :: headerAttrs) <| text "Name"
            , el ((width <| fillPortion 3) :: headerAttrs) <| text "Display name"
            , el ((width <| fillPortion 4) :: headerAttrs) <| text "Description"
            , el ((width <| fillPortion 1) :: headerAttrs) <| text " "
            ]
        , el [ width fill ] <|
            table
                [ width fill
                , height <| px 250
                , scrollbarY
                , spacing 10
                ]
                { data = model.scopes
                , columns =
                    [ { header = none
                      , width = fillPortion 2
                      , view =
                            \scope ->
                                Element.text scope.name
                      }
                    , { header = none
                      , width = fillPortion 3
                      , view =
                            \scope ->
                                Element.text scope.displayName
                      }
                    , { header = none
                      , width = fillPortion 4
                      , view =
                            \scope ->
                                Element.paragraph [] [ Element.text scope.description ]
                      }
                    , { header = none
                      , width = fillPortion 1
                      , view =
                            \scope ->
                                UI.Button.cancelButton
                                    { msg = DeleteScope scope
                                    , label = "Delete"
                                    , enabled = not (List.member scope.name predefinedScopes)
                                    }
                      }
                    ]
                }
        ]


scopesView : Model -> List (Html Msg)
scopesView model =
    [ layout [ Font.size 14 ] <|
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

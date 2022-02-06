module Pages.Application.Id_.Status_ exposing (Model, Msg, page)

import Api.InputObject exposing (ClientInput, buildClientInput)
import Api.Mutation exposing (CreateClientRequiredArguments, UpdateClientRequiredArguments, createClient, updateClient)
import Api.Object exposing (ClientDto, CreateClientPayload, ScopeDto)
import Api.Object.ClientDto as ClientDto
import Api.Object.CreateClientPayload as CreateClientPayload
import Api.Object.ScopeDto as ScopeDto
import Api.Query as Query
import Array exposing (Array)
import Effect exposing (Effect)
import Element exposing (Element, alignBottom, alignTop, centerX, centerY, column, el, fill, height, inFront, layout, maximum, none, padding, paddingEach, paddingXY, px, row, scrollbarX, shrink, spacing, text, width, wrappedRow)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Gen.Params.Application.Id_.Status_ exposing (Params)
import Graphql.Http
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, hardcoded, with)
import Http exposing (Error)
import Page
import RemoteData exposing (RemoteData)
import Request
import Shared
import UI.Button as Button
import UI.Color exposing (color)
import UI.Dialog as Dialog
import Utility exposing (RequestState(..), makeGraphQLMutation, makeGraphQLQuery)
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.protected.advanced
        (\_ ->
            { init = init shared req.params
            , update = update
            , view = view
            , subscriptions = subscriptions
            }
        )



-- INIT


type alias Model =
    { client : Client
    , form : ClientForm
    , displayScopeDialog : Bool
    , availableScopes : List Scope
    , newClient : Bool
    , clientTypes : List ClientType
    }


type alias Scope =
    { id : String
    , name : String
    , displayName : String
    , addedToResource : Bool
    }


type alias Client =
    { clientId : String
    , clientSecret : String
    , displayName : String
    , permissions : List String
    , postLogoutRedirectUris : List String
    , redirectUris : List String
    , requirePkce : Bool
    , clientType : ClientType
    , requireConsent : Bool
    }


type alias ClientForm =
    { clientId : String
    , clientSecret : String
    , displayName : String
    , permissions : List String
    , postLogoutRedirectUris : List String
    , redirectUris : List String
    , requirePkce : Bool
    , clientType : ClientType
    , requireConsent : Bool
    }


type ClientType
    = Confidential
    | Public


init : Shared.Model -> Params -> ( Model, Effect Msg )
init _ params =
    let
        model =
            { client = initialResource
            , form = { initialForm | clientId = params.id }
            , displayScopeDialog = False
            , availableScopes = []
            , newClient = params.status == "new"
            , clientTypes = []
            }
    in
    if params.id == "new" then
        ( model, Effect.fromCmd (makeScopesQuery getScopes) )

    else
        ( model, Effect.batch [ Effect.fromCmd <| makeQuery (getClient params.id), Effect.fromCmd <| makeScopesQuery getScopes, Effect.fromCmd <| makeClientTypesQuery clientTypeQuery ] )


initialResource =
    Client "" "" "" [] [] [] False Public False


initialForm =
    ClientForm "" "" "" [ "" ] [ "" ] [ "" ] False Public False


toClientType : String -> ClientType
toClientType s =
    case String.toLower s of
        "confidential" ->
            Confidential

        "public" ->
            Public

        _ ->
            Public


fromClientType : ClientType -> String
fromClientType s =
    case s of
        Confidential ->
            "confidential"

        Public ->
            "public"


clientTypeQuery : SelectionSet (List ClientType) RootQuery
clientTypeQuery =
    Query.applicationTypes |> SelectionSet.map (List.map toClientType)


makeClientTypesQuery : SelectionSet (List ClientType) RootQuery -> Cmd Msg
makeClientTypesQuery query =
    (Graphql.Http.withSimpleHttpError >> RemoteData.fromResult >> gotClientTypes) |> makeGraphQLQuery query


gotClientTypes : RemoteData (Graphql.Http.RawError (List ClientType) Http.Error) (List ClientType) -> Msg
gotClientTypes result =
    case Utility.response result of
        RequestSuccess a ->
            GotClientTypes a

        State state ->
            RequestState state

        RequestError err ->
            RequestFailed err


selectScope : Bool -> SelectionSet Scope ScopeDto
selectScope added =
    SelectionSet.succeed Scope
        |> with ScopeDto.id
        |> with ScopeDto.name
        |> with ScopeDto.displayName
        |> hardcoded added


selectClient : SelectionSet Client ClientDto
selectClient =
    SelectionSet.succeed Client
        |> with ClientDto.clientId
        |> with ClientDto.clientSecret
        |> with ClientDto.displayName
        |> with ClientDto.permissions
        |> with ClientDto.postLogoutRedirectUris
        |> with ClientDto.redirectUris
        |> with ClientDto.requirePkce
        |> with (SelectionSet.map toClientType ClientDto.type_)
        |> with ClientDto.requireConsent


getClient : String -> SelectionSet (Maybe Client) RootQuery
getClient id =
    Query.clientById (Query.ClientByIdRequiredArguments id) selectClient


getScopes : SelectionSet (List Scope) RootQuery
getScopes =
    Query.scopes (selectScope False)


makeScopesQuery : SelectionSet (List Scope) RootQuery -> Cmd Msg
makeScopesQuery query =
    (Graphql.Http.withSimpleHttpError >> RemoteData.fromResult >> gotScopes) |> makeGraphQLQuery query


gotScopes : RemoteData (Graphql.Http.RawError (List Scope) Http.Error) (List Scope) -> Msg
gotScopes result =
    case Utility.response result of
        RequestSuccess a ->
            GotScopes a

        State state ->
            RequestState state

        RequestError err ->
            RequestFailed err


makeQuery : SelectionSet (Maybe Client) RootQuery -> Cmd Msg
makeQuery query =
    (Graphql.Http.withSimpleHttpError >> RemoteData.fromResult >> clientCreateResult) |> makeGraphQLQuery query


sanitizeList : List String -> List String
sanitizeList strings =
    List.filter (\n -> n /= "") strings


clientMutationObject : Client -> ClientInput
clientMutationObject r =
    buildClientInput
        { clientId = r.clientId
        , displayName = r.displayName
        , requirePkce = r.requirePkce
        , requireConsent = r.requireConsent
        , clientSecret = r.clientSecret
        , type_ = fromClientType r.clientType
        }
        (\_ ->
            { permissions = Utility.optionalList (sanitizeList r.permissions)
            , postLogoutRedirectUris = Utility.optionalList (sanitizeList r.postLogoutRedirectUris)
            , redirectUris = Utility.optionalList (sanitizeList r.redirectUris)
            }
        )


insertApiArgs : Client -> CreateClientRequiredArguments
insertApiArgs r =
    CreateClientRequiredArguments (clientMutationObject r)


updateClientArgs : Client -> UpdateClientRequiredArguments
updateClientArgs c =
    UpdateClientRequiredArguments (clientMutationObject c)


getInsertClientObject : Client -> SelectionSet (Maybe Client) RootMutation
getInsertClientObject r =
    createClient (insertApiArgs r) createClientResponse


getUpdateClientObject : Client -> SelectionSet (Maybe Client) RootMutation
getUpdateClientObject c =
    updateClient (updateClientArgs c) createClientResponse


createClientResponse : SelectionSet (Maybe Client) CreateClientPayload
createClientResponse =
    CreateClientPayload.applicationClient selectClient


createNewClientMutation : SelectionSet (Maybe Client) RootMutation -> Cmd Msg
createNewClientMutation mutation =
    (Graphql.Http.withSimpleHttpError >> RemoteData.fromResult >> clientCreateResult) |> makeGraphQLMutation mutation


updateExistingClientMutation : SelectionSet (Maybe Client) RootMutation -> Cmd Msg
updateExistingClientMutation mutation =
    (Graphql.Http.withSimpleHttpError >> RemoteData.fromResult >> clientCreateResult) |> makeGraphQLMutation mutation


clientCreateResult : RemoteData (Graphql.Http.RawError (Maybe Client) Http.Error) (Maybe Client) -> Msg
clientCreateResult result =
    case Utility.response result of
        RequestSuccess a ->
            case a of
                Just client ->
                    GotClient client

                Nothing ->
                    CouldNotAddClient

        State state ->
            RequestState state

        RequestError err ->
            RequestFailed err


setScopeAdded : Scope -> Scope
setScopeAdded s =
    { s
        | addedToResource = True
    }


setScopeRemoved : Scope -> Scope
setScopeRemoved s =
    { s
        | addedToResource = False
    }


updateArray : Array String -> Int -> String -> List String
updateArray lst idx val =
    let
        arrLength =
            Array.length lst

        stringLength =
            String.length val
    in
    if idx + 1 == arrLength && stringLength > 0 then
        Array.push "" lst |> Array.set idx val |> Array.toList

    else if stringLength == 0 && idx + 1 < arrLength then
        let
            a1 =
                Array.slice 0 idx lst

            a2 =
                Array.slice (idx + 1) arrLength lst
        in
        Array.append a1 a2 |> Array.toList

    else
        Array.set idx val lst |> Array.toList


appendEmptyFields : Client -> Client
appendEmptyFields c =
    { c
        | permissions = c.permissions ++ [ "" ]
        , postLogoutRedirectUris = c.postLogoutRedirectUris ++ [ "" ]
        , redirectUris = c.redirectUris ++ [ "" ]
    }


type Msg
    = ResetForm
    | SaveChanges
    | GotError Error
    | GotClient Client
    | CouldNotAddClient
    | RequestState String
    | RequestFailed String
    | DisplayScopeDialog
    | CloseScopeDialog
    | GotScopes (List Scope)
    | DisplayNameEntered String
    | ToggleScopeAdded Scope Bool
    | ScopesEntered Int String
    | RedirectUrisEntered Int String
    | PostLogoutUrisEntered Int String
    | ToggleRequireConsent Bool
    | ToggleRequirePkce Bool
    | ClientSecretEntered String
    | GotClientTypes (List ClientType)
    | ToggleClientType ClientType


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ResetForm ->
            ( { model | form = model.client }, Effect.none )

        SaveChanges ->
            ( model
            , Effect.fromCmd
                (if model.newClient then
                    getInsertClientObject model.form |> createNewClientMutation

                 else
                    getUpdateClientObject model.form |> updateExistingClientMutation
                )
            )

        GotError _ ->
            ( model, Effect.none )

        GotClient client ->
            ( { model | client = client, form = appendEmptyFields client }, Effect.none )

        CouldNotAddClient ->
            ( model, Effect.none )

        -- Handle error
        RequestState string ->
            ( model, Effect.none )

        -- Handle error
        RequestFailed _ ->
            ( model, Effect.none )

        DisplayScopeDialog ->
            ( { model | displayScopeDialog = True }, Effect.none )

        CloseScopeDialog ->
            ( { model | displayScopeDialog = False }, Effect.none )

        GotScopes scopes ->
            ( { model | availableScopes = List.map (\s -> { s | addedToResource = List.member s.name model.client.permissions }) scopes }, Effect.none )

        ToggleScopeAdded scope add ->
            let
                resource =
                    model.form

                availableScopes =
                    List.map
                        (\s ->
                            if s == scope then
                                if add then
                                    setScopeAdded s

                                else
                                    setScopeRemoved s

                            else
                                s
                        )
                        model.availableScopes

                permissions =
                    if add then
                        [ scope.name ] ++ resource.permissions

                    else
                        List.filter (\s -> s /= scope.name) resource.permissions
            in
            ( { model
                | form = { resource | permissions = permissions }
                , availableScopes = availableScopes
              }
            , Effect.none
            )

        DisplayNameEntered displayName ->
            let
                resource =
                    model.form
            in
            ( { model | form = { resource | displayName = displayName } }, Effect.none )

        ScopesEntered index value ->
            let
                form =
                    model.form

                result =
                    List.map String.trim (updateArray (Array.fromList model.form.permissions) index value)
            in
            ( { model | form = { form | permissions = result } }, Effect.none )

        RedirectUrisEntered index value ->
            let
                form =
                    model.form

                result =
                    updateArray (Array.fromList model.form.redirectUris) index value
            in
            ( { model | form = { form | redirectUris = result } }, Effect.none )

        PostLogoutUrisEntered index value ->
            let
                form =
                    model.form

                result =
                    updateArray (Array.fromList model.form.postLogoutRedirectUris) index value
            in
            ( { model | form = { form | postLogoutRedirectUris = result } }, Effect.none )

        ToggleRequireConsent toggle ->
            let
                form =
                    model.form
            in
            ( { model | form = { form | requireConsent = toggle } }, Effect.none )

        ToggleRequirePkce toggle ->
            let
                form =
                    model.form
            in
            ( { model | form = { form | requirePkce = toggle } }, Effect.none )

        ClientSecretEntered clientSecret ->
            let
                form =
                    model.form
            in
            ( { model | form = { form | clientSecret = clientSecret } }, Effect.none )

        GotClientTypes types ->
            ( { model | clientTypes = types }, Effect.none )

        ToggleClientType clientType ->
            let
                form =
                    model.form
            in
            ( { model | form = { form | clientType = clientType } }, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


type alias IndexedValue =
    { index : Int, value : String }



-- VIEW


stringIndexToInput : IndexedValue -> (Int -> String -> toMsg) -> Element toMsg
stringIndexToInput indexedValue toMsg =
    Input.text
        [ height shrink
        , paddingXY 4 4
        ]
        { onChange = toMsg indexedValue.index
        , text = indexedValue.value
        , placeholder = Nothing
        , label = Input.labelHidden ""
        }


stringListView : List String -> (Int -> String -> msg) -> List (Element msg)
stringListView logoutUris msg =
    List.indexedMap Tuple.pair logoutUris |> List.map (\( i, v ) -> stringIndexToInput { index = i, value = v } <| msg)


capitalizeString : String -> String
capitalizeString s =
    (String.left 1 >> String.toUpper) s ++ String.dropLeft 1 s


clientTypeToOption : ClientType -> Input.Option ClientType Msg
clientTypeToOption t =
    fromClientType t |> capitalizeString |> text |> Input.option t


scopeNameToDisplayName : List Scope -> String -> String
scopeNameToDisplayName availableScopes scp =
    let
        scopes =
            List.filter (\s -> s.name == scp) availableScopes
    in
    case scopes of
        x :: _ ->
            x.displayName

        _ ->
            scp


formView : Model -> Element Msg
formView model =
    let
        form =
            model.form

        textBoxWidth =
            width (px 150)

        inputAttrs =
            [ height shrink
            , paddingXY 4 4
            , textBoxWidth
            ]

        clientSecretInput =
            if form.clientType == Confidential then
                Input.text inputAttrs
                    { text = form.clientSecret
                    , onChange = ClientSecretEntered
                    , placeholder = Nothing
                    , label = Input.labelAbove [] <| Element.text "Client secret (temporary input):"
                    }

            else
                none
    in
    column [ spacing 10, width fill ]
        [ Input.text
            inputAttrs
            { text = form.displayName
            , onChange = DisplayNameEntered
            , placeholder = Nothing
            , label = Input.labelAbove [] <| Element.text "Display name:"
            }
        , Input.checkbox []
            { onChange = ToggleRequireConsent
            , icon = Input.defaultCheckbox
            , checked = form.requireConsent
            , label = Input.labelRight [] <| Element.text "Require consent"
            }
        , Input.checkbox []
            { onChange = ToggleRequirePkce
            , icon = Input.defaultCheckbox
            , checked = form.requirePkce
            , label = Input.labelRight [] <| Element.text "Require Pkce"
            }
        , Input.radioRow
            [ paddingXY 0 10
            , spacing 20
            ]
            { onChange = ToggleClientType
            , selected = Just form.clientType
            , label = Input.labelAbove [] (text "Select client type")
            , options = List.map clientTypeToOption model.clientTypes
            }
        , clientSecretInput
        , text "Permissions:"
        , row [ alignTop ]
            [ column
                [ textBoxWidth ]
                (stringListView (List.map (scopeNameToDisplayName model.availableScopes) form.permissions) ScopesEntered)
            , el [ alignBottom, paddingEach { edges | left = 10 } ] addScopesButton
            ]
        , text "RedirectUris:"
        , column [ textBoxWidth ] (stringListView form.redirectUris RedirectUrisEntered)
        , text "Post logout redirects:"
        , column [ textBoxWidth ] (stringListView form.postLogoutRedirectUris PostLogoutUrisEntered)
        ]


addScopesButton : Element Msg
addScopesButton =
    Button.confirmButton
        { label = "Add permissions"
        , msg = DisplayScopeDialog
        , enabled = True
        }


scopeView : Scope -> Element Msg
scopeView scope =
    let
        checked =
            scope.addedToResource
    in
    Input.checkbox
        [ width shrink
        ]
        { onChange = ToggleScopeAdded scope
        , icon = checkBoxIcon scope
        , checked = scope.addedToResource
        , label =
            Input.labelHidden <|
                if checked then
                    "On"

                else
                    "Off"
        }


checkBoxIcon : Scope -> Bool -> Element msg
checkBoxIcon scope checked =
    row
        [ width fill ]
        [ el
            [ width <| px 150
            , height <| px 30
            , Border.width 1
            , Border.solid
            , Border.color color.grey
            , if checked then
                Background.color color.lightGrey

              else
                Background.color color.white
            ]
            (el [ centerX, centerY ] (text (String.replace "scp:" "" scope.name)))
        ]


scopesRow : List Scope -> Element Msg
scopesRow scopes =
    el
        [ width fill
        , height
            (fill
                |> maximum 400
            )
        , scrollbarX
        ]
    <|
        el [ width fill ] <|
            wrappedRow
                [ centerX ]
                (List.map (\scope -> el [ padding 10 ] (scopeView scope)) scopes)


scopesDialog : List Scope -> Element Msg
scopesDialog scopes =
    el [ width fill, height fill ]
        (column [ width fill, height fill ]
            [ scopesRow scopes
            , row [ alignBottom, centerX, paddingEach { edges | top = 10, bottom = 10 } ]
                [ Button.confirmButton { msg = CloseScopeDialog, label = "Close", enabled = True } ]
            ]
        )


cancelConfirmView : Element Msg
cancelConfirmView =
    row [ padding 10 ]
        [ el [ paddingEach { edges | right = 10, left = 10 } ] <|
            Button.cancelButton
                { enabled = True
                , msg = ResetForm
                , label = "Reset"
                }
        , el [ paddingEach { edges | right = 10, left = 10 } ] <|
            Button.confirmButton
                { enabled = True
                , msg = SaveChanges
                , label = "Save"
                }
        ]


edges =
    { top = 0
    , right = 0
    , bottom = 0
    , left = 0
    }


view : Model -> View Msg
view model =
    let
        displayScopeDialog =
            model.displayScopeDialog

        dialog =
            if displayScopeDialog then
                Dialog.view [ scopesDialog model.availableScopes ]

            else
                none
    in
    { title =
        if model.newClient then
            "Create new client"

        else
            model.form.displayName
    , body =
        [ layout [ inFront dialog ] <|
            column [ Font.size 14, width fill, paddingEach { edges | right = 300, left = 300, top = 0 } ]
                [ formView model
                , cancelConfirmView
                ]
        ]
    }

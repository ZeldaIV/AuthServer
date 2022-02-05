module Pages.Users exposing (Model, Msg, page)

import Api.InputObject exposing (UserInput, buildUserInput)
import Api.Mutation exposing (CreateUserRequiredArguments, DeleteUserRequiredArguments, createUser, deleteUser)
import Api.Object exposing (CreateUserPayload, UserDto)
import Api.Object.CreateUserPayload as CreateUserPayload
import Api.Object.DeleteEntityByIdPayload as DeleteEntityByIdPayload
import Api.Object.UserDto as UserDto
import Api.Query as Query
import Effect exposing (Effect)
import Element exposing (..)
import Element.Font as Font
import Element.Input as Input
import Graphql.Http
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Html exposing (Html)
import Http exposing (Error)
import Page exposing (Page)
import Random
import RemoteData exposing (RemoteData)
import Request exposing (Request)
import Shared
import UI.Button exposing (cancelButton, confirmButton)
import UI.Table as UITable
import Utility exposing (RequestState(..), makeGraphQLMutation, makeGraphQLQuery)
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



-- Models


type alias Model =
    { displayNewUserForm : Bool
    , form : User
    , formValid : Bool
    , userList : List User
    , seed : Random.Seed
    , uuidFromShared : Uuid
    }


type alias User =
    { id : String
    , userName : String
    , email : String
    , emailConfirmed : Bool
    , phoneNumber : String
    , phoneNumberConfirmed : Bool
    , twoFactorEnabled : Bool
    }


type alias MutationResponse =
    { user : UserDto
    }



-- INIT


initialForm : String -> User
initialForm id =
    { id = id
    , userName = ""
    , email = ""
    , emailConfirmed = False
    , phoneNumber = ""
    , phoneNumberConfirmed = False
    , twoFactorEnabled = False
    }


init : Shared.Model -> ( Model, Effect Msg )
init sharedModel =
    ( { displayNewUserForm = False
      , form = initialForm (Uuid.toString sharedModel.uuid)
      , formValid = False
      , userList = []
      , seed = sharedModel.seed
      , uuidFromShared = sharedModel.uuid
      }
    , Effect.fromCmd makeRequest
    )



-- Get registered users


selectUser : SelectionSet User UserDto
selectUser =
    SelectionSet.map7 User
        UserDto.id
        UserDto.userName
        UserDto.email
        UserDto.emailConfirmed
        (SelectionSet.withDefault "" UserDto.phoneNumber)
        UserDto.phoneNumberConfirmed
        UserDto.twoFactorEnabled


fetchUsers : SelectionSet (List User) RootQuery
fetchUsers =
    Query.users selectUser


makeRequest : Cmd Msg
makeRequest =
    (Graphql.Http.withSimpleHttpError >> RemoteData.fromResult >> usersResponse) |> makeGraphQLQuery fetchUsers


usersResponse : RemoteData (Graphql.Http.RawError (List User) Http.Error) (List User) -> Msg
usersResponse result =
    case Utility.response result of
        RequestSuccess a ->
            UsersLoaded a

        State state ->
            RequestState state

        RequestError err ->
            RequestFailed err



-- create new user


createUserPayload : SelectionSet (Maybe User) CreateUserPayload
createUserPayload =
    CreateUserPayload.user selectUser


insertUserObject : User -> Uuid -> UserInput
insertUserObject user id =
    buildUserInput
        { id = Utility.uuidToApiUuid id
        , email = user.email
        , phoneNumber = user.phoneNumber
        , twoFactorEnabled = user.twoFactorEnabled
        , userName = user.userName
        }


insertArgs : User -> Uuid -> CreateUserRequiredArguments
insertArgs user id =
    CreateUserRequiredArguments (insertUserObject user id)


getUserInsertObject : User -> Uuid -> SelectionSet (Maybe User) RootMutation
getUserInsertObject user id =
    createUser (insertArgs user id) createUserPayload


performUserMutation : SelectionSet (Maybe User) RootMutation -> Cmd Msg
performUserMutation mutation =
    (Graphql.Http.withSimpleHttpError >> RemoteData.fromResult >> newUserResponse) |> Utility.makeGraphQLMutation mutation


newUserResponse : RemoteData (Graphql.Http.RawError (Maybe User) Http.Error) (Maybe User) -> Msg
newUserResponse result =
    case Utility.response result of
        RequestSuccess a ->
            case a of
                Just user ->
                    Success user

                Nothing ->
                    CouldNotAddUser

        State state ->
            RequestState state

        RequestError err ->
            RequestFailed err



--deletion


deleteArgs : String -> DeleteUserRequiredArguments
deleteArgs id =
    DeleteUserRequiredArguments id


deletionResponse : SelectionSet Bool Api.Object.DeleteEntityByIdPayload
deletionResponse =
    DeleteEntityByIdPayload.success


getDeletionObject : String -> SelectionSet Bool RootMutation
getDeletionObject id =
    deleteUser (deleteArgs id) deletionResponse


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



-- UPDATE


type Msg
    = Success User
    | UsersLoaded (List User)
    | ApiError String
    | CancelAddUser
    | RequestState String
    | RequestFailed String
    | DeleteUser String
    | AddUser User
    | Update User
    | OnResetForm
    | CouldNotAddUser
    | DeleteSuccess Bool


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UsersLoaded users ->
            ( { model | userList = users }, Effect.none )

        ApiError _ ->
            ( model, Effect.none )

        CancelAddUser ->
            ( { model | displayNewUserForm = False }, Effect.none )

        RequestState _ ->
            ( model, Effect.none )

        RequestFailed _ ->
            ( model, Effect.none )

        Success user ->
            ( { model | userList = user :: model.userList }, Effect.none )

        DeleteUser id ->
            ( model, Effect.fromCmd (getDeletionObject id |> makeDeletion) )

        AddUser user ->
            ( model
            , Effect.batch
                [ Effect.fromCmd (getUserInsertObject user model.uuidFromShared |> performUserMutation)
                , Effect.fromShared (Shared.GenerateNewUuid model.seed)
                ]
            )

        CouldNotAddUser ->
            ( model, Effect.none )

        Update user ->
            ( { model | form = user }, Effect.none )

        OnResetForm ->
            ( { model | form = initialForm model.form.id }, Effect.none )

        DeleteSuccess _ ->
            ( model, Effect.fromCmd makeRequest )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


usersTable : Model -> Element Msg
usersTable model =
    let
        headerAttrs =
            UITable.headerAttributes
    in
    column UITable.columnAttributes
        [ row [ width fill ]
            [ el ((width <| fillPortion 3) :: headerAttrs) <| text "User name"
            , el ((width <| fillPortion 3) :: headerAttrs) <| text "Email"
            , el ((width <| fillPortion 3) :: headerAttrs) <| text "Phone"
            , el ((width <| fillPortion 2) :: headerAttrs) <| text "Two factor"
            , el ((width <| fillPortion 1) :: headerAttrs) <| text " "
            ]
        , el [ width fill ] <|
            table
                [ width fill
                , height <| px 250
                , scrollbarY
                , spacing 3
                ]
                { data = model.userList
                , columns =
                    [ { header = none
                      , width = fillPortion 3
                      , view =
                            \user ->
                                el [ centerX, centerY ] (Element.text user.userName)
                      }
                    , { header = none
                      , width = fillPortion 3
                      , view =
                            \user ->
                                el [ centerX, centerY ] (Element.text user.email)
                      }
                    , { header = none
                      , width = fillPortion 3
                      , view =
                            \user ->
                                el [ centerX, centerY ] (Element.text user.phoneNumber)
                      }
                    , { header = none
                      , width = fillPortion 2
                      , view =
                            \user ->
                                el [ centerX, centerY ]
                                    (Element.text
                                        (if user.twoFactorEnabled then
                                            "Yes"

                                         else
                                            "No"
                                        )
                                    )
                      }
                    , { header = none
                      , width = fillPortion 1
                      , view =
                            \user ->
                                el [ centerX, centerY ]
                                    (UI.Button.cancelButton
                                        { msg = DeleteUser user.id
                                        , label = "Delete"
                                        , enabled = String.toLower user.userName /= "admin"
                                        }
                                    )
                      }
                    ]
                }
        ]


userValid : User -> Bool
userValid user =
    String.length user.email >= 4 && String.length user.phoneNumber >= 8


userInputView : Model -> Element Msg
userInputView model =
    let
        user =
            model.form

        inputAttrs =
            [ height shrink
            , paddingXY 4 4
            ]
    in
    column [ spacing 20, centerX, width <| maximum 300 fill ]
        [ Input.text inputAttrs
            { onChange = \new -> Update { user | userName = new }
            , text = user.userName
            , placeholder = Nothing
            , label = Input.labelAbove [] <| text "Username"
            }
        , Input.text inputAttrs
            { onChange = \new -> Update { user | email = new }
            , text = user.email
            , placeholder = Nothing
            , label = Input.labelAbove [] <| text "E-mail"
            }
        , Input.text inputAttrs
            { onChange = \new -> Update { user | phoneNumber = new }
            , text = user.phoneNumber
            , placeholder = Nothing
            , label = Input.labelAbove [] <| text "Phone number"
            }
        , Input.checkbox
            [ centerX ]
            { checked = user.twoFactorEnabled
            , onChange = \new -> Update { user | twoFactorEnabled = new }
            , label = Input.labelRight [ centerY ] (text "Use two factor authentication")
            , icon = Input.defaultCheckbox
            }
        , row [ width fill, spaceEvenly ]
            [ cancelButton { msg = OnResetForm, label = "Reset", enabled = initialForm user.id /= user }
            , confirmButton { msg = AddUser user, label = "Add user", enabled = userValid user }
            ]
        ]


usersView : Model -> List (Html Msg)
usersView model =
    [ layout [ Font.size 14 ] <|
        column [ width fill, spacing 40 ]
            [ userInputView model
            , el [ centerX ] (usersTable model)
            ]
    ]


view : Model -> View Msg
view model =
    { title = "Users"
    , body = usersView model
    }

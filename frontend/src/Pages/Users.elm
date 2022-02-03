module Pages.Users exposing (Model, Msg, page)

import Api.InputObject exposing (UserInput, buildUserInput)
import Api.Mutation exposing (CreateUserRequiredArguments, createUser)
import Api.Object exposing (CreateUserPayload, UserDto)
import Api.Object.CreateUserPayload as CreateUserPayload
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
import Utility exposing (RequestState(..), makeGraphQLQuery)
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
    }


type alias User =
    { userName : String
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


initialForm : User
initialForm =
    { userName = ""
    , email = ""
    , emailConfirmed = False
    , phoneNumber = ""
    , phoneNumberConfirmed = False
    , twoFactorEnabled = False
    }


init : Shared.Model -> ( Model, Effect Msg )
init sharedModel =
    ( { displayNewUserForm = False
      , form = initialForm
      , formValid = False
      , userList = []
      , seed = sharedModel.seed
      }
    , Effect.fromCmd makeRequest
    )



-- Get registered users


selectUser : SelectionSet User UserDto
selectUser =
    SelectionSet.map6 User
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
        { userId = Utility.uuidToApiUuid id
        , email = user.email
        , phoneNumber = user.phoneNumber
        , twoFactorEnabled = user.twoFactorEnabled
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



-- UPDATE


type Msg
    = Success User
    | UsersLoaded (List User)
    | ApiError String
    | CancelAddUser
    | RequestState String
    | RequestFailed String
    | DeleteUser User
    | AddUser User
    | Update User
    | ToggleTwoFactor Bool
    | OnResetForm
    | CouldNotAddUser


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    let
        form =
            model.form
    in
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

        Success _ ->
            ( model, Effect.none )

        DeleteUser _ ->
            -- TODO: Add deletion
            ( model, Effect.none )

        AddUser user ->
            let
                ( newUuid, newSeed ) =
                    Random.step Uuid.uuidGenerator model.seed

                mutate =
                    getUserInsertObject user newUuid |> performUserMutation
            in
            ( model
            , Effect.batch
                [ Effect.fromCmd mutate
                , Effect.fromShared (Shared.GenerateNewUuid newSeed)
                ]
            )

        CouldNotAddUser ->
            ( model, Effect.none )

        Update user ->
            ( { model | form = user }, Effect.none )

        ToggleTwoFactor bool ->
            ( { model | form = { form | twoFactorEnabled = bool } }, Effect.none )

        OnResetForm ->
            ( { model | form = initialForm }, Effect.none )


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
            [ el ((width <| fillPortion 5) :: headerAttrs) <| text "User name"
            , el ((width <| fillPortion 4) :: headerAttrs) <| text "Email"
            , el ((width <| fillPortion 3) :: headerAttrs) <| text "Phone"
            , el ((width <| fillPortion 2) :: headerAttrs) <| text "Two factor"
            , el ((width <| fillPortion 1) :: headerAttrs) <| text " "
            ]
        , el [ width fill ] <|
            table
                [ width fill
                , height <| px 250
                , scrollbarY
                , spacing 10
                ]
                { data = model.userList
                , columns =
                    [ { header = none
                      , width = fillPortion 2
                      , view =
                            \user ->
                                Element.text user.userName
                      }
                    , { header = none
                      , width = fillPortion 3
                      , view =
                            \user ->
                                Element.text user.email
                      }
                    , { header = none
                      , width = fillPortion 4
                      , view =
                            \user ->
                                Element.text user.phoneNumber
                      }
                    , { header = none
                      , width = fillPortion 1
                      , view =
                            \user ->
                                Element.text
                                    (if user.twoFactorEnabled then
                                        "Yes"

                                     else
                                        "No"
                                    )
                      }
                    , { header = none
                      , width = fillPortion 1
                      , view =
                            \user ->
                                UI.Button.cancelButton
                                    { msg = DeleteUser user
                                    , label = "Delete"
                                    , enabled = False
                                    }
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
            , onChange = ToggleTwoFactor
            , label = Input.labelRight [ centerY ] (text "Use two factor authentication")
            , icon = Input.defaultCheckbox
            }
        , row [ width fill, spaceEvenly ]
            [ cancelButton { msg = OnResetForm, label = "Reset", enabled = initialForm /= user }
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

module Pages.Users exposing (Model, Msg, page)

import Api.InputObject exposing (UserInput, UserInputRequiredFields, buildUserInput)
import Api.Mutation exposing (CreateUserRequiredArguments, createUser)
import Api.Object exposing (CreateUserPayload, UserDto)
import Api.Object.CreateUserPayload as CreateUserPayload
import Api.Object.UserDto as UserDto
import Api.Query as Query
import Effect exposing (Effect)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Graphql.Http
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Html exposing (Html)
import Http exposing (Error)
import Page exposing (Page)
import RemoteData exposing (RemoteData)
import Request exposing (Request)
import Shared
import UI.Button exposing (cancelButton, confirmButton)
import UI.Color exposing (color)
import Utility exposing (RequestState(..), makeGraphQLMutation, makeGraphQLQuery)
import View exposing (View)


page : Shared.Model -> Request -> Page.With Model Msg
page _ _ =
    Page.protected.advanced
        (\_ ->
            { init = init
            , update = update
            , view = view
            , subscriptions = subscriptions
            }
        )


type alias Model =
    { displayNewUserForm : Bool
    , form : User
    , formValid : Bool
    , userList : List User
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


insertUserObject : User -> UserInput
insertUserObject user =
    buildUserInput
        (UserInputRequiredFields user.userName user.twoFactorEnabled)
        (\args ->
            { args
                | email = Present user.email
                , phoneNumber = Present user.phoneNumber
            }
        )


insertArgs : User -> CreateUserRequiredArguments
insertArgs user =
    CreateUserRequiredArguments (insertUserObject user)


getUserInsertObject : User -> SelectionSet (Maybe User) RootMutation
getUserInsertObject user =
    createUser (insertArgs user) mutationResponse


mutationResponse : SelectionSet (Maybe User) CreateUserPayload
mutationResponse =
    CreateUserPayload.user selectUser


makeMutation : SelectionSet (Maybe User) RootMutation -> Cmd Msg
makeMutation mutation =
    (Graphql.Http.withSimpleHttpError >> RemoteData.fromResult >> gotUser) |> makeGraphQLMutation mutation


gotUser : RemoteData (Graphql.Http.RawError (Maybe User) Http.Error) (Maybe User) -> Msg
gotUser result =
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



-- INIT


initialForm : User
initialForm =
    User "" "" False "" False False


init : ( Model, Effect Msg )
init =
    ( { displayNewUserForm = False
      , form = initialForm
      , formValid = False
      , userList = []
      }
    , Effect.fromCmd makeRequest
    )



-- UPDATE


type Msg
    = CreateNew
    | ClickMe
    | Update User
    | Add User
    | CouldNotAddUser
    | Success User
    | UsersLoaded (List User)
    | ApiError String
    | CancelAddUser
    | RequestState String
    | RequestFailed String


checkValidUser : User -> Bool
checkValidUser user =
    String.length user.email > 5 && String.length user.userName > 5


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ClickMe ->
            ( model, Effect.none )

        CreateNew ->
            ( { model | displayNewUserForm = True }, Effect.none )

        Update form ->
            ( { model | form = form, formValid = checkValidUser form }, Effect.none )

        Add newUser ->
            let
                mutationObject =
                    getUserInsertObject newUser
            in
            ( { displayNewUserForm = False, form = initialForm, formValid = False, userList = newUser :: model.userList }, Effect.fromCmd (makeMutation mutationObject) )

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

        CouldNotAddUser ->
            ( model, Effect.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Users"
    , body = usersView model
    }


usersTable : Model -> Element msg
usersTable model =
    let
        headerAttrs =
            [ Font.bold
            , Font.color (rgb255 0x72 0x9F 0xCF)
            , Border.widthEach { bottom = 1, top = 0, left = 0, right = 0 }
            ]
    in
    table [ width <| maximum 1200 <| minimum 1000 fill, spacingXY 0 10 ]
        { data = model.userList
        , columns =
            [ { header = el headerAttrs <| Element.text "User name"
              , width = fill
              , view =
                    \user ->
                        Element.text user.userName
              }
            , { header = el headerAttrs <| Element.text "Email"
              , width = fill
              , view =
                    \user ->
                        Element.text user.email
              }
            , { header = el headerAttrs <| Element.text "Phone"
              , width = fill
              , view =
                    \user ->
                        Element.text user.phoneNumber
              }
            , { header = el headerAttrs <| Element.text "Two factor"
              , width = fill
              , view =
                    \user ->
                        Element.text
                            (if user.twoFactorEnabled then
                                "X"

                             else
                                ""
                            )
              }
            ]
        }


addUserForm : Model -> Element Msg
addUserForm model =
    let
        form =
            model.form
    in
    column
        [ width (px 400)
        , height shrink
        , spacing 36
        , padding 10
        , Border.rounded 5
        , Border.shadow { offset = ( 1, 1 ), size = 0.5, blur = 10, color = color.black }
        , Background.color color.white
        ]
        [ el
            [ Region.heading 1
            , alignLeft
            , Font.size 24
            ]
            (text "Add a new user")
        , Input.email
            [ width <| maximum 400 fill ]
            { text = form.email
            , placeholder = Nothing
            , onChange = \new -> Update { form | email = new }
            , label = Input.labelLeft [ width (px 150), centerY ] (text "Email:")
            }
        , Input.username
            [ width <| maximum 400 fill ]
            { text = form.userName
            , placeholder = Nothing
            , onChange = \new -> Update { form | userName = new }
            , label = Input.labelLeft [ width (px 150), centerY ] (text "User name:")
            }
        , Input.text
            [ width <| maximum 400 fill ]
            { text = form.phoneNumber
            , placeholder = Nothing
            , onChange = \new -> Update { form | phoneNumber = new }
            , label = Input.labelLeft [ width (px 150), centerY ] (text "Phone number:")
            }
        , Input.checkbox
            [ centerX ]
            { checked = form.twoFactorEnabled
            , onChange = \new -> Update { form | twoFactorEnabled = new }
            , label = Input.labelRight [ centerY ] (text "Use two factor authentication")
            , icon = Input.defaultCheckbox
            }
        , row [ width fill, spaceEvenly ]
            [ cancelButton { msg = CancelAddUser, label = "Cancel", enabled = True }
            , confirmButton { msg = Add form, label = "Add user", enabled = model.formValid }
            ]
        ]


usersView : Model -> List (Html Msg)
usersView model =
    let
        displayForm =
            if model.displayNewUserForm then
                el [ centerX ] <| addUserForm model

            else
                none
    in
    [ layout [ width fill, height fill, padding 50 ] <|
        column [ width fill, spacing 40 ]
            [ el [ centerX ] <| confirmButton { msg = CreateNew, label = "Create new user", enabled = not model.displayNewUserForm }
            , el [ centerX, Element.inFront displayForm ]
                (usersTable model)
            ]
    ]

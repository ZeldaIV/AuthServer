module Pages.User.Id_ exposing (Model, Msg, page)

import Api.InputObject exposing (UserInput, buildUserInput)
import Api.Mutation exposing (CreateUserRequiredArguments, RemoveClaimFromUserRequiredArguments, createUser)
import Api.Object exposing (ClaimDto, CreateUserPayload, UserClaimDto, UserDto)
import Api.Object.CreateUserPayload as CreateUserPayload
import Api.Object.UserClaimDto as UserClaimDto
import Api.Object.UserDto as UserDto
import Api.Query as Query
import Effect exposing (Effect)
import Element exposing (Element, alignLeft, centerX, centerY, column, el, fill, height, layout, maximum, minimum, padding, px, rgb255, row, shrink, spaceEvenly, spacing, spacingXY, table, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Gen.Params.User.Id_ exposing (Params)
import Graphql.Http
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Html exposing (Html)
import Http
import Page
import Random
import RemoteData exposing (RemoteData)
import Request
import Shared
import UI.Button as Ui exposing (cancelButton, confirmButton)
import UI.Color exposing (color)
import Utility exposing (RequestState(..), makeGraphQLMutation, makeGraphQLQuery)
import Uuid
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page shared req =
    Page.advanced
        { init = init shared req
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Claim =
    { type_ : String
    , value : String
    }


type alias User =
    { id : String
    , email : String
    , phoneNumber : String
    , twoFactorEnabled : Bool
    , claims : List Claim
    }


type alias Model =
    { userClaims : List Claim
    , form : User
    , user : User
    , formValid : Bool
    }


initialUser : String -> User
initialUser id =
    { id = id
    , email = ""
    , phoneNumber = ""
    , twoFactorEnabled = False
    , claims = []
    }


init : Shared.Model -> Request.With Params -> ( Model, Effect Msg )
init sharedModel req =
    let
        ( newUuid, newSeed ) =
            Random.step Uuid.uuidGenerator sharedModel.seed

        requestUserId =
            case Uuid.fromString req.params.id of
                Just _ ->
                    req.params.id

                Nothing ->
                    ""

        ( userId, effect ) =
            case requestUserId of
                "" ->
                    ( Uuid.toString newUuid
                    , Effect.fromShared (Shared.GenerateNewUuid newSeed)
                    )

                _ ->
                    ( requestUserId
                    , Effect.fromCmd (getUser requestUserId |> makeUserQuery)
                    )
    in
    ( { userClaims = []
      , form = initialUser userId
      , user = initialUser userId
      , formValid = False
      }
    , effect
    )



-- UPDATE


selectClaim : SelectionSet Claim UserClaimDto
selectClaim =
    SelectionSet.map2 Claim
        UserClaimDto.type_
        UserClaimDto.value


selectUser : SelectionSet User UserDto
selectUser =
    SelectionSet.map5 User
        UserDto.id
        UserDto.email
        (SelectionSet.withDefault "" UserDto.phoneNumber)
        UserDto.twoFactorEnabled
        (UserDto.claims selectClaim)



-- create new user


insertUserObject : User -> UserInput
insertUserObject user =
    buildUserInput
        { id = user.id
        , email = user.email
        , phoneNumber = user.phoneNumber
        , twoFactorEnabled = user.twoFactorEnabled
        , userName = user.email
        }


insertArgs : User -> CreateUserRequiredArguments
insertArgs user =
    CreateUserRequiredArguments (insertUserObject user)


getUserInsertObject : User -> SelectionSet (Maybe User) RootMutation
getUserInsertObject user =
    createUser (insertArgs user) createUserPayload


createUserPayload : SelectionSet (Maybe User) CreateUserPayload
createUserPayload =
    CreateUserPayload.user selectUser


performUserMutation : SelectionSet (Maybe User) RootMutation -> Cmd Msg
performUserMutation mutation =
    (Graphql.Http.withSimpleHttpError >> RemoteData.fromResult >> newUserResponse) |> makeGraphQLMutation mutation


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



-- get existing user


deleteArgs : User -> Claim -> RemoveClaimFromUserRequiredArguments
deleteArgs user claim =
    { userId = user.id
    , claimType = claim.type_
    }


getUser : String -> SelectionSet (Maybe User) RootQuery
getUser id =
    Query.userById (Query.UserByIdRequiredArguments id) selectUser


makeUserQuery : SelectionSet (Maybe User) RootQuery -> Cmd Msg
makeUserQuery query =
    (Graphql.Http.withSimpleHttpError >> RemoteData.fromResult >> userResponse) |> makeGraphQLQuery query


userResponse : RemoteData (Graphql.Http.RawError (Maybe User) Http.Error) (Maybe User) -> Msg
userResponse result =
    case Utility.response result of
        RequestSuccess maybeUser ->
            case maybeUser of
                Just user ->
                    Success user

                Nothing ->
                    CouldNotGetUser

        State state ->
            RequestState state

        RequestError err ->
            RequestFailed err



-- remove claim from user


type Msg
    = EmailChanged String
    | ToggleTwoFactor Bool
    | PhoneNumberChanged String
    | OnResetForm
    | SaveChanges User
    | Success User
    | CouldNotAddUser
    | CouldNotGetUser
    | RequestState String
    | RequestFailed String
    | RemoveClaimFromUser Claim


validForm : User -> Bool
validForm user =
    String.length user.email >= 4 && String.length user.phoneNumber >= 8


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    let
        form =
            model.form

        valid =
            validForm model.form
    in
    case msg of
        EmailChanged string ->
            ( { model | form = { form | email = string }, formValid = valid }, Effect.none )

        ToggleTwoFactor bool ->
            ( { model | form = { form | twoFactorEnabled = bool } }, Effect.none )

        PhoneNumberChanged string ->
            ( { model | form = { form | phoneNumber = string }, formValid = valid }, Effect.none )

        OnResetForm ->
            ( { model | form = model.user }, Effect.none )

        SaveChanges user ->
            let
                mutate =
                    getUserInsertObject user |> performUserMutation
            in
            ( model, Effect.fromCmd mutate )

        Success user ->
            ( { model | form = user, user = user }, Effect.none )

        CouldNotAddUser ->
            ( model, Effect.none )

        RequestState _ ->
            ( model, Effect.none )

        CouldNotGetUser ->
            ( model, Effect.none )

        RemoveClaimFromUser claim ->
            ( model, Effect.none )

        RequestFailed _ ->
            ( model, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


userForm : Model -> Element Msg
userForm model =
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
            , onChange = EmailChanged
            , label = Input.labelLeft [ width (px 150), centerY ] (text "Email:")
            }
        , Input.text
            [ width <| maximum 400 fill ]
            { text = form.phoneNumber
            , placeholder = Nothing
            , onChange = PhoneNumberChanged
            , label = Input.labelLeft [ width (px 150), centerY ] (text "Phone number:")
            }
        , Input.checkbox
            [ centerX ]
            { checked = form.twoFactorEnabled
            , onChange = ToggleTwoFactor
            , label = Input.labelRight [ centerY ] (text "Use two factor authentication")
            , icon = Input.defaultCheckbox
            }
        , row [ width fill, spaceEvenly ]
            [ cancelButton { msg = OnResetForm, label = "Cancel", enabled = True }
            , confirmButton { msg = SaveChanges form, label = "Add user", enabled = model.formValid }
            ]
        ]


userClaimsTable : Model -> Element Msg
userClaimsTable model =
    let
        headerAttrs =
            [ Font.bold
            , Font.color (rgb255 0x72 0x9F 0xCF)
            , Border.widthEach { bottom = 1, top = 0, left = 0, right = 0 }
            ]

        userClaims =
            model.user.claims
    in
    table [ width <| maximum 1200 <| minimum 1000 fill, spacingXY 0 10 ]
        { data = userClaims
        , columns =
            [ { header = el headerAttrs <| Element.text "Type"
              , width = fill
              , view =
                    \claim ->
                        Element.text claim.type_
              }
            , { header = el headerAttrs <| Element.text "Value"
              , width = fill
              , view =
                    \claim ->
                        Element.text claim.value
              }
            , { header = el headerAttrs <| Element.text "Remove"
              , width = fill
              , view =
                    \claim ->
                        Ui.confirmButton
                            { enabled = True
                            , label = "Remove"
                            , msg = RemoveClaimFromUser claim
                            }
              }
            ]
        }


usersView : Model -> List (Html Msg)
usersView model =
    [ layout [ width fill, height fill, padding 50 ] <|
        column [ width fill, spacing 40 ]
            [ userForm model
            , userClaimsTable model
            ]
    ]


view : Model -> View Msg
view model =
    { title = "User"
    , body = usersView model
    }

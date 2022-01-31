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
import Gen.Route
import Graphql.Http
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Html exposing (Html)
import Http exposing (Error)
import Page exposing (Page)
import Random
import RemoteData exposing (RemoteData)
import Request exposing (Request)
import Shared
import UI.Button exposing (cancelButton, confirmButton)
import UI.Color exposing (color)
import Utility exposing (RequestState(..), makeGraphQLMutation, makeGraphQLQuery)
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



-- INIT


initialForm : User
initialForm =
    User "" "" False "" False False


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



-- UPDATE


type Msg
    = Success User
    | UsersLoaded (List User)
    | ApiError String
    | CancelAddUser
    | RequestState String
    | RequestFailed String
    | OnAddNewUser


checkValidUser : User -> Bool
checkValidUser user =
    String.length user.email > 5 && String.length user.userName > 5


update : Request -> Msg -> Model -> ( Model, Effect Msg )
update req msg model =
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

        OnAddNewUser ->
            let
                ( newUuid, newSeed ) =
                    Random.step Uuid.uuidGenerator model.seed
            in
            ( model
            , Effect.batch
                [ Effect.fromCmd (Request.replaceRoute (Gen.Route.User__Id_ { id = Uuid.toString newUuid }) req)
                , Effect.fromShared (Shared.GenerateNewUuid newSeed)
                ]
            )


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


usersView : Model -> List (Html Msg)
usersView model =
    [ layout [ width fill, height fill, padding 50 ] <|
        column [ width fill, spacing 40 ]
            [ el [ centerX ] <| confirmButton { msg = OnAddNewUser, label = "Create new user", enabled = not model.displayNewUserForm }
            , usersTable model
            ]
    ]

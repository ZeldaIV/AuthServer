module Pages.Users exposing (Model, Msg, page)

import Data.UserDto as UserDto exposing (UserDto)
import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Html exposing (Html)
import Page exposing (Page)
import Request exposing (Request)
import Shared
import UI.Button exposing (button)
import UI.Color exposing (color)
import View exposing (View)


page : Shared.Model -> Request -> Page.With Model Msg
page _ _ =
    Page.protected.element
        (\_ ->
            { init = init
            , update = update
            , view = view
            , subscriptions = subscriptions
            }
        )



-- INIT
-- type alias Form =
--     { userName : String
--     , email : String
--     , phoneNumber : Maybe Int
--     , twoFactorEnabled : Bool
--     }


type alias User =
    { userName : String
    , email : String
    , phoneNumber : String
    , twoFactorEnabled : Bool
    }


type alias Model =
    { displayNewUserForm : Bool
    , form : User
    , formValid : Bool
    , userList : List User
    }


initialForm : User
initialForm =
    User "" "" "" False


init : ( Model, Cmd Msg )
init =
    ( { displayNewUserForm = False
      , form = initialForm
      , formValid = True
      , userList =
            [ { userName = "David"
              , email = "Bowie"
              , phoneNumber = "23445"
              , twoFactorEnabled = False
              }
            , { userName = "David"
              , email = "Bowie"
              , phoneNumber = "23445"
              , twoFactorEnabled = True
              }
            ]
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = CreateNew
    | ClickMe
    | Update User
    | Add User


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickMe ->
            ( model, Cmd.none )

        CreateNew ->
            ( { model | displayNewUserForm = True }, Cmd.none )

        Update form ->
            ( { model | form = form }, Cmd.none )

        Add newUser ->
            ( { displayNewUserForm = False, form = initialForm, formValid = True, userList = newUser :: model.userList }, Cmd.none )


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
    table [ width <| maximum 1000 <| minimum 600 fill, spacingXY 0 10 ]
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


maybeNumberToString : Maybe Int -> String
maybeNumberToString n =
    case n of
        Just j ->
            String.fromInt j

        Nothing ->
            ""


stringToNumber : String -> Maybe Int
stringToNumber s =
    String.toInt s


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
        ]
        [ el
            [ Region.heading 1
            , alignLeft
            , Font.size 24
            ]
            (text "Add a new user")
        , Input.text
            [ width <| maximum 400 fill ]
            { text = form.email
            , placeholder = Nothing
            , onChange = \new -> Update { form | email = new }
            , label = Input.labelLeft [ width (px 150), centerY ] (text "Email:")
            }
        , Input.text
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
        , button { msg = Add form, textContent = "Add user", enabled = model.formValid }
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
            [ el [ centerX ] <| button { msg = CreateNew, textContent = "Create new user", enabled = not model.displayNewUserForm }
            , displayForm
            , el [ centerX ] (usersTable model)
            ]
    ]

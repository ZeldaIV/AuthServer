module Pages.Users exposing (Model, view, Msg, init, update)

import Browser.Navigation as Nav
import Html exposing (Html, div, h1, text)
import Skeleton



init : Nav.Key -> ( Model, Cmd msg )
init key =
    ( Model "" key
    , Cmd.none
    )

type alias Model =
    { username: String, key: Nav.Key}
    

type alias ListOfUsers =
    {users: List User}
    
type alias User =
    { username: String}
    

type Msg =
    UserMsg String
    
view : Model -> Skeleton.Details Msg
view model  =
    { title = "Users"
                , header =" yoyoy"
                , attrs = []
                , kids = [
                    div [] [
                                                  h1 [] [ text "Hello from users"]]
                        ]
                }
    
        
        
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserMsg smsg ->
            ({model | username=smsg}, Cmd.none)
module Pages.Clients exposing (Model, view, Msg, init, update)

import Browser.Navigation as Nav
import Html exposing (Html, div, h1, text)
import Skeleton



init : Nav.Key -> ( Model, Cmd msg )
init key =
    ( Model "" key
    , Cmd.none
    )

type alias Model =
    { name: String, key: Nav.Key}
    

type alias ListOfClients =
    {users: List Client}
    
type alias Client =
    { name: String}
    

type Msg =
    ClientMsg String
    
    
view : Model -> Skeleton.Details Msg
view model  =
    { title = "Clients"
    , header =" yoyoy"
    , attrs = []
    , kids = [
        div [] [
          h1 [] [ text "Hello from clients"]]
            ]
    }
    
        
        
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClientMsg smsg ->
            ({model | name=smsg}, Cmd.none)
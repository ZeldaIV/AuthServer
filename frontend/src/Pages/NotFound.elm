module Pages.NotFound exposing (view, Msg)

import Html exposing (Html, div, h1, text)
import Skeleton


type Msg
    = NoMessage

-- VIEW

view : Skeleton.Details Msg
view =
    { title = "Page Not Found"
    , header = "Could not find what you are looking for"
    , attrs = []
    , kids = [
         div [] [
               h1 [] [ text "Hello from not found"]]
             ]
            
    }

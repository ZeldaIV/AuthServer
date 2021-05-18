module Pages.Top exposing (Msg, page)

import Html exposing (..)
import Shared
import Page exposing (Page)
import Request exposing (Request)
import View exposing (View)


type alias Msg =
    Never


page : Shared.Model -> Request -> Page
page _ req =
    Page.static
        { view = view req
        }

-- VIEW


view : Request -> View Msg
view { params } =
    { title = "Homepage"
    , body = [ text "Homepage" ]
    }

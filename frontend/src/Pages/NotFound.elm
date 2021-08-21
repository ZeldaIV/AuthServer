module Pages.NotFound exposing (Msg, page)

import Html exposing (..)
import Page exposing (Page)
import Request exposing (Request)
import Shared
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
    { title = "404"
    , body =
        [ text "Not found"
        ]
    }


module Skeleton exposing ( view, Details)

import Browser exposing (Document)
import Html exposing (Attribute, Html, div, h1, text)
import Html.Attributes exposing (class)

    
type alias Details msg =
  { title : String
  , header : String
  , attrs : List (Attribute msg)
  , kids : List (Html msg)
  }

  
view : (a -> msg) -> Details a -> Browser.Document msg
view toMsg details =
  { title =
      details.title
  , body =
      [  Html.map toMsg <|
          div (class "center" :: details.attrs) details.kids
      ]
  }

viewHeader : msg -> Html msg
viewHeader page  =
    div [] [
        h1 [] [ text "Hello"]]
        

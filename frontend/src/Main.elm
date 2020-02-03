module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Pages.Clients as Clients
import Pages.NotFound as NotFound
import Pages.Root as Root
import Pages.Users as Users
import Route exposing (Route)
import Skeleton
import Url


-- MAIN


main : Program () Model Msg
main =
    Browser.application { init = init, 
    view = view,
     update = update,
      subscriptions = subscriptions, onUrlChange = UrlChanged, onUrlRequest = LinkClicked }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
  changeRouteTo (Route.fromUrl url)
        (Login {username="", password="", key=key} )


-- MODEL

type Model 
    = NotFound Nav.Key
    | Users Users.Model
    | Clients Clients.Model
    | Login Root.Model
    

-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | NoMessage NotFound.Msg
    | GotLoginMsg Root.Msg
    | GotUsersMsg Users.Msg
    | GotClientsMsg Clients.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (msg, model) of
        (LinkClicked urlRequest, _) ->
              case urlRequest of
                Browser.Internal url ->
                  ( model
                  , Nav.pushUrl (toKey model) (Url.toString url)
                  )

                Browser.External href ->
                  ( model
                  , Nav.load href
                  )

        (UrlChanged url, _) ->
              changeRouteTo (Route.fromUrl url) model

        (GotLoginMsg subMsg, Login login) ->
            Root.update subMsg login |>
                updateWith Login GotLoginMsg model

        (GotClientsMsg subMsg, Clients clients) ->
            Clients.update subMsg clients |>
                            updateWith Clients GotClientsMsg model

        (GotUsersMsg subMsg, Users users) ->
            Users.update subMsg users |>
                            updateWith Users GotUsersMsg model
                
        (_, _) ->
            -- Disregard messages that arrived for the wrong page.
            ( model, Cmd.none )
                

changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let 
        key = 
            toKey model
    in
    case maybeRoute of
        Nothing ->
            Debug.log "Whaaat?"
            ( NotFound key, Cmd.none )

        Just Route.Login ->
            Root.init key |>
                updateWith Login GotLoginMsg model
        
        Just Route.Clients ->
            Clients.init key |>
                updateWith Clients GotClientsMsg model

        Just Route.Users ->
            Users.init key |>
                updateWith Users GotUsersMsg model

updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )


toKey: Model -> Nav.Key
toKey model =
    case model of
        NotFound m->
            m
        Login l ->
            l.key
        Users u ->
            u.key
        Clients c ->
            c.key

-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none

-- VIEW


view : Model -> Browser.Document Msg
view model =
    case model of
       NotFound _ ->
          Skeleton.view NoMessage NotFound.view
            
       Login root -> 
            Skeleton.view GotLoginMsg (Root.view root)
           
       Users users ->
            Skeleton.view GotUsersMsg (Users.view users)
            
       Clients clients ->
            Skeleton.view GotClientsMsg (Clients.view clients)


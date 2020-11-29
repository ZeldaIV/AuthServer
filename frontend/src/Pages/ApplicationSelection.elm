module Pages.ApplicationSelection exposing (Params, Model, Msg, page)

import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Text as Text
import Data.ApiResourceDto exposing (ApiResourceDto)
import Html exposing (Html, h1, text)
import Html.Attributes exposing (for, style)
import Http exposing (Error)
import Request.ApiResource as ApiResource
import Spa.Document exposing (Document)
import Spa.Page as Page exposing (Page)
import Spa.Url as Url exposing (Url)
import Uuid


page : Page Params Model Msg
page =
    Page.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- INIT


type alias Params =
    ()


type alias Model =
    { form: Form
    , mode: ApplicationMode}


init : Url Params -> ( Model, Cmd Msg )
init { params } =
    ( {form = Form "" "" "", mode = None }, Cmd.none )



-- UPDATE


type alias Form = { name: String, displayName: String, description: String}

fromFormToModel: Form -> ApiResourceDto
fromFormToModel form = 
    { name = Just form.name
    , displayName = Just form.displayName
    , description = Just form.description
    , apiSecrets = Nothing
    , scopes = Nothing
    , enabled = Just True }
    
    
addedNewResource: Result Error () -> Msg
addedNewResource result =
    case result of
        Ok value ->
            AddApplicationMode None

        Err error ->
            AddApplicationMode None
        
            

type ApplicationMode
    = None
    | ApiResourceMode
    | ClientMode
    
-- update
    
type Msg
    = AddApplicationMode ApplicationMode
    | AddApiResource Form
    | NameEntered String
    | DisplayNameEntered String
    | DescriptionEntered String
    
    
update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        AddApplicationMode mode ->
            ( {model | mode = mode} , Cmd.none )

        AddApiResource form ->
           -- TODO: Call api
           ( model , ApiResource.apiResourcePut { onSend = addedNewResource, body = Just (form |> fromFormToModel)} )

        NameEntered name ->
            let
                form = model.form
            in
                ({model | form = { form | name = name}}, Cmd.none)

        DisplayNameEntered displayName ->
            let
                form = model.form
            in
                ({model | form = { form | displayName = displayName}}, Cmd.none)

        DescriptionEntered description ->
            let
                form = model.form
            in
                ({model | form = { form | description = description}}, Cmd.none)
    


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    { title = "ApplicationSelection"
    , body = [ applicationSelectionView model ]
    }
    
applicationSelectionView: Model -> Html Msg
applicationSelectionView model =
    let
        applicationMode = model.mode
    in
    case applicationMode of
        None ->
            chooseApplicationView model                   
        ApiResourceMode ->
            apiResourceView model.form
    
        ClientMode ->
             h1 [] [ text "Fill out client"]

apiResourceView: Form -> Html Msg
apiResourceView form =
    Grid.container []
    [ h1 [] [ text "Fill out api"]
    , Grid.row []
        [ Grid.col []
            [ Form.form [] 
                [ Form.group [] [
                    Form.label [for "Name"] [ text "Name"]
                    , Input.text [ Input.id "Name", Input.value form.name, Input.onInput NameEntered ]]
                  
                  , Form.group [] [
                    Form.label [ for "DisplayName"] [text "Display name"]
                    , Input.text [ Input.id "DisplayName", Input.value form.displayName, Input.onInput DisplayNameEntered ]
                    , Form.help [] [ text "Will be displayed on a Consent screen, otherwise Name will be used"] 
                  ]
                  
                  , Form.group [] [
                    Form.label [ for "Description"] [text "Description"]
                    , Input.text [ Input.id "Description", Input.value form.description, Input.onInput DescriptionEntered ]
                    , Form.help [] [ text "Will be displayed on a Consent screen"]
                  ]
                  , Grid.container [] 
                    [ Grid.row [] 
                        [ Grid.col [] [ Button.button [ Button.danger, Button.onClick (AddApplicationMode None) ] [ text "Cancel"] ]
                        , Grid.col [Col.xs2, Col.mdAuto] []
                        , Grid.col [] [ Button.button [ Button.primary, Button.onClick (AddApiResource form) ] [ text "Add"] ]
                        ]
                    ]
                ]
            ]
        , Grid.col [] []
        ]
        
        
    ]
    
    
    
chooseApplicationView: Model -> Html Msg
chooseApplicationView model =
    Grid.container []
        [ h1 [] [ text "Add a new application"]
          ,Grid.row [ Row.centerLg ]
          [ Grid.col [Col.xs, Col.mdAuto] [ addApiResourceView model ] 
          , Grid.col [Col.xs12, Col.mdAuto] []
          , Grid.col [Col.xs, Col.mdAuto] [ addApiConsumerView model ]
          ]
        ]
            
    
addApiResourceView: Model -> Html Msg
addApiResourceView _ =
    Card.config [Card.attrs [ style "width" "20rem" ]]
         |> Card.headerH3 [] [ text "Add Resource"]
         |> Card.block []
             [ Block.titleH3 [] [ text "Add an API resource" ]
             , Block.text [] [ text "Choose this if you want to add a resource, such as an API for consumption" ]]
         |> Card.block [Block.align Text.alignXsRight] 
            [Block.custom <|
                 Button.button [ Button.primary, Button.onClick (AddApplicationMode ApiResourceMode) ] [ text "Select" ]
             ]
         |> Card.view
         
addApiConsumerView: Model -> Html Msg
addApiConsumerView _ =
    Card.config [Card.attrs [ style "width" "20rem" ]]
         |> Card.headerH3 [] [ text "Add Consumer"]
         |> Card.block []
             [ Block.titleH3 [] [ text "Add an API consumer" ]
             , Block.text [] [ text "Choose this if you want to add a consumer of an API" ]]
         |> Card.block [Block.align Text.alignXsRight] 
            [Block.custom <|
                 Button.button [ Button.primary, Button.onClick (AddApplicationMode ClientMode) ] [ text "Select" ]
             ]
         |> Card.view
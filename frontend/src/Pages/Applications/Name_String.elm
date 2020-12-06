module Pages.Applications.Name_String exposing (Params, Model, Msg, page)

import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Checkbox as Checbox
import Bootstrap.Form.Fieldset as Fieldset
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Data.ApiResourceDto exposing (ApiResourceDto)
import Html exposing (h1, text)
import Shared
import Spa.Document exposing (Document)
import Spa.Page as Page exposing (Page)
import Spa.Url as Url exposing (Url)


page : Page Params Model Msg
page =
    Page.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , save = save
        , load = load
        }



-- INIT


type alias Params =
    { name : String }


type alias Model =
    { apiResource: ApiResource 
    }

type alias ApiResource =
    { enabled : Bool
    , name : String
    , displayName : String
    , description : String
    , apiSecrets : (List String)
    , scopes : (List String)
    }

init : Shared.Model -> Url Params -> ( Model, Cmd Msg )
init shared { params } =
    ( {apiResource = (resourceFromList params.name shared.apiResources) |> dtoToModel}, Cmd.none )


dtoToModel: Maybe ApiResourceDto -> ApiResource
dtoToModel dto =
    case dto of
        Just d ->
            { enabled = (Maybe.withDefault False d.enabled)
            , name = (Maybe.withDefault "" d.name)
            , displayName = (Maybe.withDefault "" d.displayName)
            , description = (Maybe.withDefault "" d.description)
            , apiSecrets = (Maybe.withDefault [""] d.apiSecrets)
            , scopes = (Maybe.withDefault [""] d.scopes)}
        Nothing ->
            { enabled = False
            , name = ""
            , displayName = ""
            , description = ""
            , apiSecrets = [""]
            , scopes = [""]} 
            

resourceFromList: String -> Maybe (List ApiResourceDto) -> Maybe ApiResourceDto
resourceFromList name resources =
    case resources of
        Just a ->
            List.head (List.filter (matchingName name) a)
        Nothing ->
            Nothing

matchingName: String -> ApiResourceDto -> Bool
matchingName name resource =
    case resource.name of
        Just a ->        
            a == name
        Nothing ->
            False
            
            
resourceName: ApiResource -> String
resourceName resource =
    resource.name
    
-- UPDATE


type Msg
    = NameEntered String
    | DisplayNameEntered String
    | DescriptionEntered String
    | Enabled Bool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NameEntered name ->
            let resource = model.apiResource
            in
            ({ model | apiResource = {resource | name = name} }, Cmd.none)

        DisplayNameEntered displayName ->
            let resource = model.apiResource
            in
            ({ model | apiResource = {resource | displayName = displayName} }, Cmd.none)

        DescriptionEntered description ->
            let resource = model.apiResource
            in
            ({ model | apiResource = {resource | description = description} }, Cmd.none)

        Enabled enabled ->
            let resource = model.apiResource
            in
            ({ model | apiResource = {resource | enabled = enabled} }, Cmd.none)
        


save : Model -> Shared.Model -> Shared.Model
save model shared =
    shared


load : Shared.Model -> Model -> ( Model, Cmd Msg )
load shared model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    { title = (resourceName model.apiResource)
    , body = [ Grid.container [] 
                [ h1 [] [text model.apiResource.name]
                , Form.form []
                    [ Form.row [] 
                      [ Form.colLabel [Col.sm2] [ text "Resource name:" ]
                      , Form.col [Col.sm10] 
                        [ Grid.row [] 
                          [ Grid.col [Col.xs4] 
                            [ Input.text [Input.id "name", Input.value model.apiResource.name, Input.onInput NameEntered]
                            , Form.help [] [ text "The name of the resource."]]
                          ]
                         ]
                      ]
                    , Form.row [] 
                      [ Form.colLabel [Col.sm2] [ text "Display name:" ]
                      , Form.col [Col.sm10]
                        [ Grid.row [] 
                          [ Grid.col [Col.xs4]
                            [ Input.text [Input.id "displayName", Input.value model.apiResource.displayName, Input.onInput DisplayNameEntered]
                            , Form.help [] [ text "Will be displayed on a Consent screen, otherwise Name will be used."]
                            ]
                          ]
                        ]
                      ]
                    , Form.row [] 
                      [ Form.colLabel [Col.sm2] [ text "Description:" ]
                      , Form.col [Col.sm10]
                        [ Grid.row [] 
                          [ Grid.col [Col.xs4] 
                            [ Input.text [Input.id "description", Input.value model.apiResource.description, Input.onInput DescriptionEntered]
                            , Form.help [] [ text "Will be displayed on a Consent screen."]
                            ]
                          ]
                        ]
                      ]
                    , Form.row [] 
                      [ Form.colLabel [Col.sm2] [ text "Scopes:" ]
                      , Form.col [Col.sm10]
                        [ Input.text [Input.id "scopes"]
                        , Form.help [] [ text "What scopes has to be present for a consumer."]] 
                      ]
                    , Form.row [] 
                        [ Form.colLabel [Col.sm2] [ text "Enable/Disable:"]
                        , Form.col [Col.sm10]
                            [ Fieldset.config 
                             |> Fieldset.children 
                                [Checbox.checkbox [Checbox.id "enabled", Checbox.inline, Checbox.checked model.apiResource.enabled, Checbox.onCheck Enabled ] ""]
                             |> Fieldset.view
                             ]
                        ]
                    , Button.button [Button.primary] [text "Update"]
                    ]
                ]
             ]
    }
module Pages.Applications.Name_String exposing (Params, Model, Msg, page)

import Bootstrap.Button as Button
import Bootstrap.Form as Form exposing (Col)
import Bootstrap.Form.Checkbox as Checbox
import Bootstrap.Form.Fieldset as Fieldset
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Data.ApiResourceDto exposing (ApiResourceDto)
import Html exposing (Html, h1, text)
import Http exposing (Error)
import Request.ApiResource exposing (apiResourceGet, apiResourcePatch)
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
    , form: ApiResource
    , allResources: Maybe (List ApiResourceDto)
    }

type alias ApiResource =
    { id: Int
    , enabled : Bool
    , name : String
    , displayName : String
    , description : String
    , apiSecrets : (List String)
    , scopes : (List String)
    }

init : Shared.Model -> Url Params -> ( Model, Cmd Msg )
init shared { params } =
    let
        resource =
            (resourceFromList params.name shared.apiResources) |> dtoToModel
    in
    ({ apiResource = resource, form = resource, allResources = shared.apiResources }, Cmd.none )


dtoToModel: Maybe ApiResourceDto -> ApiResource
dtoToModel dto =
    case dto of
        Just d ->
            { id = (Maybe.withDefault -1 d.id)
            , enabled = (Maybe.withDefault False d.enabled)
            , name = (Maybe.withDefault "" d.name)
            , displayName = (Maybe.withDefault "" d.displayName)
            , description = (Maybe.withDefault "" d.description)
            , apiSecrets = (Maybe.withDefault [""] d.apiSecrets)
            , scopes = (Maybe.withDefault [""] d.scopes)}
        Nothing ->
            { id = -1
            , enabled = False
            , name = ""
            , displayName = ""
            , description = ""
            , apiSecrets = [""]
            , scopes = [""]}
            
modelToDto: ApiResource -> ApiResourceDto
modelToDto r =
    { id = Just r.id
    , name = Just r.name
    , description = Just r.description
    , displayName = Just r.displayName
    , scopes = Just r.scopes
    , apiSecrets = Just r.apiSecrets
    , enabled = Just r.enabled
    }
            

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
    
-- UPDATE

updatedResource: Result Error () -> Msg
updatedResource result =
    case result of
        Ok _ ->
            UpdateSuccess

        Err error ->
            GotError error

newResources: Result Error (List ApiResourceDto) -> Msg
newResources result = 
    case result of
        Ok value ->
            UpdateResources value

        Err error ->
            GotError error        
        
            
type Msg
    = NameEntered String
    | DisplayNameEntered String
    | DescriptionEntered String
    | Enabled Bool
    | ScopesEntered String
    | OnReset
    | OnUpdate
    | GotError Error
    | UpdateSuccess
    | UpdateResources (List ApiResourceDto)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NameEntered name ->
            let resource = model.form
            in
            ({ model | form = {resource | name = name} }, Cmd.none)

        DisplayNameEntered displayName ->
            let resource = model.form
            in
            ({ model | form = {resource | displayName = displayName} }, Cmd.none)

        DescriptionEntered description ->
            let resource = model.form
            in
            ({ model | form = {resource | description = description} }, Cmd.none)

        Enabled enabled ->
            let resource = model.form
            in
            ({ model | form = {resource | enabled = enabled} }, Cmd.none)

        ScopesEntered scopes ->
            let (resource, newScopes) = (model.form, (String.split "," scopes))
            in
            ({ model | form = {resource | scopes = newScopes} }, Cmd.none)

        OnReset ->
            ({ model | form = model.apiResource }, Cmd.none)      

        OnUpdate ->
            let resource = (modelToDto model.form)
            in
            (model, apiResourcePatch { onSend = updatedResource, body = Just resource })

        GotError _ ->
            (model, Cmd.none)

        UpdateSuccess ->
            (model, apiResourceGet { onSend = newResources})

        UpdateResources resources ->
            ({ model | allResources = Just resources}, Cmd.none)



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

textInputRow: { id: String, title: String, value: String, help: String, msg: (String -> msg)} -> List (Col msg)
textInputRow opts = 
    [ Form.colLabel [Col.sm2] [ text opts.title ]
    , Form.col [Col.sm10] 
        [ Grid.row [] 
          [ Grid.col [Col.xs4] 
            [ Input.text [Input.id opts.id, Input.value opts.value, Input.onInput opts.msg]
            , Form.help [] [ text opts.help ]]
          ]
         ]
      ]
      
nameInput: ApiResource -> List (Col Msg)
nameInput r =
    (textInputRow 
        { id = "name"
        , title = "Resource name:"
        , value = r.name
        , help = "The name of the resource."
        , msg = NameEntered})
        
displayNameInput: ApiResource -> List (Col Msg)
displayNameInput r =
    (textInputRow 
        { id = "displayName"
        , title = "Display name:"
        , value = r.displayName
        , help = "Will be displayed on a Consent screen, otherwise Name will be used."
        , msg = DisplayNameEntered})

descriptionInput: ApiResource -> List (Col Msg)
descriptionInput r =
    (textInputRow 
        { id = "description"
        , title = "Description:"
        , value = r.description
        , help = "Will be displayed on a Consent screen."
        , msg = DescriptionEntered})

scopesInput: ApiResource -> List (Col Msg)
scopesInput r =
    (textInputRow 
        { id = "scopes"
        , title = "Scopes:"
        , value = String.join "," r.scopes
        , help = "What scopes has to be present for a consumer."
        , msg = ScopesEntered})


view : Model -> Document Msg
view model =
    { title = model.form.name
    , body = [ Grid.container [] 
                [ h1 [] [text model.form.name]
                , Form.form []
                    [ Form.row [] (nameInput model.form)
                    , Form.row [] (displayNameInput model.form)
                    , Form.row [] (descriptionInput model.form)
                    , Form.row [] (scopesInput model.form)
                    , Form.row [] 
                        [ Form.colLabel [Col.sm2] [ text "Enable/Disable:"]
                        , Form.col [Col.sm10]
                            [ Fieldset.config 
                             |> Fieldset.children 
                                [Checbox.checkbox [Checbox.id "enabled", Checbox.inline, Checbox.checked model.form.enabled, Checbox.onCheck Enabled ] ""]
                             |> Fieldset.view
                             ]
                        ]
                    , Grid.row [] 
                        [ Grid.col [] [Button.button [Button.secondary, Button.onClick OnReset] [text "Reset"]]
                        , Grid.col [] [Button.button [Button.primary, Button.onClick OnUpdate] [text "Update"]]
                        ] 
                    ]
                ]
             ]
    }
    
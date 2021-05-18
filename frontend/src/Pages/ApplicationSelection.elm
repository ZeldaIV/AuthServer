module Pages.ApplicationSelection exposing (Model, Msg, page)

import Array exposing (Array)
import Bootstrap.Badge as Badge
import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Dropdown as Dropdown exposing (DropdownItem)
import Bootstrap.Form as Form
import Bootstrap.Form.Fieldset as Fieldset
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Text as Text
import Bootstrap.Utilities.Spacing as Spacing
import Bootstrap.Utilities.Border as Border
import Data.ApiResourceDto exposing (ApiResourceDto)
import Data.ClientDto exposing (AllowedGrantTypes(..), ClientDto)
import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (for, style)
import Html.Events exposing (onClick)
import Http exposing (Error)
import Page
import Request exposing (Request)
import Request.ApiResource as ApiResource
import Request.Clients as Clients
import Shared

import Time
import View exposing (View)

page : Shared.Model -> Request -> Page.With Model Msg
page _ _ =
    Page.protected.element
        (\_ ->
            { init = init
            , update = update
            , view = view
            , subscriptions = subscriptions
            })

-- INIT
type alias Model =
    { apiForm: ApiForm
    , clientForm: ClientForm
    , grantTypes: (List AllowedGrantTypes)
    , grantTypesDropState: Dropdown.State
    , mode: ApplicationMode}


init : ( Model, Cmd Msg )
init =
    ( { apiForm = initialApiForm
       , clientForm = initialClientForm
       , grantTypes = initialGrantTypes
       , grantTypesDropState = Dropdown.initialState
       , mode = None 
       }, Cmd.none )

initialGrantTypes = [ Implicit
                    , ImplicitAndClientCredentials
                    , Code
                    , CodeAndClientCredentials
                    , Hybrid
                    , HybridAndClientCredentials
                    , ClientCredentials
                    , ResourceOwnerPassword
                    , ResourceOwnerPasswordAndClientCredentials
                    , DeviceFlow ]

initialApiForm = ApiForm "" "" ""
initialClientForm = ClientForm "" "" "" "" "" [] [] [""] [] [""] False

-- UPDATE


type alias ApiForm = { name: String, displayName: String, description: String}
type alias ClientForm = 
    { clientName: String
    , clientId: String
    , description: String
    , clientUri: String
    , logoUri: String
    , clientSecrets: (List String)
    , allowedGrantTypes: (List AllowedGrantTypes)
    , redirectUris: (List String)
    , allowedScopes: (List String)
    , postLogoutRedirectUris: (List String)
    , enabled: Bool
    }

fromFormToModel: ApiForm -> ApiResourceDto
fromFormToModel form = 
    { id = Nothing
    , name = Just form.name
    , displayName = Just form.displayName
    , description = Just form.description
    , apiSecrets = Nothing
    , scopes = Nothing
    , enabled = Just True }
    
fromClientFormToModel: ClientForm -> ClientDto
fromClientFormToModel form = 
    { id = Nothing
    , clientName = Just form.clientName
    , clientId = Just form.clientId
    , description = Just form.description
    , clientUri = Just form.clientUri
    , logoUri = Just form.logoUri
    , clientSecrets = Just form.clientSecrets
    , allowedGrantTypes = Just form.allowedGrantTypes
    , redirectUris = Just form.redirectUris
    , allowedScopes = Just form.allowedScopes
    , postLogoutRedirectUris = Just form.postLogoutRedirectUris
    , enabled = Just True
    , created = Just (Time.millisToPosix 0)
    , lastAccessed = Just (Time.millisToPosix 0)
    , updated = Just (Time.millisToPosix 0)
    }
    
    
addedNewResource: Result Error () -> Msg
addedNewResource result =
    case result of
        Ok _ ->
            AddApplicationMode None

        Err _ ->
            AddApplicationMode None
        
            

type ApplicationMode
    = None
    | ApiResourceMode
    | ClientMode
    
-- update
    
type Msg
    = AddApplicationMode ApplicationMode
    | SubmitApiResource ApiForm
    | ApiNameEntered String
    | ApiDisplayNameEntered String
    | ApiDescriptionEntered String
    | ClientNameEntered String
    | ClientIdEntered String
    | ClientDescriptionEntered String
    | ClientUriEntered String
    | ClientLogoUriEntered String
    | ClientSecretsEntered (List String)
    | ClientAllowedGrantTypesEntered (List AllowedGrantTypes)
    | ClientRedirectUrisEntered Int String
    | ClientAllowedScopesEntered (List String)
    | ClientPostLogoutRedirectUrisEntered Int String
    | ClientEnabledChanged Bool
    | GrantTypeToggleMsg Dropdown.State
    | SelectedGrantType AllowedGrantTypes
    | DeselectedGrantType AllowedGrantTypes
    | SubmitClient ClientForm
    
    
update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        AddApplicationMode mode ->
            ( {model | mode = mode} , Cmd.none )

        SubmitApiResource form ->
           ( model , ApiResource.apiResourcePut { onSend = addedNewResource, body = Just (form |> fromFormToModel)} )

        ApiNameEntered name ->
            let
                form = model.apiForm
            in
                ({model | apiForm = { form | name = name}}, Cmd.none)

        ApiDisplayNameEntered displayName ->
            let
                form = model.apiForm
            in
                ({model | apiForm = { form | displayName = displayName}}, Cmd.none)

        ApiDescriptionEntered description ->
            let
                form = model.apiForm
            in
                ({model | apiForm = { form | description = description}}, Cmd.none)

        ClientNameEntered clientName ->
            let
                form = model.clientForm
            in
                ({model | clientForm = { form | clientName = clientName}}, Cmd.none)

        ClientIdEntered clientId ->
            let
                form = model.clientForm
            in
                ({model | clientForm = { form | clientId = clientId}}, Cmd.none)

        ClientDescriptionEntered description ->
           let
               form = model.clientForm
           in
               ({model | clientForm = { form | description = description}}, Cmd.none) 

        ClientUriEntered clientUri ->
            let
                form = model.clientForm
            in
                ({model | clientForm = { form | clientUri = clientUri}}, Cmd.none)

        ClientLogoUriEntered logoUri ->
            let
                form = model.clientForm
            in
                ({model | clientForm = { form | logoUri = logoUri}}, Cmd.none)

        ClientSecretsEntered clientSecrets ->
            let
                form = model.clientForm
            in
                ({model | clientForm = { form | clientSecrets = clientSecrets}}, Cmd.none)

        ClientAllowedGrantTypesEntered allowedGrantTypes ->
            let
                form = model.clientForm
            in
                ({model | clientForm = { form | allowedGrantTypes = allowedGrantTypes}}, Cmd.none)

        ClientRedirectUrisEntered index value ->
            let
                form = model.clientForm
                result = updateArray (Array.fromList model.clientForm.redirectUris)  index value
            in
                ({model | clientForm = { form | redirectUris = result}}, Cmd.none)

        ClientAllowedScopesEntered allowedScopes ->
            let
                form = model.clientForm
            in
                ({model | clientForm = { form | allowedScopes = allowedScopes}}, Cmd.none)

        ClientPostLogoutRedirectUrisEntered index value ->
            let
                form = model.clientForm
                result = updateArray (Array.fromList model.clientForm.postLogoutRedirectUris)  index value
            in
                ({model | clientForm = { form | postLogoutRedirectUris = result}}, Cmd.none)

        ClientEnabledChanged enabled ->
            let
                form = model.clientForm
            in
                ({model | clientForm = { form | enabled = enabled}}, Cmd.none)

        SubmitClient clientForm ->
            ( model, Clients.clientsPut { onSend = addedNewResource, body = Just (clientForm |> fromClientFormToModel)} )

        GrantTypeToggleMsg state ->
            ({ model | grantTypesDropState = state }, Cmd.none)

        SelectedGrantType grantType ->
            let
                form = model.clientForm
                dropDownItems = List.filter (\e -> not (e == grantType)) model.grantTypes
                clientItems = form.allowedGrantTypes ++ [grantType]
            in
                ({model | grantTypes = dropDownItems,  clientForm = { form | allowedGrantTypes = clientItems} }, Cmd.none)

        DeselectedGrantType grantType ->
            let
                form = model.clientForm
                dropDownItems = model.grantTypes ++ [grantType]
                clientItems =  List.filter (\e -> not (e == grantType)) form.allowedGrantTypes
            in
                ({model | grantTypes = dropDownItems,  clientForm = { form | allowedGrantTypes = clientItems} }, Cmd.none)
                
            
    

updateArray: (Array String) -> Int -> String -> (List String)
updateArray lst idx val =
    if (idx + 1 == (Array.length lst) && String.length val > 0) then
        Array.push "" lst |> Array.set idx val |> Array.toList
    else if (String.length val == 0 && idx + 1 < (Array.length lst)) then
        let
            a1 = Array.slice 0 idx lst
            a2 = Array.slice (idx + 1) (Array.length lst) lst
        in
          Array.append a1 a2 |> Array.toList
    else
        Array.set idx val lst |> Array.toList

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Dropdown.subscriptions model.grantTypesDropState GrantTypeToggleMsg ]
        
-- VIEW


view : Model -> View Msg
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
            apiResourceView model.apiForm
    
        ClientMode ->
             clientView model

apiResourceView: ApiForm -> Html Msg
apiResourceView form =
    Grid.container []
    [ h1 [] [ text "Fill out api"]
    , Grid.row []
        [ Grid.col []
            [ Form.form [] 
                [ Form.group [] 
                    [ Form.label [for "Name"] [ text "Name"]
                    , Input.text [ Input.id "Name", Input.value form.name, Input.onInput ApiNameEntered ]
                    ]
                , Form.group [] 
                    [ Form.label [ for "DisplayName"] [text "Display name"]
                    , Input.text [ Input.id "DisplayName", Input.value form.displayName, Input.onInput ApiDisplayNameEntered ]
                    , Form.help [] [ text "Will be displayed on a Consent screen, otherwise Name will be used"] 
                    ]
                , Form.group [] 
                    [ Form.label [ for "Description"] [text "Description"]
                    , Input.text [ Input.id "Description", Input.value form.description, Input.onInput ApiDescriptionEntered ]
                    , Form.help [] [ text "Will be displayed on a Consent screen"]
                    ]
                , Grid.container [] 
                    [ Grid.row [] 
                        [ Grid.col [] [ Button.button [ Button.danger, Button.onClick (AddApplicationMode None) ] [ text "Cancel"] ]
                        , Grid.col [Col.xs2, Col.mdAuto] []
                        , Grid.col [] [ Button.button [ Button.primary, Button.onClick (SubmitApiResource form) ] [ text "Add"] ]
                        ]
                    ]
                ]
            ]
        , Grid.col [] []
        ]
    ]
    
clientView: Model  -> Html Msg
clientView model = 
    Grid.container []
    [ h1 [] [text "Fill out client" ]
    , Grid.row [Row.centerSm]
        [ Grid.col [Col.sm6]
            [ Form.form []
                [ Form.group []
                  [ Form.label [for "ClientId"] [ text "Client id"] 
                  , Input.text [ Input.id "ClientId", Input.value model.clientForm.clientId, Input.onInput ClientIdEntered]
                  ]
                , Form.group []
                    [ Form.label [for "ClientName"] [ text "Client name"] 
                    , Input.text [ Input.id "ClientName", Input.value model.clientForm.clientName, Input.onInput ClientNameEntered]
                    ]
                , Form.group []
                    [ Form.label [for "Description"] [ text "Description"] 
                    , Input.text [ Input.id "Description", Input.value model.clientForm.description, Input.onInput ClientDescriptionEntered]
                    ]
                , Form.group [] 
                    [ Form.label [for "ClientUri"] [ text "Client uri"] 
                    , Input.text [ Input.id "ClientUri", Input.value model.clientForm.clientUri, Input.onInput ClientUriEntered]
                    ]
                , Form.group [] 
                    [ Form.label [for "LogoUri"] [ text "Logo uri"] 
                    , Input.text [ Input.id "LogoUri", Input.value model.clientForm.logoUri, Input.onInput ClientLogoUriEntered]
                    ]
                , Fieldset.config
                    |> Fieldset.asGroup
                    |> Fieldset.legend [] [ text "Redirect uris"]
                    |> Fieldset.children
                       ( (List.indexedMap Tuple.pair model.clientForm.redirectUris) |> List.map (\(i, v) -> stringIndexToInput {index = i, value= v} <| ClientRedirectUrisEntered ) )
                       |> Fieldset.view
                , div []
                      [ Dropdown.dropdown model.grantTypesDropState 
                        { options = []
                        , toggleMsg = GrantTypeToggleMsg
                        , toggleButton = Dropdown.toggle [Button.primary] [ text "Grant Types"]
                        , items = List.map grantTypeToDropDown model.grantTypes 
                        }
                      ]
                , Form.group []
                    [div [style "height" "100px", Border.all, Border.secondary, Spacing.mt2] 
                        (List.map grantTypeToBadge model.clientForm.allowedGrantTypes)
                    ]
                , Fieldset.config
                      |> Fieldset.asGroup
                      |> Fieldset.legend [] [ text "Post logout redirect uris"]
                      |> Fieldset.children
                         ( (List.indexedMap Tuple.pair model.clientForm.postLogoutRedirectUris) |> List.map (\(i, v) -> stringIndexToInput {index = i, value= v} <| ClientPostLogoutRedirectUrisEntered ) )
                         |> Fieldset.view
                    
                ] 
                , Grid.row [Row.betweenSm] 
                    [ Grid.col [Col.sm2] [ Button.button [ Button.danger, Button.onClick (AddApplicationMode None) ] [ text "Cancel"] ]
                    , Grid.col [Col.sm2] [ Button.button [ Button.primary, Button.onClick (SubmitClient model.clientForm) ] [ text "Add"] ]
                ]
            ]
        ]
    ]
    
type alias IndexedValue = { index: Int, value: String}  
stringIndexToInput: IndexedValue -> (Int -> String -> toMsg) -> Html toMsg
stringIndexToInput  indexedValue toMsg = 
    Input.text [Input.id (String.fromInt indexedValue.index), Input.value indexedValue.value, Input.onInput <| toMsg indexedValue.index]
    
grantTypeToString: AllowedGrantTypes -> String
grantTypeToString g = 
    case g of
        NotSet ->
            "Unknown"
        Implicit ->
            "Implicit"
        ImplicitAndClientCredentials ->
            "ImplicitAndClientCredentials"
        Code ->
            "Code"
        CodeAndClientCredentials ->
            "CodeAndClientCredentials"
        Hybrid ->
            "Hybrid"
        HybridAndClientCredentials ->
            "HybridAndClientCredentials"
        ClientCredentials ->
            "ClientCredentials"
        ResourceOwnerPassword ->
            "ResourceOwnerPassword"
        ResourceOwnerPasswordAndClientCredentials ->
            "ResourceOwnerPasswordAndClientCredentials"
        DeviceFlow ->
            "DeviceFlow"    
        

grantTypeToDropDown: AllowedGrantTypes -> DropdownItem Msg
grantTypeToDropDown grantType = 
    Dropdown.buttonItem [ onClick (SelectedGrantType grantType)] [ text (grantTypeToString grantType)]
    
grantTypeToBadge: AllowedGrantTypes -> Html Msg
grantTypeToBadge grantType =
    Badge.badgeSecondary [ Spacing.ml1, Spacing.mt1, Spacing.mb1, onClick (DeselectedGrantType grantType)] [ text (grantTypeToString grantType)]
    
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
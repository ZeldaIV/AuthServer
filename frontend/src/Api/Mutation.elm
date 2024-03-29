-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.Mutation exposing (..)

import Api.InputObject
import Api.Interface
import Api.Object
import Api.Scalar
import Api.Union
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode exposing (Decoder)
import ScalarCodecs


type alias CreateAuthorizationRequiredArguments =
    { input : Api.InputObject.AuthorizationInput }


createAuthorization :
    CreateAuthorizationRequiredArguments
    -> SelectionSet decodesTo Api.Object.CreateAuthorizationPayload
    -> SelectionSet decodesTo RootMutation
createAuthorization requiredArgs____ object____ =
    Object.selectionForCompositeField "createAuthorization" [ Argument.required "input" requiredArgs____.input Api.InputObject.encodeAuthorizationInput ] object____ Basics.identity


type alias DeleteAuthorizationRequiredArguments =
    { id : Int }


deleteAuthorization :
    DeleteAuthorizationRequiredArguments
    -> SelectionSet decodesTo Api.Object.DeleteEntityByIdPayload
    -> SelectionSet decodesTo RootMutation
deleteAuthorization requiredArgs____ object____ =
    Object.selectionForCompositeField "deleteAuthorization" [ Argument.required "id" requiredArgs____.id Encode.int ] object____ Basics.identity


type alias CreateUserRequiredArguments =
    { input : Api.InputObject.UserInput }


createUser :
    CreateUserRequiredArguments
    -> SelectionSet decodesTo Api.Object.CreateUserPayload
    -> SelectionSet decodesTo RootMutation
createUser requiredArgs____ object____ =
    Object.selectionForCompositeField "createUser" [ Argument.required "input" requiredArgs____.input Api.InputObject.encodeUserInput ] object____ Basics.identity


type alias DeleteUserRequiredArguments =
    { id : ScalarCodecs.Uuid }


deleteUser :
    DeleteUserRequiredArguments
    -> SelectionSet decodesTo Api.Object.DeleteEntityByIdPayload
    -> SelectionSet decodesTo RootMutation
deleteUser requiredArgs____ object____ =
    Object.selectionForCompositeField "deleteUser" [ Argument.required "id" requiredArgs____.id (ScalarCodecs.codecs |> Api.Scalar.unwrapEncoder .codecUuid) ] object____ Basics.identity


type alias AddClaimsToUserOptionalArguments =
    { input : OptionalArgument Api.InputObject.UserClaimsInput }


type alias AddClaimsToUserRequiredArguments =
    { claimsInput : Api.InputObject.UserClaimsInput }


addClaimsToUser :
    (AddClaimsToUserOptionalArguments -> AddClaimsToUserOptionalArguments)
    -> AddClaimsToUserRequiredArguments
    -> SelectionSet decodesTo Api.Object.AddRemoveClaimsPayload
    -> SelectionSet decodesTo RootMutation
addClaimsToUser fillInOptionals____ requiredArgs____ object____ =
    let
        filledInOptionals____ =
            fillInOptionals____ { input = Absent }

        optionalArgs____ =
            [ Argument.optional "input" filledInOptionals____.input Api.InputObject.encodeUserClaimsInput ]
                |> List.filterMap Basics.identity
    in
    Object.selectionForCompositeField "addClaimsToUser" (optionalArgs____ ++ [ Argument.required "ClaimsInput" requiredArgs____.claimsInput Api.InputObject.encodeUserClaimsInput ]) object____ Basics.identity


type alias RemoveClaimFromUserRequiredArguments =
    { userId : ScalarCodecs.Uuid
    , claimType : String
    }


removeClaimFromUser :
    RemoveClaimFromUserRequiredArguments
    -> SelectionSet decodesTo Api.Object.AddRemoveClaimsPayload
    -> SelectionSet decodesTo RootMutation
removeClaimFromUser requiredArgs____ object____ =
    Object.selectionForCompositeField "removeClaimFromUser" [ Argument.required "userId" requiredArgs____.userId (ScalarCodecs.codecs |> Api.Scalar.unwrapEncoder .codecUuid), Argument.required "claimType" requiredArgs____.claimType Encode.string ] object____ Basics.identity


type alias CreateScopeRequiredArguments =
    { input : Api.InputObject.ScopeInput }


createScope :
    CreateScopeRequiredArguments
    -> SelectionSet decodesTo Api.Object.CreateScopePayload
    -> SelectionSet decodesTo RootMutation
createScope requiredArgs____ object____ =
    Object.selectionForCompositeField "createScope" [ Argument.required "input" requiredArgs____.input Api.InputObject.encodeScopeInput ] object____ Basics.identity


type alias DeleteScopeRequiredArguments =
    { id : ScalarCodecs.Uuid }


deleteScope :
    DeleteScopeRequiredArguments
    -> SelectionSet decodesTo Api.Object.DeleteEntityByIdPayload
    -> SelectionSet decodesTo RootMutation
deleteScope requiredArgs____ object____ =
    Object.selectionForCompositeField "deleteScope" [ Argument.required "id" requiredArgs____.id (ScalarCodecs.codecs |> Api.Scalar.unwrapEncoder .codecUuid) ] object____ Basics.identity


type alias CreateClientRequiredArguments =
    { input : Api.InputObject.ClientInput }


createClient :
    CreateClientRequiredArguments
    -> SelectionSet decodesTo Api.Object.CreateClientPayload
    -> SelectionSet decodesTo RootMutation
createClient requiredArgs____ object____ =
    Object.selectionForCompositeField "createClient" [ Argument.required "input" requiredArgs____.input Api.InputObject.encodeClientInput ] object____ Basics.identity


type alias UpdateClientRequiredArguments =
    { input : Api.InputObject.ClientInput }


updateClient :
    UpdateClientRequiredArguments
    -> SelectionSet decodesTo Api.Object.CreateClientPayload
    -> SelectionSet decodesTo RootMutation
updateClient requiredArgs____ object____ =
    Object.selectionForCompositeField "updateClient" [ Argument.required "input" requiredArgs____.input Api.InputObject.encodeClientInput ] object____ Basics.identity


type alias DeleteClientRequiredArguments =
    { id : Int }


deleteClient :
    DeleteClientRequiredArguments
    -> SelectionSet decodesTo Api.Object.DeleteEntityByIdPayload
    -> SelectionSet decodesTo RootMutation
deleteClient requiredArgs____ object____ =
    Object.selectionForCompositeField "deleteClient" [ Argument.required "id" requiredArgs____.id Encode.int ] object____ Basics.identity


type alias CreateClaimRequiredArguments =
    { input : Api.InputObject.ClaimInput }


createClaim :
    CreateClaimRequiredArguments
    -> SelectionSet decodesTo Api.Object.CreateClaimPayload
    -> SelectionSet decodesTo RootMutation
createClaim requiredArgs____ object____ =
    Object.selectionForCompositeField "createClaim" [ Argument.required "input" requiredArgs____.input Api.InputObject.encodeClaimInput ] object____ Basics.identity


type alias DeleteClaimRequiredArguments =
    { id : ScalarCodecs.Uuid }


deleteClaim :
    DeleteClaimRequiredArguments
    -> SelectionSet decodesTo Api.Object.DeleteEntityByIdPayload
    -> SelectionSet decodesTo RootMutation
deleteClaim requiredArgs____ object____ =
    Object.selectionForCompositeField "deleteClaim" [ Argument.required "id" requiredArgs____.id (ScalarCodecs.codecs |> Api.Scalar.unwrapEncoder .codecUuid) ] object____ Basics.identity


type alias CreateEmailServerRequiredArguments =
    { input : Api.InputObject.CreateEmailServerInput }


createEmailServer :
    CreateEmailServerRequiredArguments
    -> SelectionSet decodesTo Api.Object.EmailServerPayload
    -> SelectionSet decodesTo RootMutation
createEmailServer requiredArgs____ object____ =
    Object.selectionForCompositeField "createEmailServer" [ Argument.required "input" requiredArgs____.input Api.InputObject.encodeCreateEmailServerInput ] object____ Basics.identity


type alias UpdateEmailServerRequiredArguments =
    { input : Api.InputObject.UpdateEmailServerInput }


updateEmailServer :
    UpdateEmailServerRequiredArguments
    -> SelectionSet decodesTo Api.Object.EmailServerPayload
    -> SelectionSet decodesTo RootMutation
updateEmailServer requiredArgs____ object____ =
    Object.selectionForCompositeField "updateEmailServer" [ Argument.required "input" requiredArgs____.input Api.InputObject.encodeUpdateEmailServerInput ] object____ Basics.identity

module NewItem exposing (..)

import Bootstrap.Button as Button exposing (button, onClick)
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Browser.Navigation as Nav
import Greeting exposing (buildErrorMessage)
import Html exposing (Html, div, h3, text)
import Html.Attributes exposing (for)
import Http exposing (Metadata)
import Item
import Json.Encode as Encode
import Route


type alias Model =
    { navKey : Nav.Key
    , item : Item.ItemModel
    , createError : Maybe String
    }


type Msg
    = StoreName String
    | StoreDescription String
    | CreateItem
    | ItemCreated (Result Http.Error String)
    | CancelSave


init : Nav.Key -> ( Model, Cmd Msg )
init navKey =
    ( initialModel navKey, Cmd.none )


initialModel : Nav.Key -> Model
initialModel navKey =
    { navKey = navKey
    , item = emptyItem
    , createError = Nothing
    }


emptyItem : Item.ItemModel
emptyItem =
    { name = ""
    , description = ""
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StoreName name ->
            let
                oldItem =
                    model.item

                updateName =
                    { oldItem | name = name }
            in
            ( { model | item = updateName }, Cmd.none )

        StoreDescription description ->
            let
                oldItem =
                    model.item

                updateDescription =
                    { oldItem | description = description }
            in
            ( { model | item = updateDescription }, Cmd.none )


        CreateItem ->
            ( model, createItem model.item )

        ItemCreated (Ok _) ->
            ( {model | createError = Nothing }
            , Route.pushUrl Route.Items model.navKey
            )

        ItemCreated (Err error) ->
            ( { model | createError = Just (buildErrorMessage error) }
            , Cmd.none
            )

        CancelSave ->
            ( model, Route.pushUrl Route.Items model.navKey )


createItem : Item.ItemModel -> Cmd Msg
createItem item =
    Http.post
        { url = "/api/items"
        , body = Http.jsonBody (newItemEncoder item)
        , expect = Http.expectString ItemCreated
        }


newItemEncoder : Item.ItemModel -> Encode.Value
newItemEncoder item =
    Encode.object
        [ ( "name", Encode.string item.name )
        , ( "description", Encode.string item.description )
        ]


--    __      _______ ________          __
--    \ \    / /_   _|  ____\ \        / /
--     \ \  / /  | | | |__   \ \  /\  / /
--      \ \/ /   | | |  __|   \ \/  \/ /
--       \  /   _| |_| |____   \  /\  /
--        \/   |_____|______|   \/  \/
--


view : Model -> Html Msg
view model =
    div []
        [ h3 [] [ text "Create New Item" ]
        , newItemForm
        , viewError model.createError
        ]


viewError : Maybe String -> Html msg
viewError maybeError =
    case maybeError of
        Just error ->
            div []
                [ h3 [] [ text "Couldn't create item at this time." ]
                , text ("Error: " ++ error)
                ]

        Nothing ->
            text ""


newItemForm : Html Msg
newItemForm =
    div []
        [ Form.form []
            [ Form.group []
                [ Form.label [ for "name" ] [ text "Name" ]
                , Input.text
                      [ Input.id "name"
                      , Input.onInput StoreName
                      ]
                ]
            , Form.group []
                [ Form.label [ for "description" ] [ text "Description" ]
                , Input.text
                    [ Input.id "description"
                    , Input.onInput StoreDescription
                    ]
                ]
            ]
        , div []
            [ button [ onClick CreateItem, Button.large, Button.primary ]
                [text "Submit"]
            , button [ onClick CancelSave, Button.large, Button.primary ]
                [text "Cancel"]
            ]
        ]
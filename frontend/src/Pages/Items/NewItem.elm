module Pages.Items.NewItem exposing (Model, Msg, init, update, view)

import Bootstrap.Button as Button exposing (button, onClick)
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Browser.Navigation as Nav
import Error exposing (buildErrorMessage, viewError)
import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (class, for)
import Http exposing (Metadata)
import Json.Encode as Encode
import Pages.Items.Item as Item
import Route


type alias Model =
    { navKey : Nav.Key
    , item : Item.ItemModel
    , activeItemsPage : Int
    , createError : Maybe String
    }


type Msg
    = StoreName String
    | StoreDescription String
    | CreateItem
    | ItemCreated (Result Http.Error String)
    | CancelSave


init : Nav.Key -> Int -> ( Model, Cmd Msg )
init navKey activePage =
    ( initialModel navKey activePage, Cmd.none )


initialModel : Nav.Key -> Int -> Model
initialModel navKey activePage =
    { navKey = navKey
    , item = emptyItem
    , createError = Nothing
    , activeItemsPage = activePage
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
            ( { model | createError = Nothing }
            , Route.pushUrl (Route.Items (Just model.activeItemsPage)) model.navKey
            )

        ItemCreated (Err error) ->
            ( { model | createError = Just (buildErrorMessage error) }
            , Cmd.none
            )

        CancelSave ->
            ( model, Route.pushUrl (Route.Items (Just model.activeItemsPage)) model.navKey )


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
        [ h1 [ class "text-center" ] [ text "Create New Item" ]
        , newItemForm
        , viewShowError model.createError
        ]


viewShowError : Maybe String -> Html msg
viewShowError maybeError =
    case maybeError of
        Just error ->
            viewError "Couldn't create item at this time." error

        Nothing ->
            text ""


newItemForm : Html Msg
newItemForm =
    Grid.container []
        [ Grid.row []
            [ Grid.col [ Col.md6, Col.offsetMd3 ]
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
                        [ text "Submit" ]
                    , button [ onClick CancelSave, Button.large, Button.primary ]
                        [ text "Cancel" ]
                    ]
                ]
            ]
        ]

module Pages.Items.EditItem exposing (Model, Msg(..), init, update, view)

import Bootstrap.Button as Button exposing (button, onClick)
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Browser.Navigation as Nav
import Error exposing (buildErrorMessage, viewError)
import Html exposing (Html, div, h1, h3, text)
import Html.Attributes exposing (class, for)
import Http
import ItemsHttpClient exposing (FetchingResults(..), ItemResponse, fetchItem)
import Json.Encode as Encode
import Pages.Items.Item as Item exposing (Item, ItemModel)
import RemoteData exposing (WebData)
import Route

type alias Model =
    { navKey : Nav.Key
    , item : WebData Item
    , activeItemsPage: Int
    , errorMessage : Maybe String
    , etag : Maybe String
    }


type Msg
    = StoreName String
    | ResponseReceived (FetchingResults ItemResponse)
    | StoreDescription String
    | UpdateItem
    | ItemUpdated (Result Http.Error String)
    | CancelUpdate


init : Item.ItemId -> Nav.Key -> Int -> ( Model, Cmd Msg )
init itemId navKey activePage =
    ( initialModel navKey activePage, fetchItem itemId Nothing convertToMsg )


initialModel : Nav.Key -> Int -> Model
initialModel navKey activePage =
    { navKey = navKey
    , item = RemoteData.Loading
    , activeItemsPage = activePage
    , errorMessage = Nothing
    , etag = Nothing
    }


convertToMsg : FetchingResults ItemResponse -> Msg
convertToMsg result =
    ResponseReceived result


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ResponseReceived result ->
            case result of
                FetchError error ->
                    ( { model | errorMessage = Just error }
                    , Cmd.none
                    )

                DataReceived webData ->
                    let
                        item = case webData of
                            RemoteData.Success receivedItem ->
                                RemoteData.Success receivedItem.item
                            _ -> RemoteData.Loading


                        etag = case webData of
                            RemoteData.Success receivedItem ->
                                receivedItem.etag
                            _ -> Nothing

                    in
                    ( {model | item = item, etag = etag}, Cmd.none)

                DataNotModified ->
                     ( model, Cmd.none)


        StoreName name ->
            let
                updateName =
                    RemoteData.map
                        (\itemData -> { itemData | name = name }
                        )
                        model.item
            in
            ( { model | item = updateName }, Cmd.none )

        StoreDescription description ->
            let
                updateDescription =
                    RemoteData.map
                        (\itemData ->
                            { itemData | description = description }
                        )
                        model.item
            in
            ( { model | item = updateDescription }, Cmd.none )


        UpdateItem ->
            ( model, updateItem model.item )

        ItemUpdated (Ok _) ->
            ( {model | errorMessage = Nothing }
            , Route.pushUrl (Route.Items (Just model.activeItemsPage)) model.navKey
            )

        ItemUpdated (Err error) ->
            ( { model | errorMessage = Just (buildErrorMessage error) }
            , Cmd.none
            )

        CancelUpdate ->
            ( model, Route.pushUrl (Route.Items (Just model.activeItemsPage)) model.navKey)


updateItem : WebData Item -> Cmd Msg
updateItem item =
    case item of
        RemoteData.Success itemData ->
            let
                postUrl =
                    "/api/items/" ++ (Item.idToString itemData.id)
            in
            Http.request
                { method = "PUT"
                , headers = []
                , url = postUrl
                , body = Http.jsonBody (itemEncoder itemData)
                , expect = Http.expectString ItemUpdated
                , timeout = Nothing
                , tracker = Nothing
                }

        _ ->
            Cmd.none


itemEncoder : Item.Item -> Encode.Value
itemEncoder item =
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
        [ h1 [ class "text-center" ] [ text "Edit Item" ]
        , viewItem model.item
        , viewSaveError model.errorMessage
        ]


viewItem : WebData Item -> Html Msg
viewItem item =
    case item of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            h3 [] [ text "Loading Item..." ]

        RemoteData.Success itemData ->
            editItemForm itemData

        RemoteData.Failure httpError ->
            viewError "Couldn't fetch item at this time." (buildErrorMessage httpError)



viewSaveError : Maybe String -> Html msg
viewSaveError maybeError =
    case maybeError of
        Just error ->
            viewError "Couldn't save item at this time." error

        Nothing ->
            text ""


editItemForm : Item -> Html Msg
editItemForm item =
    Grid.container []
        [ Grid.row []
            [ Grid.col [ Col.md6, Col.offsetMd3 ]
                [ Form.form []
                    [ Form.group []
                        [ Form.label [ for "name" ] [ text "Name" ]
                        , Input.text
                              [ Input.id "name"
                              , Input.value item.name
                              , Input.onInput StoreName
                              ]
                        ]
                    , Form.group []
                        [ Form.label [ for "description" ] [ text "Description" ]
                        , Input.text
                            [ Input.id "description"
                            , Input.value item.description
                            , Input.onInput StoreDescription
                            ]
                        ]
                    ]
                , div []
                    [ button [ onClick UpdateItem, Button.large, Button.primary ]
                        [text "Submit"]
                    , button [ onClick CancelUpdate, Button.large, Button.primary ]
                        [text "Cancel"]
                    ]
                ]
            ]
        ]
module EditItem exposing (..)

import Bootstrap.Button as Button exposing (button, onClick)
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Browser.Navigation as Nav
import Greeting exposing (buildErrorMessage)
import Html exposing (Html, div, h3, text)
import Html.Attributes exposing (for)
import Http
import Item exposing (Item, ItemModel)
import Json.Encode as Encode
import RemoteData exposing (WebData)
import Route

type alias Model =
    { navKey : Nav.Key
    , item : WebData Item.Item
    , saveError : Maybe String
    }


type Msg
    = StoreName String
    | StoreDescription String
    | ItemReceived (WebData Item.Item)
    | UpdateItem
    | ItemUpdated (Result Http.Error String)


init : Item.ItemId -> Nav.Key -> ( Model, Cmd Msg )
init itemId navKey =
    ( initialModel navKey, fetchItem itemId )


initialModel : Nav.Key -> Model
initialModel navKey =
    { navKey = navKey
    , item = RemoteData.Loading
    , saveError = Nothing
    }

fetchItem : Item.ItemId -> Cmd Msg
fetchItem itemId =
    Http.get
        { url = "/api/items/" ++ (Item.idToString itemId)
        , expect =
            Item.itemDecoder
                |> Http.expectJson (RemoteData.fromResult >> ItemReceived)
        }



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ItemReceived item ->
            ( {model | item =  item}, Cmd.none)

        StoreName name ->
            let
                updateName =
                    RemoteData.map
                        (\itemData ->
                            { itemData | name = name }
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
            ( {model | saveError = Nothing }
            , Route.pushUrl Route.Items model.navKey
            )

        ItemUpdated (Err error) ->
            ( { model | saveError = Just (buildErrorMessage error) }
            , Cmd.none
            )


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
        [ h3 [] [ text "Edit Item" ]
        , viewItem model.item
        , viewSaveError model.saveError
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
            viewFetchError (buildErrorMessage httpError)


viewFetchError : String -> Html Msg
viewFetchError errorMessage =
    let
        errorHeading =
            "Couldn't fetch item at this time."
    in
    div []
        [ h3 [] [ text errorHeading ]
        , text ("Error: " ++ errorMessage)
        ]

viewSaveError : Maybe String -> Html msg
viewSaveError maybeError =
    case maybeError of
        Just error ->
            div []
                [ h3 [] [ text "Couldn't save item at this time." ]
                , text ("Error: " ++ error)
                ]

        Nothing ->
            text ""

editItemForm : Item -> Html Msg
editItemForm item =
    div []
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
            ]
        ]
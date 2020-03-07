module Pages.Items.Items exposing (..)

import Bootstrap.Alert as Alert
import Bootstrap.Button as Button exposing (button, onClick)
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Spinner as Spinner
import Bootstrap.Table as Table exposing (Row)
import Bootstrap.Utilities.Spacing as Spacing
import Error exposing (buildErrorMessage)
import Html exposing (Html, div, h1, h3, span, text)
import Html.Attributes exposing (class, href)
import Http
import Json.Decode as Decode exposing (Decoder, int, list)
import Json.Decode.Pipeline exposing (required, requiredAt)
import Pages.Items.Item as Item exposing (Item, ItemId, idToString, itemDecoder)
import RemoteData exposing (WebData)


type alias Page =
    { size : Int
    , totalElements : Int
    , totalPages : Int
    , number : Int
    }

type alias ItemsResponse =
    { items : (List Item)
    , page : Page
    }

type alias Model =
    { itemsResponse : WebData ItemsResponse
    , deleteError : Maybe String
    }

type Msg
    = FetchItems
    | ItemsReceived (WebData ItemsResponse)
    | DeleteItem ItemId
    | ItemDeleted (Result Http.Error String)

init : ( Model, Cmd Msg )
init =
    ( initialModel, fetchItems )

initialModel : Model
initialModel =
    { itemsResponse = RemoteData.Loading
    , deleteError = Nothing
    }

fetchItems : Cmd Msg
fetchItems =
    Http.get
        { url = "/api/items"
        , expect =
            itemsResponseDecoder
                |> Http.expectJson (RemoteData.fromResult >> ItemsReceived)
        }


deleteItem : ItemId -> Cmd Msg
deleteItem itemId =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = "/api/items/" ++ (idToString itemId)
        , body = Http.emptyBody
        , expect = Http.expectString ItemDeleted
        , timeout = Nothing
        , tracker = Nothing
        }

itemsResponseDecoder : Decoder ItemsResponse
itemsResponseDecoder =
    Decode.succeed ItemsResponse
        |> requiredAt ["_embedded", "items"] (list itemDecoder)
        |> requiredAt ["page"] pageDecoder


pageDecoder : Decoder Page
pageDecoder =
    Decode.succeed Page
        |> required "size" int
        |> required "totalElements" int
        |> required "totalPages" int
        |> required "number" int

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchItems ->
            ( { model | itemsResponse = RemoteData.Loading }, fetchItems )

        ItemsReceived response ->
            ( { model | itemsResponse = response }, Cmd.none )

        DeleteItem itemId ->
            ( model, deleteItem itemId )

        ItemDeleted (Ok _) ->
            ( model, fetchItems )

        ItemDeleted (Err error) ->
            ( { model | deleteError = Just (buildErrorMessage error) }
            , Cmd.none
            )


--    __      _______ ________          __
--    \ \    / /_   _|  ____\ \        / /
--     \ \  / /  | | | |__   \ \  /\  / /
--      \ \/ /   | | |  __|   \ \/  \/ /
--       \  /   _| |_| |____   \  /\  /
--        \/   |_____|______|   \/  \/
--


view : Model -> Html Msg
view model =
    Grid.container []
        [ Grid.row []
            [ Grid.col [ Col.md6, Col.offsetMd3 ]
                [ h1 [ class "text-center" ] [ text "Items view" ]]
            ]
        , Grid.row []
            [ Grid.col [ Col.md6, Col.offsetMd3 ]
                [ button [ onClick FetchItems, Button.large, Button.primary, Button.attrs [ Spacing.m1 ]]
                    [ text "Refresh items" ]
                , Alert.link [href "#items/new"] [text "Create new Item"]
                ]
            ]
        , Grid.row []
            [ Grid.col [ Col.md6, Col.offsetMd3 ]
                [ viewItemsOrError model ]
            ]
        ]


viewItemsOrError : Model -> Html Msg
viewItemsOrError model =
    case model.itemsResponse of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            div []
                [ Spinner.spinner [ Spinner.large ] [ span [ class "sr-only"]  [ text "Loading..."] ] ]

        RemoteData.Success itemsResponse ->
            viewItems itemsResponse

        RemoteData.Failure httpError ->
            viewError (buildErrorMessage httpError)


viewItems : ItemsResponse -> Html Msg
viewItems itemsResponse =
    div []
        [ Table.simpleTable
            ( Table.simpleThead
                [ Table.th [] [ text "Name" ]
                , Table.th [] [ text "Description" ]
                ]
                , Table.tbody []
                    (List.map viewItem itemsResponse.items)
            )
        ]

viewItem : Item -> Row Msg
viewItem item =
    Table.tr []
        [ Table.td []
            [ text item.name ]
        , Table.td []
            [ text item.description ]
        , Table.td []
            [ Alert.link [href ("#items/" ++ (Item.idToString item.id))] [text "Edit"]]
        , Table.td []
            [ button [onClick (DeleteItem item.id), Button.large, Button.primary ] [text "Delete"]]
        ]

-- TODO: Refactor - this functions should go to errors module
viewError : String -> Html Msg
viewError errorMessage =
    let
        errorHeading =
            "Couldn't fetch data at this time."
    in
    div []
        [ h3 [] [ text errorHeading ]
        , text ("Error: " ++ errorMessage)
        ]

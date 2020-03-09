module Pages.Items.ListItems exposing (Model, Msg, init, update, view, pagingData)

import Bootstrap.Alert as Alert
import Bootstrap.Button as Button exposing (button, onClick)
import Bootstrap.General.HAlign as HAlign
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Pagination as Pagination
import Bootstrap.Spinner as Spinner
import Bootstrap.Table as Table exposing (Row)
import Bootstrap.Utilities.Spacing as Spacing
import Error exposing (buildErrorMessage, viewError)
import Html exposing (Html, div, h1, span, text)
import Html.Attributes exposing (class, href)
import Http
import Json.Decode as Decode exposing (Decoder, int, list)
import Json.Decode.Pipeline exposing (optionalAt, required, requiredAt)
import List exposing (length, range)
import Pages.Items.Item as Item exposing (Item, ItemId, idToString, itemDecoder)
import RemoteData exposing (RemoteData(..), WebData)


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
    , activePage : Int
    }

type Msg
    = FetchItems
    | ItemsReceived (WebData ItemsResponse)
    | DeleteItem ItemId
    | ItemDeleted (Result Http.Error String)
    | Pagination Int

init : Int -> ( Model, Cmd Msg )
init pageNumber =
    ( initialModel pageNumber, fetchItems pageNumber)

initialModel : Int -> Model
initialModel pageNumber =
    { itemsResponse = RemoteData.Loading
    , deleteError = Nothing
    , activePage = pageNumber
    }

fetchItems : Int -> Cmd Msg
fetchItems pageNumber =
    Http.get
        { url = "/api/items?page=" ++ String.fromInt pageNumber
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
        |> optionalAt ["_embedded", "items"] (list itemDecoder) []
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
    let
        _ = Debug.log "ListItems Msg" msg
    in
    case msg of
        FetchItems ->
            ( { model | itemsResponse = RemoteData.Loading }, fetchItems model.activePage )

        ItemsReceived response ->
            let
                numberOfItems =
                    case response of
                        Success res -> length res.items
                        _ -> 0

                _ = Debug.log "Got items" numberOfItems
            in
            case numberOfItems of
                0 -> ( { model | itemsResponse = RemoteData.Loading }, fetchItems (model.activePage - 1) )
                _ -> ( { model | itemsResponse = response }, Cmd.none )

        DeleteItem itemId ->
            ( model, deleteItem itemId )

        ItemDeleted (Ok _) ->
            ( model, fetchItems model.activePage )

        ItemDeleted (Err error) ->
            ( { model | deleteError = Just (buildErrorMessage error) }
            , Cmd.none
            )

        Pagination page ->
            ( {model | activePage = page }, Cmd.none)


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
                , Alert.link [href "/items-new"] [text "Create new Item"]
                ]
            ]
        , Grid.row []
            [ Grid.col [ Col.md6, Col.offsetMd3 ]
                [ viewItemsOrError model ]
            ]
        , Grid.row []
            [ Grid.col [ Col.md6, Col.offsetMd3 ]
                [ simplePaginationList model ]
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
            viewError "Couldn't fetch data at this time." (buildErrorMessage httpError)


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
            [ Alert.link [href ("/items/" ++ (Item.idToString item.id))] [text "Edit"]]
        , Table.td []
            [ button [onClick (DeleteItem item.id), Button.large, Button.primary ] [text "Delete"]]
        ]



simplePaginationList : Model -> Html Msg
simplePaginationList model =
    Pagination.defaultConfig
        |> Pagination.ariaLabel "Pagination"
        |> Pagination.align HAlign.centerXs
        |> Pagination.large
        |> Pagination.itemsList
            { selectedMsg = Pagination
            , prevItem = Just <| Pagination.ListItem [] [ text "Previous" ]
            , nextItem = Just <| Pagination.ListItem [] [ text "Next" ]
            , activeIdx = model.activePage
            , data = pagingDataFromModel model
            , itemFn = \idx _ -> Pagination.ListItem [] [ text <| String.fromInt (idx + 1) ]
            , urlFn = \idx _ -> "/items?page=" ++ String.fromInt idx
            }
        |> Pagination.view

pagingDataFromModel : Model -> List Int
pagingDataFromModel model =
    case model.itemsResponse of
        RemoteData.Success itemsResponse ->
            pagingData itemsResponse.page.totalPages

        _ ->
            []

pagingData : Int -> List Int
pagingData numberOfPages =
    range 1 numberOfPages


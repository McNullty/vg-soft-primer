module Item exposing (..)

import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (required)

type ItemId
    = ItemId String


type alias Item =
    { id : ItemId
    , name : String
    , description : String
    }


itemDecoder : Decoder Item
itemDecoder =
   Decode.succeed Item
        |> required "id" idDecoder
        |> required "name" string
        |> required "description" string


idDecoder : Decoder ItemId
idDecoder =
    Decode.map ItemId string


idToString : ItemId -> String
idToString (ItemId id) =
    id


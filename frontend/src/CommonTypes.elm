module CommonTypes exposing (..)

type alias PagingData =
    { size : Int
    , totalElements : Int
    , totalPages : Int
    , number : Int
    }
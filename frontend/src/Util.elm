module Util exposing (..)

getActiveItemsPage : Maybe Int -> Int
getActiveItemsPage page =
    case page of
        Just pageNumber -> pageNumber
        Nothing -> 0
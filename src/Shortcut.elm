module Shortcut exposing (shortcutElement)

import Html exposing (Html, node)
import Json.Encode


type Key
    = Escape
    | BackSpace
    | Space
    | Tab
    | Enter
    | ArrowLeft
    | ArrowRight
    | ArrowUp
    | ArrowDown
    | ShiftLeft
    | ShiftRight
    | MetaLeft
    | MetaRight
    | AltLeft
    | AltRight
    | ControlLeft
    | ControlRight
    | Regular String


type alias Shortcut msg =
    { msg : msg
    , keyCombination :
        { baseKey : Key
        , alt : Maybe Bool
        , shift : Maybe Bool
        , ctrl : Maybe Bool
        , meta : Maybe Bool
        }
    }


encodeShortcut : Shortcut msg -> Json.Encode.Value
encodeShortcut =
    Debug.todo "do that"


shortcutElement : List (Shortcut msg) -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
shortcutElement shortcut attrs =
    node "shortcut"
        -- Add 2 attributes here: one to send the props we're listening to
        (Debug.todo "to this"
            -- one to listen to the stuff
            :: Debug.todo "and that"
            :: attrs
        )

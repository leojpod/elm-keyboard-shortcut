module Shortcut exposing
    ( Key(..)
    , esc
    , shiftShortcut
    , shortcutElement
    , simpleShortcut
    )

import Html exposing (Html, node)
import Html.Attributes
import Html.Events
import Json.Decode
import Json.Encode
import Json.Encode.Extra
import List.Extra
import Maybe.Extra


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


simpleShortcut : Key -> msg -> Shortcut msg
simpleShortcut key msg =
    { msg = msg
    , keyCombination =
        { baseKey = key
        , alt = Nothing
        , shift = Nothing
        , ctrl = Nothing
        , meta = Nothing
        }
    }


esc : msg -> Shortcut msg
esc =
    simpleShortcut Escape


shiftShortcut : Key -> msg -> Shortcut msg
shiftShortcut key msg =
    { msg = msg
    , keyCombination =
        { baseKey = key
        , alt = Nothing
        , shift = Just True
        , ctrl = Nothing
        , meta = Nothing
        }
    }


keyToString : Key -> String
keyToString key =
    case key of
        Escape ->
            "Escape"

        BackSpace ->
            "Backspace"

        Space ->
            "Space"

        Tab ->
            "Tab"

        Enter ->
            "Enter"

        ArrowLeft ->
            "ArrowLeft"

        ArrowRight ->
            "ArrowRight"

        ArrowUp ->
            "ArrowUp"

        ArrowDown ->
            "ArrowDown"

        ShiftLeft ->
            "ShiftLeft"

        ShiftRight ->
            "ShiftRight"

        MetaLeft ->
            "MetaLeft"

        MetaRight ->
            "MetaRight"

        AltLeft ->
            "AltLeft"

        AltRight ->
            "AltRight"

        ControlLeft ->
            "CtrlLeft"

        ControlRight ->
            "CtrlRight"

        Regular keyName ->
            keyName


hashShortcut : Shortcut msg -> String
hashShortcut { keyCombination } =
    keyToString keyCombination.baseKey
        ++ Maybe.Extra.unwrap ""
            (\bool ->
                if bool then
                    "alt"

                else
                    "!alt"
            )
            keyCombination.alt
        ++ Maybe.Extra.unwrap ""
            (\bool ->
                if bool then
                    "shift"

                else
                    "!shift"
            )
            keyCombination.shift
        ++ Maybe.Extra.unwrap ""
            (\bool ->
                if bool then
                    "ctrl"

                else
                    "!ctrl"
            )
            keyCombination.ctrl
        ++ Maybe.Extra.unwrap ""
            (\bool ->
                if bool then
                    "meta"

                else
                    "!meta"
            )
            keyCombination.shift


encodeShortcut : Shortcut msg -> Json.Encode.Value
encodeShortcut ({ keyCombination } as shortcut) =
    Json.Encode.object
        [ ( "name", Json.Encode.string <| hashShortcut shortcut )
        , ( "baseKey", Json.Encode.string <| keyToString keyCombination.baseKey )
        , ( "alt", Json.Encode.Extra.maybe Json.Encode.bool keyCombination.alt )
        , ( "shift", Json.Encode.Extra.maybe Json.Encode.bool keyCombination.shift )
        , ( "ctrl", Json.Encode.Extra.maybe Json.Encode.bool keyCombination.ctrl )
        , ( "meta", Json.Encode.Extra.maybe Json.Encode.bool keyCombination.meta )
        ]


onShortcut : List (Shortcut msg) -> Html.Attribute msg
onShortcut shortcuts =
    Html.Events.on "shortcut"
        (Json.Decode.at [ "detail", "name" ] Json.Decode.string
            |> Json.Decode.andThen
                (\hash ->
                    List.Extra.find (hashShortcut >> (==) hash) shortcuts
                        |> Maybe.Extra.unwrap (Json.Decode.fail "did not match a known shortcut") (.msg >> Json.Decode.succeed)
                )
        )


shortcutElement : List (Shortcut msg) -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
shortcutElement shortcuts attrs =
    node "shortcut-element"
        -- Add 2 attributes here: one to send the props we're listening to
        (Html.Attributes.property "shortcuts" (Json.Encode.list encodeShortcut shortcuts)
            -- one to listen to the stuff
            :: onShortcut shortcuts
            :: attrs
        )

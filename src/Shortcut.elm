module Shortcut exposing
    ( Key(..)
    , Shortcut
    , simpleShortcut
    , esc
    , altShortcut
    , shiftShortcut
    , ctrlShortcut
    , metaShortcut
    , shortcutElement
    )

{-| This module provide a quick and simple (enough) way of listening for keyboard event by describing which shortcut you are interested in.


# Shortcut description

The first important part of using this package is describing which shortcut should trigger which message.
This can be done by instantiating the `Shortcut` record directly or via one of the utility function


## Keys

@docs Key


## Shortcut record

In essence, a shortcut is just an indication of which key(s) we are interested in and a message that should be sent when a keyboard event matches out.

@docs Shortcut


## Utility functions

@docs simpleShortcut

@docs esc

@docs altShortcut

@docs shiftShortcut

@docs ctrlShortcut

@docs metaShortcut


# Shortcut capture

The capture part is taken care of by the custom-element that comes with this package. For a reminder on how to install it, please have a look at the [README](./).

@docs shortcutElement

-}

import Html exposing (Html, node)
import Html.Attributes
import Html.Events
import Json.Decode
import Json.Encode
import Json.Encode.Extra
import List.Extra
import Maybe.Extra


{-| The `Key` is merely an easy way to define which key you are interested in.
It has an entry for all the special keys and a constructor (`Regular`) for all the rest.
-}
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


{-| Shortcut is simply a record of a message and a keyCombination that describe the keyboard shortcut you're interested in.

Please note that the `Maybe Bool` for the alt, shift, ctrl and meta modifirs allows you to choose if you would like to ignore a modifier (`Nothing`), force it to be present (`True`) or force it to be abscent (`False`)

For instance the following key combination will match both _Shift_ _O_ and _Ctrl_ _Shift_ _O_ but not _Shift_ _Meta_ _O_

    myKeyCombination =
        { baseKey = Regular "O"
        , alt = Nothing
        , shift = Just True
        , ctrl = Nothing
        , meta = Just False
        }

-}
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


{-| if you're only interested in one key not in any of the modifiers then `simpleShortcut` is made for you.
Both of these are equivalent:

    myShortcut =
        { msg = SimpleMessage
        , keyCombination =
            { baseKey = Regular "O"
            , alt = Nothing
            , shift = Nothing
            , ctrl = Nothing
            , meta = Nothing
            }
        }

    mySimpleShortcut =
        simpleShortcut <| Regular "O"

-}
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


{-| alias of `simpleShortcut Escape`
-}
esc : msg -> Shortcut msg
esc =
    simpleShortcut Escape


{-| equivalent of setting all the modifiers to `Nothing` and the **alt** modifier to `Just True`
-}
altShortcut : Key -> msg -> Shortcut msg
altShortcut key msg =
    { msg = msg
    , keyCombination =
        { baseKey = key
        , alt = Just True
        , shift = Nothing
        , ctrl = Nothing
        , meta = Nothing
        }
    }


{-| equivalent of setting all the modifiers to `Nothing` and the **shift** modifier to `Just True`
-}
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


{-| equivalent of setting all the modifiers to `Nothing` and the **ctrl** modifier to `Just True`
-}
ctrlShortcut : Key -> msg -> Shortcut msg
ctrlShortcut key msg =
    { msg = msg
    , keyCombination =
        { baseKey = key
        , alt = Nothing
        , shift = Nothing
        , ctrl = Just True
        , meta = Nothing
        }
    }


{-| equivalent of setting all the modifiers to `Nothing` and the **meta** modifier to `Just True`
-}
metaShortcut : Key -> msg -> Shortcut msg
metaShortcut key msg =
    { msg = msg
    , keyCombination =
        { baseKey = key
        , alt = Nothing
        , shift = Nothing
        , ctrl = Nothing
        , meta = Just True
        }
    }


{-| utility function to prepare encoding of the keys
-}
keyToString : Key -> String
keyToString key =
    case key of
        Escape ->
            "Escape"

        BackSpace ->
            "Backspace"

        Space ->
            " "

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


{-| utility function to create an identity to each of the shortcut so we can find out which of them was triggered when we hear back from the custom element
-}
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


{-| the classical JSON encoder for a given shortcut
-}
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


{-| our custom event listener that will figure out which of the given shortcut was called
-}
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


{-| This is the elm wrapper for the custom-element provided by the NPM companion package
-}
shortcutElement : List (Shortcut msg) -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
shortcutElement shortcuts attrs =
    node "shortcut-element"
        -- Add 2 attributes here: one to send the props we're listening to
        (Html.Attributes.property "shortcuts" (Json.Encode.list encodeShortcut shortcuts)
            -- one to listen to the stuff
            :: onShortcut shortcuts
            :: attrs
        )

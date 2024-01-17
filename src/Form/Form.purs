module Form where

import Prelude

import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Utils (css)

type Option = Maybe Boolean

type Options = Array Option

data Action = ChangeOption Option

type Output = Option

type Input = Unit

type State = { options ∷ Options, picked ∷ Option }

initialOptions ∷ Options
initialOptions = [ Just true, Just false ]

initialState ∷ Input → State
initialState _ = { options: initialOptions, picked: Nothing }

form ∷ ∀ q. H.Component q Input Output Aff
form = H.mkComponent
  { initialState: initialState
  , render
  , eval: H.mkEval $ H.defaultEval { handleAction = handleAction }
  }
  where
  handleAction = case _ of
    ChangeOption option → do
      H.modify_ _ { picked = option }
      H.raise option

  renderOption ∷ Maybe Boolean → String
  renderOption op = case op of
    Just true → "Available"
    Just false → "Unavailable"
    Nothing → ""

  render state =
    HH.section [ css "availability-form" ]
      [ HH.section [ css "options" ]
          ( state.options <#> \option →
              HH.label_
                [ HH.input
                    [ HP.type_ HP.InputRadio
                    , HP.name "radio"
                    , HP.checked (state.picked == option)
                    , HE.onChange (\_ → ChangeOption option)
                    , css "radio__button"
                    ]
                , HH.text $ renderOption option
                ]
          )
      ]
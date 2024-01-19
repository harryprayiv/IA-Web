module Form where

import Prelude

import Effect.Aff (Aff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Utils (css)

type Option = Boolean

type State = { picked ∷ Option }

data Action = ChangeOption Option

type Output = Option

type Input = Unit

initialState ∷ Input → State
initialState _ = { picked: false }

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

  render state =
    HH.section [ css "availability-form" ]
      [ HH.section [ css "options" ]
          [ HH.label_
              [ HH.input
                  [ HP.type_ HP.InputRadio
                  , HP.name "radio"
                  , HP.checked state.picked
                  , HE.onChange (\_ → ChangeOption true)
                  , css "radio__button"
                  ]
              , HH.text "Available"
              ]
          ]
      ]

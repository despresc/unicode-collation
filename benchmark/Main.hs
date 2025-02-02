{-# LANGUAGE OverloadedStrings    #-}
{-# LANGUAGE ScopedTypeVariables  #-}
module Main (main) where

import Test.Tasty.Bench
import Test.QuickCheck
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.ICU as ICU
import Data.Text.ICU.Collate (Attribute(..), Strength(..))
import Text.Collate
import Test.QuickCheck.Instances.Text ()
import Data.List (sortBy)
-- import Debug.Trace

main :: IO ()
main = do
  (randomTexts :: [Text]) <- generate (infiniteListOf arbitrary)
  (randomSingletonTexts :: [Text]) <-
    generate (infiniteListOf (arbitrary `suchThat` (\t -> T.length t == 1)))
  let tenThousand = take 10000 randomTexts
  let tenThousandSingletons = take 10000 randomSingletonTexts
  let icuCollator lang = ICU.collatorWith (ICU.Locale lang)
                          [NormalizationMode True, Strength Quaternary]
  defaultMain
    [ bench "sort a list of 10000 random Texts (en)"
        (whnf (sortBy (collate (collatorFor "en"))) tenThousand)
    , bench "sort same list with text-icu (en)"
        (whnf (sortBy (ICU.collate (icuCollator "en"))) tenThousand)
    , bench "sort a list of 10000 random Texts (zh)"
        (whnf (sortBy (collate (collatorFor "zh"))) tenThousand)
    , bench "sort same list with text-icu (zh)"
        (whnf (sortBy (ICU.collate (icuCollator "zh"))) tenThousand)
    , bench "sort a list of 10000 random Texts (en-u-kk-false = no normalize)"
        (whnf (sortBy (collate (collatorFor "en-u-kk-false"))) tenThousand)
    , bench "sort a list of 10000 random Texts of length 1 (en)"
        (whnf (sortBy (collate (collatorFor "en"))) tenThousandSingletons)
    , bench "sort same list with text-icu (en)"
        (whnf (sortBy (ICU.collate (icuCollator "en"))) tenThousandSingletons)
    ]


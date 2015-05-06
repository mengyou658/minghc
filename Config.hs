
module Config(
    Arch(..), showArch,
    Program(..), Version,
    defaultVersion, source,
    extractVersion
    ) where

import Data.List.Extra
import Development.Shake.FilePath
import Data.Char

data Arch = Arch32 | Arch64

showArch :: Arch -> String
showArch Arch32 = "i386"
showArch Arch64 = "x86_64"

data Program = GHC | Cabal | Git | Alex | Happy | Stackage deriving (Eq,Show,Enum,Bounded)

type Version = String

defaultVersion :: Program -> Version
-- Latest released versions of all
defaultVersion GHC = "7.10.1"
defaultVersion Git = "2.4.0.1"
defaultVersion Cabal = "1.22.2.0"
defaultVersion Alex = "3.1.4"
defaultVersion Happy = "1.19.5"
defaultVersion Stackage = "20150505"

source :: Arch -> Program -> Version -> String
-- Official GHC release, available in xv and bz2, but the xv one is harder to extract on Windows systems
source arch GHC ver = "https://www.haskell.org/ghc/dist/" ++ ver ++ "/ghc-" ++ ver ++ "-" ++ showArch arch ++ "-unknown-mingw32.tar.bz2"
-- Official Cabal release as a binary snapshot
source _ Cabal ver@"1.22.2.0" =
    "https://s3.amazonaws.com/download.fpcomplete.com/minghc/cabal-install-" ++ ver ++ "-i386-unknown-mingw32.tar.gz"
source _ Cabal ver = "https://www.haskell.org/cabal/release/cabal-install-" ++ ver ++ "/cabal-" ++ ver ++ "-i386-unknown-mingw32.tar.gz"
-- Generated by using PortableGit, removing Perl, and recompressing
-- See: https://github.com/snoyberg/minghc/issues/6#issuecomment-66904686
source _ Git ver = "https://s3.amazonaws.com/download.fpcomplete.com/minghc/PortableGit-" ++ ver ++ ".7z.exe"
-- Both Alex and Happy were generated by compiling with GHC 7.8.3 using the $prefix approach.
-- See: https://github.com/fpco/minghc/issues/24#issuecomment-91231733
source _ Alex ver = "https://s3.amazonaws.com/download.fpcomplete.com/minghc/alex-" ++ ver ++ ".zip"
source _ Happy ver = "https://s3.amazonaws.com/download.fpcomplete.com/minghc/happy-" ++ ver ++ ".zip"
source _ Stackage ver = "https://s3.amazonaws.com/download.fpcomplete.com/minghc/stackage-cli-" ++ ver ++ ".zip"


-- | Given a filename containing a version-like bit, extract the version
extractVersion :: String -> Version
extractVersion = intercalate "." . takeWhile f . dropWhile (not . f) . wordsBy (`elem` "-.") . takeFileName
    where f = all isDigit

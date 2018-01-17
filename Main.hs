module Main where

import Control.Monad
import qualified Data.ByteString as B
import Data.Char
import Data.Int

import Hero

main :: IO ()
main = do
  s <- B.getContents
  case parseWasm s of
    Left err -> putStrLn $ "parse error: " ++ show err
    Right out -> runWasm [syscall] out "e"

syscall :: HeroVM -> [WasmOp] -> IO HeroVM
syscall vm [I32_const hp, I32_const sp, I32_const n]
  | n == 21 = do
    when (getTag /= 5) $ error "BUG! want String"
    let slen = getNumVM 4 (addr + 4) vm
    putStr $ [chr $ getNumVM 1 (addr + 8 + i) vm | i <- [0..slen - 1]]
    pure $ putNumVM 4 hp (4 :: Int) $ putNumVM 4 (hp + 4) (0 :: Int)
      $ pushVM (I32_const (hp + 8)) vm
  | n == 22 = do
    when (getTag /= 3) $ error "BUG! want Int"
    print (getNumVM 8 (addr + 8) vm :: Int)
    pure $ putNumVM 4 hp (4 :: Int) $ putNumVM 4 (hp + 4) (0 :: Int)
      $ pushVM (I32_const (hp + 8)) vm
  | otherwise = error $ "BUG! bad syscall " ++ show n
  where
    addr = getNumVM 4 (sp + 4) vm :: Int32
    getTag = getNumVM 1 addr vm :: Int
syscall a b = error $ "BUG! bad syscall " ++ show (a, b)

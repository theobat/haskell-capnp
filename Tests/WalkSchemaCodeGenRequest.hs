-- | This module defines a test that tries to walk over the
-- CodeGeneratorRequest in `testdata/schema-codegenreq.capnp`,
-- failing if any of the data is not as expected.
module Tests.WalkSchemaCodeGenRequest
    (walkSchemaCodeGenRequestTest)
  where

import qualified Data.ByteString as BS
import Control.Monad.Quota
import Tests.Util
import Prelude hiding (length)
import Schema.CapNProto.Reader.Schema as Schema
import Data.CapNProto.Message as M
import Data.CapNProto.Untyped
import qualified Schema.CapNProto.Reader.Schema.CodeGeneratorRequest as CGReq
import Test.Framework (Test)
import Test.HUnit (Assertion, assertEqual)

import Data.CapNProto.Blob (BlobSlice)

-- TODO: This contains a bit of copypasta from some of the untyped tests; should
-- factor that out.
theAssert :: Assertion
theAssert = do
    bytes <- BS.readFile "testdata/schema-codegenreq"
    msg <- M.decode bytes
    ((), endQuota) <- runQuotaT (rootPtr msg >>= reader) 1024
    assertEqual "Correct remaining quota" 1016 endQuota
  where
    reader :: Maybe (Ptr (BlobSlice BS.ByteString)) -> QuotaT IO ()
    reader (Just (PtrStruct root)) = do
        let req = Schema.CodeGeneratorRequest root
        Just nodes <- CGReq.nodes req
        Just requestedFiles <- CGReq.requestedFiles req
        37 <- length nodes
        1 <- length requestedFiles
        return ()
    reader _ = error "Expected `Just (PtrStruct root)`"

walkSchemaCodeGenRequestTest :: Test
walkSchemaCodeGenRequestTest =
    assertionsToTest "walk schema CodeGenerationRequest" [theAssert]

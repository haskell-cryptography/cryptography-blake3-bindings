# `cryptography-blake3-bindings` [![CI](https://github.com/haskell-cryptography/cryptography-blake3-bindings/actions/workflows/ci.yml/badge.svg)](https://github.com/haskell-cryptography/cryptography-blake3-bindings/actions/workflows/ci.yml) [![made with Haskell](https://img.shields.io/badge/Made%20in-Haskell-%235e5086?logo=haskell&style=flat-square)](https://haskell.org)

## What is this?

A set of low-level bindings (and helpers) wrapping the [C implementation of
BLAKE3](https://github.com/BLAKE3-team/BLAKE3/tree/master/c), version 1.6.0.

## What're the goals of this project?

### Ease of use

No user of this library should ever have to think about C, linking to system
libraries, enabling SIMD through weird flags, or any similar issues. Just add
this as a dependency and go.

### Minimality

No weird lawless type class hierarchy. No dependencies outside of `base`. These
are truly minimal bindings, for those who want the ability to operate as close
to the original code as posssible.

### Stability and clarity

Just by reading the documentation of this library, you should know everything
you need to use it. No reading the C 'documentation' should ever be required.
Furthermore, you shouldn't need to doubt that this behaves - our CI should prove
it to you. No surprises on upgrades either - _impeccable_
[PVP](https://pvp.haskell.org) compliance only here.

## How do I use this?

```haskell
{-# LANGUAGE ScopedTypeVariables #-}

module Sample where

import Data.Word (Word8)
import Foreign.Ptr (Ptr)
import Foreign.Marshal.Alloc (mallocBytes)
import Cryptography.BLAKE3.Bindings (
  blake3HasherAlloc,
  blake3HasherInit,
  blake3HasherUpdate,
  blake3OutLen,
  blake3HasherFree
  )

hashMeSomeData :: IO (Ptr Word8)
hashMeSomeData = do
  -- allocate and init a hasher
  hasherPtr <- blake3HasherAlloc
  blake3HasherInit hasherPtr
  -- allocate some data to hash
  -- we'll assume you've set it all up somehow
  (len, dataPtr) <- mkDataWithLen
  -- hash the data
  blake3HasherUpdate hasherPtr dataPtr len
  -- allocate a buffer of the right size to store the result
  outPtr :: Ptr Word8 <- mallocBytes . fromIntegral $ blake3OutLen
  -- write out the hashed data
  blake3HasherFinalize hasherPtr outPtr blake3OutLen
  -- release the hasher
  blake3HasherFree hasherPtr
  -- yield the answer
  pure outPtr
```

## What does this run on?

Our CI currently checks Windows, Linux (on Ubuntu) and macOS. Additionally, we
also verify that the embedded BLAKE3 compiles correctly on SIMD and non-SIMD
platforms: we currently test x86-64 (Github Actions default), aarch64 and armv7.

## What can I do with this?

The bindings themselves are licensed under `BSD-3-Clause`, while the C code for
BLAKE3 is under `Apache-2.0`. See the `LICENSE` and `LICENSE.BLAKE3` files for
more information.

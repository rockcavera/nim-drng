## Provides access to the rdrand and rdseed instructions. Based on Intel's DRNG
## Library (libdrng)
## 
## This package supports the following compilers:
## GCC: rdrand 4.6.0 or higher; rdseed no information
## CLANG: rdrand 3.2.0 or higher; rdseed no information
## VCC: rdrand and rdseed Visual C ++ 2015 or higher
## 
## Basic Use
## =========
## ```nim
## import drng
## 
## # Checks if the rdrand instruction is supported by the hardware
## if rdRandIsSupported:
##   # Obtaining 16 random bits
##   var u16: uint16
## 
##   if rdRand16(u16) == DrngSuccess:
##     echo "16 random bits: ", u16
##   
##   # Obtaining 32 random bits
##   var u32: uint32
## 
##   if rdRand32(u32) == DrngSuccess:
##     echo "32 random bits: ", u32
##   
##   # Obtaining 64 random bits
##   var u64: uint64
## 
##   if rdRand64(u64) == DrngSuccess:
##     echo "64 random bits: ", u64
##   
##   # Obtaining N random bytes
##   var nRandBytes = newSeq[uint8](u16 mod 38)
## 
##   if rdRandGetBytes(nRandBytes) == DrngSuccess:
##     echo len(nRandBytes), " random bytes: ", nRandBytes
##   
##   # Obtaining N random `uint16`
##   var nRandu16 = newSeq[uint16](u16 mod 28)
## 
##   if rdRandGetN16(nRandu16) == DrngSuccess:
##     echo len(nRandu16), " random `uint16`: ", nRandu16
##   
##   # Obtaining N random `uint32`
##   var nRandu32 = newSeq[uint32](u32 mod 18)
## 
##   if rdRandGetN32(nRandu32) == DrngSuccess:
##     echo len(nRandu32), " random `uint32`: ", nRandu32
##   
##   # Obtaining N random `uint64`
##   var nRandu64 = newSeq[uint64](u64 mod 8)
## 
##   if rdRandGetN64(nRandu64) == DrngSuccess:
##     echo len(nRandu64), " random `uint64`: ", nRandu64
## else:
##   echo "RdRand not supported"
## 
## # Checks if the rdseed instruction is supported by the hardware
## if rdSeedIsSupported:
##   # Obtaining 16 random bits
##   var u16: uint16
## 
##   if rdSeed16(u16) == DrngSuccess:
##     echo "16 random bits: ", u16
##   
##   # Obtaining 32 random bits
##   var u32: uint32
## 
##   if rdSeed32(u32) == DrngSuccess:
##     echo "32 random bits: ", u32
##   
##   # Obtaining 64 random bits
##   var u64: uint64
## 
##   if rdSeed64(u64) == DrngSuccess:
##     echo "64 random bits: ", u64
##   
##   # Obtaining N random bytes
##   var nRandBytes = newSeq[uint8](u16 mod 38)
## 
##   if rdSeedGetBytes(nRandBytes) == DrngSuccess:
##     echo len(nRandBytes), " random bytes: ", nRandBytes
##   
##   # Obtaining N random `uint16`
##   var nRandu16 = newSeq[uint16](u16 mod 28)
## 
##   if rdSeedGetN16(nRandu16) == DrngSuccess:
##     echo len(nRandu16), " random `uint16`: ", nRandu16
##   
##   # Obtaining N random `uint32`
##   var nRandu32 = newSeq[uint32](u32 mod 18)
## 
##   if rdSeedGetN32(nRandu32) == DrngSuccess:
##     echo len(nRandu32), " random `uint32`: ", nRandu32
##   
##   # Obtaining N random `uint64`
##   var nRandu64 = newSeq[uint64](u64 mod 8)
## 
##   if rdSeedGetN64(nRandu64) == DrngSuccess:
##     echo len(nRandu64), " random `uint64`: ", nRandu64
## else:
##   echo "RdSeed not supported"
## ```
# https://software.intel.com/content/www/us/en/develop/articles/intel-digital-random-number-generator-drng-library-implementation-and-uses.html
# https://software.intel.com/content/www/us/en/develop/articles/intel-digital-random-number-generator-drng-software-implementation-guide.html

import pkg/cpuwhat

const intSize = sizeof(int)

when defined(amd64) or defined(i386):
  when defined(gcc) or defined(clang):
    {.passC: "-mrdrnd -mrdseed".}

    func  builtin_rdrand16(x: var cushort): cuint
                          {.importc: "__builtin_ia32_rdrand16_step", nodecl.}
    func  builtin_rdrand32(x: var cuint): cuint
                          {.importc: "__builtin_ia32_rdrand32_step", nodecl.}
    
    func  builtin_rdseed16(x: var cushort): cuint
                          {.importc: "__builtin_ia32_rdseed_hi_step", nodecl.}
    func  builtin_rdseed32(x: var cuint): cuint
                          {.importc: "__builtin_ia32_rdseed_si_step", nodecl.}

    when intSize == 8:
      func  builtin_rdrand64(x: var culonglong): cuint
                            {.importc: "__builtin_ia32_rdrand64_step", nodecl.}
      
      func  builtin_rdseed64(x: var culonglong): cuint
                            {.importc: "__builtin_ia32_rdseed_di_step", nodecl.}
  elif defined(vcc):
    func  builtin_rdrand16(x: var cushort): cint {.importc: "_rdrand16_step",
                                                  header: "<immintrin.h>".}
    func  builtin_rdrand32(x: var cuint): cint {.importc: "_rdrand32_step",
                                                header: "<immintrin.h>".}

    func  builtin_rdseed16(x: var cushort): cint {.importc: "_rdseed16_step",
                                                  header: "<immintrin.h>".}
    func  builtin_rdseed32(x: var cuint): cint {.importc: "_rdseed32_step",
                                                header: "<immintrin.h>".}

    when intSize == 8:
      func  builtin_rdrand64(x: var culonglong): cint
                            {.importc: "_rdrand64_step",
                             header: "<immintrin.h>".}

      func  builtin_rdseed64(x: var culonglong): cint
                            {.importc: "_rdseed64_step",
                             header: "<immintrin.h>".}
  else:
    {.fatal: "Compiler not supported.".}
else:
  {.fatal: "This package supports only the `amd64` and `i386` architectures.".}

type
  DrngStatus* = enum
    DrngUnsupported = -3
      ## The rdseed/rdrand instruction is unsupported by the host hardware.
    DrngSupported = -2
      ## The rdseed/rdrand instruction is supported by the host hardware.
    DrngNotReady = -1
      ## The rdseed/rdrand call was unsuccessful, the hardware was not ready,
      ## and a random number was not returned.
    DrngSuccess = 1
      ## The rdseed/rdrand call was successful, the hardware was ready, and a
      ## random number was returned.

const
  retryLimitRdRand = 10
  retryLimitRdSeed = 0
  czero = when defined(gcc) or defined(clang): 0.cuint else: 0.cint

let
  rdRandIsSupported* = hasRDRAND()
    ## It will be set to `true` if the hardware supports the rdrand instruction
    ## or `false` if it does not.
  rdSeedIsSupported* = hasRDSEED()
    ## It will be set to `true` if the hardware supports the rdseed instruction
    ## or `false` if it does not.

##########
# RdRand #
##########

proc rdRand16*(x: var uint16, retry: int = retryLimitRdRand): DrngStatus =
  ## Calls rdrand and stores 16 random bits in `x`.
  ## 
  ## If successful, `DrngSuccess` will be returned. Can return `DrngUnsupported`
  ## or `DrngNotReady`.
  ## 
  ## **Parameters**
  ## - `x` is an `uint16` where the random result will be stored.
  ## - `retry` determines the number of attempts to obtain a successful.
  if not rdRandIsSupported:
    return DrngUnsupported

  var n = 1

  while true:
    if builtin_rdrand16(x) > czero:
      return DrngSuccess

    inc(n)

    if n > retry:
      return DrngNotReady

proc rdRand32*(x: var uint32, retry: int = retryLimitRdRand): DrngStatus =
  ## Calls rdrand and stores 32 random bits in `x`.
  ## 
  ## If successful, `DrngSuccess` will be returned. Can return `DrngUnsupported`
  ## or `DrngNotReady`.
  ## 
  ## ## **Parameters**
  ## - `x` is an `uint32` where the random result will be stored.
  ## - `retry` determines the number of attempts to obtain a successful.
  if not rdRandIsSupported:
    return DrngUnsupported

  var n = 1

  while true:
    if builtin_rdrand32(x) > czero:
      return DrngSuccess

    inc(n)

    if n > retry:
      return DrngNotReady

proc rdRand64*(x: var uint64, retry: int = retryLimitRdRand): DrngStatus =
  ## Calls rdrand and stores 64 random bits in `x`.
  ## 
  ## If successful, `DrngSuccess` will be returned. Can return `DrngUnsupported`
  ## or `DrngNotReady`.
  ##
  ## **Parameters**
  ## - `x` is an `uint64` where the random result will be stored.
  ## - `retry` determines the number of attempts to obtain a successful.
  if not rdRandIsSupported:
    return DrngUnsupported

  when intSize == 8:
    var n = 1

    while true:
      if builtin_rdrand64(x) > czero:
        return DrngSuccess

      inc(n)

      if n > retry:
        return DrngNotReady
  elif intSize == 4:
    var
      aux: uint32
      n = 1
      y = 2

    while true:
      if builtin_rdrand32(aux) > czero:
        dec(y)

        if y == 0:
          x = x or cast[uint64](aux)

          return DrngSuccess

        x = cast[uint64](aux) shl 32

      inc(n)

      if n > retry:
        return DrngNotReady

proc rdRandGetBytes*(x: var openArray[uint8]): DrngStatus =
  ## Calls rdrand and fills `x` with random bits.
  ## 
  ## If successful, `DrngSuccess` will be returned. Can return `DrngUnsupported`
  ## or `DrngNotReady`.
  var
    i = 0
    n = len(x)

  while n > intSize:
    when intSize == 4:
      var aux: uint32

      result = rdRand32(aux)
    elif intSize == 8:
      var aux: uint64

      result = rdRand64(aux)
    
    if result != DrngSuccess: return result

    for e in 1 .. intSize:
      x[i] = cast[uint8](aux)

      aux = aux shr 8

      inc(i)

    dec(n, intSize)
  
  if n > 0:
    when intSize == 4:
      var aux: uint32

      result = rdRand32(aux)
    elif intSize == 8:
      var aux: uint64

      result = rdRand64(aux)
    
    if result != DrngSuccess: return result

    while n > 0:
      x[i] = cast[uint8](aux)

      aux = aux shr 8

      dec(n)
      inc(i)

proc rdRandGetN16*(x: var openArray[uint16]): DrngStatus =
  ## Calls rdrand and fills `x` with random bits.
  ## 
  ## If successful, `DrngSuccess` will be returned. Can return `DrngUnsupported`
  ## or `DrngNotReady`.
  for i in 0 ..< len(x):
    result = rdRand16(x[i])

    if result != DrngSuccess: break

proc rdRandGetN32*(x: var openArray[uint32]): DrngStatus =
  ## Calls rdrand and fills `x` with random bits.
  ## 
  ## If successful, `DrngSuccess` will be returned. Can return `DrngUnsupported`
  ## or `DrngNotReady`.
  for i in 0 ..< len(x):
    result = rdRand32(x[i])

    if result != DrngSuccess: break

proc rdRandGetN64*(x: var openArray[uint64]): DrngStatus =
  ## Calls rdrand and fills `x` with random bits.
  ## 
  ## If successful, `DrngSuccess` will be returned. Can return `DrngUnsupported`
  ## or `DrngNotReady`.
  for i in 0 ..< len(x):
    result = rdRand64(x[i])

    if result != DrngSuccess: break

##########
# RdSeed #
##########

proc rdSeed16*(x: var uint16, retry: int = retryLimitRdSeed): DrngStatus =
  ## Calls rdseed and stores 16 random bits in `x`.
  ## 
  ## If successful, `DrngSuccess` will be returned. Can return `DrngUnsupported`
  ## or `DrngNotReady`.
  ## 
  ## **Parameters**
  ## - `x` is an `uint16` where the random result will be stored.
  ## - `retry` determines the number of attempts to obtain a successful.
  if not rdSeedIsSupported:
    return DrngUnsupported

  var n = 1

  while true:
    if builtin_rdseed16(x) > czero:
      return DrngSuccess

    inc(n)

    if n > retry:
      return DrngNotReady

proc rdSeed32*(x: var uint32, retry: int = retryLimitRdSeed): DrngStatus =
  ## Calls rdseed and stores 32 random bits in `x`.
  ## 
  ## If successful, `DrngSuccess` will be returned. Can return `DrngUnsupported`
  ## or `DrngNotReady`.
  ## 
  ## **Parameters**
  ## - `x` is an `uint32` where the random result will be stored.
  ## - `retry` determines the number of attempts to obtain a successful.
  if not rdSeedIsSupported:
    return DrngUnsupported

  var n = 1

  while true:
    if builtin_rdseed32(x) > czero:
      return DrngSuccess

    inc(n)

    if n > retry:
      return DrngNotReady

proc rdSeed64*(x: var uint64, retry: int = retryLimitRdSeed): DrngStatus =
  ## Calls rdseed and stores 64 random bits in `x`.
  ## 
  ## If successful, `DrngSuccess` will be returned. Can return `DrngUnsupported`
  ## or `DrngNotReady`.
  ## 
  ## **Parameters**
  ## - `x` is an `uint64` where the random result will be stored.
  ## - `retry` determines the number of attempts to obtain a successful.
  if not rdSeedIsSupported:
    return DrngUnsupported

  when intSize == 8:
    var n = 1

    while true:
      if builtin_rdseed64(x) > czero:
        return DrngSuccess

      inc(n)

      if n > retry:
        return DrngNotReady
  elif intSize == 4:
    var
      aux: uint32
      n = 1
      y = 2

    while true:
      if builtin_rdseed32(aux) > czero:
        dec(y)

        if y == 0:
          x = x or cast[uint64](aux)

          return DrngSuccess

        x = cast[uint64](aux) shl 32

      inc(n)

      if n > retry:
        return DrngNotReady

proc rdSeedGetBytes*(x: var openArray[uint8]): DrngStatus =
  ## Calls rdseed and fills `x` with random bits.
  ## 
  ## If successful, `DrngSuccess` will be returned. Can return `DrngUnsupported`
  ## or `DrngNotReady`.
  var
    i = 0
    n = len(x)

  while n > intSize:
    when intSize == 4:
      var aux: uint32

      result = rdSeed32(aux)
    elif intSize == 8:
      var aux: uint64

      result = rdSeed64(aux)
    
    if result != DrngSuccess: return result

    for e in 1 .. intSize:
      x[i] = cast[uint8](aux)

      aux = aux shr 8

      inc(i)

    dec(n, intSize)
  
  if n > 0:
    when intSize == 4:
      var aux: uint32

      result = rdSeed32(aux)
    elif intSize == 8:
      var aux: uint64

      result = rdSeed64(aux)
    
    if result != DrngSuccess: return result

    while n > 0:
      x[i] = cast[uint8](aux)

      aux = aux shr 8

      dec(n)
      inc(i)

proc rdSeedGetN16*(x: var openArray[uint16]): DrngStatus =
  ## Calls rdseed and fills `x` with random bits.
  ## 
  ## If successful, `DrngSuccess` will be returned. Can return `DrngUnsupported`
  ## or `DrngNotReady`.
  for i in 0 ..< len(x):
    result = rdRand16(x[i])

    if result != DrngSuccess: break

proc rdSeedGetN32*(x: var openArray[uint32]): DrngStatus =
  ## Calls rdseed and fills `x` with random bits.
  ## 
  ## If successful, `DrngSuccess` will be returned. Can return `DrngUnsupported`
  ## or `DrngNotReady`.
  for i in 0 ..< len(x):
    result = rdRand32(x[i])

    if result != DrngSuccess: break

proc rdSeedGetN64*(x: var openArray[uint64]): DrngStatus =
  ## Calls rdseed and fills `x` with random bits.
  ## 
  ## If successful, `DrngSuccess` will be returned. Can return `DrngUnsupported`
  ## or `DrngNotReady`.
  for i in 0 ..< len(x):
    result = rdRand64(x[i])

    if result != DrngSuccess: break
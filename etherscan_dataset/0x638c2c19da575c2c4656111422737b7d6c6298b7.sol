// Sources flattened with hardhat v2.5.0 https://hardhat.org

// File contracts/libs/ABDKMath64x64.sol

// SPDX-License-Identifier: BSD-4-Clause
/*
 * ABDK Math 64.64 Smart Contract Library.  Copyright © 2019 by ABDK Consulting.
 * Author: Mikhail Vladimirov <mikhail.vladimirov@gmail.com>
 */
pragma solidity ^0.8.0;

/**
 * Smart contract library of mathematical functions operating with signed
 * 64.64-bit fixed point numbers.  Signed 64.64-bit fixed point number is
 * basically a simple fraction whose numerator is signed 128-bit integer and
 * denominator is 2^64.  As long as denominator is always the same, there is no
 * need to store it, thus in Solidity signed 64.64-bit fixed point numbers are
 * represented by int128 type holding only the numerator.
 */
library ABDKMath64x64 {
  /*
   * Minimum value signed 64.64-bit fixed point number may have. 
   */
  int128 private constant MIN_64x64 = -0x80000000000000000000000000000000;

  /*
   * Maximum value signed 64.64-bit fixed point number may have. 
   */
  int128 private constant MAX_64x64 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

  /**
   * Convert signed 256-bit integer number into signed 64.64-bit fixed point
   * number.  Revert on overflow.
   *
   * @param x signed 256-bit integer number
   * @return signed 64.64-bit fixed point number
   */
  function fromInt (int256 x) internal pure returns (int128) {
    unchecked {
      require (x >= -0x8000000000000000 && x <= 0x7FFFFFFFFFFFFFFF);
      return int128 (x << 64);
    }
  }

  /**
   * Convert signed 64.64 fixed point number into signed 64-bit integer number
   * rounding down.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64-bit integer number
   */
  function toInt (int128 x) internal pure returns (int64) {
    unchecked {
      return int64 (x >> 64);
    }
  }

  /**
   * Convert unsigned 256-bit integer number into signed 64.64-bit fixed point
   * number.  Revert on overflow.
   *
   * @param x unsigned 256-bit integer number
   * @return signed 64.64-bit fixed point number
   */
  function fromUInt (uint256 x) internal pure returns (int128) {
    unchecked {
      require (x <= 0x7FFFFFFFFFFFFFFF);
      return int128 (int256 (x << 64));
    }
  }

  /**
   * Convert signed 64.64 fixed point number into unsigned 64-bit integer
   * number rounding down.  Revert on underflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @return unsigned 64-bit integer number
   */
  function toUInt (int128 x) internal pure returns (uint64) {
    unchecked {
      require (x >= 0);
      return uint64 (uint128 (x >> 64));
    }
  }

  /**
   * Convert signed 128.128 fixed point number into signed 64.64-bit fixed point
   * number rounding down.  Revert on overflow.
   *
   * @param x signed 128.128-bin fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function from128x128 (int256 x) internal pure returns (int128) {
    unchecked {
      int256 result = x >> 64;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  /**
   * Convert signed 64.64 fixed point number into signed 128.128 fixed point
   * number.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 128.128 fixed point number
   */
  function to128x128 (int128 x) internal pure returns (int256) {
    unchecked {
      return int256 (x) << 64;
    }
  }

  /**
   * Calculate x + y.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function add (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      int256 result = int256(x) + y;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  /**
   * Calculate x - y.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function sub (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      int256 result = int256(x) - y;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  /**
   * Calculate x * y rounding down.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function mul (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      int256 result = int256(x) * y >> 64;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  /**
   * Calculate x * y rounding towards zero, where x is signed 64.64 fixed point
   * number and y is signed 256-bit integer number.  Revert on overflow.
   *
   * @param x signed 64.64 fixed point number
   * @param y signed 256-bit integer number
   * @return signed 256-bit integer number
   */
  function muli (int128 x, int256 y) internal pure returns (int256) {
    unchecked {
      if (x == MIN_64x64) {
        require (y >= -0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF &&
          y <= 0x1000000000000000000000000000000000000000000000000);
        return -y << 63;
      } else {
        bool negativeResult = false;
        if (x < 0) {
          x = -x;
          negativeResult = true;
        }
        if (y < 0) {
          y = -y; // We rely on overflow behavior here
          negativeResult = !negativeResult;
        }
        uint256 absoluteResult = mulu (x, uint256 (y));
        if (negativeResult) {
          require (absoluteResult <=
            0x8000000000000000000000000000000000000000000000000000000000000000);
          return -int256 (absoluteResult); // We rely on overflow behavior here
        } else {
          require (absoluteResult <=
            0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
          return int256 (absoluteResult);
        }
      }
    }
  }

  /**
   * Calculate x * y rounding down, where x is signed 64.64 fixed point number
   * and y is unsigned 256-bit integer number.  Revert on overflow.
   *
   * @param x signed 64.64 fixed point number
   * @param y unsigned 256-bit integer number
   * @return unsigned 256-bit integer number
   */
  function mulu (int128 x, uint256 y) internal pure returns (uint256) {
    unchecked {
      if (y == 0) return 0;

      require (x >= 0);

      uint256 lo = (uint256 (int256 (x)) * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)) >> 64;
      uint256 hi = uint256 (int256 (x)) * (y >> 128);

      require (hi <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
      hi <<= 64;

      require (hi <=
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF - lo);
      return hi + lo;
    }
  }

  /**
   * Calculate x / y rounding towards zero.  Revert on overflow or when y is
   * zero.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function div (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      require (y != 0);
      int256 result = (int256 (x) << 64) / y;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  /**
   * Calculate x / y rounding towards zero, where x and y are signed 256-bit
   * integer numbers.  Revert on overflow or when y is zero.
   *
   * @param x signed 256-bit integer number
   * @param y signed 256-bit integer number
   * @return signed 64.64-bit fixed point number
   */
  function divi (int256 x, int256 y) internal pure returns (int128) {
    unchecked {
      require (y != 0);

      bool negativeResult = false;
      if (x < 0) {
        x = -x; // We rely on overflow behavior here
        negativeResult = true;
      }
      if (y < 0) {
        y = -y; // We rely on overflow behavior here
        negativeResult = !negativeResult;
      }
      uint128 absoluteResult = divuu (uint256 (x), uint256 (y));
      if (negativeResult) {
        require (absoluteResult <= 0x80000000000000000000000000000000);
        return -int128 (absoluteResult); // We rely on overflow behavior here
      } else {
        require (absoluteResult <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        return int128 (absoluteResult); // We rely on overflow behavior here
      }
    }
  }

  /**
   * Calculate x / y rounding towards zero, where x and y are unsigned 256-bit
   * integer numbers.  Revert on overflow or when y is zero.
   *
   * @param x unsigned 256-bit integer number
   * @param y unsigned 256-bit integer number
   * @return signed 64.64-bit fixed point number
   */
  function divu (uint256 x, uint256 y) internal pure returns (int128) {
    unchecked {
      require (y != 0);
      uint128 result = divuu (x, y);
      require (result <= uint128 (MAX_64x64));
      return int128 (result);
    }
  }

  /**
   * Calculate -x.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function neg (int128 x) internal pure returns (int128) {
    unchecked {
      require (x != MIN_64x64);
      return -x;
    }
  }

  /**
   * Calculate |x|.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function abs (int128 x) internal pure returns (int128) {
    unchecked {
      require (x != MIN_64x64);
      return x < 0 ? -x : x;
    }
  }

  /**
   * Calculate 1 / x rounding towards zero.  Revert on overflow or when x is
   * zero.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function inv (int128 x) internal pure returns (int128) {
    unchecked {
      require (x != 0);
      int256 result = int256 (0x100000000000000000000000000000000) / x;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  /**
   * Calculate arithmetics average of x and y, i.e. (x + y) / 2 rounding down.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function avg (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      return int128 ((int256 (x) + int256 (y)) >> 1);
    }
  }

  /**
   * Calculate geometric average of x and y, i.e. sqrt (x * y) rounding down.
   * Revert on overflow or in case x * y is negative.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function gavg (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      int256 m = int256 (x) * int256 (y);
      require (m >= 0);
      require (m <
          0x4000000000000000000000000000000000000000000000000000000000000000);
      return int128 (sqrtu (uint256 (m)));
    }
  }

  /**
   * Calculate x^y assuming 0^0 is 1, where x is signed 64.64 fixed point number
   * and y is unsigned 256-bit integer number.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y uint256 value
   * @return signed 64.64-bit fixed point number
   */
  function pow (int128 x, uint256 y) internal pure returns (int128) {
    unchecked {
      bool negative = x < 0 && y & 1 == 1;

      uint256 absX = uint128 (x < 0 ? -x : x);
      uint256 absResult;
      absResult = 0x100000000000000000000000000000000;

      if (absX <= 0x10000000000000000) {
        absX <<= 63;
        while (y != 0) {
          if (y & 0x1 != 0) {
            absResult = absResult * absX >> 127;
          }
          absX = absX * absX >> 127;

          if (y & 0x2 != 0) {
            absResult = absResult * absX >> 127;
          }
          absX = absX * absX >> 127;

          if (y & 0x4 != 0) {
            absResult = absResult * absX >> 127;
          }
          absX = absX * absX >> 127;

          if (y & 0x8 != 0) {
            absResult = absResult * absX >> 127;
          }
          absX = absX * absX >> 127;

          y >>= 4;
        }

        absResult >>= 64;
      } else {
        uint256 absXShift = 63;
        if (absX < 0x1000000000000000000000000) { absX <<= 32; absXShift -= 32; }
        if (absX < 0x10000000000000000000000000000) { absX <<= 16; absXShift -= 16; }
        if (absX < 0x1000000000000000000000000000000) { absX <<= 8; absXShift -= 8; }
        if (absX < 0x10000000000000000000000000000000) { absX <<= 4; absXShift -= 4; }
        if (absX < 0x40000000000000000000000000000000) { absX <<= 2; absXShift -= 2; }
        if (absX < 0x80000000000000000000000000000000) { absX <<= 1; absXShift -= 1; }

        uint256 resultShift = 0;
        while (y != 0) {
          require (absXShift < 64);

          if (y & 0x1 != 0) {
            absResult = absResult * absX >> 127;
            resultShift += absXShift;
            if (absResult > 0x100000000000000000000000000000000) {
              absResult >>= 1;
              resultShift += 1;
            }
          }
          absX = absX * absX >> 127;
          absXShift <<= 1;
          if (absX >= 0x100000000000000000000000000000000) {
              absX >>= 1;
              absXShift += 1;
          }

          y >>= 1;
        }

        require (resultShift < 64);
        absResult >>= 64 - resultShift;
      }
      int256 result = negative ? -int256 (absResult) : int256 (absResult);
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  /**
   * Calculate sqrt (x) rounding down.  Revert if x < 0.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function sqrt (int128 x) internal pure returns (int128) {
    unchecked {
      require (x >= 0);
      return int128 (sqrtu (uint256 (int256 (x)) << 64));
    }
  }

  /**
   * Calculate binary logarithm of x.  Revert if x <= 0.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function log_2 (int128 x) internal pure returns (int128) {
    unchecked {
      require (x > 0);

      int256 msb = 0;
      int256 xc = x;
      if (xc >= 0x10000000000000000) { xc >>= 64; msb += 64; }
      if (xc >= 0x100000000) { xc >>= 32; msb += 32; }
      if (xc >= 0x10000) { xc >>= 16; msb += 16; }
      if (xc >= 0x100) { xc >>= 8; msb += 8; }
      if (xc >= 0x10) { xc >>= 4; msb += 4; }
      if (xc >= 0x4) { xc >>= 2; msb += 2; }
      if (xc >= 0x2) msb += 1;  // No need to shift xc anymore

      int256 result = msb - 64 << 64;
      uint256 ux = uint256 (int256 (x)) << uint256 (127 - msb);
      for (int256 bit = 0x8000000000000000; bit > 0; bit >>= 1) {
        ux *= ux;
        uint256 b = ux >> 255;
        ux >>= 127 + b;
        result += bit * int256 (b);
      }

      return int128 (result);
    }
  }

  /**
   * Calculate natural logarithm of x.  Revert if x <= 0.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function ln (int128 x) internal pure returns (int128) {
    unchecked {
      require (x > 0);

      return int128 (int256 (
          uint256 (int256 (log_2 (x))) * 0xB17217F7D1CF79ABC9E3B39803F2F6AF >> 128));
    }
  }

  /**
   * Calculate binary exponent of x.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function exp_2 (int128 x) internal pure returns (int128) {
    unchecked {
      require (x < 0x400000000000000000); // Overflow

      if (x < -0x400000000000000000) return 0; // Underflow

      uint256 result = 0x80000000000000000000000000000000;

      if (x & 0x8000000000000000 > 0)
        result = result * 0x16A09E667F3BCC908B2FB1366EA957D3E >> 128;
      if (x & 0x4000000000000000 > 0)
        result = result * 0x1306FE0A31B7152DE8D5A46305C85EDEC >> 128;
      if (x & 0x2000000000000000 > 0)
        result = result * 0x1172B83C7D517ADCDF7C8C50EB14A791F >> 128;
      if (x & 0x1000000000000000 > 0)
        result = result * 0x10B5586CF9890F6298B92B71842A98363 >> 128;
      if (x & 0x800000000000000 > 0)
        result = result * 0x1059B0D31585743AE7C548EB68CA417FD >> 128;
      if (x & 0x400000000000000 > 0)
        result = result * 0x102C9A3E778060EE6F7CACA4F7A29BDE8 >> 128;
      if (x & 0x200000000000000 > 0)
        result = result * 0x10163DA9FB33356D84A66AE336DCDFA3F >> 128;
      if (x & 0x100000000000000 > 0)
        result = result * 0x100B1AFA5ABCBED6129AB13EC11DC9543 >> 128;
      if (x & 0x80000000000000 > 0)
        result = result * 0x10058C86DA1C09EA1FF19D294CF2F679B >> 128;
      if (x & 0x40000000000000 > 0)
        result = result * 0x1002C605E2E8CEC506D21BFC89A23A00F >> 128;
      if (x & 0x20000000000000 > 0)
        result = result * 0x100162F3904051FA128BCA9C55C31E5DF >> 128;
      if (x & 0x10000000000000 > 0)
        result = result * 0x1000B175EFFDC76BA38E31671CA939725 >> 128;
      if (x & 0x8000000000000 > 0)
        result = result * 0x100058BA01FB9F96D6CACD4B180917C3D >> 128;
      if (x & 0x4000000000000 > 0)
        result = result * 0x10002C5CC37DA9491D0985C348C68E7B3 >> 128;
      if (x & 0x2000000000000 > 0)
        result = result * 0x1000162E525EE054754457D5995292026 >> 128;
      if (x & 0x1000000000000 > 0)
        result = result * 0x10000B17255775C040618BF4A4ADE83FC >> 128;
      if (x & 0x800000000000 > 0)
        result = result * 0x1000058B91B5BC9AE2EED81E9B7D4CFAB >> 128;
      if (x & 0x400000000000 > 0)
        result = result * 0x100002C5C89D5EC6CA4D7C8ACC017B7C9 >> 128;
      if (x & 0x200000000000 > 0)
        result = result * 0x10000162E43F4F831060E02D839A9D16D >> 128;
      if (x & 0x100000000000 > 0)
        result = result * 0x100000B1721BCFC99D9F890EA06911763 >> 128;
      if (x & 0x80000000000 > 0)
        result = result * 0x10000058B90CF1E6D97F9CA14DBCC1628 >> 128;
      if (x & 0x40000000000 > 0)
        result = result * 0x1000002C5C863B73F016468F6BAC5CA2B >> 128;
      if (x & 0x20000000000 > 0)
        result = result * 0x100000162E430E5A18F6119E3C02282A5 >> 128;
      if (x & 0x10000000000 > 0)
        result = result * 0x1000000B1721835514B86E6D96EFD1BFE >> 128;
      if (x & 0x8000000000 > 0)
        result = result * 0x100000058B90C0B48C6BE5DF846C5B2EF >> 128;
      if (x & 0x4000000000 > 0)
        result = result * 0x10000002C5C8601CC6B9E94213C72737A >> 128;
      if (x & 0x2000000000 > 0)
        result = result * 0x1000000162E42FFF037DF38AA2B219F06 >> 128;
      if (x & 0x1000000000 > 0)
        result = result * 0x10000000B17217FBA9C739AA5819F44F9 >> 128;
      if (x & 0x800000000 > 0)
        result = result * 0x1000000058B90BFCDEE5ACD3C1CEDC823 >> 128;
      if (x & 0x400000000 > 0)
        result = result * 0x100000002C5C85FE31F35A6A30DA1BE50 >> 128;
      if (x & 0x200000000 > 0)
        result = result * 0x10000000162E42FF0999CE3541B9FFFCF >> 128;
      if (x & 0x100000000 > 0)
        result = result * 0x100000000B17217F80F4EF5AADDA45554 >> 128;
      if (x & 0x80000000 > 0)
        result = result * 0x10000000058B90BFBF8479BD5A81B51AD >> 128;
      if (x & 0x40000000 > 0)
        result = result * 0x1000000002C5C85FDF84BD62AE30A74CC >> 128;
      if (x & 0x20000000 > 0)
        result = result * 0x100000000162E42FEFB2FED257559BDAA >> 128;
      if (x & 0x10000000 > 0)
        result = result * 0x1000000000B17217F7D5A7716BBA4A9AE >> 128;
      if (x & 0x8000000 > 0)
        result = result * 0x100000000058B90BFBE9DDBAC5E109CCE >> 128;
      if (x & 0x4000000 > 0)
        result = result * 0x10000000002C5C85FDF4B15DE6F17EB0D >> 128;
      if (x & 0x2000000 > 0)
        result = result * 0x1000000000162E42FEFA494F1478FDE05 >> 128;
      if (x & 0x1000000 > 0)
        result = result * 0x10000000000B17217F7D20CF927C8E94C >> 128;
      if (x & 0x800000 > 0)
        result = result * 0x1000000000058B90BFBE8F71CB4E4B33D >> 128;
      if (x & 0x400000 > 0)
        result = result * 0x100000000002C5C85FDF477B662B26945 >> 128;
      if (x & 0x200000 > 0)
        result = result * 0x10000000000162E42FEFA3AE53369388C >> 128;
      if (x & 0x100000 > 0)
        result = result * 0x100000000000B17217F7D1D351A389D40 >> 128;
      if (x & 0x80000 > 0)
        result = result * 0x10000000000058B90BFBE8E8B2D3D4EDE >> 128;
      if (x & 0x40000 > 0)
        result = result * 0x1000000000002C5C85FDF4741BEA6E77E >> 128;
      if (x & 0x20000 > 0)
        result = result * 0x100000000000162E42FEFA39FE95583C2 >> 128;
      if (x & 0x10000 > 0)
        result = result * 0x1000000000000B17217F7D1CFB72B45E1 >> 128;
      if (x & 0x8000 > 0)
        result = result * 0x100000000000058B90BFBE8E7CC35C3F0 >> 128;
      if (x & 0x4000 > 0)
        result = result * 0x10000000000002C5C85FDF473E242EA38 >> 128;
      if (x & 0x2000 > 0)
        result = result * 0x1000000000000162E42FEFA39F02B772C >> 128;
      if (x & 0x1000 > 0)
        result = result * 0x10000000000000B17217F7D1CF7D83C1A >> 128;
      if (x & 0x800 > 0)
        result = result * 0x1000000000000058B90BFBE8E7BDCBE2E >> 128;
      if (x & 0x400 > 0)
        result = result * 0x100000000000002C5C85FDF473DEA871F >> 128;
      if (x & 0x200 > 0)
        result = result * 0x10000000000000162E42FEFA39EF44D91 >> 128;
      if (x & 0x100 > 0)
        result = result * 0x100000000000000B17217F7D1CF79E949 >> 128;
      if (x & 0x80 > 0)
        result = result * 0x10000000000000058B90BFBE8E7BCE544 >> 128;
      if (x & 0x40 > 0)
        result = result * 0x1000000000000002C5C85FDF473DE6ECA >> 128;
      if (x & 0x20 > 0)
        result = result * 0x100000000000000162E42FEFA39EF366F >> 128;
      if (x & 0x10 > 0)
        result = result * 0x1000000000000000B17217F7D1CF79AFA >> 128;
      if (x & 0x8 > 0)
        result = result * 0x100000000000000058B90BFBE8E7BCD6D >> 128;
      if (x & 0x4 > 0)
        result = result * 0x10000000000000002C5C85FDF473DE6B2 >> 128;
      if (x & 0x2 > 0)
        result = result * 0x1000000000000000162E42FEFA39EF358 >> 128;
      if (x & 0x1 > 0)
        result = result * 0x10000000000000000B17217F7D1CF79AB >> 128;

      result >>= uint256 (int256 (63 - (x >> 64)));
      require (result <= uint256 (int256 (MAX_64x64)));

      return int128 (int256 (result));
    }
  }

  /**
   * Calculate natural exponent of x.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function exp (int128 x) internal pure returns (int128) {
    unchecked {
      require (x < 0x400000000000000000); // Overflow

      if (x < -0x400000000000000000) return 0; // Underflow

      return exp_2 (
          int128 (int256 (x) * 0x171547652B82FE1777D0FFDA0D23A7D12 >> 128));
    }
  }

  /**
   * Calculate x / y rounding towards zero, where x and y are unsigned 256-bit
   * integer numbers.  Revert on overflow or when y is zero.
   *
   * @param x unsigned 256-bit integer number
   * @param y unsigned 256-bit integer number
   * @return unsigned 64.64-bit fixed point number
   */
  function divuu (uint256 x, uint256 y) private pure returns (uint128) {
    unchecked {
      require (y != 0);

      uint256 result;

      if (x <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
        result = (x << 64) / y;
      else {
        uint256 msb = 192;
        uint256 xc = x >> 192;
        if (xc >= 0x100000000) { xc >>= 32; msb += 32; }
        if (xc >= 0x10000) { xc >>= 16; msb += 16; }
        if (xc >= 0x100) { xc >>= 8; msb += 8; }
        if (xc >= 0x10) { xc >>= 4; msb += 4; }
        if (xc >= 0x4) { xc >>= 2; msb += 2; }
        if (xc >= 0x2) msb += 1;  // No need to shift xc anymore

        result = (x << 255 - msb) / ((y - 1 >> msb - 191) + 1);
        require (result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

        uint256 hi = result * (y >> 128);
        uint256 lo = result * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

        uint256 xh = x >> 192;
        uint256 xl = x << 64;

        if (xl < lo) xh -= 1;
        xl -= lo; // We rely on overflow behavior here
        lo = hi << 128;
        if (xl < lo) xh -= 1;
        xl -= lo; // We rely on overflow behavior here

        assert (xh == hi >> 128);

        result += xl / y;
      }

      require (result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
      return uint128 (result);
    }
  }

  /**
   * Calculate sqrt (x) rounding down, where x is unsigned 256-bit integer
   * number.
   *
   * @param x unsigned 256-bit integer number
   * @return unsigned 128-bit integer number
   */
  function sqrtu (uint256 x) private pure returns (uint128) {
    unchecked {
      if (x == 0) return 0;
      else {
        uint256 xx = x;
        uint256 r = 1;
        if (xx >= 0x100000000000000000000000000000000) { xx >>= 128; r <<= 64; }
        if (xx >= 0x10000000000000000) { xx >>= 64; r <<= 32; }
        if (xx >= 0x100000000) { xx >>= 32; r <<= 16; }
        if (xx >= 0x10000) { xx >>= 16; r <<= 8; }
        if (xx >= 0x100) { xx >>= 8; r <<= 4; }
        if (xx >= 0x10) { xx >>= 4; r <<= 2; }
        if (xx >= 0x8) { r <<= 1; }
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1; // Seven iterations should be enough
        uint256 r1 = x / r;
        return uint128 (r < r1 ? r : r1);
      }
    }
  }
}


// File contracts/interfaces/IFortOptions.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

/// @dev Define methods for european option
interface IFortOptions {
    
    /// @dev Option structure for view methods
    struct OptionView {
        uint index;
        address tokenAddress;
        uint strikePrice;
        bool orientation;
        uint exerciseBlock;
        uint balance;
        address owner;
    }
    
    /// @dev Option open event
    /// @param index Index of option
    /// @param dcuAmount Amount of paid DCU
    /// @param owner Owner of this option
    /// @param amount Amount of option
    event Open(
        uint index,
        uint dcuAmount,
        address owner,
        uint amount
    );

    /// @dev Option exercise event
    /// @param index Index of option
    /// @param amount Amount of option to exercise
    /// @param owner Owner of this option
    /// @param gain Amount of dcu gained
    event Exercise(uint index, uint amount, address owner, uint gain);
    
    /// @dev Option sell event
    /// @param index Index of option
    /// @param amount Amount of option to sell
    /// @param owner Owner of this option
    /// @param dcuAmount Amount of dcu acquired
    event Sell(uint index, uint amount, address owner, uint dcuAmount);

    /// @dev Returns the share of the specified option for target address
    /// @param index Index of the option
    /// @param addr Target address
    function balanceOf(uint index, address addr) external view returns (uint);

    /// @dev Find the options of the target address (in reverse order)
    /// @param start Find forward from the index corresponding to the given contract address 
    /// (excluding the record corresponding to start)
    /// @param count Maximum number of records returned
    /// @param maxFindCount Find records at most
    /// @param owner Target address
    /// @return optionArray Matched option array
    function find(
        uint start, 
        uint count, 
        uint maxFindCount, 
        address owner
    ) external view returns (OptionView[] memory optionArray);

    /// @dev List options
    /// @param offset Skip previous (offset) records
    /// @param count Return (count) records
    /// @param order Order. 0 reverse order, non-0 positive order
    /// @return optionArray Matched option array
    function list(uint offset, uint count, uint order) external view returns (OptionView[] memory optionArray);
    
    /// @dev Obtain the number of European options that have been opened
    /// @return Number of European options opened
    function getOptionCount() external view returns (uint);

    /// @dev Estimate the amount of option
    /// @param tokenAddress Target token address, 0 means eth
    /// @param oraclePrice Current price from oracle
    /// @param strikePrice The exercise price set by the user. During settlement, the system will compare the 
    /// current price of the subject matter with the exercise price to calculate the user's profit and loss
    /// @param orientation true: call, false: put
    /// @param exerciseBlock After reaching this block, the user will exercise manually, and the block will be
    /// recorded in the system using the block number
    /// @param dcuAmount Amount of paid DCU
    /// @return amount Amount of option
    function estimate(
        address tokenAddress,
        uint oraclePrice,
        uint strikePrice,
        bool orientation,
        uint exerciseBlock,
        uint dcuAmount
    ) external view returns (uint amount);

    /// @dev Open option
    /// @param tokenAddress Target token address, 0 means eth
    /// @param strikePrice The exercise price set by the user. During settlement, the system will compare the 
    /// current price of the subject matter with the exercise price to calculate the user's profit and loss
    /// @param orientation true: call, false: put
    /// @param exerciseBlock After reaching this block, the user will exercise manually, and the block will be
    /// recorded in the system using the block number
    /// @param dcuAmount Amount of paid DCU
    function open(
        address tokenAddress,
        uint strikePrice,
        bool orientation,
        uint exerciseBlock,
        uint dcuAmount
    ) external payable;

    /// @dev Exercise option
    /// @param index Index of option
    /// @param amount Amount of option to exercise
    function exercise(uint index, uint amount) external payable;

    /// @dev Sell option
    /// @param index Index of option
    /// @param amount Amount of option to sell
    function sell(uint index, uint amount) external payable;

    /// @dev Calculate option price
    /// @param oraclePrice Current price from oracle
    /// @param strikePrice The exercise price set by the user. During settlement, the system will compare the 
    /// current price of the subject matter with the exercise price to calculate the user's profit and loss
    /// @param orientation true: call, false: put
    /// @param exerciseBlock After reaching this block, the user will exercise manually, and the block will be
    /// recorded in the system using the block number
    /// @return v Option price. Need to divide (USDT_BASE << 64)
    function calcV(
        address tokenAddress,
        uint oraclePrice,
        uint strikePrice,
        bool orientation,
        uint exerciseBlock
    ) external view returns (uint v);
}


// File contracts/custom/ChainParameter.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

/// @dev Base contract of Hedge
contract ChainParameter {

    // Block time. ethereum 14 seconds, BSC 3 seconds, polygon 2.2 seconds
    uint constant BLOCK_TIME = 14;

    // Minimal exercise block period. 180000
    uint constant MIN_PERIOD = 180000;

    uint constant MIN_EXERCISE_BLOCK = 180000;
}


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.2.0

// MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// File contracts/libs/TransferHelper.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value,gas:5000}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


// File contracts/interfaces/IHedgeDAO.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

/// @dev This interface defines the DAO methods
interface IHedgeDAO {

    /// @dev Application Flag Changed event
    /// @param addr DAO application contract address
    /// @param flag Authorization flag, 1 means authorization, 0 means cancel authorization
    event ApplicationChanged(address addr, uint flag);
    
    /// @dev Set DAO application
    /// @param addr DAO application contract address
    /// @param flag Authorization flag, 1 means authorization, 0 means cancel authorization
    function setApplication(address addr, uint flag) external;

    /// @dev Check DAO application flag
    /// @param addr DAO application contract address
    /// @return Authorization flag, 1 means authorization, 0 means cancel authorization
    function checkApplication(address addr) external view returns (uint);

    /// @dev Add reward
    /// @param pool Destination pool
    function addETHReward(address pool) external payable;

    /// @dev The function returns eth rewards of specified pool
    /// @param pool Destination pool
    function totalETHRewards(address pool) external view returns (uint);

    /// @dev Settlement
    /// @param pool Destination pool. Indicates which pool to pay with
    /// @param tokenAddress Token address of receiving funds (0 means ETH)
    /// @param to Address to receive
    /// @param value Amount to receive
    function settle(address pool, address tokenAddress, address to, uint value) external payable;
}


// File contracts/interfaces/IHedgeMapping.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

/// @dev The interface defines methods for Hedge builtin contract address mapping
interface IHedgeMapping {

    /// @dev Set the built-in contract address of the system
    /// @param dcuToken Address of dcu token contract
    /// @param hedgeDAO IHedgeDAO implementation contract address
    /// @param hedgeOptions IHedgeOptions implementation contract address
    /// @param hedgeFutures IHedgeFutures implementation contract address
    /// @param hedgeVaultForStaking IHedgeVaultForStaking implementation contract address
    /// @param nestPriceFacade INestPriceFacade implementation contract address
    function setBuiltinAddress(
        address dcuToken,
        address hedgeDAO,
        address hedgeOptions,
        address hedgeFutures,
        address hedgeVaultForStaking,
        address nestPriceFacade
    ) external;

    /// @dev Get the built-in contract address of the system
    /// @return dcuToken Address of dcu token contract
    /// @return hedgeDAO IHedgeDAO implementation contract address
    /// @return hedgeOptions IHedgeOptions implementation contract address
    /// @return hedgeFutures IHedgeFutures implementation contract address
    /// @return hedgeVaultForStaking IHedgeVaultForStaking implementation contract address
    /// @return nestPriceFacade INestPriceFacade implementation contract address
    function getBuiltinAddress() external view returns (
        address dcuToken,
        address hedgeDAO,
        address hedgeOptions,
        address hedgeFutures,
        address hedgeVaultForStaking,
        address nestPriceFacade
    );

    /// @dev Get address of dcu token contract
    /// @return Address of dcu token contract
    function getDCUTokenAddress() external view returns (address);

    /// @dev Get IHedgeDAO implementation contract address
    /// @return IHedgeDAO implementation contract address
    function getHedgeDAOAddress() external view returns (address);

    /// @dev Get IHedgeOptions implementation contract address
    /// @return IHedgeOptions implementation contract address
    function getHedgeOptionsAddress() external view returns (address);

    /// @dev Get IHedgeFutures implementation contract address
    /// @return IHedgeFutures implementation contract address
    function getHedgeFuturesAddress() external view returns (address);

    /// @dev Get IHedgeVaultForStaking implementation contract address
    /// @return IHedgeVaultForStaking implementation contract address
    function getHedgeVaultForStakingAddress() external view returns (address);

    /// @dev Get INestPriceFacade implementation contract address
    /// @return INestPriceFacade implementation contract address
    function getNestPriceFacade() external view returns (address);

    /// @dev Registered address. The address registered here is the address accepted by Hedge system
    /// @param key The key
    /// @param addr Destination address. 0 means to delete the registration information
    function registerAddress(string calldata key, address addr) external;

    /// @dev Get registered address
    /// @param key The key
    /// @return Destination address. 0 means empty
    function checkAddress(string calldata key) external view returns (address);
}


// File contracts/interfaces/IHedgeGovernance.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev This interface defines the governance methods
interface IHedgeGovernance is IHedgeMapping {

    /// @dev Set governance authority
    /// @param addr Destination address
    /// @param flag Weight. 0 means to delete the governance permission of the target address. Weight is not 
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function setGovernance(address addr, uint flag) external;

    /// @dev Get governance rights
    /// @param addr Destination address
    /// @return Weight. 0 means to delete the governance permission of the target address. Weight is not 
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function getGovernance(address addr) external view returns (uint);

    /// @dev Check whether the target address has governance rights for the given target
    /// @param addr Destination address
    /// @param flag Permission weight. The permission of the target address must be greater than this weight 
    /// to pass the check
    /// @return True indicates permission
    function checkGovernance(address addr, uint flag) external view returns (bool);
}


// File contracts/HedgeBase.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev Base contract of Hedge
contract HedgeBase {

    /// @dev IHedgeGovernance implementation contract address
    address public _governance;

    /// @dev To support open-zeppelin/upgrades
    /// @param governance IHedgeGovernance implementation contract address
    function initialize(address governance) public virtual {
        require(_governance == address(0), "Hedge:!initialize");
        _governance = governance;
    }

    /// @dev Rewritten in the implementation contract, for load other contract addresses. Call 
    ///      super.update(newGovernance) when overriding, and override method without onlyGovernance
    /// @param newGovernance IHedgeGovernance implementation contract address
    function update(address newGovernance) public virtual {

        address governance = _governance;
        require(governance == msg.sender || IHedgeGovernance(governance).checkGovernance(msg.sender, 0), "Hedge:!gov");
        _governance = newGovernance;
    }

    //---------modifier------------

    modifier onlyGovernance() {
        require(IHedgeGovernance(_governance).checkGovernance(msg.sender, 0), "Hedge:!gov");
        _;
    }
}


// File contracts/custom/HedgeFrequentlyUsed.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev Base contract of Hedge
contract HedgeFrequentlyUsed is HedgeBase {

    // Address of DCU contract
    address constant DCU_TOKEN_ADDRESS = 0xf56c6eCE0C0d6Fbb9A53282C0DF71dBFaFA933eF;

    // Address of NestOpenPrice contract
    address constant NEST_OPEN_PRICE = 0xE544cF993C7d477C7ef8E91D28aCA250D135aa03;
    
    // USDT base
    uint constant USDT_BASE = 1 ether;
}


// File contracts/interfaces/INestBatchPrice2.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

/// @dev This contract implemented the mining logic of nest
interface INestBatchPrice2 {

    /// @dev Get the latest trigger price
    /// @param channelId Target channelId
    /// @param pairIndices Array of pair indices
    /// @param payback Address to receive refund
    /// @return prices Price array, i * 2 is the block where the ith price is located, and i * 2 + 1 is the ith price
    function triggeredPrice(
        uint channelId,
        uint[] calldata pairIndices, 
        address payback
    ) external payable returns (uint[] memory prices);

    /// @dev Get the full information of latest trigger price
    /// @param channelId Target channelId
    /// @param pairIndices Array of pair indices
    /// @param payback Address to receive refund
    /// @return prices Price array, i * 4 is the block where the ith price is located, i * 4 + 1 is the ith price,
    /// i * 4 + 2 is the ith average price and i * 4 + 3 is the ith volatility
    function triggeredPriceInfo(
        uint channelId, 
        uint[] calldata pairIndices,
        address payback
    ) external payable returns (uint[] memory prices);

    /// @dev Find the price at block number
    /// @param channelId Target channelId
    /// @param pairIndices Array of pair indices
    /// @param height Destination block number
    /// @param payback Address to receive refund
    /// @return prices Price array, i * 2 is the block where the ith price is located, and i * 2 + 1 is the ith price
    function findPrice(
        uint channelId,
        uint[] calldata pairIndices, 
        uint height, 
        address payback
    ) external payable returns (uint[] memory prices);

    /// @dev Get the last (num) effective price
    /// @param channelId Target channelId
    /// @param pairIndices Array of pair indices
    /// @param count The number of prices that want to return
    /// @param payback Address to receive refund
    /// @return prices Result array, i * count * 2 to (i + 1) * count * 2 - 1 are 
    /// the price results of group i quotation pairs
    function lastPriceList(
        uint channelId, 
        uint[] calldata pairIndices, 
        uint count, 
        address payback
    ) external payable returns (uint[] memory prices);

    /// @dev Returns lastPriceList and triggered price info
    /// @param channelId Target channelId
    /// @param pairIndices Array of pair indices
    /// @param count The number of prices that want to return
    /// @param payback Address to receive refund
    /// @return prices result of group i quotation pair. Among them, the first two count * are the latest prices, 
    /// and the last four are: trigger price block number, trigger price, average price and volatility
    function lastPriceListAndTriggeredPriceInfo(
        uint channelId, 
        uint[] calldata pairIndices,
        uint count, 
        address payback
    ) external payable returns (uint[] memory prices);
}


// File contracts/custom/FortPriceAdapter.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev Base contract of Hedge
contract FortPriceAdapter is HedgeFrequentlyUsed {
    
    // token configuration
    struct TokenConfig {
        // The channelId for call nest price
        uint16 channelId;
        // The pairIndex for call nest price
        uint16 pairIndex;

        // SigmaSQ for token
        uint64 sigmaSQ;
        // MIU_LONG for token
        uint64 miuLong;
        // MIU_SHORT for token
        uint64 miuShort;
    }

    // Post unit: 2000usd
    uint constant POST_UNIT = 2000 * USDT_BASE;

    function _pairIndices(uint pairIndex) private pure returns (uint[] memory pairIndices) {
        pairIndices = new uint[](1);
        pairIndices[0] = pairIndex;
    }

    // Query latest 2 price
    function _lastPriceList(
        TokenConfig memory tokenConfig, 
        uint fee, 
        address payback
    ) internal returns (uint[] memory prices) {
        prices = INestBatchPrice2(NEST_OPEN_PRICE).lastPriceList {
            value: fee
        } (uint(tokenConfig.channelId), _pairIndices(uint(tokenConfig.pairIndex)), 2, payback);

        prices[1] = _toUSDTPrice(prices[1]);
        prices[3] = _toUSDTPrice(prices[3]);
    }

    // Query latest price
    function _latestPrice(
        TokenConfig memory tokenConfig, 
        uint fee, 
        address payback
    ) internal returns (uint oraclePrice) {
        uint[] memory prices = INestBatchPrice2(NEST_OPEN_PRICE).lastPriceList {
            value: fee
        } (uint(tokenConfig.channelId), _pairIndices(uint(tokenConfig.pairIndex)), 1, payback);

        oraclePrice = _toUSDTPrice(prices[1]);
    }

    // Find price by blockNumber
    function _findPrice(
        TokenConfig memory tokenConfig, 
        uint blockNumber, 
        uint fee, 
        address payback
    ) internal returns (uint oraclePrice) {
        uint[] memory prices = INestBatchPrice2(NEST_OPEN_PRICE).findPrice {
            value: fee
        } (uint(tokenConfig.channelId), _pairIndices(uint(tokenConfig.pairIndex)), blockNumber, payback);

        oraclePrice = _toUSDTPrice(prices[1]);
    }

    // Convert to usdt based price
    function _toUSDTPrice(uint rawPrice) internal pure returns (uint) {
        return POST_UNIT * 1 ether / rawPrice;
    }
}


// File @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol@v4.2.0

// MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}


// File @openzeppelin/contracts/utils/Context.sol@v4.2.0

// MIT

pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// File @openzeppelin/contracts/token/ERC20/ERC20.sol@v4.2.0

// MIT

pragma solidity ^0.8.0;



/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}


// File contracts/DCU.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev DCU token
contract DCU is HedgeBase, ERC20("Decentralized Currency Unit", "DCU") {

    // Flags for account
    mapping(address=>uint) _minters;

    constructor() {
    }

    modifier onlyMinter {
        require(_minters[msg.sender] == 1, "DCU:not minter");
        _;
    }

    /// @dev Set mining permission flag
    /// @param account Target address
    /// @param flag Mining permission flag
    function setMinter(address account, uint flag) external onlyGovernance {
        _minters[account] = flag;
    }

    /// @dev Check mining permission flag
    /// @param account Target address
    /// @return flag Mining permission flag
    function checkMinter(address account) external view returns (uint) {
        return _minters[account];
    }

    /// @dev Mint DCU
    /// @param to Target address
    /// @param value Mint amount
    function mint(address to, uint value) external onlyMinter {
        _mint(to, value);
    }

    /// @dev Burn DCU
    /// @param from Target address
    /// @param value Burn amount
    function burn(address from, uint value) external onlyMinter {
        _burn(from, value);
    }
}


// File contracts/FortOptions.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev European option
contract FortOptions is ChainParameter, HedgeFrequentlyUsed, FortPriceAdapter, IFortOptions {

    /// @dev Option structure
    struct Option {
        uint32 owner;
        uint112 balance;
        uint16 tokenIndex;
        uint56 strikePrice;
        bool orientation;
        uint32 exerciseBlock;
    }

    // token registration information
    struct TokenRegistration {
        TokenConfig tokenConfig;
        address tokenAddress;
    }

    // 64bits 1
    int128 constant ONE = 0x10000000000000000;

    // 64bits 50000
    uint constant V50000 = 0x0C3500000000000000000;

    // Proportion of option selling value, 10000 basis. 9500
    uint constant SELL_RATE = 9500;

    uint[8] _oldStoragePlaceHolder;

    // Option array
    Option[] _options;

    // Registered account address mapping
    mapping(address=>uint) _accountMapping;

    // Registered accounts
    address[] _accounts;

    // token to index mapping
    mapping(address=>uint) _tokenMapping;

    // token registration information array
    TokenRegistration[] _tokenRegistrations;

    constructor() {
    }

    /// @dev To support open-zeppelin/upgrades
    /// @param governance IHedgeGovernance implementation contract address
    function initialize(address governance) public override {
        super.initialize(governance);
        _accounts.push();
    }

    /// @dev Register token information
    /// @param tokenAddress Target token address, 0 means eth
    /// @param tokenConfig token configuration
    function register(address tokenAddress, TokenConfig calldata tokenConfig) external onlyGovernance {

        // Get index + 1 by tokenAddress
        uint index = _tokenMapping[tokenAddress];
        
        // index == 0 means token not registered, add
        if (index == 0) {
            // Add TokenRegistration to array
            _tokenRegistrations.push(TokenRegistration(tokenConfig, tokenAddress));
            // Record index + 1
            index = _tokenRegistrations.length;
            require(index < 0x10000, "FO:too much tokenRegistrations");
            _tokenMapping[tokenAddress] = index;
        } else {
            _tokenRegistrations[index - 1].tokenConfig = tokenConfig;
        }
    }

    /// @dev Returns the share of the specified option for target address
    /// @param index Index of the option
    /// @param addr Target address
    function balanceOf(uint index, address addr) external view override returns (uint) {
        Option memory option = _options[index];
        if (uint(option.owner) == getAccountIndex(addr)) {
            return uint(option.balance);
        }
        return 0;
    }

    /// @dev Find the options of the target address (in reverse order)
    /// @param start Find forward from the index corresponding to the given contract address 
    /// (excluding the record corresponding to start)
    /// @param count Maximum number of records returned
    /// @param maxFindCount Find records at most
    /// @param owner Target address
    /// @return optionArray Matched option array
    function find(
        uint start, 
        uint count, 
        uint maxFindCount, 
        address owner
    ) external view override returns (OptionView[] memory optionArray) {
        
        optionArray = new OptionView[](count);
        
        // Calculate search region
        Option[] storage options = _options;
        uint i = options.length;
        uint end = 0;
        if (start > 0) {
            i = start;
        }
        if (i > maxFindCount) {
            end = i - maxFindCount;
        }
        
        uint ownerIndex = getAccountIndex(owner);
        // Loop lookup to write qualified records to the buffer
        for (uint index = 0; index < count && i > end;) {
            Option storage option = options[--i];
            if (uint(option.owner) == ownerIndex) {
                optionArray[index++] = _toOptionView(option, i);
            }
        }
    }

    /// @dev List options
    /// @param offset Skip previous (offset) records
    /// @param count Return (count) records
    /// @param order Order. 0 reverse order, non-0 positive order
    /// @return optionArray Matched option array
    function list(
        uint offset, 
        uint count, 
        uint order
    ) external view override returns (OptionView[] memory optionArray) {

        // Load options
        Option[] storage options = _options;
        // Create result array
        optionArray = new OptionView[](count);
        uint length = options.length;
        uint i = 0;

        // Reverse order
        if (order == 0) {
            uint index = length - offset;
            uint end = index > count ? index - count : 0;
            while (index > end) {
                Option storage option = options[--index];
                optionArray[i++] = _toOptionView(option, index);
            }
        } 
        // Positive order
        else {
            uint index = offset;
            uint end = index + count;
            if (end > length) {
                end = length;
            }
            while (index < end) {
                optionArray[i++] = _toOptionView(options[index], index);
                ++index;
            }
        }
    }

    /// @dev Obtain the number of European options that have been opened
    /// @return Number of European options opened
    function getOptionCount() external view override returns (uint) {
        return _options.length;
    }

    /// @dev Open option
    /// @param tokenAddress Target token address, 0 means eth
    /// @param strikePrice The exercise price set by the user. During settlement, the system will compare the 
    /// current price of the subject matter with the exercise price to calculate the user's profit and loss
    /// @param orientation true: call, false: put
    /// @param exerciseBlock After reaching this block, the user will exercise manually, and the block will be
    /// recorded in the system using the block number
    /// @param dcuAmount Amount of paid DCU
    function open(
        address tokenAddress,
        uint strikePrice,
        bool orientation,
        uint exerciseBlock,
        uint dcuAmount
    ) external payable override {

        // _tokenMapping[tokenAddress] > 0 means token registered
        uint tokenIndex = _tokenMapping[tokenAddress] - 1;
        TokenConfig memory tokenConfig = _tokenRegistrations[tokenIndex].tokenConfig;

        // 1. Query price from oracle
        uint oraclePrice = _latestPrice(tokenConfig, msg.value, msg.sender);

        // 2. Calculate the amount of option
        uint amount = _estimate(tokenConfig, oraclePrice, strikePrice, orientation, exerciseBlock, dcuAmount);

        // 3. Open
        // Emit open event
        emit Open(_options.length, dcuAmount, msg.sender, amount);
        // Add option to array
        _options.push(Option(
            //uint32 owner;
            uint32(_addressIndex(msg.sender)),
            //uint112 balance;
            _toUInt112(amount),
            uint16(tokenIndex),
            //uint56 strikePrice;
            _encodeFloat(strikePrice),
            //bool orientation;
            orientation,
            //uint32 exerciseBlock;
            uint32(exerciseBlock)
        ));

        // 4. Burn DCU
        DCU(DCU_TOKEN_ADDRESS).burn(msg.sender, dcuAmount);
    }

    /// @dev Estimate the amount of option
    /// @param tokenAddress Target token address, 0 means eth
    /// @param oraclePrice Current price from oracle
    /// @param strikePrice The exercise price set by the user. During settlement, the system will compare the 
    /// current price of the subject matter with the exercise price to calculate the user's profit and loss
    /// @param orientation true: call, false: put
    /// @param exerciseBlock After reaching this block, the user will exercise manually, and the block will be
    /// recorded in the system using the block number
    /// @param dcuAmount Amount of paid DCU
    /// @return amount Amount of option
    function estimate(
        address tokenAddress,
        uint oraclePrice,
        uint strikePrice,
        bool orientation,
        uint exerciseBlock,
        uint dcuAmount
    ) external view override returns (uint amount) {
        return _estimate(
            _tokenRegistrations[_tokenMapping[tokenAddress] - 1].tokenConfig,
            oraclePrice,
            strikePrice,
            orientation,
            exerciseBlock,
            dcuAmount
        );
    }
    
    /// @dev Exercise option
    /// @param index Index of option
    /// @param amount Amount of option to exercise
    function exercise(uint index, uint amount) external payable override {

        // 1. Load the option
        Option storage option = _options[index];
        address owner = _accounts[uint(option.owner)];
        uint strikePrice = _decodeFloat(option.strikePrice);
        bool orientation = option.orientation;
        uint exerciseBlock = uint(option.exerciseBlock);

        TokenConfig memory tokenConfig = _tokenRegistrations[option.tokenIndex].tokenConfig;

        require(block.number >= exerciseBlock, "FEO:at maturity");

        // 2. Deduct the specified amount
        option.balance = _toUInt112(uint(option.balance) - amount);

        // 3. Find the price by specified block from oracle
        uint oraclePrice = _findPrice(tokenConfig, exerciseBlock, msg.value, msg.sender);

        // 4. Calculate the number of DCU that can be obtained
        uint gain = 0;
        // Call option
        if (orientation) {
            // Win
            if (oraclePrice > strikePrice) {
                gain = amount * (oraclePrice - strikePrice) / USDT_BASE;
            }
        } 
        // Put option
        else {
            // Win
            if (oraclePrice < strikePrice) {
                gain = amount * (strikePrice - oraclePrice) / USDT_BASE;
            }
        }

        // 5. If win, mint DCU to user
        if (gain > 0) {
            DCU(DCU_TOKEN_ADDRESS).mint(owner, gain);
        }

        // emit Exercise event
        emit Exercise(index, amount, owner, gain);
    }

    /// @dev Sell option
    /// @param index Index of option
    /// @param amount Amount of option to sell
    function sell(uint index, uint amount) external payable override {
        // Sell formula: vt=Max(ct(T,K)*0.95, 0). 
        // ct(K,T) Is the price of option present
        // Note: No less than 1% condition

        // 1. Load the option
        Option storage option = _options[index];
        address owner = _accounts[uint(option.owner)];
        require(owner == msg.sender, "FO:not owner");
        uint strikePrice = _decodeFloat(option.strikePrice);
        bool orientation = option.orientation;
        uint exerciseBlock = uint(option.exerciseBlock);

        TokenConfig memory tokenConfig = _tokenRegistrations[option.tokenIndex].tokenConfig;

        // 2. Deduct the specified amount
        option.balance = _toUInt112(uint(option.balance) - amount);

        // 3. Query price from oracle
        uint oraclePrice = _latestPrice(tokenConfig, msg.value, msg.sender);

        // 4. Calculate option price
        uint dcuAmount = amount * _calcV(
            tokenConfig, 
            oraclePrice,
            strikePrice,
            orientation,
            exerciseBlock
        ) * SELL_RATE / (USDT_BASE * 0x27100000000000000000); 
        //(USDT_BASE * 10000 << 64);

        if (dcuAmount > 0) {
            DCU(DCU_TOKEN_ADDRESS).mint(msg.sender, dcuAmount);
        }

        // emit Sell event
        emit Sell(index, amount, msg.sender, dcuAmount);
    }

    /// @dev Calculate option price
    /// @param oraclePrice Current price from oracle
    /// @param strikePrice The exercise price set by the user. During settlement, the system will compare the 
    /// current price of the subject matter with the exercise price to calculate the user's profit and loss
    /// @param orientation true: call, false: put
    /// @param exerciseBlock After reaching this block, the user will exercise manually, and the block will be
    /// recorded in the system using the block number
    /// @return v Option price. Need to divide (USDT_BASE << 64)
    function calcV(
        address tokenAddress,
        uint oraclePrice,
        uint strikePrice,
        bool orientation,
        uint exerciseBlock
    ) public view override returns (uint v) {
        return _calcV(
            _tokenRegistrations[_tokenMapping[tokenAddress] - 1].tokenConfig,
            oraclePrice,
            strikePrice,
            orientation,
            exerciseBlock
        );
    }

    /// @dev Gets the address corresponding to the given index number
    /// @param index The index number of the specified address
    /// @return The address corresponding to the given index number
    function indexAddress(uint index) public view returns (address) {
        return _accounts[index];
    }

    /// @dev Gets the registration index number of the specified address
    /// @param addr Destination address
    /// @return 0 means nonexistent, non-0 means index number
    function getAccountIndex(address addr) public view returns (uint) {
        return _accountMapping[addr];
    }

    /// @dev Get the length of registered account array
    /// @return The length of registered account array
    function getAccountCount() external view returns (uint) {
        return _accounts.length;
    }

    // Convert to OptionView
    function _toOptionView(
        Option storage option, 
        uint index
    ) private view returns (OptionView memory) {
        return OptionView(
            index,
            _tokenRegistrations[option.tokenIndex].tokenAddress,
            _decodeFloat(option.strikePrice),
            option.orientation,
            uint(option.exerciseBlock),
            option.balance,
            _accounts[uint(option.owner)]
        );
    }

    // Convert 18 decimal points to 64 binary points
    function _d18TOb64(uint v) private pure returns (int128) {
        require(v < 0x6F05B59D3B200000000000000000000, "FEO:can't convert to 64bits");
        return int128(int((v << 64) / 1 ether));
    }

    // Convert uint to int128
    function _toInt128(uint v) private pure returns (int128) {
        require(v < 0x80000000000000000000000000000000, "FEO:can't convert to int128");
        return int128(int(v));
    }

    // Convert int128 to uint
    function _toUInt(int128 v) private pure returns (uint) {
        require(v >= 0, "FEO:can't convert to uint");
        return uint(int(v));
    }

    // Convert uint to uint112
    function _toUInt112(uint v) private pure returns (uint112) {
        require(v < 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF,"HO:can't convert to uint112");
        return uint112(v);
    }

    // Calculate standard normal distribution by table
    function _snd(int128 x) private pure returns (int128) {
        uint[28] memory table = [
            /* */ ///////////////////// STANDARD NORMAL TABLE //////////////////////////
            /* */ 0x174A15BF143412A8111C0F8F0E020C740AE6095807CA063B04AD031E018F0000, //
            ///// 0x2F8C2E0F2C912B1229922811268F250B23872202207D1EF61D6F1BE61A5D18D8, //
            /* */ 0x2F8C2E0F2C912B1229922811268F250B23872202207D1EF61D6F1BE61A5D18D4, //
            /* */ 0x46A2453C43D4426B41003F943E263CB63B4539D3385F36EA357333FB32823108, //
            /* */ 0x5C0D5AC5597B582F56E05590543E52EA5194503C4EE24D874C294ACA49694807, //
            /* */ 0x6F6C6E466D1F6BF56AC9699B686A6738660364CC6392625761195FD95E975D53, //
            /* */ 0x807E7F7F7E7D7D797C737B6A7A5F79517841772F761A750373E972CD71AF708E, //
            /* */ 0x8F2A8E518D768C998BB98AD789F2890B88218736864785568463836E8276817B, //
            /* */ 0x9B749AC19A0B9953989997DD971E965D959A94D4940C9342927591A690D49000, //
            ///// 0xA57CA4ECA459A3C4A32EA295A1FAA15CA0BDA01C9F789ED29E2A9D809CD39C25, //
            /* */ 0xA57CA4ECA459A3C4A32EA295A1FAA15DA0BDA01C9F789ED29E2A9D809CD39C25, //
            /* */ 0xAD78AD07AC93AC1EABA7AB2EAAB3AA36A9B8A937A8B5A830A7AAA721A697A60B, //
            /* */ 0xB3AAB353B2FAB2A0B245B1E7B189B128B0C6B062AFFDAF96AF2DAEC2AE56ADE8, //
            /* */ 0xB859B818B7D6B793B74EB708B6C0B678B62EB5E2B595B547B4F7B4A6B454B400, //
            /* */ 0xBBCDBB9EBB6EBB3CBB0ABAD7BAA2BA6DBA36B9FFB9C6B98CB951B915B8D8B899, //
            /* */ 0xBE49BE27BE05BDE2BDBEBD99BD74BD4DBD26BCFEBCD5BCACBC81BC56BC29BBFC, //
            /* */ 0xC006BFEEBFD7BFBEBFA5BF8CBF72BF57BF3CBF20BF03BEE6BEC8BEA9BE8ABE69, //
            /* */ 0xC135C126C116C105C0F4C0E3C0D1C0BFC0ACC099C086C072C05DC048C032C01C, //
            /* */ 0xC200C1F5C1EBC1E0C1D5C1C9C1BEC1B1C1A5C198C18BC17EC170C162C154C145, //
            /* */ 0xC283C27CC275C26EC267C260C258C250C248C240C238C22FC226C21DC213C20A, //
            /* */ 0xC2D6C2D2C2CDC2C9C2C5C2C0C2BBC2B6C2B1C2ACC2A7C2A1C29BC295C28FC289, //
            /* */ 0xC309C306C304C301C2FEC2FCC2F9C2F6C2F2C2EFC2ECC2E8C2E5C2E1C2DEC2DA, //
            /* */ 0xC328C326C325C323C321C320C31EC31CC31AC318C316C314C312C310C30EC30B, //
            /* */ 0xC33AC339C338C337C336C335C334C333C332C331C330C32EC32DC32CC32AC329, //
            /* */ 0xC344C343C343C342C342C341C341C340C33FC33FC33EC33DC33DC33CC33BC33A, //
            /* */ 0xC34AC349C349C349C348C348C348C348C347C347C346C346C346C345C345C344, //
            /* */ 0xC34DC34DC34CC34CC34CC34CC34CC34CC34BC34BC34BC34BC34BC34AC34AC34A, //
            /* */ 0xC34EC34EC34EC34EC34EC34EC34EC34EC34EC34EC34DC34DC34DC34DC34DC34D, //
            /* */ 0xC34FC34FC34FC34FC34FC34FC34FC34FC34FC34FC34FC34FC34FC34FC34EC34E, //
            /* */ 0xC350C350C350C350C350C350C34FC34FC34FC34FC34FC34FC34FC34FC34FC34F  //
            /* */ //////////////////// MADE IN CHINA 2021-08-24 ////////////////////////
        ];

        uint ux = uint(int(x < 0 ? -x : x)) * 100;
        uint i = ux >> 64;
        uint v = V50000;

        if (i < 447) {
            v = uint((table[i >> 4] >> ((i & 0xF) << 4)) & 0xFFFF) << 64;
            v = (
                    (
                        (
                            (uint((table[(i + 1) >> 4] >> (((i + 1) & 0xF) << 4)) & 0xFFFF) << 64)
                            - v
                        ) * (ux & 0xFFFFFFFFFFFFFFFF) //(ux - (i << 64))
                    ) >> 64
                ) + v;
        }

        if (x > 0) {
            v = V50000 + v;
        } else {
            v = V50000 - v;
        }

        return int128(int(v / 100000));
    }

    /// @dev Estimate the amount of option
    /// @param oraclePrice Current price from oracle
    /// @param strikePrice The exercise price set by the user. During settlement, the system will compare the 
    /// current price of the subject matter with the exercise price to calculate the user's profit and loss
    /// @param orientation true: call, false: put
    /// @param exerciseBlock After reaching this block, the user will exercise manually, and the block will be
    /// recorded in the system using the block number
    /// @param dcuAmount Amount of paid DCU
    /// @return amount Amount of option
    function _estimate(
        TokenConfig memory tokenConfig,
        uint oraclePrice,
        uint strikePrice,
        bool orientation,
        uint exerciseBlock,
        uint dcuAmount
    ) private view returns (uint amount) {

        require(exerciseBlock > block.number + MIN_PERIOD, "FEO:exerciseBlock too small");

        // 1. Calculate option price
        uint v = _calcV(
            tokenConfig, 
            oraclePrice,
            strikePrice,
            orientation,
            exerciseBlock
        );

        // 2. Correct option price
        if (orientation) {
            //v = _calcVc(config, oraclePrice, T, strikePrice);
            // Vc>=S0*1%; Vp>=K*1%
            // require(v * 100 >> 64 >= oraclePrice, "FEO:vc must greater than S0*1%");
            if (v * 100 >> 64 < oraclePrice) {
                v = oraclePrice * 0x10000000000000000 / 100;
            }
        } else {
            //v = _calcVp(config, oraclePrice, T, strikePrice);
            // Vc>=S0*1%; Vp>=K*1%
            // require(v * 100 >> 64 >= strikePrice, "FEO:vp must greater than K*1%");
            if (v * 100 >> 64 < strikePrice) {
                v = strikePrice * 0x10000000000000000 / 100;
            }
        }

        // 3. Calculate the amount of option
        amount = (USDT_BASE << 64) * dcuAmount / v;
    }

    /// @dev Calculate option price
    /// @param oraclePrice Current price from oracle
    /// @param strikePrice The exercise price set by the user. During settlement, the system will compare the 
    /// current price of the subject matter with the exercise price to calculate the user's profit and loss
    /// @param orientation true: call, false: put
    /// @param exerciseBlock After reaching this block, the user will exercise manually, and the block will be
    /// recorded in the system using the block number
    /// @return v Option price. Need to divide (USDT_BASE << 64)
    function _calcV(
        TokenConfig memory tokenConfig,
        uint oraclePrice,
        uint strikePrice,
        bool orientation,
        uint exerciseBlock
    ) private view returns (uint v) {

        // Convert the total time according to the average block out time
        uint T = (exerciseBlock - block.number) * BLOCK_TIME;
        v = orientation 
            ? _calcVc(tokenConfig, oraclePrice, T, strikePrice) 
            : _calcVp(tokenConfig, oraclePrice, T, strikePrice);
    }

    // Calculate option price for call
    function _calcVc(TokenConfig memory tokenConfig, uint S0, uint T, uint K) private pure returns (uint vc) {

        int128 sigmaSQ_T = _d18TOb64(uint(tokenConfig.sigmaSQ) * T);
        int128 miu_T = _toInt128(uint(tokenConfig.miuLong) * T);
        int128 sigma_t = ABDKMath64x64.sqrt(sigmaSQ_T);
        int128 D1 = _D1(S0, K, sigmaSQ_T, miu_T);
        int128 d = ABDKMath64x64.div(D1, sigma_t);

        uint left = _toUInt(ABDKMath64x64.mul(
            //ABDKMath64x64.exp(miu_T), 
            // Use approximate calculation method: x*(1+rt)
            // by chenf 2021-12-28 15:27
            miu_T + ONE,
            ABDKMath64x64.sub(
                ONE,
                _snd(ABDKMath64x64.sub(d, sigma_t))
            )
        )) * S0;
        uint right = _toUInt(ABDKMath64x64.sub(ONE, _snd(d))) * K;
        
        vc = left > right ? left - right : 0;
    }

    // Calculate option price for put
    function _calcVp(TokenConfig memory tokenConfig, uint S0, uint T, uint K) private pure returns (uint vp) {

        int128 sigmaSQ_T = _d18TOb64(uint(tokenConfig.sigmaSQ) * T);
        int128 miu_T = _toInt128(uint(tokenConfig.miuShort) * T);
        int128 sigma_t = ABDKMath64x64.sqrt(sigmaSQ_T);
        int128 D1 = _D1(S0, K, sigmaSQ_T, miu_T);
        int128 d = ABDKMath64x64.div(D1, sigma_t);

        uint left = _toUInt(_snd(d)) * K;
        uint right = _toUInt(ABDKMath64x64.mul(
            //ABDKMath64x64.exp(miu_T), 
            // Use approximate calculation method: x*(1+rt)
            // by chenf 2021-12-28 15:27
            miu_T + ONE,
            _snd(ABDKMath64x64.sub(d, sigma_t))
        )) * S0;

        vp = left > right ? left - right : 0;
    }

    // d1 in formula, Because didn't divide by σ, So it's named D1
    function _D1(uint S0, uint K, int128 sigmaSQ_T, int128 miu_T) private pure returns (int128) {

        //require(K < 0x1000000000000000000000000000000000000000000000000, "FEO:K can't ROL 64bits");
        return
            ABDKMath64x64.sub(
                ABDKMath64x64.add(
                    ABDKMath64x64.ln(_toInt128(K * 0x10000000000000000 / S0)),
                    sigmaSQ_T >> 1
                ),
                miu_T
            );
    }
    
    /// @dev Encode the uint value as a floating-point representation in the form of fraction * 16 ^ exponent
    /// @param value Destination uint value
    /// @return float format
    function _encodeFloat(uint value) private pure returns (uint56) {

        uint exponent = 0; 
        while (value > 0x3FFFFFFFFFFFF) {
            value >>= 4;
            ++exponent;
        }
        return uint56((value << 6) | exponent);
    }

    /// @dev Decode the floating-point representation of fraction * 16 ^ exponent to uint
    /// @param floatValue fraction value
    /// @return decode format
    function _decodeFloat(uint56 floatValue) private pure returns (uint) {
        return (uint(floatValue) >> 6) << ((uint(floatValue) & 0x3F) << 2);
    }
    
    /// @dev Gets the index number of the specified address. If it does not exist, register
    /// @param addr Destination address
    /// @return The index number of the specified address
    function _addressIndex(address addr) private returns (uint) {

        uint index = _accountMapping[addr];
        if (index == 0) {
            // If it exceeds the maximum number that 32 bits can store, you can't continue to register a new account.
            // If you need to support a new account, you need to update the contract
            require((_accountMapping[addr] = index = _accounts.length) < 0x100000000, "HO:!accounts");
            _accounts.push(addr);
        }

        return index;
    }
}
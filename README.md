# Single-Precision-FPU-Verilog

## Overview

This project implements an IEEE-754 Single Precision Floating Point Unit (FPU) using Verilog HDL.

## Features

- IEEE-754 single precision (32-bit) support
- Floating point decoding
- Special case detection (Zero, Infinity, NaN, Subnormal)
- Floating point multiplication
- Normalization logic
- Synthesizable Verilog RTL

## Operations Supported

- Floating point multiplication
- Special case handling:
  - NaN propagation
  - Infinity arithmetic
  - Zero handling
  - Subnormal number detection

## Design Summary

- Floating point numbers are divided into sign, exponent, and mantissa
- Exponent and mantissa are processed separately
- Normalization ensures the result is in proper IEEE format
- Special cases are handled before arithmetic operations

## Module Description

### fpu_decoding.v
- Detects floating point categories:
  - Zero
  - Infinity
  - Normal numbers
  - Subnormal numbers
  - Signaling NaN (sNaN)
  - Quiet NaN (qNaN)

### fpu_mul.v
- Implements floating point multiplication
- Handles:
  - Sign calculation
  - Exponent computation
  - Mantissa multiplication
  - Normalization
  - Special cases

## Tools

- Verilog HDL
- Vivado (for synthesis and simulation)

## Future Improvements

- Addition and subtraction unit
- Division unit
- Rounding modes implementation
- Fully pipelined FPU
- Comprehensive testbench

## Author

Preet Rathore

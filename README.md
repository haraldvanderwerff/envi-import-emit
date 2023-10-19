# envi-import-emit

## Introduction

This [IDL](https://www.nv5geospatialsoftware.com/Products/IDL) program converts [EMIT level 2A](https://lpdaac.usgs.gov/data/get-started-data/collection-overview/missions/emit-overview/) NetCDF files to [ENVI](https://www.nv5geospatialsoftware.com/Products/ENVI) format, consisting of a binary data file and an ASCII header.

The EMIT data comes in 3 files per acquired scene: one has the spectral datacube, one has the reflectance uncertainty, and one has band masks. The program can convert these data "as is", and optionally also apply geocorrection and masking.

## Installation

The program can be executed directly from the source files:
```
idl -e hw_emitter
```

Alternatively, the source can first be compiled into a binary file that can be run with an IDL virtual machine:
```
idl -e hw_emitter_compile
idl -vm=hw_emitter.sav
```

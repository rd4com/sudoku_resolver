Here is the **simplest|minimal|readable** python3 resolver (naive backtracking, recursive):

```python
sqr   = lambda g,x,y: g[y*9+x:y*9+x+3] + g[y*9+x+9:y*9+x+12] + g[y*9+x+18:y*9+x+21]
col   = lambda g,x:   g[x::9]
row   = lambda g,y:   g[y*9:y*9+9]
free  = lambda g,x,y: set("123456789") - set(col(g,x) + row(g,y) + sqr(g,(x//3)*3,(y//3)*3))

def resolv(g):
    i=g.find(".")
    if i>=0:
        for elem in free(g,i%9,i//9):
            ng=resolv( g[:i] + elem + g[i+1:] )
            if ng: return ng
    else:
        return g
```


Some grids are available in `grids.txt` (a grid by line of 81 chars, empty cases are `.`)

The idea of the repo, is to compare differents languages at "run times". Currently, there a c/mojo/nim/java/js/rust versions. So every version implements the same algorithm, without using specials optimisations provided by the language itself ... and try to resolve the **first 100 grids** !!!

## Context (on my computer)

On my computer (Intel® N100 × 4 / ubuntu 23.10), with versions:
 * gcc   : gcc (Ubuntu 13.2.0-4ubuntu3) 13.2.0
 * java  : openjdk 22-ea 2024-03-19
 * mojo  : mojo 0.4.0 (9e33b013)
 * nim   : Nim Compiler Version 1.6.14 [Linux: amd64]
 * node  : v18.13.0
 * py311 : Python 3.11.6
 * py37  : Python 3.7.16
 * pypy  : Python 3.10.13 (f1607341da97ff5a1e93430b6e8c4af0ad1aa019, Sep 28 2023, 05:41:26)
 * codon : 0.16.3
 * rust  : rustc 1.71.1 (eb26296b5 2023-08-03) (built from a source tarball)

## Simple version, results

The 1/1 implementations of the py version, in each language (using strings)

```
sudoku.c (the simple algo, with strings (AI translation from java one))
 - gcc   : 2.52 seconds

sudoku.java (the simple algo, with strings)
 - java  : 18.74 seconds

sudoku.js (the simple algo, with strings (AI translation from java one))
 - node  : 44.99 seconds

sudoku.mojo (the simple algo, with strings)
 - mojo  : 6.65 seconds

sudoku.nim (the simple algo, with strings)
 - nim   : 10.14 seconds

sudoku.py (the simple algo, with strings)
 - pypy  : 18.84 seconds
 - codon : 20.43 seconds
 - py311 : 26.86 seconds
 - py37  : 39.78 seconds

sudoku.rs (the simple algo, with strings (AI translation from java one))
 - rust  : 37.79 seconds
```

## SPECIALIZED versions, results

The same algo, but with specialized types/structures for the language (to speed up things)

```
sudoku_specialized.mojo (the simple algo, with specialized mojo-types)
 - mojo  : 2.12 seconds

sudoku_specialized.rs (the simple algo, with ultra-specialized types/api)
 - rust  : 0.97 seconds

```

## If you want to tests on your own

You will need, at least, python3 ;-) (it will autodetect compilers/interpreters on your host)
```
$ git clone https://github.com/manatlan/sudoku_resolver.git
$ cd sudoku_resolver
$ chmod +x make.py
$ ./make.py .
...(processing)...
$ ./make.py hstats
```
(repeat the `./make.py .` to get accurate results)

see command line [make.py](make.md)

## OPTIMIZED algo

See results on [an optimized algo](optimized) versions. (a better algo)

## EXPERIMENTS results:

See [experimentals](experiments) versions. (just for tests purposes)


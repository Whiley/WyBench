#!/bin/sh
rm *.class
wyjc *.whiley
javac -cp .:../lib/wyrt.jar *.java
whiley Tetris

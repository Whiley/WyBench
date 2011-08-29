// This file implements a parse for chess games in Portable Game
// Notation (PGN) format.  This is based around short-algebraic notation.
// Such moves are, by themselves, incomplete.  We must have access to the 
// current board state in order to decode them.
//
// See http://en.wikipedia.org/wiki/Algebraic_chess_notation for more.

import whiley.lang.*
import ShortMove:*
import Board:*

define state as {string input, int pos}
define SyntaxError as {string msg}

[ShortRound] parseChessGame(string input) throws SyntaxError:
    pos = 0
    moves = []
    while pos < |input|:        
        round,pos = parseRound(pos,input)
        moves = moves + [round]
    return moves

(ShortRound,int) parseRound(int pos, string input):
    pos = parseNumber(pos,input)
    pos = parseWhiteSpace(pos,input)
    white,pos = parseMove(pos,input,true)
    pos = parseWhiteSpace(pos,input)
    if pos < |input|:
        black,pos = parseMove(pos,input,false)
        pos = parseWhiteSpace(pos,input)
    else:
        black = null
    return (white,black),pos

int parseNumber(int pos, string input) throws SyntaxError:
    while pos < |input| && input[pos] != '.':
        pos = pos + 1
    if pos == |input|:
        throw { msg: "unexpected end of file" }
    return pos+1

(ShortMove,int) parseMove(int pos, string input, bool isWhite):
    // first, we check for castling moves    
    if |input| >= (pos+5) && input[pos..(pos+5)] == "O-O-O":
        move = { isWhite: isWhite, kingSide: false }
        pos = pos + 5
    else if |input| >= (pos+3) && input[pos..(pos+3)] == "O-O":
        move = { isWhite: isWhite, kingSide: true }
        pos = pos + 3
    else:
        // not a castling move
        p,pos = parsePiece(pos,input,isWhite)
        f,pos = parseShortPos(pos,input)
        if input[pos] == 'x':
            pos = pos + 1
            flag = true
        else:
            flag = false
        t,pos = parsePos(pos,input)
        move = { piece: p, from: f, to: t, isTake: flag }
    // finally, test for a check move
    if pos < |input| && input[pos] == '+':
        pos = pos + 1
        move = {check: move}     
    return move,pos

(Piece,int) parsePiece(int index, string input, bool isWhite):
    lookahead = input[index]
    switch lookahead:
        case 'N':
            piece = KNIGHT
            break
        case 'B':
            piece = BISHOP
            break
        case 'R':
            piece = ROOK
            break
        case 'K':
            piece = KING
            break
        case 'Q':
            piece = QUEEN
            break
        default:
            index = index - 1
            piece = PAWN
    return {kind: piece, colour: isWhite}, index+1
    
(Pos,int) parsePos(int pos, string input):
    c = input[pos] - 'a'
    r = input[pos+1] - '1'
    return { col: c, row: r },pos+2

(ShortPos,int) parseShortPos(int index, string input):
    c = input[index]
    if Char.isDigit(c):
        // signals rank only
        return { row: (c - '1') },index+1
    else if c != 'x' && Char.isLetter(c):
        // so, could be file only, file and rank, or empty
        d = input[index+1]
        if Char.isLetter(d):
            // signals file only
            return { col: (c - 'a') },index+1         
        else if (index+2) < |input| && Char.isLetter(input[index+2]):
            // signals file and rank
            return { col: (c - 'a'), row: (d - '1') },index+2
    // no short move given
    return null,index

int parseWhiteSpace(int index, string input):
    while index < |input| && isWhiteSpace(input[index]):
        index = index + 1
    return index

bool isWhiteSpace(char c):
    return c == ' ' || c == '\t' || c == '\n'


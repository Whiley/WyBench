
// Compression Methods
public define DEFLATE as 8 

// Compression Levels
public define FASTEST as 0 
public define FAST as 1
public define DEFAULT as 2
public define MAXIMUM as 3

// zlib header
define Header as {
    int method, // Compression Method
    int info,   // Compression info
    int level   // Compression Level
}

public Header Header(int method, int info, int level):
    return {
        method: method,
        info: info,
        level: level
    }


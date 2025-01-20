//
// Copyright 2025 Howard Milano
//
// Research of an aspect of John Conway's Game of Life.
// Four Gosper Glider Guns are created in the four corners of an area of Game of Life,
// with their creation time optionally staggered. All of them shoot at the center of the
// screen, and really to each other as well. Then we observe what happens. Will
// any or all or some of the guns survive into a stable state? Guns are either killed
// by mayhem engulfing them, OR by stray gliders. After some experimenting
// it shows that it's possible to create stable states with all three possibilities.
//
// For instance, 
// where One, Two, Three and Four are the staggered creation times of the guns,
// which you can set in the gunCreations variable below:
// 
// Fastest All Guns Dead at One=0, Two=12, Three=12, Four=0 Generation=883
// Slowest All Guns Dead at One=3, Two=7, Three=3, Four=12 Generation=12754
// Fastest One Gun Alive at One=0, Two=2, Three=10, Four=0 Generation=1654
// Slowest One Gun Alive at One=2, Two=12, Three=10, Four=11 Generation=11654
// Fastest Two Guns Alive at One=0, Two=12, Three=1, Four=11 Generation=1007
// Slowest Two Guns Alive at One=3, Two=5, Three=3, Four=12 Generation=5866
// Fastest Three Guns Alive at One=0, Two=12, Three=8, Four=3 Generation=1060
// Slowest Three Guns Alive at One=1, Two=8, Three=1, Four=12 Generation=1767
// Fastest Four Guns Alive at One=0, Two=0, Three=2, Four=2 Generation=253
// Slowest Four Guns Alive at One=2, Two=12, Three=8, Four=7 Generation=818
//
// Quoted generation times above are approximate, usually about 30 generations too high
// due to the need to wait for Glider Gun cycles to complete.
//
// Some noteworthy fights:
// At One=0, Two=2, Three=10, Four=0 : fast one gun survives, 2 stray slider kills (1654 generations)
// At One=0, Two=12, Three=1, Four=11 = fast two guns survive, 2 stray slider kills (1007 generations)
// At One=0, Two=12, Three=12, Four=0 = fast all guns dead, 2 stray slider kills (883 generations)
// At One=0, Two=7, Three=3, Four=12 = fast all guns dead, 3 stray glider kills (1594 generations)
//

// Here you set the creation times for guns One, Two, Three and Four.
// Should be 0 or higher, but of course, if you want to see what happens
// with less than 4 guns, make one or more entries less than zero
// Example primed is for slowest four guns alive after generation 818
int[] gunCreations = { 2, 12, 8, 7};

int cols;
int rows;
int[][] grid;
int resolution;
int generation = 0;

void setup() {
  // If you change the size or resolution, you need to do all testing again
  // and expect to get different outcomes
  size(1485, 1200);
  resolution = 10;
  
  cols = width / resolution;
  rows = height / resolution;
  grid = new int[cols][rows];
  // Adjust to your own preference
  frameRate(20);
}

void draw() {
  background(0);
  
  if (generation == gunCreations[0])
    loadGliderGunTopLeft();
  if (generation == gunCreations[1])
    loadGliderGunTopRight();
  if (generation == gunCreations[2])
    loadGliderGunBottomRight();
  if (generation == gunCreations[3])
    loadGliderGunBottomLeft();
    
  // Generate the grid 
  generate();
  
  // Paint the pixels based on the grid
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      if (grid[i][j] == 1) {
        fill(255);
        stroke(0);
        rect(i * resolution, j * resolution, resolution - 1, resolution - 1);
      }
    }
  }
  //save("out_glider_gun_" + generation + ".png");
  generation++;
}

// Generate the grid according to the Game of Life rules
void generate() {
  int[][] nextGen = new int[cols][rows];
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      int neighbors = 0;
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          int col = x + i;
          int row = y + j;
          if (col < 0 || col >= cols || row < 0 || row >= rows)
            neighbors += 0;
          else
            neighbors += grid[col][row];
        }
      }
      neighbors -= grid[x][y];

      if (grid[x][y] == 1 && (neighbors < 2 || neighbors > 3)) {
        nextGen[x][y] = 0;
      } else if (grid[x][y] == 0 && neighbors == 3) {
        nextGen[x][y] = 1;
      } else {
        nextGen[x][y] = grid[x][y];
      }
    }
  }
  grid = nextGen;
}

void mousePressed() {
  save("out_glider_gun_" + generation + ".png");
}

// Coordinates for Gosper Glider Gun (relative to top-left)
int[][] gliderGun = {
  {24, 0}, {22, 1}, {24, 1}, {12, 2}, {13, 2}, {20, 2}, {21, 2}, {34, 2}, {35, 2},
  {11, 3}, {15, 3}, {20, 3}, {21, 3}, {34, 3}, {35, 3}, {0, 4}, {1, 4}, {10, 4},
  {16, 4}, {20, 4}, {21, 4}, {0, 5}, {1, 5}, {10, 5}, {14, 5}, {16, 5},
  {17, 5}, {22, 5}, {24, 5}, {10, 6}, {16, 6}, {24, 6}, {11, 7}, {15, 7},
  {12, 8}, {13, 8}
};

void loadGliderGunTopLeft() {
  for (int[] cell : gliderGun) {
    int x = cell[0];
    int y = cell[1];
    grid[x+1][y+1] = 1;
  }
}

void loadGliderGunTopRight() {
  for (int[] cell : gliderGun) {
    int x = cols - cell[0] - 1;
    int y = cell[1];
    grid[x-1][y+1] = 1;
  }
}

void loadGliderGunBottomRight() {
  for (int[] cell : gliderGun) {
    int x = cols - cell[0] - 1;
    int y = rows - cell[1] - 1;
    grid[x-1][y-1] = 1;
  }
}

void loadGliderGunBottomLeft() {
  for (int[] cell : gliderGun) {
    int x = cell[0];
    int y = rows - cell[1] - 1;
    grid[x+1][y-1] = 1;
  }
}

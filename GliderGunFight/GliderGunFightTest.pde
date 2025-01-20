//
// Copyright 2025 Howard Milano
//
// Testing part of the research of an aspect of John Conway's Game of Life. See GliderGunFight.
// Four Gosper Glider Guns are created in the four corners of an area of Game of Life,
// with their creation time optionally staggered. All of them shoot at the center of the
// screen, and really to each other as well. Then we observe what happens. Will
// any or all or some of the guns survive into a stable state? Guns are either killed
// by mayhem engulfing them, OR by stray gliders.
//
// This test does a deep search using creation times from 0 - 12 for each of the four guns.
// This search yields fastest and slowest times for the following stable situations:
// - All guns dead
// - Four guns alive
// - Three guns alive
// - Two guns alive
// - One gun alive
//
// In addition it shows the results for the various creation times. Any result that is
// the mirror image of a previous result is skipped and not shown in the output.
// 
// See complete output in the GliderGunFightTestData.txt file.
//

int cols;
int rows;
int[][] grid;
int resolution;
int generation = 0;

// Used to pick up where we left for each new call to draw()
int lastOne = 0;
int lastTwo = 0; 
int lastThree = 0;
int lastFour = 0;

// Limit of the deep search, adjust to your liking
int testLimit = 13;

boolean gunTopLeftDead;
boolean gunTopRightDead;
boolean gunBottomRightDead;
boolean gunBottomLeftDead;

int gunTopLeftAliveGeneration;
int gunTopRightAliveGeneration;
int gunBottomRightAliveGeneration;
int gunBottomLeftAliveGeneration;

String filePath = "GliderGunFightTestData.txt";
PFont font;

StringList previousScreens = new StringList();
StringList screenHistory = new StringList();

int fastestAllGunsDead = MAX_INT;
String fastestAllGunsDeadDetails;
int fastestOneGunAlive = MAX_INT;
String fastestOneGunAliveDetails;
int fastestTwoGunsAlive = MAX_INT;
String fastestTwoGunsAliveDetails;
int fastestThreeGunsAlive = MAX_INT;
String fastestThreeGunsAliveDetails;
int fastestFourGunsAlive = MAX_INT;
String fastestFourGunsAliveDetails;

int slowestAllGunsDead = 0;
String slowestAllGunsDeadDetails;
int slowestOneGunAlive = 0;
String slowestOneGunAliveDetails;
int slowestTwoGunsAlive = 0;
String slowestTwoGunsAliveDetails;
int slowestThreeGunsAlive = 0;
String slowestThreeGunsAliveDetails;
int slowestFourGunsAlive = 0;
String slowestFourGunsAliveDetails;

void setup() {
  // If you change the size or resolution, you need to do all testing again
  // and expect to get different outcomes
  size(1485, 1200);
  resolution = 10;

  cols = width / resolution;
  rows = height / resolution;

  // Adjust to your own preference
  frameRate(15);
  font = createFont("Arial", 28, true);
  
  // Empty the data file so we start fresh
  String[] data = new String[1];
  data[0] = "";
  saveStrings(filePath, data);
}

void draw() {
  grid = new int[cols][rows];
  
  gunTopLeftDead = false;
  gunTopRightDead = false;
  gunBottomRightDead = false;
  gunBottomLeftDead = false;
  
  // No guns created yet
  gunTopLeftAliveGeneration = -1;
  gunTopRightAliveGeneration = -1;
  gunBottomRightAliveGeneration = -1;
  gunBottomLeftAliveGeneration = -1;

  // Used to detect duplicate screens
  screenHistory.clear();
  previousScreens.clear();
  
  // Pick up where we left off
  for (int one = lastOne; one < testLimit; one++)
  {
    for (int two = lastTwo; two < testLimit; two++)
    {
      for (int three = lastThree; three < testLimit; three++)
      {
        for ( int four = lastFour; four < testLimit; four++)
        {          
          // Rotating the screen 180 degrees should be the same result
          if (two < one || three < one)
            continue;
          generation = 0;
          while (true)
          {
            if (generation == one)
              loadGliderGunTopLeft();
            if (generation == two)
              loadGliderGunTopRight();
            if (generation == three)
              loadGliderGunBottomRight();
            if (generation == four)
              loadGliderGunBottomLeft();
              
            // Generate the grid and compute a hash value
            long screenHashValue = generate();
            
            // Check if guns are still alive
            int gunsAlive = checkGliderGunTopLeftAlive();
            gunsAlive += checkGliderGunTopRightAlive();
            gunsAlive += checkGliderGunBottomRightAlive();
            gunsAlive += checkGliderGunBottomLeftAlive();
            
            // Are all guns dead?
            if (gunsAlive <= 0)
            {
              // Record result of this experiment
              String tail = "All guns dead";
              String s = "One=" + one + ", Two=" + two + ", Three=" + three + ", Four=" + four +
              " Generation=" + generation;
              writeToFile(s + " " + tail);
              writeText(s + " " + tail);

              if (generation > slowestAllGunsDead) {
                slowestAllGunsDead = generation;
                slowestAllGunsDeadDetails = s;
              }
              if (generation < fastestAllGunsDead) {
                fastestAllGunsDead = generation;
                fastestAllGunsDeadDetails = s;
              }
                
              // We pick up the search in the next call to draw()  
              lastOne = one;
              lastTwo = two;
              lastThree = three;
              lastFour = four + 1;
              
              // Can be used for testing guns are really all dead
              //background(0);
              //for (int i = 0; i < cols; i++) {
              //  for (int j = 0; j < rows; j++) {
              //    if (grid[i][j] == 1) {
              //      fill(255);
              //      stroke(0);
              //      rect(i * resolution, j * resolution, resolution - 1, resolution - 1);
              //    }
              //  }
              //}
              //save("out_glider_gun_" + generation + ".png");
              return;
            }
            
            // Have we seen this screen before?
            String previousScreensAsString = "";
            for (int x = 0; x < previousScreens.size(); x++)
              previousScreensAsString += "" + previousScreens.get(x);
            previousScreensAsString += "" + screenHashValue;
            if (screenHistory.hasValue(previousScreensAsString))
            {
              // Record result of this experiment
              String tail = "" + gunsAlive + " gun" + ((gunsAlive > 1) ? "s" : "") + " alive";
              String s = "One=" + one + ", Two=" + two + ", Three=" + three + ", Four=" + four +
              " Generation=" + generation;
              
              writeToFile(s + " " + tail);
              writeText(s + " " + tail);

              if (gunsAlive == 1) {
                if (generation < fastestOneGunAlive) {
                  fastestOneGunAlive = generation;
                  fastestOneGunAliveDetails = s;
                }
                if (generation > slowestOneGunAlive) {
                  slowestOneGunAlive = generation;
                  slowestOneGunAliveDetails = s;
                }
              }
              else if (gunsAlive == 2) {
                if (generation < fastestTwoGunsAlive) {
                  fastestTwoGunsAlive = generation;
                  fastestTwoGunsAliveDetails = s;
                }
                if (generation > slowestTwoGunsAlive) {
                  slowestTwoGunsAlive = generation;
                  slowestTwoGunsAliveDetails = s;
                }
              }
              else if (gunsAlive == 3) {
                if (generation < fastestThreeGunsAlive) {
                  fastestThreeGunsAlive = generation;
                  fastestThreeGunsAliveDetails = s;
                }
                if (generation > slowestThreeGunsAlive) {
                  slowestThreeGunsAlive = generation;
                  slowestThreeGunsAliveDetails = s;
                }
              }
              else if (gunsAlive == 4) {
                if (generation < fastestFourGunsAlive) {
                  fastestFourGunsAlive = generation;
                  fastestFourGunsAliveDetails = s;
                }
                if (generation > slowestFourGunsAlive) {
                  slowestFourGunsAlive = generation;
                  slowestFourGunsAliveDetails = s;
                }
              }

              // We pick up the search in the next call to draw()  
              lastOne = one;
              lastTwo = two;
              lastThree = three;
              lastFour = four + 1;
              
              // Can be used for testing how many guns are alive
              //background(0);
              //for (int i = 0; i < cols; i++) {
              //  for (int j = 0; j < rows; j++) {
              //    if (grid[i][j] == 1) {
              //      fill(255);
              //      stroke(0);
              //      rect(i * resolution, j * resolution, resolution - 1, resolution - 1);
              //    }
              //  }
              //}
              //save("out_glider_gun_" + generation + ".png");
              return;
            }
            
            // Record this screen and the previous screens
            screenHistory.append(previousScreensAsString);
            previousScreens.append("" + screenHashValue);
            // Keep at least one cycle of the Glider Guns
            if (previousScreens.size() > 31)
              previousScreens.remove(0);
            
            generation++;
          }
        }
        lastFour = 0;
      }
      lastThree = 0;
    }
    lastTwo = 0;
  }
  String s = "Fastest All Guns Dead at " + fastestAllGunsDeadDetails;
  writeToFile(s);
  s = "Slowest All Guns Dead at " + slowestAllGunsDeadDetails;
  writeToFile(s);
  s = "Fastest One Gun Alive at " + fastestOneGunAliveDetails;
  writeToFile(s);
  s = "Slowest One Gun Alive at " + slowestOneGunAliveDetails;
  writeToFile(s);
  s = "Fastest Two Guns Alive at " + fastestTwoGunsAliveDetails;
  writeToFile(s);
  s = "Slowest Two Guns Alive at " + slowestTwoGunsAliveDetails;
  writeToFile(s);
  s = "Fastest Three Guns Alive at " + fastestThreeGunsAliveDetails;
  writeToFile(s);
  s = "Slowest Three Guns Alive at " + slowestThreeGunsAliveDetails;
  writeToFile(s);
  s = "Fastest Four Guns Alive at " + fastestFourGunsAliveDetails;
  writeToFile(s);
  s = "Slowest Four Guns Alive at " + slowestFourGunsAliveDetails;
  writeToFile(s);
  exit();
}

// Generate the grid according to the Game of Life rules
long generate() {
  int cellsTurnedOn = 0;
  int count = 0;
  long totalHashValue = 0L;
  long hash = 0L;
  int[][] nextGen = new int[cols][rows];
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      
      // Find the neighbors
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

      // Update a hash
      hash += x + y + neighbors + count;
      
      // Update the grid
      if (grid[x][y] == 1 && (neighbors < 2 || neighbors > 3)) {
        nextGen[x][y] = 0;
      } else if (grid[x][y] == 0 && neighbors == 3) {
        nextGen[x][y] = 1;
        cellsTurnedOn++;
      } else {
        nextGen[x][y] = grid[x][y];
        cellsTurnedOn += nextGen[x][y];
      }
      hash += cellsTurnedOn;
      totalHashValue += hash;
      count++;
    }
  }
  totalHashValue += 31;
  grid = nextGen;
  return totalHashValue;
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
  gunTopLeftAliveGeneration = generation;
  for (int[] cell : gliderGun) {
    int x = cell[0];
    int y = cell[1];
    grid[x+1][y+1] = 1;
  }
}

int checkGliderGunTopLeftAlive() {
  // Has it been created, if not, count as alive
  if (gunTopLeftAliveGeneration < 0)
    return 1;
  // Is it already dead
  if (gunTopLeftDead)
    return 0;
  // Check if it's alive
  for (int[] cell : gliderGun) {
    int x = cell[0];
    int y = cell[1];
    if (grid[x+1][y+1] != 1)
    {
      // It might be dead, but has it been alive recently
      // Check for at least one full gun cycle
      if (generation - gunTopLeftAliveGeneration > 31)
      {
        gunTopLeftDead = true;
        return 0;
      }
      // For now assume it's alive
      return 1;
    }
  }
  // It's fully alive and going
  gunTopLeftAliveGeneration = generation;
  return 1;
}

void loadGliderGunTopRight() {
  gunTopRightAliveGeneration = generation;
  for (int[] cell : gliderGun) {
    int x = cols - cell[0] - 1;
    int y = cell[1];
    grid[x-1][y+1] = 1;
  }
}

int checkGliderGunTopRightAlive() {
  // Has it been created, if not, count as alive
  if (gunTopRightAliveGeneration < 0)
    return 1;
  // Is it already dead
  if (gunTopRightDead)
    return 0;
  // Check if it's alive
  for (int[] cell : gliderGun) {
    int x = cols - cell[0] - 1;
    int y = cell[1];
    if (grid[x-1][y+1] != 1)
    {
      // It might be dead, but has it been alive recently
      if (generation - gunTopRightAliveGeneration > 31)
      {
        gunTopRightDead = true;
        return 0;
      }
      // For now assume it's alive
      return 1;
    }
  }
  // It's fully alive and going
  gunTopRightAliveGeneration = generation;
  return 1;
}

void loadGliderGunBottomRight() {
  gunBottomRightAliveGeneration = generation;
  for (int[] cell : gliderGun) {
    int x = cols - cell[0] - 1;
    int y = rows - cell[1] - 1;
    grid[x-1][y-1] = 1;
  }
}

int checkGliderGunBottomRightAlive() {
  // Has it been created, if not, count as alive
  if (gunBottomRightAliveGeneration < 0)
    return 1;
  // Is it already dead
  if (gunBottomRightDead)
    return 0;
  // Check if it's alive
  for (int[] cell : gliderGun) {
    int x = cols - cell[0] - 1;
    int y = rows - cell[1] - 1;
    if (grid[x-1][y-1] != 1)
    {
      // It might be dead, but has it been alive recently
      if (generation - gunBottomRightAliveGeneration > 31)
      {
        gunBottomRightDead = true;
        return 0;
      }
      // For now assume it's alive
      return 1;
    }
  }
  // It's fully alive and going
  gunBottomRightAliveGeneration = generation;
  return 1;
}

void loadGliderGunBottomLeft() {
  gunBottomLeftAliveGeneration = generation;
  for (int[] cell : gliderGun) {
    int x = cell[0];
    int y = rows - cell[1] - 1;
    grid[x+1][y-1] = 1;
  }
}

int checkGliderGunBottomLeftAlive() {
  // Has it been created, if not, count as alive
  if (gunBottomLeftAliveGeneration < 0)
    return 1;
  // Is it already dead
  if (gunBottomLeftDead)
    return 0;
  // Check if it's alive
  for (int[] cell : gliderGun) {
    int x = cell[0];
    int y = rows - cell[1] - 1;
    if (grid[x+1][y-1] != 1)
    {
      // It might be dead, but has it been alive recently
      if (generation - gunBottomLeftAliveGeneration > 31)
      {
        gunBottomLeftDead = true;
        return 0;
      }
      // For now assume it's alive
      return 1;
    }
  }
  // It's fully alive and going
  gunBottomLeftAliveGeneration = generation;
  return 1;
}

void writeToFile(String dataToAppend) {
  String[] existingData = loadStrings(filePath);

  String[] combinedData = new String[existingData.length + 1];
  arrayCopy(existingData, combinedData, existingData.length);
  combinedData[existingData.length] = dataToAppend;

  saveStrings(filePath, combinedData);
}

// Update the screen
void writeText(String data) {
  background(255);
  textFont(font,28);
  fill(0);         
  text(data,10,100);
}

// 
// Copyright Howard Milano
//
// Visualization of Wolfram 1dautomata rules
//

// Rule can be 0 - 255
byte automataRule = byte(169);
int generation = 0;

void setup()
{
  size(1200, 1000);
  smooth();
  background(255);
  frameRate(300);

  // Set a black dot at the middle top
  loadPixels();
  pixels[pixelWidth/2] = color(0);
  updatePixels();
}
void draw()
{
  loadPixels();
  // Trim the bottom row of pixels
  for (int x = pixelWidth * pixelHeight - 1 - pixelWidth; x >= 0; x--)
  {
    pixels[x + pixelWidth] = pixels[x];
  }

  // Update the top row of pixels according to the automata rule
  for( int x = 0; x < pixelWidth; x++)
  {
    // Collect neighbors below
    byte neighbors = 0;
    // Left below
    neighbors = red(pixels[x + pixelWidth - 1 + (x == 0 ? pixelWidth : 0)]) > 0 ? 0 : byte(1);
    // Below
    neighbors <<= 1;
    neighbors |= red(pixels[x + pixelWidth]) > 0 ? 0 : byte(1);
    // Right below
    neighbors <<= 1;
    neighbors |= red(pixels[x + pixelWidth + 1 - (x == pixelWidth - 1 ? pixelWidth : 0) ]) > 0 ? 0 : byte(1);
    // Apply rule
    pixels[x] = ((automataRule >> neighbors) & byte(1)) == 1 ? color(0) : color(255); 
  }
  updatePixels();
  generation++;
  if (mousePressed)
  {
    save("out_" + int(automataRule) + "_" + generation + ".png");
  }
}

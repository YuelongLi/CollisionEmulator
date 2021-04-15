import java.util.Random;
import java.util.Arrays;
import java.util.LinkedList;

//Number of blocks involved.
int blockCount = 2;
//Specify the parameters of blocks in any order, with {mass, x coordinate, x velocity}
double[][] blockParams = new double[][]{new double[]{10000, 600, -70},new double[]{1, 300, 0}};

//A helper counter for color depiction of blocks.
int blockCounter = 0;
//Number of possible initial block locations, must be
//greater than the number of blocks present.
int maxInitPos = blockCount*3;
//Velocity magnitude bound.
float maxSpeed = 100;
//Minimum side length of a block.
int minSideLength = 30;
//Maximum width of a block.
int maxSideLength;
//Maximum mass allowed, which is proportional to the logrithm of the side length.
double maxMass;
//Minimum mass, computed instead of ordained.
double minMass;
//Logrithmic conversion constant from mass to length.
double mc;
//Constant vertical surface location of the centers of the blocks.
float surY;
//All blocks concerned.
Block[] blocks = new Block[blockCount];
//Random color arrays generated. 
int[][] cols = {{255,0,0},{0,255,0},{0,0,255},{255,255,0},{0,255,255},{255,0,255},
  {128,128,0},{0,128,0},{128,0,128},{128,0,0},{215,215,0},{189,183,107},
  {143,188,143},{47,79,79},{25,25,112},{218,112,214},{255,235,205},{188,143,143},
  {255,218,185},{112,128,144},{230,230,250}}; 
//Right-most block that collides into wall in conjunction with blocks on the left, if any.
int rightMostWallPusher = -1;
float framerate = 80;
void setup()
{
  //Why, define size.
  //size(1200,1000);
  fullScreen();
  //Define uniform initial spacing interval.
  //maxSideLength = width/maxInitPos;
  maxSideLength = 50;
  //Define vertical position of blocks' movements.
  surY = 0.6*height;
  //If the width and height are too discrepant, rectify them to the minimum.
  if(maxSideLength > surY)
  {
    println("Entered!");
    maxSideLength = (int)(surY*0.4);
    maxInitPos = width/maxSideLength;
    if(maxInitPos < blockCount)
      throw new RuntimeException("Cannot Initialize Scenario with Current Dimensions! Scale Up Vertical Stretch.");
  }
  //Computation-setup inconsistency.
  if(minSideLength > maxSideLength)
    throw new RuntimeException("Minimum Side Length Too Large!");
  //Postulate maximum mass.
  maxMass = Math.pow(maxSideLength, 5);
  minMass = Math.pow(minSideLength, 7);
  //Compute constant for mass-logrithmic conversion.
  mc = Math.exp(maxSideLength)/maxMass;
  //Initialize blocks;
  initBlocks(blockParams);
  //initBlocks();
  //initBlocks();
  frameRate(framerate);
}

int frameIndex = 0;
float timeStamp = 0;
void draw()
{
  background(0);
  //Draw horizontal boundary.
  stroke(255, 255, 255);
  line(0, surY, width, surY);
  timeStamp += 1/frameRate;
  //Compute movement.
  HashMap<Block, Float> frame = getFrame(timeStamp);
  depictBlocks(frame);
  //for(int i = 0; i <= rightMostWallPusher; i++)
  //{
  //  Block wp = blocks[i];
  //  wp.v = -wp.v;
  //}
  //Reset wall-pusher index.
  //rightMostWallPusher = -1;
  //noLoop();
  fill(#abcdef); 
  textSize(25);
  text (collisionCount, 133, 433); 
}

//Either all blocks randomized or all with provided initial conditions.
void initBlocks(double[]... inimxvs)
{
  //Possible to provide initial positions and velocities
  //of some blocks with the rest randomly initialized.
  if(inimxvs.length == blockCount)
    for(int i = 0; i < inimxvs.length; i++)
      blocks[i] = new Block(inimxvs[i][0], (float)inimxvs[i][1], (float)inimxvs[i][2]);
  else if(inimxvs.length != 0)
    throw new RuntimeException("Insufficient Initial Conditions!");
  else
  {
    //Helper array for randomization.
    int[] availPos = new int[maxInitPos];
    for(int i = 0; i < maxInitPos; i++)
      availPos[i] = i;
    //Randomize non-conflicting block locations.
    for(int i = 0; i < blockCount; i++)
    {
      int randIndex = (int)((maxInitPos - i)*Math.random());
      int randInitPos = availPos[randIndex];
      //Fill in with the last element.
      availPos[randIndex] = availPos[maxInitPos - i - 1];
      //Randomized side length; prevent block with unobservable side length.
      int sl = (int)((maxSideLength - minSideLength)*Math.random()) + minSideLength;
      blocks[i] = new Block(sl, 
                            randInitPos*maxSideLength + sl/2, 
                            -maxSpeed + (float)(Math.random()*2*maxSpeed));
    }
  }
}

void depictBlocks(HashMap<Block, Float> frame)
{
  for(Block block: blocks)
    depict(block, frame.get(block));
}


  
public void depict(Block block, float x)
{
  fill(block.col);
  rect(x - block.sideLength/2, surY - block.sideLength, block.sideLength, block.sideLength);
}

public class Block implements Comparable<Block>
{
  //Horizontal position.
  public float x;
  //Horizontal velocity.
  public float v;
  //Mass.
  public double m;
  //Side length;
  public float sideLength;
  //Color.
  public color col;

  //Instantiate a block provided with its mass.  
  public Block(double m, float x, float v)
  {
    this.m = m;
    this.x = x;
    this.v = v;
    //Render logrithmically proportional length.
    sideLength = (int)Math.log(mc*m);
    //Give a color.
    //col = color(rand.nextInt(255), rand.nextInt(255), rand.nextInt(255));
    if(blockCounter >= blockCount)
      blockCounter = 0;
    col = color(cols[blockCounter][0], cols[blockCounter][1], cols[blockCounter][2]);
    blockCounter++;
  }
  
  //Instantiate provided the side length.
  public Block(int l, float x, float v)
  {
    sideLength = l;
    this.x = x;
    this.v = v;
    this.m = Math.exp(l)/mc;
    println(m);
    //col = color(rand.nextInt(255), rand.nextInt(255), rand.nextInt(255));
    if(blockCounter >= blockCount)
      blockCounter = 0;
    col = color(cols[blockCounter][0], cols[blockCounter][1], cols[blockCounter][2]);
    blockCounter++;
  }
  
  public float rightBound(){
    return this.x+this.sideLength/2;
  }
  
  public float leftBound(){
    return this.x-this.sideLength/2;
  }
  
  //If two blocks are colliding: overlap in volume with co-central distance diminishing.
  public boolean isColliding(Block other)
  {
    Block toTheRight = Math.max(x, other.x) == x? this: other;
    Block toTheLeft = toTheRight == this? other: this;
    return toTheRight.x - toTheRight.sideLength/2 <= toTheLeft.x + toTheLeft.sideLength/2&& 
            (v - other.v)*(x - other.x) < 0;
  }
  
  public boolean isPushingWall()
  {
    return x - sideLength/2 <= 0;
  }
  
  public double absVelocityDifference(Block other)
  {
    return Math.abs(v - other.v);
  }
  
  public int compareTo(Block other)
  {
    return this.x < other.x? -1: (this.x == other.x? 0: 1);
  }
  
  public String toString()
  {
    return String.format("Block of Length %d and Mass %f at %f in velocity %f with Color %s", sideLength, m, x, v, col);
  }
}

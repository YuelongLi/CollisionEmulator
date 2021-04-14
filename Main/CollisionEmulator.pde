float t = 0;

public class CollisionTuple
{
  Block one, two;
  
  public CollisionTuple(Block one, Block two)
  {
    this.one = one;
    this.two = two;
  }
}


void updatePostCollisionVelocities(CollisionTuple ct)
{
    Block a = ct.one;
    Block b = ct.two;
    float v1 = a.v, v2 = b.v;
    double m1 = a.m, m2 = b.m;
    a.v = v1+2*(v2-v1)*(float)((m2)/(m1+m2));
    b.v = v2+2*(v1-v2)*(float)((m1)/(m1+m2));
}


void increment()
{
  float dt = getTimeGap();
  //println(dt);
  t+=dt;
  for(int i = 0; i < blocks.length; i++)
    blocks[i].x += blocks[i].v*dt;
  //println(frameRate);
}

float getTimeGap(){
  float dt = 1/framerate;
  if(blocks[0].v<0)
    if(blocks[0].leftBound()/-blocks[0].v<dt)
      dt = blocks[0].leftBound()/-blocks[0].v;
  for(int i = 1; i < blocks.length; i++){
    Block a = blocks[i], b = blocks[i-1];
    if(b.v>a.v){
      float timeGap = (a.leftBound()-b.rightBound())/(b.v-a.v);
      if(timeGap<dt) {
        dt = timeGap+0.0000001;
        //println("dt: "+dt+" from "+i);
        //println(a.leftBound()>b.rightBound());
      }
    }
  }
  return dt;
}

int collisionCount = 0;
void computeCollisions(){
  //Check for wall-pushers.
  if(blocks[0].isPushingWall())
  {
    blocks[0].v = -blocks[0].v;
    //rightMostWallPusher++;
      //println("colliding block 0 with wall");
      collisionCount++;
      println("collision #: "+collisionCount);
  }
  for(int i = 1; i < blocks.length; i++)
  {
    //Colliding?
    if(blocks[i].isColliding(blocks[i - 1]))
    {
      //if(onWallPushing)
      //  rightMostWallPusher++;
      //collidingDuos.add(new CollisionTuple(blocks[i], blocks[i - 1]));
      updatePostCollisionVelocities(new CollisionTuple(blocks[i], blocks[i - 1]));
      //println("colliding block "+i +" with block "+(i-1));
      collisionCount++;
      println("collision #: "+collisionCount);
    }
  }
  //Reverse velocities for wall-pushers.
  //if(onWallPushing){
      
  //    onWallPushing = false;
  //}
}


HashMap<Block, Float> frame = new HashMap<Block, Float>();
boolean computing = false;
HashMap<Block, Float> getFrame(float timeStamp){
  //Consider collisions.
  //Sort blocks from left to right.
  if(!computing){
    computing = true;
    Arrays.sort(blocks);
    while(t<timeStamp){
      computeCollisions();
      increment();
    }
    for(Block block : blocks)
      frame.put(block, block.x);
    computing = false;
  }
  return frame;
}
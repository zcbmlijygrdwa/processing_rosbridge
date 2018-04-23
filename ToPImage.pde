

/**
 * Implementation of ROS sensor_msgs/Image.msg:
 * <a href="http://docs.ros.org/api/sensor_msgs/html/msg/Image.html">http://docs.ros.org/api/sensor_msgs/html/msg/Image.html</a>.
 * This class can also decode the ROS Image into a Java Buffered Image for images that are encoded in either
 * bgr8, rgb8, or mono8, by using the {@link #toBufferedImage()} method.
 * @author James MacGlashan.
 */
public class ToPImage {

  public Header header;
  public int height_image;
  public int width_image;
  public String encoding;
  public int is_bigendian;
  public int step;
  public byte[] data;

  public ToPImage() {
  }

  public ToPImage(Header header, int height_image, int width_image, String encoding, int is_bigendian, int step, byte[] data) {
    this.header = header;
    this.height_image = height_image;
    this.width_image = width_image;
    this.encoding = encoding;
    this.is_bigendian = is_bigendian;
    this.step = step;
    this.data = data;
  }

  public ToPImage(int height_image, int width_image, String encoding, byte[] data) {
    this.height_image = height_image;
    this.width_image = width_image;
    this.encoding = encoding;
    this.data = data;
  }


  /**
   * Constructs a {@link BufferedImage} from this ROS Image, provided the encoding is either rgb8, bgr8, or mono8.
   * If it is not one of those encodings, then a runtime exception will be thrown.
   * @return a {@link BufferedImage} representation of this image.
   */
  public PImage getPImage() {
    if (this.encoding.equals("bgr8") || this.encoding.equals("rgb8")) {
      return this.getPImageFromRGB8();
    } else if (this.encoding.equals("mono8")) {
      //return this.getPImageFromMono8();
      return null;
    }


    throw new RuntimeException("ROS Image does not currently decode " + this.encoding + ". See Java doc for support types.");
  }


  /**
   * Constructs a {@link BufferedImage} from this ROS Image assuming the encoding is mono8
   * @return a {@link BufferedImage} representation of this image.
   */
  protected PImage getPImageFromMono8() {
    int w = this.width_image;
    int h = this.height_image;

    PImage i = new PImage(w, h, RGB);
    for (int y = 0; y < h; ++y) {
      for (int x = 0; x < w; ++x) {

        //row major
        int index = (y * w) + x;
        // combine to RGB format
          int r = (data[index++]& 0xFF );
          int g = (data[index++]& 0xFF );
          int b = (data[index++]& 0xFF );
        
         i.pixels[y*w+x] = color(r, g, b);
      }
    }

    return i;
  }


  /**
   * Constructs a {@link BufferedImage} representation from this ROS Image assuming the encoding is either rgb8 or bgr8.
   * @return a {@link BufferedImage} representation of this image.
   */
  protected PImage getPImageFromRGB8() {

    int w = this.width_image;
    int h = this.height_image;

    PImage i = new PImage(w, h, RGB);
    i.loadPixels();
    int index = 0;
       
    for (int y = 0; y < h; ++y) {
      for (int x = 0; x < w; ++x) {

        //row major, consecutive channels
        index = (y * w * 3) + (x * 3);
        // combine to RGB format
        if (this.encoding.equals("bgr8")) {

          int b = (data[index++]& 0xFF );
          int g = (data[index++]& 0xFF );
          int r = (data[index++]& 0xFF );

          i.pixels[y*w+x] = color(r, g, b);
        } else if (this.encoding.equals("rgb8")) {
          int r = (data[index++]& 0xFF );
          int g = (data[index++]& 0xFF );
          int b = (data[index++]& 0xFF );

          i.pixels[y*w+x] = color(r, g, b);
        } else {
          throw new RuntimeException("ROS Image toBufferedImageFromRGB8 does not decode " + this.encoding);
        }
      }
    }
    i.updatePixels();
    return i;
  }
}

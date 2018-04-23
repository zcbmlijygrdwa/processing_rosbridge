import java.io.*;

import javax.imageio.ImageIO;

import java.util.Base64;
import ros.Publisher;
import ros.RosBridge;
import ros.RosListenDelegate;
import ros.SubscriptionRequestMsg;
import ros.msgs.std_msgs.PrimitiveMsg;
import ros.tools.MessageUnpacker;

import com.fasterxml.jackson.databind.JsonNode;

import java.awt.image.BufferedImage;

int a = 1;

PImage img;

void setup() {

  // need to run: roslaunch rosbridge_server rosbridge_websocket.launch 

  size(1000, 1000);

  println(a); 

  Publisher p;

  PrimitiveMsg pp;


  String URI = "ws://localhost:9090";

  RosBridge bridge = new RosBridge();
  bridge.connect(URI, true);

  bridge.subscribe(SubscriptionRequestMsg.generate("/webcam/image_raw")
    .setType("sensor_msgs/Image")
    .setFragmentSize(50000)
    .setThrottleRate(1)
    .setQueueLength(1), 
    new RosListenDelegate() {

    public void receive(JsonNode data, String stringRep) {

      int h = data.get("msg").get("height").asInt();
      int w = data.get("msg").get("width").asInt();
      String encoding = data.get("msg").get("encoding").textValue();

      ObjectMapper om = new ObjectMapper();
      final ObjectWriter writer = om.writer();

      // Use the writer for thread safe access.
      try {
        byte[] imageData = Base64.getDecoder().decode(data.get("msg").get("data").textValue());
        ToPImage tpi = new ToPImage(h, w, encoding, imageData);
        img = tpi.getPImage();
      }

      catch(Exception e) {
        println(e.toString());
      }
    }
  }
  );

  //  Publisher pub = new Publisher("/java_to_ros", "std_msgs/String", bridge);

  //  for (int i = 0; i < 100; i++) {
  //    pub.publish(new PrimitiveMsg<String>("hello from java " + i));
  //    println("hello from java " + i);
  //    try {
  //      Thread.sleep(500);
  //    } 
  //    catch (InterruptedException e) {
  //      e.printStackTrace();
  //    }
  //  }
}


void draw() {

  if (img!=null)
    image(img, 0, 0);
}

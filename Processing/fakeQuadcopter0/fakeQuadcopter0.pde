import java.net.*;
void setup() {
  Socket MyClient;
    try {
           MyClient = new Socket("Machine name", PortNumber);
    }
    catch (IOException e) {
        System.out.println(e);
    }
}
void draw() {
}



import java.net.*;
import java.io.DataInputStream;

// Number of times to spam the quadcopter with our message.
final int COMM_REPEATS = 2;
final int QUAD_PORT = 42042;

Socket sockie;
BufferedReader sockie_in;
boolean connected = false;
String connectionIP = "";

void initNetworking() {
  sockie = new Socket();
  try {
    // Time specified in millis (.1s)
    sockie.setSoTimeout(100);
  } catch(SocketException se) {
    println2("Couldn't set socket timeout!");
  }
}

// Are we actively scanning the network?
boolean scanningLAN = false;

// Scan for button presses and communicate with quadcopter if connected.
void updateNetworking() {
  if(!connected && lanScan.is_on) scanningLAN = true;
  if(scanningLAN) scanLAN(QUAD_PORT, 500);
  if(dropConnection.is_on && dropConnection.changed) disconnect();
  if(connected) {
    quadComm();
  }
}

void quadComm() {
  // DATA TRANSMITTING SECTION (TX)
  // Create our "packet" (we should really not be calling these packets)
  String toSend = "$"
                  + (CONTROL_X_EASED + CONTROL_X0) + "~" + (CONTROL_Y_EASED + CONTROL_Y0) + "~" + 0.f + "~"  // X, Y, and Z target rotation
                  + P_COEFF.value + "~" + I_COEFF.value + "~" + D_COEFF.value + "~"                                      // PID GET HYPED
                  + THROTTLE                                                                   // Throttle or whatever
                  + "%";
  
  // Convert "packet" to a byte array with UTF-8 encoding
  //(not the most efficent but definitely the most clear)
  byte[] b = null;
  try {
    b = toSend.getBytes("UTF-8");
  } catch(java.io.UnsupportedEncodingException uee) {
    println2("Could not encode data transmission to UTF-8 format!");
    return;
  }
  
  // Spam the quadcopter with our "packet" [COMM_REPEATS] times
  try {
    for(int i = 0; i < COMM_REPEATS; i++) sockie.getOutputStream().write(b);
  } catch(IOException ioe) {
    println2("Could not write to socket!");
    disconnect();
  }
  
  // DATA RECEIVING SECTION (RX)
  
  // Don't get data every frame for speed
  if(frameCount%5==0) {
    char[] cbuf = new char[48];
    try {
      // Get 48 bytes (chars) of information from sockie
      sockie_in.read(cbuf, 0, 48);
    } catch(IOException ioe) {
      println2("Failed to read data from socket!");
      return;
    }
    // Partition data into "packets" and then individual values with different delimeters
    String s = new String(cbuf);
    String[] parts = s.split(">")[0].substring(1).split("/");
    float[] receivedData = toFloatArray(parts);
    
    // Use the data we received
    QUADCOPTER_TICKS = round(receivedData[0]);
    QUADCOPTER_RX = receivedData[1];
    QUADCOPTER_RY = receivedData[2];
    QUADCOPTER_RZ = receivedData[3];
    //println(QUADCOPTER_RX, QUADCOPTER_RY, QUADCOPTER_RZ);
  }
}

int lanScanIndex = -1;
int LANSCAN_START = 2;
int LANSCAN_STOP = 10;
boolean LANSCAN_INCLUDE72 = true;

// Ticks passed on the quadcopter's python script and the quadcopter's actual physical rotation
// These variables are defined here to make them closer to the spot they're set in.
int QUADCOPTER_TICKS = 0;
float QUADCOPTER_RX = 0.f;
float QUADCOPTER_RY = 0.f;
float QUADCOPTER_RZ = 0.f;

// Timeout specified in millis, scans from range 192.168.1.[start-stop] inclusive
// Includes the IP 191.168.7.2 (BeagleBone Black default USB connection address) if "include72" is set to true
// Run this function repeatedly until scanningLAN == false.
void scanLAN(int port, int timeout) {
  if(lanScanIndex == -1) {
    if(LANSCAN_INCLUDE72) {
      if(connect("192.168.7.2", port, timeout)) {
        connected = true;
        connectionIP = "192.168.7.2";
        initReader();
        scanningLAN = false;
      } else lanScanIndex = LANSCAN_START;
      return;
    } else lanScanIndex = LANSCAN_START;
  } else {
    if(connect("192.168.1." + lanScanIndex, port, timeout)) {
      connected = true;
      connectionIP = "192.168.1." + lanScanIndex;
      initReader();
      scanningLAN = false;
    } else lanScanIndex++;
    if(lanScanIndex == LANSCAN_STOP + 1) {
      println2("Failed to locate quadcopter!");
      lanScanIndex = -1;
      scanningLAN = false;
    }
  }
}

void initReader() {
  try {
    sockie_in = new BufferedReader(new InputStreamReader(sockie.getInputStream()));
  } catch(IOException ioe) {
    println2("Failed to open socket IO streams!");
  }
}

// Cloase socket and socket read streams (if connected).
void disconnect() {
  if(connected) {
    try {
      sockie_in.close();
      sockie.close();
    } catch(IOException ioe) {
      println2("Failed to close connection..?");
      return;
    }
    println2("Disconnected from " + connectionIP);
    connected = false;
    connectionIP = "";
  } else println2("Already disconnected.");
}

// Returns true if the connection was successful.
boolean connect(String ip, int port, int timeout) {
  sockie = new Socket();
  try {
    sockie.connect(new InetSocketAddress(ip, port), timeout);
    println2("Connected to " + ip + " on port " + port);
    return true;
  } catch(IOException uhe) {
    println2("Failed to connect on " + ip + " on port " + port);
    return false;
  }
}
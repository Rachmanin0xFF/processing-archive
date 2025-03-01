void setup() {
  size(1, 1, P2D);
  println(isIPV4("192.168.1.5"));
  println(isIPV4("a.b.d.c"));
  println(isIPV4("192.168.1.c"));
}

public boolean isIPV4(String adr) {
  String[] d = adr.split("\\.");
  if(d.length != 4) return false;
  for(String s : d)
    for(char c : s.toCharArray())
      if(c!='0'&&c!='1'&&c!='2'&&c!='3'&&c!='4'&&c!='5'&&c!='6'&&c!='7'&&c!='8'&&c!='9') {
        return false;
      }
  return true;
}

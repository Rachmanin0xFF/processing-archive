
String[] names = new String[]{"jw02733-o001_t001_nircam_clear-f090w_i2d.fits",
"nircam_clear-f090w_segm.fits",
"nircam_clear-f187n_i2d.fits",
"nircam_clear-f187n_segm.fits",
"nircam_clear-f212n_i2d.fits",
"nircam_clear-f212n_segm.fits",
"nircam_clear-f356w_i2d.fits",
"nircam_clear-f356w_segm.fits",
"nircam_f405n-f444w_i2d.fits",
"nircam_f405n-f444w_segm.fits",
"nircam_f444w-f470n_i2d.fits",
"nircam_f444w-f470n_segm.fits",
"nircam_f405n-f444w_i2d.fits",
"miri_f770w_i2d.fits",
"miri_f770w_segm.fits",
"miri_f1130w_i2d.fits",
"miri_f1130w_segm.fits",
"miri_f1280w_i2d.fits",
"miri_f1280w_segm.fits",
"miri_f1800w_i2d.fits",
"miri_f1800w_segm.fits",
"miri",
"nircam"};
boolean is_in(String s) {
  boolean ret = false;
  for(int i = 0; i < names.length; i++) {
    ret |= s.contains(names[i]);
  }
  return ret;
}

void setup() {
  size(512, 512, P2D);
  String[] shs = loadStrings("dowlod.sh");
  ArrayList<String> out = new ArrayList<String>();
  for(int i = 0; i < shs.length; i++) {
    ArrayList<String> toAdd = new ArrayList<String>();
    if(shs[i].contains("cat ")) {
      toAdd.add(shs[i]);
      i++;
      toAdd.add(shs[i]);
      if(shs[i].contains("L3") && is_in(shs[i])) {
        for(int j = 0; j < 5; j++) {
          i++;
          toAdd.add(shs[i]);
        }
        out.addAll(toAdd);
      } else {
        for(int j = 0; j < 5; j++) i++;
      }
    }
  }
  String[] rs = new String[out.size()];
  for(int i = 0; i < rs.length; i++) {
    rs[i] = out.get(i);
  }
  saveStrings("downlod2.sh", rs);
}

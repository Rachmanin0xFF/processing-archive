
//String letters =  "abcdefghijklmnopqrstuvwxyz";
//String letters2 = "tbcehfghijklmeopsrsauvwxyz";
String letters =  "dnatigvekjhmcqufrobzpslxwy"; //This
String letters2 = "eotainshrglcfmwudybpvkjxqz"; //Turns into this
void setup() {
  String r = "aed tjaenivxtavnk onrd vg vqqhtzdthtknjancunj qdag mda rnfk an bjgvkdgg an rdcdta aed ejkg rvr aedu gdkr hd rtjmeadig fedk v tgzdr cni gnkg unjid aed gtrrdga bjkoe v dpdi hda bja unj otk bda bdcnid fdid aeinjme hvgadi vqq htzd t htk nja nc unj aitkljvq tg t cnidga bja nk cvid fvaevk nkod unj cvkr unji odkadi unj tid gjid an fvk unjid t gsvkdqdgg stqd staedavo qna tkr unj etpdka mna t oqjd gnhdenf vqq htzd t htk nja nc unj vh kdpdi mnkkt otaoe hu bidtae gtu mnnrbud an aengd fen zkdf hd bnu ftg v t cnnq vk goennq cni ojaavkm muh aevg mjug mna dh gotidr an rdtae ensd ed rndgka gdd ivmea aeinjme hd knf v idtqqu fvge aeta v zkdf enf an gfvh bd t htk fd hjga bd gfvca tg t onjigvkm ivpdi bd t htk fvae tqq aed cniod nc t midta ausennk bd t htk fvae tqq aed gaidkmae nc t itmvkm cvid hugadivnjg tg aed rtiz gvrd nc aed hnnk avhd vg itovkm anftir jg avqq aed ejkg tiivpd eddr hu dpdiu nirdi tkr unj hvmea gjipvpd unjid jkgjvadr cni aed itmd nc fti gn stoz js mn enhd unjid aeinjme enf onjqr v htzd t htk nja nc unj bd t htk fd hjga bd gfvca tg t onjigvkm ivpdi bd t htk fvae tqq aed cniod nc t midta ausennk bd t htk fvae tqq aed gaidkmae nc t itmvkm cvid hugadivnjg tg aed rtiz gvrd nc aed hnnk bd t htk fd hjga bd gfvca tg t onjigvkm ivpdi bd t htk fvae tqq aed cniod nc t midta ausennk bd t htk fvae tqq aed gaidkmae nc t itmvkm cvid hugadivnjg tg aed rtiz gvrd nc aed hnnk";
  boolean[] edited = new boolean[r.length()];
  for(int i = 0; i < letters.length(); i++) {
    println("Replacing " + letters.charAt(i) + " with " + letters2.charAt(i));
    for(int k = 0; k < r.length(); k++) {
      if(r.charAt(k) == letters.charAt(i) && !edited[k]) {
        r = r.substring(0, k) + letters2.charAt(i) + r.substring(k+1);
        edited[k] = true;
      }
    }
  }
  println("");
  println(r);
}


import prohtml.*;

HtmlList htmlList;

void setup(){
  //enter your url here
  htmlList = new HtmlList("http://en.wikipedia.org/wiki/List_of_Quercus_species#Section_Quercus");
  
  ArrayList links = (ArrayList) htmlList.getLinks();
  for(int i = 0;i<links.size();i++){
    println(((Url)(links.get(i))).toString());
  }
}

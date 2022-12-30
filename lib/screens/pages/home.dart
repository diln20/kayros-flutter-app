import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

final List<String> imageList = [
  "https://www.channelbiz.es/wp-content/uploads/2015/08/paquetes.jpg",
  "https://allstarservicecorp.com/wp-content/uploads/2020/07/a-enviosurgentes1-1024x597.jpg",
  "https://s3.amazonaws.com/businessinsider.mx/wp-content/uploads/2021/06/07130217/robo-de-identidad-paquetes.jpg",
  "https://blablanegocios.com/wp-content/uploads/sites/2/2016/11/EL-EMBALAJE-DE-LOS-PAQUETES-ES-IMPORTANTE-1.jpg",
  "https://thumbs.dreamstime.com/b/cami%C3%B3n-de-reparto-con-el-icono-del-paquete-ejemplo-transporte-art%C3%ADculo-env%C3%ADo-dise%C3%B1o-simple-s%C3%ADmbolo-vector-esquema-126378536.jpg",
  "https://www.neostuff.net/wp-content/uploads/2015/09/rastreo-de-envios-internacionales.jpg"
];

class MenuData {
  MenuData(this.icon, this.title);
  final IconData icon;
  final String title;
}

final List<MenuData> menu = [
  MenuData(Icons.move_to_inbox_outlined, 'Menu 1'),
  MenuData(Icons.find_in_page_outlined, 'Menu 2'),
  MenuData(Icons.move_to_inbox_outlined, 'Menu 3'),
  MenuData(Icons.find_in_page_outlined, 'Menu 4'),
];

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      GFCarousel(
        enableInfiniteScroll: true,
        autoPlay: true,
        items: imageList.map(
          (url) {
            return Container(
              margin: EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                child: Image.network(url, fit: BoxFit.cover, width: 500.0),
              ),
            );
          },
        ).toList(),
        onPageChanged: (index) {
          setState(() {
            index;
          });
        },
      ),
      Container(
        padding: EdgeInsets.all(10),
        child: SafeArea(
          child: SingleChildScrollView(
              child: Scrollbar(
            thickness: 3,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: SafeArea(
                  child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SingleChildScrollView(
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        itemCount: menu.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 1,
                            crossAxisCount: 2,
                            crossAxisSpacing: 4.0,
                            mainAxisSpacing: 4.0),
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            elevation: 0.2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                            child: InkWell(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    menu[index].icon,
                                    size: 30,
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    menu[index].title,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.black87),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )),
            ),
          )),
        ),
      )
    ]);
  }
}

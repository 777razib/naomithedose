import 'package:flutter/material.dart';
import 'package:naomithedose/core/style/text_style.dart';
import 'package:naomithedose/feature/home/widget/video_widget.dart';

class ViewVideoAndDetails extends StatelessWidget {
  const ViewVideoAndDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 60,),
          VideoWidget(
            title: '',
            date: '',
            subTitle: '',
            videoUrl: '',
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20,),
                Text("Talk of Business Poadcast",style: globalHeadingTextStyle(color: Colors.black,fontSize: 16),),
                Row(
                  children: [
                    Text("By Jacson Don",style: globalHeadingTextStyle(color: Colors.grey,fontSize: 12),),
                    const SizedBox(width: 2,),
                    Text("Duration: 3.05 min",style: globalHeadingTextStyle(color: Colors.grey,fontSize: 12)) ,
                    const SizedBox(width: 2,),
                    Text("8 days ago",style: globalHeadingTextStyle(color: Colors.grey,fontSize: 12)),
                    const SizedBox(width: 2,),
                    Row(
                      children: [
                        Icon(Icons.visibility),
                        const SizedBox(width: 2,),
                        Text("8 days ago",style: globalHeadingTextStyle(color: Colors.grey,fontSize: 12)),
                      ],
                    )


                  ],
                )
              ],
            ),
          )

        ],
      ),
    );
  }
}

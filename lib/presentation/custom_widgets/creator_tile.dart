import 'package:flutter/material.dart';

Widget creatorTile(BuildContext context,){
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: Column(
      children: [
        Text("Created by:",style: TextStyle(fontSize: 20,),),
        Divider(
          color: Theme.of(context).colorScheme.tertiary.withAlpha(100),
        ),
        Row(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(100), child: Image.asset("lib/core/assets/creator_pfp.jpg",height: 50,width: 50,fit: BoxFit.cover,)),
            SizedBox(width: 10,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Name: Victor Munene"),
                  Text("Email: kraizyvic@gmail.com"),
                  //Text("Phone: +254 738570503"),
                ],
              )
            )
          ],
        ),
        SizedBox(height: 10,),
        Text("Click on this tile to learn more about me and view more of my projects on Github",textAlign: TextAlign.center,),

        SizedBox(height: 5,),
        Text("Long press to copy email address",textAlign: TextAlign.center,style: TextStyle(color: Colors.amber),)
      ],
    ),
  );
}
import 'package:flutter/material.dart';

class TutorialCard extends StatelessWidget {
  const TutorialCard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: SizedBox(
        width: screenWidth * 0.75,
        child: Card(
          color: Colors.blue[50],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                child: const Text(
                  '使用教程',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1. 复制视频分享链接', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 12),
                    Text('2. 粘贴到输入框中', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 12),
                    Text('3. 点击解析按钮', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 12),
                    Text('4. 等待解析完成后即可复制或下载', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

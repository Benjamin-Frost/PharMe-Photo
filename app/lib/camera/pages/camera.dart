import '../../common/module.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CameraDescription>>(
      future: availableCameras(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final cameras = snapshot.data;
          if (cameras == null || cameras.isEmpty) {
            return Center(
              child: Text('No cameras found'),
            );
          } else {
            return CameraPreviewWrapper(cameras.first);
          }
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

class CameraPreviewWrapper extends StatefulWidget {
  const CameraPreviewWrapper(
    this.camera, {
    Key? key,
  }) : super(key: key);

  final CameraDescription camera;

  @override
  State<CameraPreviewWrapper> createState() => _CameraPreviewWrapperState();
}

class _CameraPreviewWrapperState extends State<CameraPreviewWrapper> {
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.camera, ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }
    return CameraPreview(controller);
  }
}

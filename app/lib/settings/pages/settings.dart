import '../../common/module.dart';
import '../utils.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      Card(
        child: ListTile(
          leading: Icon(Icons.delete),
          title: Text(context.l10n.settings_page_delete_data),
          trailing: Icon(Icons.chevron_right),
          onTap: () => showDialog(
            context: context,
            builder: (_) => _deleteDataDialog(context),
          ),
        ),
      ),
      IconButton(
        icon: Icon(Icons.ac_unit_sharp),
        onPressed: () => {
          showBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (BuildContext modalContext) {
              return MultipleChoiceWidget();
            },
          )
        },
      ),
    ]);
  }

  Widget _deleteDataDialog(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.settings_page_delete_data),
      content: Text(context.l10n.settings_page_delete_data_text),
      actions: [
        TextButton(
          onPressed: context.router.root.pop,
          child: Text(context.l10n.settings_page_cancel),
        ),
        TextButton(
          onPressed: () async {
            await deleteAllAppData();
            await context.router.replaceAll([LoginRouter()]);
          },
          child: Text(
            context.l10n.settings_page_continue,
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}

class MultipleChoiceWidget extends StatefulWidget {
  const MultipleChoiceWidget({Key? key}) : super(key: key);

  @override
  State<MultipleChoiceWidget> createState() => _MultipleChoiceWidgetState();
}

class _MultipleChoiceWidgetState extends State<MultipleChoiceWidget> {
  int? answer = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      width: double.infinity,
      child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(answer.toString()),
              ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return RadioListTile(
                      title: Text(index.toString()),
                      value: index,
                      groupValue: answer,
                      onChanged: (int? value) {
                        setState(() {
                          answer = value;
                        });
                      },
                    );
                  },
                  itemCount: 4),
            ],
          )),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:web3dart/web3dart.dart';
import 'slider_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Bizingo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Client httpClient;
  late Web3Client ethClient;
  bool data = false;
  int myAmt = 0;
  dynamic myData;
  String txhash = "";
  final myAdd ="";

@override
void initState(){
  super.initState();
  httpClient = Client();
  ethClient = Web3Client("", httpClient);
  getBalance(myAdd);
}
Future<DeployedContract> loadContract() async{
  String abi = await rootBundle.loadString("assets/abi.json");
  String contractAdd = ""; //Deployed Address
  final contract = DeployedContract(ContractAbi.fromJson(abi, "Biz"),
      EthereumAddress.fromHex(contractAdd));
  return contract;
}
Future<List<dynamic>> query(String functionName, List<dynamic> args) async{
  final contract = await loadContract();
  final ethFunction = contract.function(functionName);
  final result = await ethClient.call(contract: contract,
      function: ethFunction,
      params: args);
  return result;
}
Future<void> getBalance(String targetAdd) async{
  // EthereumAddress address = EthereumAddress.fromHex(targetAdd);
  List<dynamic> result = await query("getBalance", []);
  myData = result[0];
  data = true;
  setState(() {});
}
Future<String> submit(String functionName, List <dynamic> args) async{
  EthPrivateKey credential = EthPrivateKey
      .fromHex("Private Key Here");
  DeployedContract contract = await loadContract();
  final ethFunction = contract.function(functionName);
  final result = await ethClient.sendTransaction(credential
      , Transaction.callContract(contract: contract, function: ethFunction, parameters: args)
      ,fetchChainIdFromNetworkId: true);
  return result;
}
Future<String> sendCoin() async{
  var bigAmount = BigInt.from(myAmt);
  var response = await submit("depositBalance", [bigAmount]);

  print("deposited");
  txhash = response;
  setState(() {});
  return response;
}
Future<String> withdrawCoin() async{
    var bigAmount = BigInt.from(myAmt);
    var response = await submit("withdrawBalance", [bigAmount]);
    print("withdrawn");
    txhash = response;
    setState(() {});
    return response;
}
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Vx.gray300,

      body: ZStack([
        VxBox()
            .blue600
            .size(context.screenWidth, context.percentHeight*30)
            .make(),
        VStack([
          (context.percentHeight*10).heightBox,
          "Bizingo".text.xl5.white.bold.center.makeCentered().py16(),
          (context.percentHeight*5).heightBox,
          VxBox(child: VStack([
            "Balance".text.gray700.xl4.semiBold.makeCentered(),
            10.heightBox,
            data?"\$$myData".text.bold.xl6.makeCentered().shimmer()
                :const CircularProgressIndicator().centered(),

          ]))
              .white
              .size(context.screenWidth, context.percentHeight * 18)
              .rounded.shadowXl
              .make()
              .p16(),
          30.heightBox,
          SliderWidget(
            min: 0,
            max: 100,
            // finalVal :(value){
            //   myAmt = (value*100).round();
            //   print(myAmt);
            // }
          ).centered(),

          HStack([
            MaterialButton(
              onPressed: () => getBalance(myAdd),
                color: Colors.blueAccent,
                shape: Vx.roundedSm,
                textColor: Colors.white,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh), // Icon
                  SizedBox(width: 8), // Spacing between icon and text
                  Text("Refresh"), // Text
                ],
              ),
            ).h(50),
            MaterialButton(
              onPressed: () => sendCoin(),
              color: Colors.green,
              shape: Vx.roundedSm,
              textColor: Colors.white,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.call_made_outlined), // Icon
                  SizedBox(width: 8), // Spacing between icon and text
                  Text("Deposit"), // Text
                ],
              ),
            ).h(50),
            MaterialButton(
              onPressed: () => withdrawCoin(),
              color: Colors.redAccent,
              shape: Vx.roundedSm,
              textColor: Colors.white,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.call_received_outlined), // Icon
                  SizedBox(width: 8), // Spacing between icon and text
                  Text("Withdraw"), // Text
                ],
              ),
            ).h(50)
          ],
            alignment: MainAxisAlignment.spaceAround,
            axisSize: MainAxisSize.max,
          ).p16(),
          // if(txhash.isNotEmpty) txhash.text.black.makeCentered()
        ])
      ]),

    );
  }
}

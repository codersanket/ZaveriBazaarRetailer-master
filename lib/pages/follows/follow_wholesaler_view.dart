import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sonaar_retailer/pages/ratings_page.dart';
import 'package:sonaar_retailer/pages/wholesaler_view.dart';
import 'package:sonaar_retailer/services/date.service.dart';
import 'package:sonaar_retailer/services/follow_service.dart';
import 'package:sonaar_retailer/services/userlog_service.dart';
import 'package:url_launcher/url_launcher.dart';

class FollowWholesalerViewPage extends StatefulWidget {
  final String followId, heroTag;

  FollowWholesalerViewPage({
    Key key,
    @required this.followId,
    this.heroTag,
  }) : super(key: key);

  @override
  _FollowWholesalerViewPageState createState() =>
      _FollowWholesalerViewPageState();
}

class _FollowWholesalerViewPageState extends State<FollowWholesalerViewPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Map<String, dynamic> firm;
  bool isLoading = false;
  var error;

  @override
  void initState() {
    super.initState();
    fetchWholesaler();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Wholesaler details')),
      body: isLoading
          ? Center(child: CircularProgressIndicator(strokeWidth: 2.0))
          : error == null
              ? SingleChildScrollView(child: buildProfile())
              : Center(child: Text(error.toString())),
    );
  }

  Widget buildProfile() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Image
          buildImage(),

          SizedBox(height: 4),

          // Name
          Text(
            firm['name'],
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 2),

          // City
          Text(
            firm['city'] != null ? firm['city'] : '-',
            style: TextStyle(fontSize: 16),
          ),

          SizedBox(height: 16),

          // Registration status
          // buildStatusView(retailer['registered']),

          SizedBox(height: 16),

          // Ratings card
          buildRatingsCard(),

          SizedBox(height: 16),

          // Details card
          buildDetailsCard(),

          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget buildDetailsCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 8),
          buildMobileItem(),
          Divider(height: 8, color: Colors.grey.shade400),
          buildWhatsappItem(),
          Divider(height: 8, color: Colors.grey.shade400),
          // buildDetailItem('Address', '123, ABC Society, XYZ lorem road'),
          buildDetailItem('City', firm['city']),
          buildDetailItem('Pincode', firm['pincode']),
          Divider(height: 8, color: Colors.grey.shade400),
          buildMoreDetails(),
        ],
      ),
    );
  }

  Widget buildMobileItem() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Mobile number',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                firm['mobile'] ?? '-',
                style: TextStyle(fontSize: 16),
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: IconButton(
                      padding: EdgeInsets.all(0),
                      icon: Icon(Icons.call),
                      onPressed: call,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  SizedBox(width: 16),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: IconButton(
                      padding: EdgeInsets.all(0),
                      icon: Icon(Icons.message),
                      onPressed: messageRetailer,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget buildWhatsappItem() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Whatsapp number',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                firm['mobile'] ?? '-',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                  padding: EdgeInsets.all(0),
                  icon: ImageIcon(AssetImage('images/whatsapp.png')),
                  onPressed: whatsappRetailer,
                  color: Theme.of(context).accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          SizedBox(height: 4),
          Text(
            value ?? '-',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget buildMoreDetails() {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'View more details',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade500,
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WholesalerViewPage(
              wholesalerId: firm['id'].toString(),
            ),
          ),
        );
      },
    );
  }

  Widget buildRatingsCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        // Counters
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              buildCount('Ratings', firm['rating']['count'].toString()),
              buildCount('Joined', DateService.MMMyyyy(firm['created_at'])),
              buildCount('Followers', firm['follows_count'].toString()),
            ],
          ),

          Divider(height: 1, color: Colors.grey.shade400),

          // Ratings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              // Rating count
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
                child: buildRatingCount(),
              ),

              // Rating progress
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: buildRatingIndicators(),
                ),
              ),
            ],
          ),

          Divider(height: 1, color: Colors.grey.shade400),

          // View all ratings
          InkWell(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'View all ratings',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RatingsPage(mobile: firm['mobile']),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget buildRatingIndicators() {
    return Column(
      children: <Widget>[
        buildRatingIndicator(
            5, firm['rating']['5star'], firm['rating']['count']),
        SizedBox(height: 4),
        buildRatingIndicator(
            4, firm['rating']['4star'], firm['rating']['count']),
        SizedBox(height: 4),
        buildRatingIndicator(
            3, firm['rating']['3star'], firm['rating']['count']),
        SizedBox(height: 4),
        buildRatingIndicator(
            2, firm['rating']['2star'], firm['rating']['count']),
        SizedBox(height: 4),
        buildRatingIndicator(
            1, firm['rating']['1star'], firm['rating']['count']),
      ],
    );
  }

  Widget buildRatingIndicator(int label, int count, int total) {
    Color color;
    switch (label) {
      case 5:
        color = Colors.green;
        break;
      case 4:
        color = Colors.lime;
        break;
      case 3:
        color = Colors.yellow.shade600;
        break;
      case 2:
        color = Colors.orange;
        break;
      case 1:
        color = Colors.red;
        break;
      default:
        color = Colors.white;
    }

    return Row(
      children: <Widget>[
        Text(label.toString()),
        SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: total > 0 ? (count / total) : 0,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget buildRatingCount() {
    return Column(
      children: <Widget>[
        // rating
        Text(
          firm['rating']['average'].toString(),
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w500,
          ),
        ),

        SizedBox(height: 4),

        // indicator
        RatingBarIndicator(
          itemCount: 5,
          rating: double.tryParse(firm['rating']['average']),
          itemSize: 18,
          unratedColor: Colors.grey[350],
          itemBuilder: (BuildContext context, int index) {
            return Icon(Icons.star, color: Colors.yellow.shade600);
          },
        ),

        SizedBox(height: 2),

        // ratings count
        Text(
          '${firm['rating']['count']} ${firm['rating']['count'] > 1 ? 'ratings' : 'rating'}',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget buildCount(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 2),
          Text(
            value ?? '-',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatusView(bool isRegistered) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      color: isRegistered ? Colors.lightGreen : Colors.grey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              isRegistered ? Icons.done : Icons.info_outline,
              size: 16,
              color: Colors.white,
            ),
            SizedBox(width: 4),
            Text(
              isRegistered ? 'Registered' : 'Non registered',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImage() {
    return Hero(
      tag: widget.heroTag,
      child: Container(
        width: 120,
        height: 120,
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
            image: DecorationImage(
              image: firm['thumb_url'] != null
                  ? CachedNetworkImageProvider(firm['thumb_url'])
                  : AssetImage('images/placeholder.png'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(60),
            border: Border.all(
              color: Colors.white,
              width: 4.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ]),
      ),
    );
  }

  void fetchWholesaler() {
    setState(() => isLoading = true);

    FollowService.getWholesalerById(widget.followId).then((res) {
      setState(() {
        firm = res;
        error = null;
      });
    }).catchError((err) {
      setState(() => error = err);
    }).whenComplete(() {
      setState(() => isLoading = false);
    });
  }

  call() {
    launch("tel://${firm['mobile']}");
  }

  void messageRetailer() {
    launch("sms:${firm['mobile']}");
  }

  void whatsappRetailer() {
    UserLogService.userLogById(firm['id'].toString(), 'Wholesaler details').then((res) {
      print("userLogById Success");
    }).catchError((err) {
      print("userLogById Error:" + err.toString());
    });
    // do whatsapp share process
    launch("https://api.whatsapp.com/send?phone=${firm['mobile']}");
  }
}

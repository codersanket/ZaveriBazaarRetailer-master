import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sonaar_retailer/pages/ratings_page.dart';
import 'package:sonaar_retailer/services/date.service.dart';
import 'package:sonaar_retailer/services/wholesaler_rating_service.dart';
import 'package:url_launcher/url_launcher.dart';

class RatingWholesalerViewPage extends StatefulWidget {
  final String ratingId, heroTag;
  final Function(String id) onRatingDelete;

  RatingWholesalerViewPage({
    Key key,
    @required this.ratingId,
    this.heroTag,
    this.onRatingDelete,
  }) : super(key: key);

  @override
  _RatingWholesalerViewState createState() => _RatingWholesalerViewState();
}

class _RatingWholesalerViewState extends State<RatingWholesalerViewPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Map<String, dynamic> wholesaler;
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
          : (error != null
              ? Center(child: Text(error.toString()))
              : SingleChildScrollView(child: buildProfile())),
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
            wholesaler['name'],
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 2),

          // City
          Text(
            wholesaler['city'] != null ? wholesaler['city'] : '-',
            style: TextStyle(fontSize: 16),
          ),

          SizedBox(height: 16),

          // Registration status
          buildStatusView(wholesaler['registered']),

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
          buildDetailItem('City', wholesaler['city']),
          buildDetailItem('Pincode', wholesaler['pincode']),
          SizedBox(height: 8),
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
                wholesaler['mobile'] ?? '-',
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
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(width: 16),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: IconButton(
                      padding: EdgeInsets.all(0),
                      icon: Icon(Icons.message),
                      onPressed: messageWholesaler,
                      color: Colors.grey.shade700,
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
                wholesaler['whatsapp_mobile'] ?? '-',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                  padding: EdgeInsets.all(0),
                  icon: ImageIcon(AssetImage('images/whatsapp.png')),
                  onPressed: whatsappWholesaler,
                  color: Colors.grey.shade700,
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

  Widget buildRatingsCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        // Counters
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              buildCount('Ratings', wholesaler['rating']['count'].toString()),
              buildCount(
                  'Joined', DateService.MMMyyyy(wholesaler['created_at'])),
              buildCount('Followers', wholesaler['follows_count'].toString()),
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
                  builder: (_) => RatingsPage(
                    mobile: wholesaler['mobile'],
                    onRatingDelete: widget.onRatingDelete,
                  ),
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
            5, wholesaler['rating']['5star'], wholesaler['rating']['count']),
        SizedBox(height: 4),
        buildRatingIndicator(
            4, wholesaler['rating']['4star'], wholesaler['rating']['count']),
        SizedBox(height: 4),
        buildRatingIndicator(
            3, wholesaler['rating']['3star'], wholesaler['rating']['count']),
        SizedBox(height: 4),
        buildRatingIndicator(
            2, wholesaler['rating']['2star'], wholesaler['rating']['count']),
        SizedBox(height: 4),
        buildRatingIndicator(
            1, wholesaler['rating']['1star'], wholesaler['rating']['count']),
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
          wholesaler['rating']['average'].toString(),
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w500,
          ),
        ),

        SizedBox(height: 4),

        // indicator
        RatingBarIndicator(
          itemCount: 5,
          rating: double.tryParse(wholesaler['rating']['average']),
          itemSize: 18,
          unratedColor: Colors.grey[350],
          itemBuilder: (BuildContext context, int index) {
            return Icon(Icons.star, color: Colors.yellow.shade600);
          },
        ),

        SizedBox(height: 2),

        // ratings count
        Text(
          '${wholesaler['rating']['count']} ${wholesaler['rating']['count'] > 1 ? 'ratings' : 'rating'}',
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
              image: wholesaler['thumb_url'] != null
                  ? CachedNetworkImageProvider(wholesaler['thumb_url'])
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

    WholesalerRatingService.getWholesalerById(widget.ratingId).then((res) {
      setState(() {
        wholesaler = res;
        //print('WHOLESALER ID ??????????????????????+$wholesaler');
        error = null;
      });
    }).catchError((err) {
      setState(() => error = err);
    }).whenComplete(() {
      setState(() => isLoading = false);
    });
  }

  call() {
    launch("tel://${wholesaler['mobile']}");
  }

  void messageWholesaler() {
    launch("sms:${wholesaler['mobile']}");
  }

  void whatsappWholesaler() {
    launch(
        "https://api.whatsapp.com/send?phone=${wholesaler['whatsapp_mobile']}");
  }
}

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/user_event.dart';
import '../../services/user_event_service.dart';

class UserCheckinScreen
    extends StatefulWidget {
  final UserEvent event;

  const UserCheckinScreen({
    super.key,
    required this.event,
  });

  @override
  State<UserCheckinScreen>
      createState() =>
          _UserCheckinScreenState();
}

class _UserCheckinScreenState
    extends State<UserCheckinScreen> {
  // =========================================================
  // Colors
  // =========================================================

  static const Color backgroundColor =
      Color(0xFF080D13);

  static const Color cardColor =
      Color(0xFF101720);

  static const Color borderColor =
      Color(0xFF26313D);

  static const Color primaryColor =
      Color(0xFFB7F52B);

  static const Color textPrimary =
      Color(0xFFF3F5F7);

  static const Color textSecondary =
      Color(0xFF8B98A5);

  static const Color dangerColor =
      Color(0xFFFF6262);

  static const Color warningColor =
      Color(0xFFFFB74D);

  // =========================================================
  // State
  // =========================================================

  Position? _position;

  double? _previewDistance;

  bool _isLoadingLocation =
      false;

  bool _isCheckingIn =
      false;

  String? _locationError;

  // =========================================================
  // Event
  // =========================================================

  UserEvent get event =>
      widget.event;

  // =========================================================
  // Init
  // =========================================================

  @override
  void initState() {
    super.initState();

    _getLocation();
  }

  // =========================================================
  // GPS Permission + Current Position
  // =========================================================

  Future<void> _getLocation() async {
    if (_isLoadingLocation) {
      return;
    }

    setState(() {
      _isLoadingLocation =
          true;

      _locationError =
          null;
    });

    try {
      // -------------------------------------------------------
      // เปิด Location Service หรือยัง
      // -------------------------------------------------------

      final serviceEnabled =
          await Geolocator
              .isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isLoadingLocation =
              false;

          _locationError =
              'กรุณาเปิดบริการตำแหน่ง (Location/GPS) ก่อน';
        });

        return;
      }

      // -------------------------------------------------------
      // Permission
      // -------------------------------------------------------

      var permission =
          await Geolocator
              .checkPermission();

      if (permission ==
          LocationPermission.denied) {
        permission =
            await Geolocator
                .requestPermission();
      }

      if (permission ==
          LocationPermission.denied) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isLoadingLocation =
              false;

          _locationError =
              'ไม่ได้รับอนุญาตให้เข้าถึงตำแหน่ง';
        });

        return;
      }

      if (permission ==
          LocationPermission
              .deniedForever) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isLoadingLocation =
              false;

          _locationError =
              'สิทธิ์ตำแหน่งถูกปิดถาวร กรุณาเปิดจากการตั้งค่าแอป';
        });

        return;
      }

      // -------------------------------------------------------
      // Current GPS
      // -------------------------------------------------------

      final position =
          await Geolocator
              .getCurrentPosition(
        locationSettings:
            const LocationSettings(
          accuracy:
              LocationAccuracy.high,
        ),
      );

      // -------------------------------------------------------
      // Preview Distance
      // Client คำนวณเพื่อแสดงผลเท่านั้น
      // Backend จะคำนวณใหม่อีกครั้งตอน Check-in
      // -------------------------------------------------------

      final distance =
          Geolocator
              .distanceBetween(
        position.latitude,
        position.longitude,
        event.latitude,
        event.longitude,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _position =
            position;

        _previewDistance =
            distance;

        _isLoadingLocation =
            false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingLocation =
            false;

        _locationError =
            'ไม่สามารถอ่านตำแหน่งปัจจุบันได้';
      });
    }
  }

  // =========================================================
  // Check-in
  // =========================================================

  Future<void> _checkIn() async {
    if (_isCheckingIn) {
      return;
    }

    if (_position == null) {
      _showMessage(
        'กรุณารอตรวจสอบตำแหน่ง GPS ก่อน',
        error: true,
      );

      return;
    }

    setState(() {
      _isCheckingIn =
          true;
    });

    // อ่านตำแหน่งใหม่อีกครั้ง
    // ไม่ใช้ค่าที่ค้างอยู่ตั้งแต่เปิดหน้า
    try {
      final freshPosition =
          await Geolocator
              .getCurrentPosition(
        locationSettings:
            const LocationSettings(
          accuracy:
              LocationAccuracy.high,
        ),
      );

      final result =
          await UserEventService
              .checkIn(
        eventId:
            event.id,

        latitude:
            freshPosition.latitude,

        longitude:
            freshPosition.longitude,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isCheckingIn =
            false;

        _position =
            freshPosition;

        _previewDistance =
            Geolocator
                .distanceBetween(
          freshPosition.latitude,
          freshPosition.longitude,
          event.latitude,
          event.longitude,
        );
      });

      // -------------------------------------------------------
      // Success
      // -------------------------------------------------------

      if (result['success'] ==
          true) {
        final distance =
            double.tryParse(
          result[
                  'distance_meters']
              .toString(),
        );

        await _showSuccessDialog(
          distance,
        );

        if (!mounted) {
          return;
        }

        Navigator.pop(
          context,
          true,
        );

        return;
      }

      // -------------------------------------------------------
      // Failed
      // -------------------------------------------------------

      final distance =
          double.tryParse(
        result[
                'distance_meters']
            ?.toString() ??
            '',
      );

      final radius =
          double.tryParse(
        result[
                'allowed_radius']
            ?.toString() ??
            '',
      );

      if (distance != null &&
          radius != null) {
        _showMessage(
          '${result['message']}\n'
          'คุณอยู่ห่าง ${distance.toStringAsFixed(1)} เมตร '
          'จากกิจกรรม\n'
        );

        return;
      }

      _showMessage(
        result['message'] ??
            'ไม่สามารถเช็กอินได้',
        error: true,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isCheckingIn =
            false;
      });

      _showMessage(
        'ไม่สามารถอ่านตำแหน่ง GPS ได้',
        error: true,
      );
    }
  }

  // =========================================================
  // Success
  // =========================================================

  Future<void> _showSuccessDialog(
    double? distance,
  ) async {
    await showDialog<void>(
      context:
          context,

      barrierDismissible:
          false,

      builder: (context) {
        return AlertDialog(
          backgroundColor:
              cardColor,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius
                    .circular(
              22,
            ),
          ),

          content:
              Column(
            mainAxisSize:
                MainAxisSize.min,

            children: [
              Container(
                width: 70,
                height: 70,

                decoration:
                    BoxDecoration(
                  color:
                      primaryColor
                          .withOpacity(
                    0.10,
                  ),

                  shape:
                      BoxShape.circle,
                ),

                child:
                    const Icon(
                  Icons
                      .check_circle_rounded,

                  color:
                      primaryColor,

                  size:
                      40,
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              const Text(
                'เช็กอินสำเร็จ',

                style:
                    TextStyle(
                  color:
                      textPrimary,

                  fontSize:
                      20,

                  fontWeight:
                      FontWeight
                          .w800,
                ),
              ),

              const SizedBox(
                height: 7,
              ),

              Text(
                distance == null
                    ? 'บันทึกการเช็กอินเรียบร้อยแล้ว'
                    : 'คุณอยู่ห่างจากจุดกิจกรรม '
                        '${distance.toStringAsFixed(1)} เมตร',

                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  color:
                      textSecondary,

                  fontSize:
                      11,

                  height:
                      1.5,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              SizedBox(
                width:
                    double.infinity,

                child:
                    ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },

                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        primaryColor,

                    foregroundColor:
                        backgroundColor,

                    elevation:
                        0,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),
                  ),

                  child:
                      const Text(
                    'ตกลง',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // Build
  // =========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final withinRadius =
        _previewDistance !=
            null &&
        _previewDistance! <=
            event.checkinRadius;

    return Scaffold(
      backgroundColor:
          backgroundColor,

      appBar: AppBar(
        backgroundColor:
            backgroundColor,

        elevation: 0,

        leading:
            IconButton(
          onPressed: () {
            Navigator.pop(
              context,
              false,
            );
          },

          icon:
              const Icon(
            Icons
                .arrow_back_ios_new_rounded,

            color:
                textPrimary,

            size:
                20,
          ),
        ),

        title:
            const Text(
          'เช็กอินกิจกรรม',

          style:
              TextStyle(
            color:
                textPrimary,

            fontSize:
                18,

            fontWeight:
                FontWeight.w700,
          ),
        ),
      ),

      body:
          SafeArea(
        top: false,

        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets
                  .fromLTRB(
            20,
            15,
            20,
            120,
          ),

          child:
              Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // =============================================
              // Event
              // =============================================

              Container(
                width:
                    double.infinity,

                padding:
                    const EdgeInsets
                        .all(
                  18,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      cardColor,

                  borderRadius:
                      BorderRadius
                          .circular(
                    21,
                  ),

                  border:
                      Border.all(
                    color:
                        borderColor,
                  ),
                ),

                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'กำลังเช็กอิน',

                      style:
                          TextStyle(
                        color:
                            primaryColor,

                        fontSize:
                            9,

                        letterSpacing:
                            1.5,

                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      event.title,

                      style:
                          const TextStyle(
                        color:
                            textPrimary,

                        fontSize:
                            19,

                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),

                    const SizedBox(
                      height: 11,
                    ),

                    Row(
                      children: [
                        const Icon(
                          Icons
                              .location_on_outlined,

                          color:
                              primaryColor,

                          size:
                              16,
                        ),

                        const SizedBox(
                          width: 7,
                        ),

                        Expanded(
                          child:
                              Text(
                            event
                                .locationName,

                            style:
                                const TextStyle(
                              color:
                                  textSecondary,

                              fontSize:
                                  10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              // =============================================
              // GPS Status
              // =============================================

              const Text(
                'ตำแหน่งของคุณ',

                style:
                    TextStyle(
                  color:
                      textPrimary,

                  fontSize:
                      17,

                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              Container(
                width:
                    double.infinity,

                padding:
                    const EdgeInsets
                        .all(
                  18,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      cardColor,

                  borderRadius:
                      BorderRadius
                          .circular(
                    20,
                  ),

                  border:
                      Border.all(
                    color:
                        _locationError !=
                                null
                            ? dangerColor
                                .withOpacity(
                                  0.35,
                                )
                            : withinRadius
                                ? primaryColor
                                    .withOpacity(
                                      0.30,
                                    )
                                : borderColor,
                  ),
                ),

                child:
                    _buildLocationContent(
                  withinRadius,
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              // =============================================
              // Radius
              // =============================================

              Container(
                padding:
                    const EdgeInsets
                        .all(
                  15,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      primaryColor
                          .withOpacity(
                    0.05,
                  ),

                  borderRadius:
                      BorderRadius
                          .circular(
                    16,
                  ),

                  border:
                      Border.all(
                    color:
                        primaryColor
                            .withOpacity(
                      0.15,
                    ),
                  ),
                ),

                child:
                    Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const Icon(
                      Icons
                          .radar_rounded,

                      color:
                          primaryColor,

                      size:
                          20,
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child:
                          Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [
                          const Text(
                            'พื้นที่ที่อนุญาต',

                            style:
                                TextStyle(
                              color:
                                  textPrimary,

                              fontSize:
                                  11,

                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),

                          const SizedBox(
                            height: 3,
                          ),

                          Text(
                            'ต้องอยู่ภายในรัศมี ${event.checkinRadius} เมตร '
                            'จากจุดกิจกรรมจึงจะเช็กอินได้',

                            style:
                                const TextStyle(
                              color:
                                  textSecondary,

                              fontSize:
                                  10,

                              height:
                                  1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar:
          SafeArea(
        top: false,

        child:
            Container(
          padding:
              const EdgeInsets
                  .fromLTRB(
            20,
            12,
            20,
            15,
          ),

          decoration:
              const BoxDecoration(
            color:
                backgroundColor,

            border:
                Border(
              top:
                  BorderSide(
                color:
                    borderColor,
              ),
            ),
          ),

          child:
              SizedBox(
            height:
                55,

            child:
                ElevatedButton(
              onPressed:
                  _position ==
                              null ||
                          _isCheckingIn
                      ? null
                      : _checkIn,

              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    primaryColor,

                foregroundColor:
                    backgroundColor,

                disabledBackgroundColor:
                    const Color(
                  0xFF1B2630,
                ),

                disabledForegroundColor:
                    textSecondary,

                elevation:
                    0,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    17,
                  ),
                ),
              ),

              child:
                  _isCheckingIn
                      ? const SizedBox(
                          width:
                              23,

                          height:
                              23,

                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2.5,

                            color:
                                backgroundColor,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,

                          children: [
                            Icon(
                              Icons
                                  .my_location_rounded,

                              size:
                                  20,
                            ),

                            SizedBox(
                              width:
                                  8,
                            ),

                            Text(
                              'เช็กอินด้วย GPS',

                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),
                          ],
                        ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // Location Content
  // =========================================================

  Widget _buildLocationContent(
    bool withinRadius,
  ) {
    if (_isLoadingLocation) {
      return const Column(
        children: [
          CircularProgressIndicator(
            color:
                primaryColor,

            strokeWidth:
                2.5,
          ),

          SizedBox(
            height: 13,
          ),

          Text(
            'กำลังตรวจสอบตำแหน่ง GPS...',

            style:
                TextStyle(
              color:
                  textSecondary,

              fontSize:
                  11,
            ),
          ),
        ],
      );
    }

    if (_locationError !=
        null) {
      return Column(
        children: [
          const Icon(
            Icons
                .location_off_rounded,

            color:
                dangerColor,

            size:
                35,
          ),

          const SizedBox(
            height: 11,
          ),

          Text(
            _locationError!,

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              color:
                  textPrimary,

              fontSize:
                  11,

              height:
                  1.4,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          TextButton.icon(
            onPressed:
                _getLocation,

            icon:
                const Icon(
              Icons
                  .refresh_rounded,

              color:
                  primaryColor,

              size:
                  17,
            ),

            label:
                const Text(
              'ลองใหม่',

              style:
                  TextStyle(
                color:
                    primaryColor,
              ),
            ),
          ),
        ],
      );
    }

    if (_position ==
        null) {
      return const Text(
        'ยังไม่พบตำแหน่ง',

        style:
            TextStyle(
          color:
              textSecondary,
        ),
      );
    }

    return Column(
      children: [
        Icon(
          withinRadius
              ? Icons
                  .location_on_rounded
              : Icons
                  .wrong_location_rounded,

          color:
              withinRadius
                  ? primaryColor
                  : warningColor,

          size:
              38,
        ),

        const SizedBox(
          height: 10,
        ),

        Text(
          withinRadius
              ? 'คุณอยู่ในพื้นที่เช็กอิน'
              : 'คุณอยู่นอกพื้นที่เช็กอิน',

          style:
              TextStyle(
            color:
                withinRadius
                    ? primaryColor
                    : warningColor,

            fontSize:
                14,

            fontWeight:
                FontWeight.w700,
          ),
        ),

        if (_previewDistance !=
            null) ...[
          const SizedBox(
            height: 5,
          ),

          Text(
            'ห่างจากจุดกิจกรรมประมาณ '
            '${_previewDistance!.toStringAsFixed(1)} เมตร',

            style:
                const TextStyle(
              color:
                  textSecondary,

              fontSize:
                  10,
            ),
          ),
        ],

        const SizedBox(
          height: 10,
        ),

        Text(
          '${_position!.latitude.toStringAsFixed(6)}, '
          '${_position!.longitude.toStringAsFixed(6)}',

          style:
              const TextStyle(
            color:
                Color(
              0xFF65727E,
            ),

            fontSize:
                9,
          ),
        ),

        const SizedBox(
          height: 8,
        ),

        TextButton.icon(
          onPressed:
              _getLocation,

          icon:
              const Icon(
            Icons
                .refresh_rounded,

            color:
                primaryColor,

            size:
                15,
          ),

          label:
              const Text(
            'อัปเดตตำแหน่ง',

            style:
                TextStyle(
              color:
                  primaryColor,

              fontSize:
                  10,
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // Message
  // =========================================================

  void _showMessage(
    String message, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(message),

        backgroundColor:
            error
                ? const Color(
                    0xFFD94A4A,
                  )
                : const Color(
                    0xFF253512,
                  ),
      ),
    );
  }
}
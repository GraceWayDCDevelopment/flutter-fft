import 'dart:async';
import 'package:flutter/services.dart';

class FlutterFft {
  static const MethodChannel _channel =
      const MethodChannel("com.slins.flutterfft/record");

  static StreamController<List<Object>>? _recorderController;

  Stream<List<Object>> get onRecorderStateChanged =>
      _recorderController!.stream;

  bool _isRecording = false;

  double _subscriptionDuration = 0.25;

  int _numChannels = 1;
  int _sampleRate = 44100;
  AndroidAudioSource _androidAudioSource = AndroidAudioSource.MIC;
  double _tolerance = 1.0;

  double _frequency = 0;

  String _note = "";
  double _target = 0;
  double _distance = 0;
  int _octave = 0;

  String _nearestNote = "";
  double _nearestTarget = 0;
  double _nearestDistance = 0;
  int _nearestOctave = 0;

  bool _isOnPitch = false;

  List<String> _tuning = ["E4", "B3", "G3", "D3", "A2", "E2"];

  bool get getIsRecording => _isRecording;
  double get getSubscriptionDuration => _subscriptionDuration;
  int get getNumChannels => _numChannels;
  int get getSampleRate => _sampleRate;
  AndroidAudioSource get getAndroidAudioSource => _androidAudioSource;
  double get getTolerance => _tolerance;

  double get getFrequency => _frequency;

  String get getNote => _note;
  double get getTarget => _target;
  double get getDistance => _distance;
  int get getOctave => _octave;

  String get getNearestNote => _nearestNote;
  double get getNearestTarget => _nearestTarget;
  double get getNearestDistance => _nearestDistance;
  int get getNearestOctave => _nearestOctave;

  bool get getIsOnPitch => _isOnPitch;

  List<String> get getTuning => _tuning;

  set setIsRecording(bool isRecording) => _isRecording = isRecording;
  set setSubscriptionDuration(double subscriptionDuration) =>
      _subscriptionDuration = subscriptionDuration;
  set setTolerance(double tolerance) => _tolerance = tolerance;
  set setFrequency(double frequency) => _frequency = frequency;

  set setNumChannels(int numChannels) => _numChannels = numChannels;
  set setSampleRate(int sampleRate) => _sampleRate = sampleRate;
  set setAndroidAudioSource(AndroidAudioSource androidAudioSource) =>
      _androidAudioSource = androidAudioSource;

  set setNote(String note) => _note = note;
  set setTarget(double target) => _target = target;
  set setDistance(double distance) => _distance = distance;
  set setOctave(int octave) => _octave = octave;

  set setNearestNote(String nearestNote) => _nearestNote = nearestNote;
  set setNearestTarget(double nearestTarget) => _nearestTarget = nearestTarget;
  set setNearestDistance(double nearestDistance) =>
      _nearestDistance = nearestDistance;
  set setNearestOctave(int nearestOctave) => _nearestOctave = nearestOctave;

  set setIsOnPitch(bool isOnPitch) => _isOnPitch = isOnPitch;

  set setTuning(List<String> tuning) => _tuning = tuning;

  _setRecorderCallback() async {
    if (_recorderController == null) {
      _recorderController = new StreamController.broadcast();
    }

    _channel.setMethodCallHandler((MethodCall call) {
      switch (call.method) {
        case "updateRecorderProgress":
          if (_recorderController != null) {
            _recorderController!.add(call.arguments);
          } else {
            print("Is not null");
          }
          break;
        default:
          throw new ArgumentError("Unknown method: ${call.method}");
      }
      return Future.delayed(Duration(microseconds: 1));
    });
  }

  Future<void> _removeRecorderCallback() async {
    /*if (_recorderController != null) {}
    _recorderController
      //..add(null)
      ..close();*/
    if (_recorderController != null) _recorderController!.close();
    _recorderController = null;
  }

  Future<String> startRecorder() async {
    print("~~~~~~~~Got to started");
    try {
      await _channel.invokeMethod("setSubscriptionDuration",
          <String, double>{'sec': this.getSubscriptionDuration});
    } catch (err) {
      print("Could not set subscription duration, error: $err");
    }
    print("~~~~~~~~FINISHED Channel Invoke");

    if (this.getIsRecording) {
      throw new RecorderRunningException("Recorder is already running.");
    }

    try {
      print("~~~~~~~~${this.getTuning}");
      print("~~~~~~~~${this.getNumChannels}");
      print("~~~~~~~~${this.getSampleRate}");
      print("~~~~~~~~${this.getAndroidAudioSource.value}");
      print("~~~~~~~~${this.getTolerance}");
      String result = await _channel.invokeMethod(
        'startRecorder',
        <String, dynamic>{
          'tuning': this.getTuning,
          'numChannels': this.getNumChannels,
          'sampleRate': this.getSampleRate,
          'androidAudioSource': this.getAndroidAudioSource.value,
          'tolerance': this.getTolerance,
        },
      );
      print("~~~~~~~~Finished invoke 2");
      _setRecorderCallback();
      print("~~~~~~~~Finished Set Recorder Callback");
      this.setIsRecording = true;

      print("~~~~~~~~Ready to return result");
      return result;
    } catch (err) {
      throw new Exception(err);
    }
  }

  Future<String> stopRecorder() async {
    if (!this.getIsRecording) {
      throw new RecorderStoppedException("Recorder is not running.");
    }

    String result = await _channel.invokeMethod("stopRecorder");
    this.setIsRecording = false;
    _removeRecorderCallback();

    return result;
  }
}

class RecorderRunningException implements Exception {
  final String message;
  RecorderRunningException(this.message);
}

class RecorderStoppedException implements Exception {
  final String message;
  RecorderStoppedException(this.message);
}

class AndroidAudioSource {
  final _value;
  const AndroidAudioSource._internal(this._value);
  toString() => 'AndroidAudioSource.$_value';
  int get value => _value;

  static const DEFAULT = const AndroidAudioSource._internal(0);
  static const MIC = const AndroidAudioSource._internal(1);
  static const VOICE_UPLINK = const AndroidAudioSource._internal(2);
  static const VOICE_DOWNLINK = const AndroidAudioSource._internal(3);
  static const CAMCORDER = const AndroidAudioSource._internal(4);
  static const VOICE_RECOGNITION = const AndroidAudioSource._internal(5);
  static const VOICE_COMMUNICATION = const AndroidAudioSource._internal(6);
  static const REMOTE_SUBMIX = const AndroidAudioSource._internal(7);
  static const UNPROCESSED = const AndroidAudioSource._internal(8);
  static const RADIO_TUNER = const AndroidAudioSource._internal(9);
  static const HOTWORD = const AndroidAudioSource._internal(10);
}

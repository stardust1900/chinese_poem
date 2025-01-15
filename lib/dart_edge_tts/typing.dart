// Custom types for edge-tts in Dart

import 'dart:typed_data';

// Define enums for literal values
enum TTSChunkType { audio, wordBoundary }

enum ContentCategory {
  cartoon,
  conversation,
  copilot,
  dialect,
  general,
  news,
  novel,
  sports,
}

enum VoicePersonality {
  approachable,
  authentic,
  authority,
  bright,
  caring,
  casual,
  cheerful,
  clear,
  comfort,
  confident,
  considerate,
  conversational,
  cute,
  expressive,
  friendly,
  honest,
  humorous,
  lively,
  passion,
  pleasant,
  positive,
  professional,
  rational,
  reliable,
  sincere,
  sunshine,
  warm,
}

enum Gender { female, male }

enum SuggestedCodec { audio24khz48kbitrateMonoMp3 }

enum VoiceStatus { ga }

// Define custom types using classes and enums

class TTSChunk {
  final TTSChunkType type;
  final Uint8List? data; // only for audio
  final int duration; // only for WordBoundary
  final int offset; // only for WordBoundary
  final String text; // only for WordBoundary

  TTSChunk({
    required this.type,
    this.data,
    required this.duration,
    required this.offset,
    required this.text,
  });

  factory TTSChunk.fromMap(Map<String, dynamic> map) {
    return TTSChunk(
      type: map['type'] == 'audio'
          ? TTSChunkType.audio
          : TTSChunkType.wordBoundary,
      data: map['data'] != null ? Uint8List.fromList(map['data']) : null,
      duration: map['duration'],
      offset: map['offset'],
      text: map['text'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type == TTSChunkType.audio ? 'audio' : 'WordBoundary',
      'data': data?.toList(),
      'duration': duration,
      'offset': offset,
      'text': text,
    };
  }
}

class VoiceTag {
  final List<ContentCategory> contentCategories;
  final List<VoicePersonality> voicePersonalities;

  VoiceTag({
    required this.contentCategories,
    required this.voicePersonalities,
  });

  factory VoiceTag.fromMap(Map<String, dynamic> map) {
    return VoiceTag(
      contentCategories: (map['ContentCategories'] as List<dynamic>)
          .map((e) => ContentCategory.values.byName(e))
          .toList(),
      voicePersonalities: (map['VoicePersonalities'] as List<dynamic>)
          .map((e) => VoicePersonality.values.byName(e))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ContentCategories': contentCategories.map((e) => e.name).toList(),
      'VoicePersonalities': voicePersonalities.map((e) => e.name).toList(),
    };
  }
}

class Voice {
  final String name;
  final String shortName;
  final Gender gender;
  final String locale;
  final SuggestedCodec suggestedCodec;
  final String friendlyName;
  final VoiceStatus status;
  final VoiceTag voiceTag;

  Voice({
    required this.name,
    required this.shortName,
    required this.gender,
    required this.locale,
    required this.suggestedCodec,
    required this.friendlyName,
    required this.status,
    required this.voiceTag,
  });

  factory Voice.fromMap(Map<String, dynamic> map) {
    return Voice(
      name: map['Name'],
      shortName: map['ShortName'],
      gender: Gender.values.byName(map['Gender']),
      locale: map['Locale'],
      suggestedCodec: SuggestedCodec.values.byName(map['SuggestedCodec']),
      friendlyName: map['FriendlyName'],
      status: VoiceStatus.values.byName(map['Status']),
      voiceTag: VoiceTag.fromMap(map['VoiceTag']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Name': name,
      'ShortName': shortName,
      'Gender': gender.name,
      'Locale': locale,
      'SuggestedCodec': suggestedCodec.name,
      'FriendlyName': friendlyName,
      'Status': status.name,
      'VoiceTag': voiceTag.toMap(),
    };
  }
}

class VoicesManagerVoice extends Voice {
  final String language;

  VoicesManagerVoice({
    required super.name,
    required super.shortName,
    required super.gender,
    required super.locale,
    required super.suggestedCodec,
    required super.friendlyName,
    required super.status,
    required super.voiceTag,
    required this.language,
  });

  factory VoicesManagerVoice.fromMap(Map<String, dynamic> map) {
    return VoicesManagerVoice(
      name: map['Name'],
      shortName: map['ShortName'],
      gender: Gender.values.byName(map['Gender']),
      locale: map['Locale'],
      suggestedCodec: SuggestedCodec.values.byName(map['SuggestedCodec']),
      friendlyName: map['FriendlyName'],
      status: VoiceStatus.values.byName(map['Status']),
      voiceTag: VoiceTag.fromMap(map['VoiceTag']),
      language: map['Language'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map['Language'] = language;
    return map;
  }
}

class VoicesManagerFind {
  final Gender? gender;
  final String? locale;
  final String? language;

  VoicesManagerFind({this.gender, this.locale, this.language});

  Map<String, dynamic> toMap() {
    return {
      if (gender != null) 'Gender': gender!.name,
      if (locale != null) 'Locale': locale,
      if (language != null) 'Language': language,
    };
  }

  factory VoicesManagerFind.fromMap(Map<String, dynamic> map) {
    return VoicesManagerFind(
      gender:
          map['Gender'] != null ? Gender.values.byName(map['Gender']) : null,
      locale: map['Locale'],
      language: map['Language'],
    );
  }
}

class CommunicateState {
  Uint8List partialText;
  int offsetCompensation;
  int lastDurationOffset;
  bool streamWasCalled;

  CommunicateState({
    required this.partialText,
    required this.offsetCompensation,
    required this.lastDurationOffset,
    required this.streamWasCalled,
  });

  factory CommunicateState.fromMap(Map<String, dynamic> map) {
    return CommunicateState(
      partialText: Uint8List.fromList(map['partial_text']),
      offsetCompensation: map['offset_compensation'],
      lastDurationOffset: map['last_duration_offset'],
      streamWasCalled: map['stream_was_called'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'partial_text': partialText.toList(),
      'offset_compensation': offsetCompensation,
      'last_duration_offset': lastDurationOffset,
      'stream_was_called': streamWasCalled,
    };
  }
}

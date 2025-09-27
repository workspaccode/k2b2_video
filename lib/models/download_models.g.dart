// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DownloadTaskAdapter extends TypeAdapter<DownloadTask> {
  @override
  final int typeId = 0;

  @override
  DownloadTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DownloadTask(
      id: fields[0] as String,
      videoId: fields[1] as String,
      title: fields[2] as String,
      thumbnailUrl: fields[3] as String,
      videoUrl: fields[4] as String,
      quality: fields[5] as DownloadQuality,
      status: fields[6] as DownloadStatus,
      progress: fields[7] as double,
      downloadedBytes: fields[8] as int,
      totalBytes: fields[9] as int,
      localPath: fields[10] as String?,
      createdAt: fields[11] as DateTime,
      completedAt: fields[12] as DateTime?,
      errorMessage: fields[13] as String?,
      downloadSpeed: fields[14] as double,
      estimatedTimeRemaining: fields[15] as Duration,
    );
  }

  @override
  void write(BinaryWriter writer, DownloadTask obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.videoId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.thumbnailUrl)
      ..writeByte(4)
      ..write(obj.videoUrl)
      ..writeByte(5)
      ..write(obj.quality)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.progress)
      ..writeByte(8)
      ..write(obj.downloadedBytes)
      ..writeByte(9)
      ..write(obj.totalBytes)
      ..writeByte(10)
      ..write(obj.localPath)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.completedAt)
      ..writeByte(13)
      ..write(obj.errorMessage)
      ..writeByte(14)
      ..write(obj.downloadSpeed)
      ..writeByte(15)
      ..write(obj.estimatedTimeRemaining);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DownloadSettingsAdapter extends TypeAdapter<DownloadSettings> {
  @override
  final int typeId = 1;

  @override
  DownloadSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DownloadSettings(
      defaultQuality: fields[0] as DownloadQuality,
      downloadOnlyOnWifi: fields[1] as bool,
      allowDownloadOnMobileData: fields[2] as bool,
      maxConcurrentDownloads: fields[3] as int,
      autoDownloadWatchLater: fields[4] as bool,
      downloadLocation: fields[5] as String,
      deleteAfterDays: fields[6] as bool,
      deleteAfterDaysCount: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DownloadSettings obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.defaultQuality)
      ..writeByte(1)
      ..write(obj.downloadOnlyOnWifi)
      ..writeByte(2)
      ..write(obj.allowDownloadOnMobileData)
      ..writeByte(3)
      ..write(obj.maxConcurrentDownloads)
      ..writeByte(4)
      ..write(obj.autoDownloadWatchLater)
      ..writeByte(5)
      ..write(obj.downloadLocation)
      ..writeByte(6)
      ..write(obj.deleteAfterDays)
      ..writeByte(7)
      ..write(obj.deleteAfterDaysCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DownloadStatusAdapter extends TypeAdapter<DownloadStatus> {
  @override
  final int typeId = 2;

  @override
  DownloadStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DownloadStatus.queued;
      case 1:
        return DownloadStatus.downloading;
      case 2:
        return DownloadStatus.paused;
      case 3:
        return DownloadStatus.completed;
      case 4:
        return DownloadStatus.failed;
      case 5:
        return DownloadStatus.cancelled;
      default:
        return DownloadStatus.queued;
    }
  }

  @override
  void write(BinaryWriter writer, DownloadStatus obj) {
    switch (obj) {
      case DownloadStatus.queued:
        writer.writeByte(0);
        break;
      case DownloadStatus.downloading:
        writer.writeByte(1);
        break;
      case DownloadStatus.paused:
        writer.writeByte(2);
        break;
      case DownloadStatus.completed:
        writer.writeByte(3);
        break;
      case DownloadStatus.failed:
        writer.writeByte(4);
        break;
      case DownloadStatus.cancelled:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DownloadQualityAdapter extends TypeAdapter<DownloadQuality> {
  @override
  final int typeId = 3;

  @override
  DownloadQuality read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DownloadQuality.low;
      case 1:
        return DownloadQuality.medium;
      case 2:
        return DownloadQuality.high;
      case 3:
        return DownloadQuality.ultra;
      default:
        return DownloadQuality.low;
    }
  }

  @override
  void write(BinaryWriter writer, DownloadQuality obj) {
    switch (obj) {
      case DownloadQuality.low:
        writer.writeByte(0);
        break;
      case DownloadQuality.medium:
        writer.writeByte(1);
        break;
      case DownloadQuality.high:
        writer.writeByte(2);
        break;
      case DownloadQuality.ultra:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadQualityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

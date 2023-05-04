from storages.backends.s3boto3 import S3Boto3Storage  # pylint: disable=import-error


class StaticRootS3Boto3Storage(S3Boto3Storage):  # pylint: disable=too-few-public-methods
    location = "static"
    default_acl = "public-read"


class MediaRootS3Boto3Storage(S3Boto3Storage):  # pylint: disable=too-few-public-methods
    location = "media"
    file_overwrite = False
